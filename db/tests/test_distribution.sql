-- =============================================================================
-- NOONA PLUS ERP | اختبار التوزيع والمبيعات الميدانية بحساب NOONA_APP - يتراجع في النهاية
--   المندوب وسيارته وعهدته، خط السير والمحلات والموقع، تحميل السيارة، الزيارة والبيع والتحصيل بطرق الدفع ورقم الإشعار،
--   التأكيد والرفض، المرتجع، أمر التوريد، إنهاء الزيارة وسبب عدم الشراء، تسوية اليوم والتوريد والعجز، العمولات، واتساب
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_distribution.sql
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
  l_rep NUMBER; l_rt NUMBER; l_sh1 NUMBER; l_sh2 NUMBER; l_it NUMBER; l_wh NUMBER; l_van NUMBER; l_box NUMBER;
  l_v NUMBER; l_inv NUMBER; l_c NUMBER; l_c2 NUMBER; l_x NUMBER; l_n NUMBER; l_ord NUMBER; l_st NUMBER; l_ln NUMBER;
  l_s VARCHAR2(4000); l_h CLOB; l_acc NUMBER; l_tot NUMBER;
  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE rejects(p_name VARCHAR2, p_code VARCHAR2, p_sql VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
    ok(p_name, FALSE, 'accepted');
  EXCEPTION WHEN OTHERS THEN
    ok(p_name, INSTR(SQLERRM, p_code) > 0, SUBSTR(SQLERRM, 1, 200));
  END rejects;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_n := NOONA_DST_PKG.quick_setup;
  ok('ready', NOONA_DST_PKG.is_ready = 'Y');
  ok('distance Riyadh: two points ~1.1 km', NOONA_DST_PKG.distance_m(24.7136, 46.6753, 24.7236, 46.6753) BETWEEN 1100 AND 1125,
     NOONA_DST_PKG.distance_m(24.7136, 46.6753, 24.7236, 46.6753));
  -- مندوب مربوط بالمستخدم الحالي (تنشأ السيارة والعهدة تلقائياً)
  UPDATE dst_rep SET user_name = NULL WHERE user_name = 'ADMIN' AND company_id = NOONA_DST_PKG.company;
  l_rep := NOONA_DST_PKG.save_rep('{"code":"R' || l_sfx || '","name":"مندوب اختبار ' || l_sfx || '","user":"ADMIN","phone":"0551112233",'
        || '"basis":"SALES","rate":2,"target":10000}');
  SELECT van_warehouse_id, cash_box_id INTO l_van, l_box FROM dst_rep WHERE id = l_rep;
  ok('rep van warehouse and cash custody created', l_van IS NOT NULL AND l_box IS NOT NULL);
  ok('current user is the rep', NOONA_DST_PKG.my_rep = l_rep);
  l_rt := NOONA_DST_PKG.save_route('{"code":"RT' || l_sfx || '","name":"خط العليا ' || l_sfx || '","rep":' || l_rep
        || ',"region":"الرياض","days":"SUN,MON,TUE,WED,THU,FRI,SAT"}');
  rejects('invalid visit days', 'NOONA-DST-021',
    'DECLARE x NUMBER; BEGIN x := NOONA_DST_PKG.save_route(''{"code":"X' || l_sfx || '","name":"x","days":"FUNDAY"}''); END;');
  l_sh1 := NOONA_DST_PKG.save_shop('{"name":"بقالة النور ' || l_sfx || '","owner":"أبو خالد","phone":"0501234567","type":"GROCERY",'
        || '"route":' || l_rt || ',"landmark":"بجوار مسجد الحي"}');
  l_sh2 := NOONA_DST_PKG.save_shop('{"name":"سوبرماركت الفجر ' || l_sfx || '","phone":"0507654321","type":"SUPERMARKET","route":' || l_rt
        || ',"lat":24.7200,"lng":46.6800}');
  SELECT customer_account_id INTO l_acc FROM dst_shop WHERE id = l_sh1;
  ok('shop created with a sales customer account', l_acc IS NOT NULL AND NOONA_DST_PKG.shop_label(l_sh1) LIKE '%بقالة النور%');
  SELECT route_seq INTO l_n FROM dst_shop WHERE id = l_sh2;
  ok('shops ordered on the route', l_n = 2, l_n);
  l_h := NOONA_DST_PKG.plan_html(l_rep, TRUNC(SYSDATE), 'f?p=1:2:::::P2_SHOP:#SHOP#');
  ok('today plan lists route shops with navigation', DBMS_LOB.INSTR(l_h, 'بقالة النور ' || l_sfx) > 0 AND DBMS_LOB.INSTR(l_h, 'google.com/maps') > 0);

  -- مخزون: صنف برصيد في المستودع الرئيسي ثم تحميل السيارة
  l_wh := NOONA_INV_PKG.default_warehouse;
  l_it := NOONA_INV_PKG.save_item('{"name":"عصير برتقال 200 مل ' || l_sfx || '","code":"JU' || l_sfx || '","price":11.5,"incl":"Y"}');
  l_n := NOONA_INV_PKG.save_stock_doc('{"id":null,"type":"ADJ_IN","date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '","wh":' || l_wh
        || ',"reason":"COUNT","action":"POST","lines":[{"i":' || l_it || ',"q":100,"c":6}]}');
  l_x := NOONA_DST_PKG.load_van('{"rep":' || l_rep || ',"direction":"LOAD","wh":' || l_wh || ',"lines":[{"i":' || l_it || ',"q":50}]}');
  ok('van loaded 50 from main warehouse', NOONA_INV_PKG.on_hand(l_it, l_van) = 50 AND NOONA_INV_PKG.on_hand(l_it, l_wh) = 50);
  ok('van stock page', DBMS_LOB.INSTR(NOONA_DST_PKG.van_stock_html(l_rep), 'عصير برتقال') > 0);

  -- زيارة أولى: يحفظ موقع المحل
  l_v := NOONA_DST_PKG.start_visit('{"shop":' || l_sh1 || ',"lat":24.7136,"lng":46.6753}');
  SELECT latitude INTO l_x FROM dst_shop WHERE id = l_sh1;
  ok('first visit saves the shop location for the next distribution', l_x = 24.7136);
  rejects('cannot open another shop while a visit is open', 'NOONA-DST-051',
    'DECLARE x NUMBER; BEGIN x := NOONA_DST_PKG.start_visit(''{"shop":' || l_sh2 || '}''); END;');
  ok('same shop resumes the open visit', NOONA_DST_PKG.start_visit('{"shop":' || l_sh1 || '}') = l_v);
  l_inv := NOONA_DST_PKG.visit_sale('{"visit":' || l_v || ',"lines":[{"i":' || l_it || ',"q":10}],"pay":{"method":"CASH","amount":50}}');
  SELECT total_amount INTO l_tot FROM sal_invoice WHERE id = l_inv;
  ok('van sale invoice 10 x 11.5 = 115', l_tot = 115, l_tot);
  ok('sold from the van stock', NOONA_INV_PKG.on_hand(l_it, l_van) = 40);
  SELECT COUNT(*) INTO l_n FROM dst_collection WHERE visit_id = l_v AND payment_method = 'CASH' AND status_code = 'POSTED' AND ar_receipt_id IS NOT NULL;
  ok('cash payment posted to the rep custody', l_n = 1);
  ok('rep custody cash balance 50', NOONA_CSH_PKG.balance(l_box, NULL) = 50, NOONA_CSH_PKG.balance(l_box, NULL));
  ok('shop balance after sale and cash = 65', NOONA_SAL_PKG.customer_balance(l_acc) = 65, NOONA_SAL_PKG.customer_balance(l_acc));
  rejects('bank transfer needs the notice number', 'NOONA-DST-063',
    'DECLARE x NUMBER; BEGIN x := NOONA_DST_PKG.collect(''{"visit":' || l_v || ',"amount":10,"method":"BANK_TRANSFER"}''); END;');
  l_c := NOONA_DST_PKG.collect('{"visit":' || l_v || ',"amount":40,"method":"BANK_TRANSFER","ref":"TRF' || l_sfx || '","bank":"الراجحي","invoice":' || l_inv || '}');
  SELECT status_code INTO l_s FROM dst_collection WHERE id = l_c;
  ok('transfer waits for accountant verification', l_s = 'PENDING_VERIFY');
  ok('pending transfer does not reduce the balance yet', NOONA_SAL_PKG.customer_balance(l_acc) = 65);
  rejects('same notice number cannot be used twice', 'NOONA-DST-065',
    'DECLARE x NUMBER; BEGIN x := NOONA_DST_PKG.collect(''{"visit":' || l_v || ',"amount":40,"method":"BANK_TRANSFER","ref":"trf' || l_sfx || '"}''); END;');
  rejects('cheque needs a due date', 'NOONA-DST-064',
    'DECLARE x NUMBER; BEGIN x := NOONA_DST_PKG.collect(''{"visit":' || l_v || ',"amount":5,"method":"CHEQUE","ref":"CH1"}''); END;');
  NOONA_DST_PKG.verify_collection(l_c);
  SELECT status_code || '/' || NVL2(ar_receipt_id, 'R', '-') || '/' || NVL2(verified_by, 'V', '-') INTO l_s FROM dst_collection WHERE id = l_c;
  ok('verified transfer posted to the bank with receipt', l_s = 'POSTED/R/V', l_s);
  ok('shop balance after verified transfer = 25', NOONA_SAL_PKG.customer_balance(l_acc) = 25, NOONA_SAL_PKG.customer_balance(l_acc));
  l_c2 := NOONA_DST_PKG.collect('{"visit":' || l_v || ',"amount":5,"method":"CHEQUE","ref":"CH' || l_sfx || '","chequeDate":"'
        || TO_CHAR(SYSDATE + 30, 'YYYY-MM-DD') || '"}');
  NOONA_DST_PKG.reject_collection(l_c2, 'شيك بدون رصيد');
  SELECT status_code INTO l_s FROM dst_collection WHERE id = l_c2;
  ok('rejected cheque', l_s = 'REJECTED');
  ok('visit page shows whatsapp invoice link', DBMS_LOB.INSTR(NOONA_DST_PKG.visit_html(l_v), 'wa.me/966501234567') > 0);
  NOONA_DST_PKG.close_visit(l_v);
  SELECT outcome || '/' || sales_amount || '/' || collected_amount INTO l_s FROM dst_visit WHERE id = l_v;
  ok('visit closed as sale with totals', l_s = 'SALE/115/90', l_s);

  -- زيارة بلا شراء
  l_v := NOONA_DST_PKG.start_visit('{"shop":' || l_sh2 || ',"lat":24.7300,"lng":46.6800}');
  SELECT distance_m INTO l_n FROM dst_visit WHERE id = l_v;
  ok('far check-in measured (about 1.1 km from shop)', l_n > 1000, l_n);
  rejects('no-sale needs a reason', 'NOONA-DST-057', 'BEGIN NOONA_DST_PKG.close_visit(' || l_v || '); END;');
  NOONA_DST_PKG.close_visit(l_v, 'CLOSED');
  SELECT outcome || '/' || no_sale_reason INTO l_s FROM dst_visit WHERE id = l_v;
  ok('no-sale visit with reason', l_s = 'NO_SALE/CLOSED', l_s);

  -- مرتجع وأمر توريد
  l_v := NOONA_DST_PKG.start_visit('{"shop":' || l_sh1 || '}');
  SELECT MIN(id) INTO l_ln FROM sal_invoice_line WHERE invoice_id = l_inv;
  l_x := NOONA_DST_PKG.visit_return('{"visit":' || l_v || ',"invoice":' || l_inv || ',"reason":"تالف","lines":[{"l":' || l_ln || ',"q":2}]}');
  ok('returned items back to the van', NOONA_INV_PKG.on_hand(l_it, l_van) = 42, NOONA_INV_PKG.on_hand(l_it, l_van));
  SELECT returns_amount INTO l_x FROM dst_visit WHERE id = l_v;
  ok('return amount on the visit (2 x 11.5)', l_x = 23, l_x);
  l_ord := NOONA_DST_PKG.place_order('{"visit":' || l_v || ',"date":"' || TO_CHAR(SYSDATE + 1, 'YYYY-MM-DD') || '","lines":[{"i":' || l_it || ',"q":20}]}');
  SELECT total_amount INTO l_x FROM dst_order WHERE id = l_ord;
  ok('pre-sale order priced 20 x 11.5 = 230', l_x = 230, l_x);
  NOONA_DST_PKG.close_visit(l_v);
  l_x := NOONA_DST_PKG.deliver_order(l_ord);
  SELECT status_code INTO l_s FROM dst_order WHERE id = l_ord;
  ok('order delivered from main warehouse with invoice', l_s = 'INVOICED' AND NOONA_INV_PKG.on_hand(l_it, l_wh) = 30);

  -- تسوية اليوم: النقد 50 والمسلم 45 (عجز 5 يبقى في العهدة)
  ok('settlement preview', DBMS_LOB.INSTR(NOONA_DST_PKG.settlement_preview_html(l_rep, TRUNC(SYSDATE)), 'النقد المطلوب تسليمه') > 0);
  l_st := NOONA_DST_PKG.settle_day('{"rep":' || l_rep || ',"counted":45}');
  SELECT cash_expected || '/' || cash_counted || '/' || cash_diff || '/' || transfers_amount INTO l_s FROM dst_settlement WHERE id = l_st;
  ok('settlement: expected 50, handed 45, shortage -5, transfers 40', l_s = '50/45/-5/40', l_s);
  ok('custody keeps the shortage (5)', NOONA_CSH_PKG.balance(l_box, NULL) = 5, NOONA_CSH_PKG.balance(l_box, NULL));
  rejects('day settled only once', 'NOONA-DST-093', 'DECLARE x NUMBER; BEGIN x := NOONA_DST_PKG.settle_day(''{"rep":' || l_rep || ',"counted":0}''); END;');
  NOONA_DST_PKG.approve_settlement(l_st);
  l_n := NOONA_DST_PKG.calc_commissions(SYSDATE);
  SELECT commission_amount INTO l_x FROM dst_commission WHERE rep_id = l_rep AND period_start = TRUNC(SYSDATE, 'MM');
  ok('commission 2% of net sales (115 - 23) = 1.84', l_x = 1.84, l_x);

  ok('performance report', DBMS_LOB.INSTR(NOONA_DST_PKG.performance_html(TRUNC(SYSDATE), TRUNC(SYSDATE)), 'مندوب اختبار ' || l_sfx) > 0);
  ok('rep day report', DBMS_LOB.INSTR(NOONA_DST_PKG.rep_day_html(l_rep, TRUNC(SYSDATE)), 'بقالة النور') > 0);
  ok('shop card with whatsapp statement', DBMS_LOB.INSTR(NOONA_DST_PKG.shop_card_html(l_sh1), 'wa.me') > 0);
  ok('shops geo json', DBMS_LOB.INSTR(NOONA_DST_PKG.shops_geo_json(l_rt), '"lat":24.7136') > 0);
  ok('idle shops report', NOONA_DST_PKG.idle_shops_html(0) IS NOT NULL);

  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || (g_fail + 1) || ' failed');
END;
/
EXIT
