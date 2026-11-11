-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية للنقل والشحن (مدن ومسارات سعودية، أسطول، سائقون، تعرفة، أوامر، رحلات بحالاتها)
--   sqlplus NOONA_APP@//host:1521/PDB @demo/transport_demo.sql <username>
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON
DECLARE
  l_n NUMBER;
  l_ruh NUMBER; l_jed NUMBER; l_dmm NUMBER; l_med NUMBER; l_jip NUMBER; l_qas NUMBER;
  l_r1 NUMBER; l_r2 NUMBER; l_r3 NUMBER;
  l_v1 NUMBER; l_v2 NUMBER; l_v3 NUMBER; l_d1 NUMBER; l_d2 NUMBER; l_d3 NUMBER;
  l_gen NUMBER; l_bulk NUMBER; l_cont NUMBER; l_cust NUMBER; l_cust2 NUMBER;
  l_o1 NUMBER; l_o2 NUMBER; l_o3 NUMBER; l_o4 NUMBER;
  l_t1 NUMBER; l_t2 NUMBER; l_t3 NUMBER; l_i NUMBER; l_x NUMBER;
  l_d0 TIMESTAMP := CAST(TRUNC(SYSDATE) - 2 + 6/24 AS TIMESTAMP);
BEGIN
  NOONA_APEX_PKG.post_auth('&1', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  SELECT COUNT(*) INTO l_n FROM trn_location WHERE company_id = NOONA_TRN_PKG.company AND code = 'RUH';
  IF l_n > 0 THEN DBMS_OUTPUT.PUT_LINE('demo exists'); RETURN; END IF;
  l_n := NOONA_TRN_PKG.quick_setup;
  l_ruh := NOONA_TRN_PKG.save_location('{"code":"RUH","name":"الرياض","type":"CITY","region":"منطقة الرياض","country":"SA"}');
  l_jed := NOONA_TRN_PKG.save_location('{"code":"JED","name":"جدة","type":"CITY","region":"منطقة مكة المكرمة","country":"SA"}');
  l_dmm := NOONA_TRN_PKG.save_location('{"code":"DMM","name":"الدمام","type":"CITY","region":"المنطقة الشرقية","country":"SA"}');
  l_med := NOONA_TRN_PKG.save_location('{"code":"MED","name":"المدينة المنورة","type":"CITY","country":"SA"}');
  l_jip := NOONA_TRN_PKG.save_location('{"code":"JIP","name":"ميناء جدة الإسلامي","type":"PORT","city":"جدة","country":"SA"}');
  l_qas := NOONA_TRN_PKG.save_location('{"code":"QAS","name":"محطة وقود الخاصرة","type":"FUEL_STATION","city":"الخاصرة","country":"SA"}');
  l_r1 := NOONA_TRN_PKG.save_route('{"from":' || l_ruh || ',"to":' || l_dmm || ',"distance":410,"hours":5,"toll":0}');
  l_r2 := NOONA_TRN_PKG.save_route('{"from":' || l_jip || ',"to":' || l_ruh || ',"distance":960,"hours":11,"roadType":"HIGHWAY"}');
  l_r3 := NOONA_TRN_PKG.save_route('{"from":' || l_jed || ',"to":' || l_med || ',"distance":420,"hours":5}');
  l_v1 := NOONA_TRN_PKG.save_vehicle('{"plate":"أ ب ج 1234","type":"TRUCK","make":"Mercedes-Benz","model":"Actros 2645","year":2023,"capacityTons":25,'
          || '"ownership":"OWNED","purchaseCost":420000,"funding":"OPENING","openingAccum":95000,"purchaseDate":"' || TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE, 'YYYY'), -12), 'YYYY-MM-DD') || '",''
          || '"odometer":182400,"fuelPer100":34,"licenseExpiry":"' || TO_CHAR(SYSDATE + 280, 'YYYY-MM-DD') || '","insuranceExpiry":"' || TO_CHAR(SYSDATE + 150, 'YYYY-MM-DD') || '"}');
  l_v2 := NOONA_TRN_PKG.save_vehicle('{"plate":"د هـ و 5678","type":"CONTAINER_CARRIER","make":"Volvo","model":"FH 500","year":2022,"capacityTons":30,'
          || '"ownership":"OWNED","purchaseCost":465000,"funding":"OPENING","openingAccum":160000,"purchaseDate":"' || TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE, 'YYYY'), -12), 'YYYY-MM-DD') || '",''
          || '"odometer":240100,"fuelPer100":36,"licenseExpiry":"' || TO_CHAR(SYSDATE + 90, 'YYYY-MM-DD') || '","insuranceExpiry":"' || TO_CHAR(SYSDATE + 40, 'YYYY-MM-DD') || '"}');
  l_v3 := NOONA_TRN_PKG.save_vehicle('{"plate":"ر س ص 9012","type":"TIPPER","make":"MAN","model":"TGS 41.440","year":2021,"capacityTons":35,'
          || '"ownership":"OWNED","purchaseCost":510000,"funding":"OPENING","openingAccum":245000,"purchaseDate":"' || TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE, 'YYYY'), -12), 'YYYY-MM-DD') || '",''
          || '"odometer":310500,"fuelPer100":40,"licenseExpiry":"' || TO_CHAR(SYSDATE + 200, 'YYYY-MM-DD') || '"}');
  l_d1 := NOONA_TRN_PKG.save_driver('{"name":"عبدالله القحطاني","phone":"0551234567","licenseNo":"HV-102030","licenseClass":"ثقيل","licenseExpiry":"'
          || TO_CHAR(SYSDATE + 500, 'YYYY-MM-DD') || '","hazmat":"Y","allowance":250}');
  l_d2 := NOONA_TRN_PKG.save_driver('{"name":"محمد العتيبي","phone":"0559876543","licenseNo":"HV-405060","licenseClass":"ثقيل","licenseExpiry":"'
          || TO_CHAR(SYSDATE + 300, 'YYYY-MM-DD') || '","allowance":250}');
  l_d3 := NOONA_TRN_PKG.save_driver('{"name":"خالد الشمري","phone":"0533332211","licenseNo":"HV-708090","licenseClass":"ثقيل","licenseExpiry":"'
          || TO_CHAR(SYSDATE + 25, 'YYYY-MM-DD') || '","allowance":200}');
  SELECT MIN(id) INTO l_gen FROM trn_cargo_type WHERE code = 'GEN' AND company_id = NOONA_TRN_PKG.company;
  SELECT MIN(id) INTO l_bulk FROM trn_cargo_type WHERE code = 'BULK' AND company_id = NOONA_TRN_PKG.company;
  SELECT MIN(id) INTO l_cont FROM trn_cargo_type WHERE code = 'CONT' AND company_id = NOONA_TRN_PKG.company;
  SELECT MIN(a.id), MAX(a.id) INTO l_cust, l_cust2 FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id
   WHERE a.company_id = NOONA_TRN_PKG.company AND NVL(c.is_walk_in, 'N') = 'N' AND a.status_code = 'ACTIVE';
  l_x := NOONA_TRN_PKG.save_rate('{"name":"تعرفة عامة للطن","basis":"PER_METRIC_TON","rate":38,"minCharge":500,"priority":200,"from":"2026-01-01"}');
  l_x := NOONA_TRN_PKG.save_rate('{"name":"الرياض - الدمام للطن","route":' || l_r1 || ',"basis":"PER_METRIC_TON","rate":42,"from":"2026-01-01"}');
  l_x := NOONA_TRN_PKG.save_rate('{"name":"حاويات الميناء - الرياض","route":' || l_r2 || ',"cargo":' || l_cont || ',"basis":"PER_CONTAINER","rate":3200,"from":"2026-01-01"}');
  l_x := NOONA_TRN_PKG.save_rate('{"name":"عقد عميل للطن-كيلومتر","customer":' || l_cust || ',"basis":"PER_TON_KM","rate":0.095,"from":"2026-01-01"}');
  l_o1 := NOONA_TRN_PKG.save_order('{"customer":' || l_cust2 || ',"from":' || l_ruh || ',"to":' || l_dmm || ',"cargo":' || l_gen
          || ',"qty":22,"uom":"METRIC_TON","description":"مواد غذائية معبأة","otherCharges":250,"pickupDate":"' || TO_CHAR(SYSDATE - 2, 'YYYY-MM-DD') || '"}');
  l_o2 := NOONA_TRN_PKG.save_order('{"customer":' || l_cust2 || ',"from":' || l_jip || ',"to":' || l_ruh || ',"cargo":' || l_cont
          || ',"qty":1,"uom":"CONTAINER","weightKg":24000,"description":"حاوية 40 قدم أجهزة كهربائية","customerRef":"BL-778812"}');
  l_o3 := NOONA_TRN_PKG.save_order('{"customer":' || l_cust || ',"from":' || l_jed || ',"to":' || l_med || ',"cargo":' || l_bulk
          || ',"qty":32,"uom":"METRIC_TON","description":"أسمنت سائب","pickupDate":"' || TO_CHAR(SYSDATE + 1, 'YYYY-MM-DD') || '"}');
  l_o4 := NOONA_TRN_PKG.save_order('{"customer":' || l_cust2 || ',"from":' || l_ruh || ',"to":' || l_dmm || ',"cargo":' || l_gen
          || ',"qty":30,"uom":"SHORT_TON","description":"قطع غيار (طن أمريكي)","pickupDate":"' || TO_CHAR(SYSDATE + 3, 'YYYY-MM-DD') || '"}');
  NOONA_TRN_PKG.confirm_order(l_o1); NOONA_TRN_PKG.confirm_order(l_o2); NOONA_TRN_PKG.confirm_order(l_o3); NOONA_TRN_PKG.confirm_order(l_o4);
  -- رحلة مكتملة مع عطل محلول
  l_t1 := NOONA_TRN_PKG.create_trip('{"vehicle":' || l_v1 || ',"driver":' || l_d1 || ',"route":' || l_r1 || ',"departure":"'
          || TO_CHAR(l_d0, 'YYYY-MM-DD HH24:MI') || '","orders":[' || l_o1 || ']}');
  l_x := NOONA_TRN_PKG.add_stop(l_t1, l_qas, 'FUEL', 30);
  NOONA_TRN_PKG.depart(l_t1, 182450, l_d0);
  l_i := NOONA_TRN_PKG.report_incident('{"trip":' || l_t1 || ',"type":"TIRE","severity":"MEDIUM","description":"انفجار إطار خلفي قرب الخاصرة",'
         || '"location":' || l_qas || ',"locationText":"كم 180 طريق الرياض - الدمام"}');
  NOONA_TRN_PKG.acknowledge_incident(l_i, 'ورشة الطريق المتنقلة');
  NOONA_TRN_PKG.resolve_incident(l_i, 'تركيب إطار احتياطي وفحص الضغط', 45, 900);
  l_x := NOONA_TRN_PKG.add_expense(l_t1, 'FUEL', 520, 230);
  l_x := NOONA_TRN_PKG.add_expense(l_t1, 'DRIVER_ALLOWANCE', 250);
  NOONA_TRN_PKG.arrive(l_t1, l_d0 + INTERVAL '6' HOUR + INTERVAL '20' MINUTE);
  NOONA_TRN_PKG.deliver_order(l_t1, l_o1, 22, 'مستودع الدمام المركزي', NULL, l_d0 + INTERVAL '7' HOUR);
  NOONA_TRN_PKG.complete_trip(l_t1, 182872, 230);
  -- رحلة في الطريق مع عطل مفتوح
  l_t2 := NOONA_TRN_PKG.create_trip('{"vehicle":' || l_v2 || ',"driver":' || l_d2 || ',"route":' || l_r2 || ',"departure":"'
          || TO_CHAR(SYSTIMESTAMP - INTERVAL '5' HOUR, 'YYYY-MM-DD HH24:MI') || '","orders":[' || l_o2 || ']}');
  NOONA_TRN_PKG.depart(l_t2, 240150, SYSTIMESTAMP - INTERVAL '5' HOUR);
  l_i := NOONA_TRN_PKG.report_incident('{"trip":' || l_t2 || ',"type":"BREAKDOWN","severity":"HIGH","description":"ارتفاع حرارة المحرك وتوقف الشاحنة",'
         || '"locationText":"كم 420 طريق جدة - الرياض قرب ظلم"}');
  NOONA_TRN_PKG.acknowledge_incident(l_i, 'وكيل فولفو - فرع الطائف');
  -- رحلة مجدولة
  l_t3 := NOONA_TRN_PKG.create_trip('{"vehicle":' || l_v3 || ',"driver":' || l_d1 || ',"route":' || l_r3 || ',"departure":"'
          || TO_CHAR(SYSDATE + 1, 'YYYY-MM-DD') || ' 05:30","orders":[' || l_o3 || ']}');
  -- فوترة الرحلة المكتملة
  l_x := NOONA_TRN_PKG.invoice_orders(TO_CHAR(l_o1));
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('transport demo created');
END;
/
EXIT
