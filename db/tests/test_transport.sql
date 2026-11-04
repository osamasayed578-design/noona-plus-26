-- =============================================================================
-- NOONA PLUS ERP | اختبار النقل والشحن والترحيل بحساب NOONA_APP - يتراجع في النهاية
--   الوحدات (طن متري/قصير/طويل)، الترحيل بأسسه، أولوية التعرفة، الحمولة ونوع العربة والمواد الخطرة، الرخص،
--   زمن الوصول المتوقع والتوقفات، الأعطال والاستجابة والتأخير، المصروفات، التسليم والعجز، الإقفال، الفوترة، المؤشرات
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_transport.sql
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
  l_a NUMBER; l_b NUMBER; l_c NUMBER; l_r NUMBER;
  l_v NUMBER; l_v2 NUMBER; l_d NUMBER; l_d2 NUMBER;
  l_gen NUMBER; l_haz NUMBER;
  l_cust NUMBER;
  l_rt1 NUMBER; l_rt2 NUMBER;
  l_o1 NUMBER; l_o2 NUMBER; l_o3 NUMBER;
  l_t NUMBER; l_t2 NUMBER;
  l_st NUMBER; l_inc NUMBER; l_x NUMBER; l_inv NUMBER;
  l_n NUMBER;
  l_eta1 TIMESTAMP; l_eta2 TIMESTAMP;
  l_s VARCHAR2(4000);
  l_dep TIMESTAMP := CAST(TRUNC(SYSDATE) + 8/24 AS TIMESTAMP);
  l_j JSON_OBJECT_T;

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

  -- ---------------------------------------------------------------- التجهيز والوحدات
  l_n := NOONA_TRN_PKG.quick_setup;
  ok('quick setup: cargo types + revenue account', l_n >= 7 AND NOONA_TRN_PKG.is_ready = 'Y', l_n);
  ok('2 metric tons = 2000 kg', NOONA_TRN_PKG.to_kg(2, 'METRIC_TON') = 2000);
  ok('1 short ton = 907.185 kg', ROUND(NOONA_TRN_PKG.to_kg(1, 'SHORT_TON'), 3) = 907.185);
  ok('1 long ton = 1016.047 kg', ROUND(NOONA_TRN_PKG.to_kg(1, 'LONG_TON'), 3) = 1016.047);
  ok('1 short ton = 0.907185 metric ton', ROUND(NOONA_TRN_PKG.convert_weight(1, 'SHORT_TON', 'METRIC_TON'), 6) = 0.907185);
  ok('10 metric tons = 11.0231 short tons', ROUND(NOONA_TRN_PKG.convert_weight(10, 'METRIC_TON', 'SHORT_TON'), 4) = 11.0231);

  -- ---------------------------------------------------------------- الترحيل بأسسه
  ok('per metric ton: 50 x 20 t = 1000', NOONA_TRN_PKG.freight('PER_METRIC_TON', 50, 20, 'METRIC_TON', NULL, NULL, NULL) = 1000);
  ok('per short ton: 50 on 20,000 kg = 1102.31', NOONA_TRN_PKG.freight('PER_SHORT_TON', 50, 20000, 'KG', NULL, NULL, NULL) = 1102.31);
  ok('per long ton: 50 on 20 t = 984.21', NOONA_TRN_PKG.freight('PER_LONG_TON', 50, 20, 'METRIC_TON', NULL, NULL, NULL) = 984.21);
  ok('per ton-km: 0.1 x 20 t x 500 km = 1000', NOONA_TRN_PKG.freight('PER_TON_KM', 0.1, 20, 'METRIC_TON', NULL, NULL, 500) = 1000);
  ok('per km: 3 x 500 = 1500', NOONA_TRN_PKG.freight('PER_KM', 3, 1, 'TRIP', NULL, NULL, 500) = 1500);
  ok('per trip flat', NOONA_TRN_PKG.freight('PER_TRIP', 2500, 1, 'TRIP', NULL, NULL, NULL) = 2500);
  ok('per container: 2 x 1800', NOONA_TRN_PKG.freight('PER_CONTAINER', 1800, 2, 'CONTAINER', NULL, NULL, NULL) = 3600);
  ok('minimum charge applies', NOONA_TRN_PKG.freight('PER_METRIC_TON', 50, 2, 'METRIC_TON', NULL, NULL, NULL, 400) = 400);
  rejects('per container needs container count', 'NOONA-TRN-018',
    'DECLARE x NUMBER; BEGIN x := NOONA_TRN_PKG.freight(''PER_CONTAINER'', 10, 5, ''METRIC_TON'', NULL, NULL, NULL); END;');
  rejects('per km needs a distance', 'NOONA-TRN-018',
    'DECLARE x NUMBER; BEGIN x := NOONA_TRN_PKG.freight(''PER_KM'', 3, 1, ''TRIP'', NULL, NULL, NULL); END;');

  -- ---------------------------------------------------------------- المواقع والمسار
  l_a := NOONA_TRN_PKG.save_location('{"code":"KRT' || l_sfx || '","name":"الخرطوم ' || l_sfx || '","type":"CITY","country":"SD"}');
  l_b := NOONA_TRN_PKG.save_location('{"code":"PSD' || l_sfx || '","name":"بورتسودان ' || l_sfx || '","type":"PORT","country":"SD"}');
  l_c := NOONA_TRN_PKG.save_location('{"code":"ATB' || l_sfx || '","name":"عطبرة ' || l_sfx || '","type":"CITY"}');
  rejects('route needs two different cities', 'NOONA-TRN-003',
    'DECLARE x NUMBER; BEGIN x := NOONA_TRN_PKG.save_route(''{"from":' || l_a || ',"to":' || l_a || ',"distance":10}''); END;');
  l_r := NOONA_TRN_PKG.save_route('{"from":' || l_a || ',"to":' || l_b || ',"distance":840}');
  SELECT standard_hours INTO l_n FROM trn_route WHERE id = l_r;
  ok('standard hours default from distance (840/70 = 12)', l_n = 12, l_n);
  ok('route found in both directions', NOONA_TRN_PKG.find_route(l_b, l_a) = l_r);

  -- ---------------------------------------------------------------- الأسطول والسائقون
  SELECT id INTO l_gen FROM trn_cargo_type WHERE code = 'GEN' AND company_id = NOONA_TRN_PKG.company;
  SELECT id INTO l_haz FROM trn_cargo_type WHERE code = 'HAZ' AND company_id = NOONA_TRN_PKG.company;
  l_v := NOONA_TRN_PKG.save_vehicle('{"plate":"خ ط ' || l_sfx || '","type":"TRUCK","make":"Mercedes","model":"Actros","capacityTons":25,'
        || '"odometer":100000,"licenseExpiry":"' || TO_CHAR(SYSDATE + 200, 'YYYY-MM-DD') || '","insuranceExpiry":"' || TO_CHAR(SYSDATE + 100, 'YYYY-MM-DD') || '"}');
  rejects('plate is unique per company', 'NOONA-TRN-009',
    'DECLARE x NUMBER; BEGIN x := NOONA_TRN_PKG.save_vehicle(''{"plate":"خ ط ' || l_sfx || '","capacityTons":10}''); END;');
  l_v2 := NOONA_TRN_PKG.save_vehicle('{"plate":"ق ر ' || l_sfx || '","type":"TRUCK","capacityTons":30,"insuranceExpiry":"'
        || TO_CHAR(SYSDATE - 1, 'YYYY-MM-DD') || '"}');
  l_d := NOONA_TRN_PKG.save_driver('{"name":"أحمد السائق ' || l_sfx || '","licenseNo":"L' || l_sfx || '","licenseClass":"HEAVY","licenseExpiry":"'
        || TO_CHAR(SYSDATE + 300, 'YYYY-MM-DD') || '","phone":"0912345678"}');
  l_d2 := NOONA_TRN_PKG.save_driver('{"name":"سائق برخصة منتهية ' || l_sfx || '","licenseNo":"X' || l_sfx || '","licenseExpiry":"'
        || TO_CHAR(SYSDATE - 5, 'YYYY-MM-DD') || '"}');

  -- ---------------------------------------------------------------- التعرفة والعميل
  SELECT MIN(a.id) INTO l_cust FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id
   WHERE a.company_id = NOONA_TRN_PKG.company AND NVL(c.is_walk_in, 'N') = 'N' AND a.status_code = 'ACTIVE'
     AND NOT EXISTS (SELECT 1 FROM trn_rate r WHERE r.customer_account_id = a.id);   -- عميل بلا تعرفة خاصة سابقة
  ok('a credit customer exists', l_cust IS NOT NULL);
  l_rt1 := NOONA_TRN_PKG.save_rate('{"name":"عام للطن","basis":"PER_METRIC_TON","rate":40,"minCharge":300}');
  l_rt2 := NOONA_TRN_PKG.save_rate('{"name":"عقد العميل","customer":' || l_cust || ',"route":' || l_r || ',"basis":"PER_METRIC_TON","rate":45}');
  ok('most specific rate wins (customer + route)', NOONA_TRN_PKG.find_rate(l_cust, l_r, l_gen) = l_rt2);
  ok('general rate for other routes', NOONA_TRN_PKG.find_rate(l_cust, NULL, l_gen) = l_rt1);
  l_j := JSON_OBJECT_T.parse(NOONA_TRN_PKG.quote_json('{"customer":' || l_cust || ',"from":' || l_a || ',"to":' || l_b || ',"cargo":' || l_gen
         || ',"qty":20,"uom":"METRIC_TON"}'));
  ok('quote: 20 t x 45 = 900 over 840 km', l_j.get_number('freight') = 900 AND l_j.get_number('distanceKm') = 840, l_j.to_string);

  -- ---------------------------------------------------------------- أوامر الشحن
  l_o1 := NOONA_TRN_PKG.save_order('{"customer":' || l_cust || ',"from":' || l_a || ',"to":' || l_b || ',"cargo":' || l_gen
          || ',"qty":20,"uom":"METRIC_TON","otherCharges":100,"description":"أكياس أسمنت","pickupDate":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '"}');
  SELECT freight_amount, total_amount, weight_kg, rate_id INTO l_n, l_x, l_a, l_st FROM trn_order WHERE id = l_o1;
  ok('order priced from contract rate (900 + 100)', l_n = 900 AND l_x = 1000 AND l_st = l_rt2, l_n || '/' || l_x);
  ok('order weight from metric tons', l_a = 20000);
  SELECT from_location_id INTO l_a FROM trn_order WHERE id = l_o1;
  l_o2 := NOONA_TRN_PKG.save_order('{"customer":' || l_cust || ',"from":' || l_a || ',"to":' || l_b || ',"cargo":' || l_gen
          || ',"qty":12000,"uom":"KG","basis":"PER_SHORT_TON","rate":50}');
  SELECT freight_amount INTO l_n FROM trn_order WHERE id = l_o2;
  ok('manual agreed rate per short ton (12000 kg x 50 / 907.18474)', l_n = 661.39, l_n);
  l_o3 := NOONA_TRN_PKG.save_order('{"customer":' || l_cust || ',"from":' || l_a || ',"to":' || l_b || ',"cargo":' || l_haz
          || ',"qty":3,"uom":"METRIC_TON"}');
  rejects('cannot load an unconfirmed order', 'NOONA-TRN-052',
    'DECLARE x NUMBER; BEGIN x := NOONA_TRN_PKG.create_trip(''{"vehicle":' || l_v || ',"driver":' || l_d || ',"route":' || l_r
    || ',"orders":[' || l_o1 || ']}''); END;');
  NOONA_TRN_PKG.confirm_order(l_o1);
  NOONA_TRN_PKG.confirm_order(l_o2);
  NOONA_TRN_PKG.confirm_order(l_o3);

  -- ---------------------------------------------------------------- الرحلة والتحقق
  rejects('expired driver license blocks the trip', 'NOONA-TRN-046',
    'DECLARE x NUMBER; BEGIN x := NOONA_TRN_PKG.create_trip(''{"vehicle":' || l_v || ',"driver":' || l_d2 || ',"route":' || l_r || '}''); END;');
  rejects('expired vehicle insurance blocks the trip', 'NOONA-TRN-043',
    'DECLARE x NUMBER; BEGIN x := NOONA_TRN_PKG.create_trip(''{"vehicle":' || l_v2 || ',"driver":' || l_d || ',"route":' || l_r || '}''); END;');
  l_t := NOONA_TRN_PKG.create_trip('{"vehicle":' || l_v || ',"driver":' || l_d || ',"route":' || l_r || ',"departure":"'
         || TO_CHAR(l_dep, 'YYYY-MM-DD HH24:MI') || '","orders":[' || l_o1 || ']}');
  SELECT eta INTO l_eta1 FROM trn_trip WHERE id = l_t;
  ok('ETA = departure + 12 h standard time', l_eta1 = l_dep + INTERVAL '12' HOUR, TO_CHAR(l_eta1, 'YYYY-MM-DD HH24:MI'));
  rejects('capacity: 20 t + 12 t exceeds 25 t', 'NOONA-TRN-053', 'BEGIN NOONA_TRN_PKG.add_order(' || l_t || ', ' || l_o2 || '); END;');
  rejects('hazardous cargo needs a certified driver', 'NOONA-TRN-055', 'BEGIN NOONA_TRN_PKG.add_order(' || l_t || ', ' || l_o3 || '); END;');
  SELECT status_code INTO l_s FROM trn_order WHERE id = l_o1;
  ok('loaded order is planned', l_s = 'PLANNED');
  l_st := NOONA_TRN_PKG.add_stop(l_t, l_c, 'REST', 60);
  SELECT eta, revenue_amount, load_kg INTO l_eta2, l_n, l_x FROM trn_trip WHERE id = l_t;
  ok('a planned 60-minute rest stop moves the ETA', l_eta2 = l_eta1 + INTERVAL '60' MINUTE);
  ok('trip revenue and load from its shipments', l_n = 1000 AND l_x = 20000, l_n || '/' || l_x);
  rejects('odometer cannot go back', 'NOONA-TRN-063', 'BEGIN NOONA_TRN_PKG.depart(' || l_t || ', 99000); END;');
  NOONA_TRN_PKG.depart(l_t, 100050, l_dep);
  SELECT status_code INTO l_s FROM trn_vehicle WHERE id = l_v;
  ok('departure puts vehicle on trip', l_s = 'ON_TRIP');
  SELECT status_code INTO l_s FROM trn_order WHERE id = l_o1;
  ok('shipment in transit', l_s = 'IN_TRANSIT');
  rejects('vehicle on an active trip cannot go to maintenance', 'NOONA-TRN-012',
    'BEGIN NOONA_TRN_PKG.set_vehicle_status(' || l_v || ', ''MAINTENANCE''); END;');
  l_x := NOONA_TRN_PKG.save_vehicle('{"plate":"م ن ' || l_sfx || '","type":"TRUCK","capacityTons":15}');
  rejects('the same driver cannot start another trip', 'NOONA-TRN-047',
    'DECLARE x NUMBER; BEGIN x := NOONA_TRN_PKG.create_trip(''{"vehicle":' || l_x || ',"driver":' || l_d || ',"route":' || l_r || '}''); END;');

  -- ---------------------------------------------------------------- عطل بالطريق والاستجابة
  l_inc := NOONA_TRN_PKG.report_incident('{"trip":' || l_t || ',"type":"BREAKDOWN","severity":"HIGH","description":"عطل في نظام التبريد قرب عطبرة",'
           || '"location":' || l_c || ',"reportedBy":"السائق"}');
  SELECT vehicle_id, driver_id, status_code INTO l_n, l_x, l_s FROM trn_incident WHERE id = l_inc;
  ok('incident takes vehicle and driver from the trip', l_n = l_v AND l_x = l_d AND l_s = 'REPORTED');
  rejects('resolution needs an action', 'NOONA-TRN-089', 'BEGIN NOONA_TRN_PKG.resolve_incident(' || l_inc || ', NULL, 10); END;');
  NOONA_TRN_PKG.acknowledge_incident(l_inc, 'فريق الصيانة المتنقل');
  NOONA_TRN_PKG.respond_incident(l_inc, 'تحرك فني من عطبرة');
  NOONA_TRN_PKG.resolve_incident(l_inc, 'تغيير مروحة المحرك', 120, 350);
  SELECT delay_minutes, eta, expense_amount INTO l_n, l_eta1, l_x FROM trn_trip WHERE id = l_t;
  ok('downtime added to trip delay', l_n = 120);
  ok('ETA shifted by downtime (12h + 60m + 120m from departure)', l_eta1 = l_dep + INTERVAL '15' HOUR, TO_CHAR(l_eta1, 'HH24:MI'));
  ok('repair cost becomes a trip expense', l_x = 350);
  SELECT acknowledged_at, responded_at, resolved_at INTO l_eta1, l_eta2, l_dep FROM trn_incident WHERE id = l_inc;
  ok('response timestamps recorded', l_eta1 IS NOT NULL AND l_eta2 IS NOT NULL AND l_dep IS NOT NULL);
  l_dep := CAST(TRUNC(SYSDATE) + 8/24 AS TIMESTAMP);
  NOONA_TRN_PKG.close_incident(l_inc);
  l_x := NOONA_TRN_PKG.add_expense(l_t, 'FUEL', 1200, 400);
  rejects('expense must be positive', 'NOONA-TRN-077', 'DECLARE x NUMBER; BEGIN x := NOONA_TRN_PKG.add_expense(' || l_t || ', ''TOLL'', 0); END;');
  SELECT expense_amount, fuel_liters INTO l_n, l_x FROM trn_trip WHERE id = l_t;
  ok('fuel expense and liters on the trip', l_n = 1550 AND l_x = 400, l_n || '/' || l_x);

  -- ---------------------------------------------------------------- الوصول والتسليم والإقفال
  rejects('cannot complete before delivering', 'NOONA-TRN-072', 'BEGIN NOONA_TRN_PKG.complete_trip(' || l_t || ', 101000); END;');
  NOONA_TRN_PKG.arrive(l_t, l_dep + INTERVAL '15' HOUR + INTERVAL '10' MINUTE);
  rejects('delivered quantity within loaded', 'NOONA-TRN-069',
    'BEGIN NOONA_TRN_PKG.deliver_order(' || l_t || ', ' || l_o1 || ', 21, ''المستلم''); END;');
  NOONA_TRN_PKG.deliver_order(l_t, l_o1, 19.5, 'مخزن الميناء', 'كيسان ممزقان');
  SELECT shortage_qty, status_code INTO l_n, l_s FROM trn_order WHERE id = l_o1;
  ok('shortage recorded on delivery', l_n = 0.5 AND l_s = 'DELIVERED');
  -- وصل خلال الموعد المحدث لكن بعد الموعد الأصلي (بسبب العطل): يحسب متأخراً عن الجدول
  ok('arrival after the original schedule counts as late', NOONA_TRN_PKG.timeliness(l_t) = 'LATE', NOONA_TRN_PKG.timeliness(l_t));
  NOONA_TRN_PKG.complete_trip(l_t, 101720, 410);
  SELECT status_code, actual_distance_km INTO l_s, l_n FROM trn_trip WHERE id = l_t;
  ok('trip completed with actual distance', l_s = 'COMPLETED' AND l_n = 1670);
  SELECT status_code, odometer_km INTO l_s, l_n FROM trn_vehicle WHERE id = l_v;
  ok('vehicle available with updated odometer', l_s = 'AVAILABLE' AND l_n = 101720);
  SELECT status_code INTO l_s FROM trn_driver WHERE id = l_d;
  ok('driver available again', l_s = 'AVAILABLE');

  -- ---------------------------------------------------------------- الفوترة
  rejects('only delivered orders are invoiced', 'NOONA-TRN-093', 'DECLARE x NUMBER; BEGIN x := NOONA_TRN_PKG.invoice_orders(''' || l_o2 || '''); END;');
  l_inv := NOONA_TRN_PKG.invoice_orders(TO_CHAR(l_o1));
  SELECT subtotal, customer_account_id, status_code INTO l_n, l_x, l_s FROM sal_invoice WHERE id = l_inv;
  ok('freight invoice posted for the customer', l_n = 1000 AND l_x = l_cust AND l_s IN ('POSTED', 'PARTIALLY_PAID', 'PAID'), l_n || ' ' || l_s);
  SELECT status_code, sales_invoice_id INTO l_s, l_n FROM trn_order WHERE id = l_o1;
  ok('order marked invoiced', l_s = 'INVOICED' AND l_n = l_inv);
  SELECT COUNT(*) INTO l_n FROM sal_invoice_line WHERE invoice_id = l_inv AND description LIKE '%عجز 0.5%';
  ok('invoice line mentions the shortage', l_n = 1);

  -- ---------------------------------------------------------------- الإلغاء والمؤشرات
  l_t2 := NOONA_TRN_PKG.create_trip('{"vehicle":' || l_v || ',"driver":' || l_d || ',"from":' || l_b || ',"to":' || l_a || ',"orders":[' || l_o2 || ']}');
  NOONA_TRN_PKG.cancel_trip(l_t2, 'تأجيل العميل');
  SELECT status_code INTO l_s FROM trn_order WHERE id = l_o2;
  ok('cancelled trip returns its shipments to confirmed', l_s = 'CONFIRMED');
  ok('revenue metric includes delivered freight', NOONA_ANL_PKG.kpi('TRN_REVENUE', TRUNC(SYSDATE) - 1, TRUNC(SYSDATE) + 1) >= 1000);
  ok('tonnage metric counts delivered tons', NOONA_ANL_PKG.kpi('TRN_TONNAGE', TRUNC(SYSDATE) - 1, TRUNC(SYSDATE) + 1) >= 19.5);
  ok('incidents metric', NOONA_ANL_PKG.kpi('TRN_INCIDENTS', TRUNC(SYSDATE) - 1, TRUNC(SYSDATE) + 1) >= 1);
  ok('board renders', DBMS_LOB.GETLENGTH(NOONA_TRN_PKG.board_html) > 100);
  ok('trip page renders', DBMS_LOB.INSTR(NOONA_TRN_PKG.trip_html(l_t), 'صافي الرحلة') > 0);

  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || (g_fail + 1) || ' failed');
END;
/
EXIT
