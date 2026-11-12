-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية لصيدلية تبيع بالفاتورة ونقاط البيع (تشغل بعد demo_trade_data)
--   أدوية بمادة فعالة وتركيز وشكل صيدلاني ورقم تسجيل ودفعات بتواريخ صلاحية (منها قريب الانتهاء ومنتهٍ)،
--   مورد أدوية ثانٍ وفاتورة شراء بدفعات، عملاء آجلون (عيادات ومستشفى)، فواتير بيع آجلة ونقدية بوصفة،
--   نقطة بيع ثانية، ورديتان مقفلتان ووردية مفتوحة بمبيعات بطرق سداد مختلفة ووصفات ومرتجع
--   sqlplus NOONA_APP@... @demo/demo_pharmacy.sql <مسؤول المؤسسة>
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE
COLUMN 1 NEW_VALUE 1 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
DEFINE ADMIN_USER = '&1'
DECLARE
  c_admin CONSTANT VARCHAR2(100) := NVL(UPPER(TRIM('&ADMIN_USER')), 'ADMIN');
  TYPE t_ids IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
  it t_ids; cus t_ids;
  l_co NUMBER; l_n NUMBER; l_wh NUMBER; l_box NUMBER; l_sup NUMBER; l_term NUMBER; l_term2 NUMBER; l_sh NUMBER; l_sid NUMBER;
  l_sale NUMBER; l_line NUMBER; l_r CLOB; l_rules SYS.ODCINUMBERLIST;
  FUNCTION dt(p_days NUMBER) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(TRUNC(SYSDATE) - p_days, 'YYYY-MM-DD'); END;
  FUNCTION ex(p_days NUMBER) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(TRUNC(SYSDATE) + p_days, 'YYYY-MM-DD'); END;
  PROCEDURE login(p_user VARCHAR2) IS
  BEGIN
    NOONA_APEX_PKG.cleanup_request;
    NOONA_APEX_PKG.post_auth(p_user, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  END login;
  FUNCTION catid(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM inv_item_category WHERE code = p_code; RETURN l;
  END catid;
  PROCEDURE med(p_key VARCHAR2, p_name VARCHAR2, p_generic VARCHAR2, p_strength VARCHAR2, p_form VARCHAR2, p_rx VARCHAR2, p_price NUMBER,
                p_min NUMBER, p_bc VARCHAR2) IS
  BEGIN
    it(p_key) := NOONA_INV_PKG.save_item('{"name":"' || p_name || '","code":"PH-' || p_key || '","cat":' || catid('PHARMA')
               || ',"generic":"' || p_generic || '","strength":"' || p_strength || '","form":"' || p_form || '","rx":"' || p_rx
               || '","reg":"SFDA-PH-' || p_key || '","price":' || p_price || ',"incl":"Y","min":' || p_min || ',"barcodes":["' || p_bc || '"]}');
  END med;
  FUNCTION pos_sale(p_key VARCHAR2, p_cust NUMBER, p_lines VARCHAR2, p_pays VARCHAR2, p_rx VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
  BEGIN
    l_r := NOONA_POS_PKG.sale('{"key":"' || p_key || '","shift":' || l_sh || ',"cust":' || NVL(TO_CHAR(p_cust), 'null')
           || ',"rx":' || CASE WHEN p_rx IS NULL THEN 'null' ELSE '"' || p_rx || '"' END || ',"lines":[' || p_lines || '],"pays":[' || p_pays || ']}');
    RETURN TO_NUMBER(JSON_VALUE(l_r, '$.id'));
  END pos_sale;
  FUNCTION total_of(p_sale NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT total_amount INTO l FROM pos_sale WHERE id = p_sale; RETURN l;
  END total_of;
  FUNCTION q(p_key VARCHAR2, p_q NUMBER) RETURN VARCHAR2 IS BEGIN RETURN '{"i":' || it(p_key) || ',"q":' || p_q || '}'; END q;
BEGIN
  login(c_admin);
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  SELECT COUNT(*) INTO l_n FROM inv_item WHERE item_code = 'PH-OMP';
  IF l_n > 0 THEN DBMS_OUTPUT.PUT_LINE('بيانات الصيدلية التجريبية محملة سابقاً - لم يضف شيء.'); RETURN; END IF;
  IF NOONA_POS_PKG.is_ready = 'N' THEN l_n := NOONA_POS_PKG.quick_setup; END IF;
  SELECT id BULK COLLECT INTO l_rules FROM dms_archive_rule WHERE is_active = 'Y';
  UPDATE dms_archive_rule SET is_active = 'N' WHERE is_active = 'Y';
  l_wh := NOONA_INV_PKG.default_warehouse;
  SELECT MIN(id) INTO l_box FROM csh_cash_box WHERE company_id = l_co AND status_code = 'ACTIVE' AND box_type = 'MAIN';

  -- الأدوية ومستلزمات الصيدلية
  med('OMP', 'أوميبرازول 20 مجم 14 كبسولة', 'Omeprazole', '20mg', 'CAPSULE', 'N', 19.5, 40, '6281002000011');
  med('MET', 'ميتفورمين 500 مجم 50 قرص', 'Metformin', '500mg', 'TABLET', 'Y', 14, 60, '6281002000028');
  med('ATR', 'أتورفاستاتين 20 مجم 30 قرص', 'Atorvastatin', '20mg', 'TABLET', 'Y', 46, 30, '6281002000035');
  med('AML', 'أملوديبين 5 مجم 30 قرص', 'Amlodipine', '5mg', 'TABLET', 'Y', 21, 30, '6281002000042');
  med('IBU', 'إيبوبروفين 400 مجم 30 قرص', 'Ibuprofen', '400mg', 'TABLET', 'N', 12, 50, '6281002000059');
  med('AZI', 'أزيثرومايسين 500 مجم 3 أقراص', 'Azithromycin', '500mg', 'TABLET', 'Y', 33, 20, '6281002000066');
  med('SAL', 'بخاخ سالبوتامول 100 مكجم', 'Salbutamol', '100mcg', 'OTHER', 'Y', 17, 15, '6281002000073');
  med('LOR', 'لوراتادين 10 مجم 20 قرص', 'Loratadine', '10mg', 'TABLET', 'N', 15, 30, '6281002000080');
  med('ORS', 'محلول أملاح الإرواء 10 أكياس', 'Oral Rehydration Salts', '20.5g', 'OTHER', 'N', 11, 20, '6281002000097');
  med('INS', 'إنسولين قلم 100 وحدة/مل', 'Insulin Glargine', '100IU/ml', 'INJECTION', 'Y', 98, 10, '6281002000103');
  med('CRM', 'كريم هيدروكورتيزون 1% 15 جم', 'Hydrocortisone', '1%', 'CREAM', 'N', 13.5, 15, '6281002000110');
  med('DRP', 'قطرة عين مرطبة 10 مل', 'Carboxymethylcellulose', '0.5%', 'DROPS', 'N', 24, 15, '6281002000127');

  -- مورد ثانٍ وفاتورة شراء آجلة بالدفعات وتواريخ الصلاحية (منها قريب الانتهاء)
  l_sup := NOONA_PUR_PKG.save_supplier('{"name":"شركة الإمداد الطبي المتقدم","nameEn":"Advanced Medical Supply Co.","tax":"310000000000093",'
         || '"cr":"1010000009","phone":"0112223344","term":"NET60"}');
  l_n := NOONA_PUR_PKG.save_invoice('{"sup":' || l_sup || ',"date":"' || dt(40) || '","supInv":"AMS-44120","mode":"CREDIT","action":"POST","lines":['
     || '{"i":' || it('OMP') || ',"q":120,"p":9.8,"lot":"OMP-2509","exp":"' || ex(480) || '"},'
     || '{"i":' || it('MET') || ',"q":150,"p":6.5,"lot":"MET-2507","exp":"' || ex(400) || '"},'
     || '{"i":' || it('ATR') || ',"q":60,"p":24,"lot":"ATR-2508","exp":"' || ex(520) || '"},'
     || '{"i":' || it('AML') || ',"q":80,"p":10,"lot":"AML-2506","exp":"' || ex(360) || '"},'
     || '{"i":' || it('IBU') || ',"q":200,"p":5.2,"lot":"IBU-2410","exp":"' || ex(40) || '"},'
     || '{"i":' || it('IBU') || ',"q":100,"p":5.4,"lot":"IBU-2509","exp":"' || ex(610) || '"},'
     || '{"i":' || it('AZI') || ',"q":50,"p":16,"lot":"AZI-2505","exp":"' || ex(300) || '"},'
     || '{"i":' || it('SAL') || ',"q":40,"p":8,"lot":"SAL-2504","exp":"' || ex(270) || '"},'
     || '{"i":' || it('LOR') || ',"q":90,"p":6,"lot":"LOR-2411","exp":"' || ex(75) || '"},'
     || '{"i":' || it('ORS') || ',"q":60,"p":4.5,"lot":"ORS-2503","exp":"' || ex(700) || '"},'
     || '{"i":' || it('INS') || ',"q":25,"p":62,"lot":"INS-2510","exp":"' || ex(200) || '"},'
     || '{"i":' || it('CRM') || ',"q":40,"p":6,"lot":"CRM-2502","exp":"' || ex(450) || '"},'
     || '{"i":' || it('DRP') || ',"q":40,"p":11,"lot":"DRP-2501","exp":"' || ex(330) || '"}]}');

  -- عملاء آجلون: عيادات ومستشفى ومريض مزمن
  cus('CLINIC') := NOONA_SAL_PKG.save_customer('{"name":"مجمع عيادات الرعاية الطبية","person":"N","tax":"310000000000103","phone":"0114445566","term":"NET30","limit":30000}');
  cus('HOSP') := NOONA_SAL_PKG.save_customer('{"name":"مستشفى الأمل الخاص","person":"N","tax":"310000000000113","phone":"0115556677","term":"NET60","limit":80000}');
  cus('CHRONIC') := NOONA_SAL_PKG.save_customer('{"name":"عبدالرحمن صالح الدوسري (مريض مزمن)","person":"Y","phone":"0551237788","term":"NET15","limit":1500}');
  l_n := NOONA_SAL_PKG.save_invoice('{"cust":' || cus('CLINIC') || ',"date":"' || dt(25) || '","mode":"CREDIT","action":"POST","lines":['
     || q('IBU', 40) || ',' || q('LOR', 20) || ',' || q('CRM', 10) || ',' || q('ORS', 15) || ']}');
  l_n := NOONA_SAL_PKG.save_invoice('{"cust":' || cus('HOSP') || ',"date":"' || dt(15) || '","mode":"CREDIT","rx":"HOSP-RX-3391","action":"POST","lines":['
     || q('INS', 8) || ',' || q('AZI', 12) || ',' || q('SAL', 10) || ',' || q('OMP', 30) || ']}');
  l_n := NOONA_SAL_PKG.save_invoice('{"cust":' || cus('CHRONIC') || ',"date":"' || dt(10) || '","mode":"CREDIT","rx":"RX-90114","action":"POST","lines":['
     || q('MET', 2) || ',' || q('ATR', 1) || ',' || q('AML', 1) || ']}');
  l_n := NOONA_SAL_PKG.save_invoice('{"date":"' || dt(5) || '","mode":"CASH","place":"BOX:' || l_box || '","name":"عميل نقدي","rx":"RX-90377",'
     || '"action":"POST","lines":[' || q('AZI', 1) || ',' || q('IBU', 1) || ']}');

  -- نقطة بيع ثانية للصيدلية على نفس المستودع والصندوق
  SELECT MIN(id) INTO l_term FROM pos_terminal WHERE company_id = l_co AND status_code = 'ACTIVE';
  SELECT MIN(id) INTO l_term2 FROM pos_terminal WHERE company_id = l_co AND code = 'POS-PH2';
  IF l_term2 IS NULL THEN
    l_term2 := NOONA_POS_PKG.create_terminal('POS-PH2', 'كاشير الصيدلية 2', l_wh, l_box);
  END IF;
  -- وردية مقفلة على كل نقطة ببيع ووصفات وطرق سداد ومرتجع
  FOR o IN (SELECT id FROM pos_shift WHERE terminal_id IN (l_term, l_term2) AND status_code = 'OPEN') LOOP
    l_n := NOONA_POS_PKG.close_shift(o.id, NOONA_POS_PKG.expected_cash(o.id));
  END LOOP;
  l_sh := NOONA_POS_PKG.open_shift(l_term2, 500);
  l_sale := pos_sale('PH-1', NULL, q('OMP', 1) || ',' || q('LOR', 1), '{"m":"CASH","a":40}');
  l_sid := l_sale;
  l_sale := pos_sale('PH-2', NULL, q('MET', 2) || ',' || q('AML', 1), '{"m":"MADA","a":' || 49 || ',"ref":"MADA-3301"}', 'RX-91002');
  l_sale := pos_sale('PH-3', NULL, q('IBU', 2) || ',' || q('ORS', 1), '{"m":"STC_PAY","a":35,"ref":"STC-8812"}');
  l_sale := pos_sale('PH-4', cus('CHRONIC'), q('ATR', 1), '{"m":"CREDIT","a":46}', 'RX-91003');
  l_sale := pos_sale('PH-5', NULL, q('DRP', 1) || ',' || q('CRM', 1), '{"m":"CASH","a":20},{"m":"APPLE_PAY","a":17.5,"ref":"AP-55190"}');
  SELECT MIN(id) INTO l_line FROM pos_sale_line WHERE sale_id = l_sid AND item_id = it('LOR');
  l_r := NOONA_POS_PKG.return_sale('{"key":"PH-R1","shift":' || l_sh || ',"orig":' || l_sid || ',"lines":[{"l":' || l_line || ',"q":1}]}');
  NOONA_POS_PKG.cash_movement(l_sh, 'PAYOUT', 30, 'سداد أجرة توصيل أدوية');
  l_n := NOONA_POS_PKG.close_shift(l_sh, NOONA_POS_PKG.expected_cash(l_sh) - 5);
  -- وردية مفتوحة الآن على الكاشير الأول
  l_sh := NOONA_POS_PKG.open_shift(l_term, 300);
  l_sale := pos_sale('PH-6', NULL, q('SAL', 1) || ',' || q('LOR', 1), '{"m":"MADA","a":32,"ref":"MADA-3355"}', 'RX-91010');
  l_sale := pos_sale('PH-7', NULL, q('INS', 1), '{"m":"CASH","a":100}', 'RX-91011');
  l_sale := pos_sale('PH-8', NULL, q('ORS', 2) || ',' || q('IBU', 1), '{"m":"CASH","a":34}');

  FORALL i IN 1 .. l_rules.COUNT
    UPDATE dms_archive_rule SET is_active = 'Y' WHERE id = l_rules(i);
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('الصيدلية: 12 دواء بدفعات وصلاحيات، مورد وفاتورة شراء، 3 عملاء آجلين و4 فواتير، نقطة بيع ثانية، وردية مقفلة بمرتجع ووردية مفتوحة');
  DBMS_OUTPUT.PUT_LINE('تم تحميل بيانات الصيدلية التجريبية. افتح «المبيعات ونقاط البيع».');
  NOONA_APEX_PKG.cleanup_request;
END;
/
EXIT
