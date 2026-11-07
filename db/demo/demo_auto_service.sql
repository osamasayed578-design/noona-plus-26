-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية لمراكز خدمة السيارات (بعد التحديث 35) - تشغل بحساب NOONA_APP ولا تكرر
-- (تكتشف فئة الخدمات ذات الرمز OIL):
--   sqlplus NOONA_APP@//host:1521/PDB @demo/demo_auto_service.sql ADMIN
-- المحتوى:
--   * 8 فئات خدمات (كروت) و20 خدمة بأسعارها وأوقاتها القياسية وموعد الخدمة التالية، وقطعها الافتراضية
--   * 22 قطعة غيار بأرقام القطع والباركود والماركة والتوافق مع الطرازات، وبدائل، وأرصدة افتتاحية
--   * 5 رافعات ومواقع عمل، 6 فنيين بتكلفة الساعة والعمولة، 3 شركات تأمين بخصوماتها وتحمل العميل
--   * 12 مركبة بملاكها، وأوامر إصلاح منجزة ومفوترة ومسلمة خلال الشهر (نقدي وآجل وتأمين)
--   * الوضع الحالي: سيارات في الورشة (قيد العمل، بانتظار قطع، جاهزة، بانتظار التسليم)، وحجوزات اليوم والغد
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE
COLUMN 1 NEW_VALUE 1 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
DEFINE ADMIN_USER = '&1'

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/

PROMPT ========== مركز خدمة السيارات: الإعداد والقطع والخدمات والمركبات والأوامر
DECLARE
  c_admin CONSTANT VARCHAR2(128) := NVL(UPPER(TRIM('&ADMIN_USER')), 'ADMIN');
  l_n     NUMBER;
  l_x     NUMBER;
  l_auto  NUMBER;
  l_wh    NUMBER;
  l_box   VARCHAR2(30);
  l_lines VARCHAR2(32767);
  l_job   NUMBER;
  l_inv   NUMBER;
  l_cnt   PLS_INTEGER := 0;
  TYPE t_map IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
  cat t_map; it t_map; sv t_map; te t_map; ins t_map; ve t_map; bay t_map;

  PROCEDURE say(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
  FUNCTION code_of(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN 'AU-' || p; END;
  PROCEDURE part(p_key VARCHAR2, p_name VARCHAR2, p_brand VARCHAR2, p_mpn VARCHAR2, p_price NUMBER, p_cost NUMBER, p_qty NUMBER,
                 p_fit VARCHAR2 DEFAULT NULL, p_alt VARCHAR2 DEFAULT NULL) IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM inv_item WHERE manufacturer_part_no = p_mpn;
    IF l IS NULL THEN
      l := NOONA_INV_PKG.save_item('{"name":"' || p_name || '","cat":' || l_auto || ',"price":' || p_price || ',"brand":"' || p_brand || '",'
           || '"mpn":"' || p_mpn || '","barcodes":["62' || LPAD(DBMS_UTILITY.GET_HASH_VALUE(p_mpn, 1, 999999999), 11, '0') || '"]'
           || CASE WHEN p_fit IS NOT NULL THEN ',"fitment":' || p_fit END
           || CASE WHEN p_alt IS NOT NULL THEN ',"alternates":[{"no":"' || p_alt || '"}]' END || '}');
      l_lines := l_lines || CASE WHEN l_lines IS NOT NULL THEN ',' END || '{"i":' || l || ',"q":' || p_qty || ',"c":' || p_cost || '}';
    END IF;
    it(p_key) := l;
  END part;
  -- الفئة أو الخدمة الموجودة (من الفئات الافتراضية للتجهيز السريع) تحدث بدل إنشائها مرة أخرى
  FUNCTION eid(p_table VARCHAR2, p_code VARCHAR2) RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    IF p_table = 'CAT' THEN
      SELECT MAX(id) INTO l FROM aut_service_category WHERE company_id = NOONA_AUT_PKG.company AND code = p_code;
    ELSE
      SELECT MAX(id) INTO l FROM aut_service WHERE company_id = NOONA_AUT_PKG.company AND code = p_code;
    END IF;
    RETURN CASE WHEN l IS NOT NULL THEN '"id":' || l || ',' END;
  END eid;
  PROCEDURE category(p_key VARCHAR2, p_name VARCHAR2, p_icon VARCHAR2, p_color VARCHAR2, p_sort NUMBER) IS
  BEGIN
    cat(p_key) := NOONA_AUT_PKG.save_category('{' || eid('CAT', p_key) || '"code":"' || p_key || '","name":"' || p_name || '","icon":"' || p_icon || '","color":"' || p_color
                                             || '","sort":' || p_sort || '}');
  END category;
  PROCEDURE service(p_key VARCHAR2, p_cat VARCHAR2, p_name VARCHAR2, p_price NUMBER, p_min NUMBER, p_icon VARCHAR2, p_parts VARCHAR2 DEFAULT NULL,
                    p_days NUMBER DEFAULT NULL, p_km NUMBER DEFAULT NULL, p_warranty NUMBER DEFAULT 30) IS
  BEGIN
    sv(p_key) := NOONA_AUT_PKG.save_service('{' || eid('SVC', p_key) || '"code":"' || p_key || '","name":"' || p_name || '","cat":' || cat(p_cat) || ',"price":' || p_price
                 || ',"minutes":' || p_min || ',"icon":"' || p_icon || '","warrantyDays":' || p_warranty
                 || CASE WHEN p_days IS NOT NULL THEN ',"nextDays":' || p_days END || CASE WHEN p_km IS NOT NULL THEN ',"nextKm":' || p_km END
                 || CASE WHEN p_parts IS NOT NULL THEN ',"parts":[' || p_parts || ']' END || '}');
  END service;
  FUNCTION pp(p_key VARCHAR2, p_qty NUMBER DEFAULT 1, p_opt VARCHAR2 DEFAULT 'N') RETURN VARCHAR2 IS
  BEGIN RETURN '{"item":' || it(p_key) || ',"qty":' || p_qty || ',"optional":"' || p_opt || '"}'; END pp;
  PROCEDURE vehicle(p_key VARCHAR2, p_plate VARCHAR2, p_make VARCHAR2, p_model VARCHAR2, p_year NUMBER, p_color VARCHAR2, p_owner VARCHAR2,
                    p_phone VARCHAR2, p_odo NUMBER, p_ins VARCHAR2 DEFAULT NULL) IS
  BEGIN
    ve(p_key) := NOONA_AUT_PKG.save_vehicle('{"plate":"' || p_plate || '","make":"' || p_make || '","model":"' || p_model || '","year":' || p_year
                 || ',"color":"' || p_color || '","ownerName":"' || p_owner || '","ownerPhone":"' || p_phone || '","odometer":' || p_odo
                 || CASE WHEN p_ins IS NOT NULL THEN ',"insurer":' || ins(p_ins) || ',"policy":"POL-' || p_key || '","policyExpiry":"'
                      || TO_CHAR(ADD_MONTHS(SYSDATE, 5), 'YYYY-MM-DD') || '"' END
                 || ',"regExpiry":"' || TO_CHAR(SYSDATE + DBMS_UTILITY.GET_HASH_VALUE(p_plate, 0, 300) - 20, 'YYYY-MM-DD') || '"}');
  END vehicle;
  -- ينجز كل خدمات الأمر بفني ومدة، ويرجع الأمر
  PROCEDURE work(p_job NUMBER, p_tech VARCHAR2, p_complete BOOLEAN DEFAULT TRUE) IS
  BEGIN
    FOR l IN (SELECT id, NVL(work_minutes, 30) m FROM aut_job_line WHERE job_card_id = p_job AND line_type IN ('SERVICE', 'SUBLET')
               AND line_status = 'PENDING' ORDER BY line_no) LOOP
      NOONA_AUT_PKG.update_line('{"id":' || l.id || ',"tech":' || te(p_tech) || '}');
      NOONA_AUT_PKG.line_action(l.id, 'START');
      IF p_complete THEN
        NOONA_AUT_PKG.line_action(l.id, 'DONE');
        NOONA_AUT_PKG.update_line('{"id":' || l.id || ',"minutes":' || ROUND(l.m * (0.8 + DBMS_RANDOM.VALUE(0, 0.5))) || '}');
      END IF;
    END LOOP;
    IF p_complete THEN NOONA_AUT_PKG.set_job_status(p_job, 'COMPLETED'); END IF;
  END work;
  -- يرجع أوقات الأمر إلى يوم سابق (لتنوع تقارير الفترة)
  PROCEDURE backdate(p_job NUMBER, p_days NUMBER, p_hours NUMBER) IS
    l_in TIMESTAMP := CAST(TRUNC(SYSDATE) - p_days + (8 + MOD(p_job, 4)) / 24 AS TIMESTAMP);
  BEGIN
    UPDATE aut_job_card SET checkin_at = l_in, promised_at = l_in + NUMTODSINTERVAL(p_hours + 1, 'HOUR'),
                            started_at = l_in + INTERVAL '20' MINUTE, completed_at = l_in + NUMTODSINTERVAL(p_hours, 'HOUR'),
                            delivered_at = CASE WHEN delivered_at IS NOT NULL THEN l_in + NUMTODSINTERVAL(p_hours + 0.75, 'HOUR') END,
                            doc_date = TRUNC(CAST(l_in AS DATE))
     WHERE id = p_job;
    UPDATE aut_job_line SET started_at = l_in + INTERVAL '25' MINUTE, done_at = l_in + NUMTODSINTERVAL(p_hours - 0.2, 'HOUR')
     WHERE job_card_id = p_job AND line_status = 'DONE';
  END backdate;
  FUNCTION open_job(p_veh VARCHAR2, p_odo NUMBER, p_svcs VARCHAR2, p_complaint VARCHAR2, p_extra VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
  BEGIN
    RETURN NOONA_AUT_PKG.open_job('{"vehicle":' || ve(p_veh) || ',"odometer":' || p_odo || ',"complaint":"' || p_complaint || '","services":[' || p_svcs || ']'
           || ',"promised":"' || TO_CHAR(SYSDATE + 3 / 24, 'YYYY-MM-DD HH24:MI') || '"' || p_extra || '}');
  END open_job;
BEGIN
  NOONA_APEX_PKG.post_auth(c_admin, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  -- علامة البيانات التجريبية: خدمة OIL-SYN (الفئات الافتراضية للتجهيز السريع لا تكفي دليلاً)
  SELECT COUNT(*) INTO l_n FROM aut_service WHERE company_id = NOONA_AUT_PKG.company AND code = 'OIL-SYN';
  IF l_n > 0 THEN
    say('بيانات مركز الخدمة موجودة مسبقاً - لا شيء للإضافة');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;
  l_n := NOONA_AUT_PKG.quick_setup;
  l_wh := NOONA_AUT_PKG.default_warehouse;
  SELECT MIN(id) INTO l_auto FROM inv_item_category WHERE code = 'AUTO';
  SELECT 'BOX:' || MIN(id) INTO l_box FROM csh_cash_box WHERE company_id = NOONA_AUT_PKG.company AND status_code = 'ACTIVE';

  -- ------------------------------------------------------------ الرافعات والفنيون وشركات التأمين
  l_x := NOONA_AUT_PKG.save_bay('{"code":"L3","name":"رافعة 3","type":"LIFT","sort":3}');
  l_x := NOONA_AUT_PKG.save_bay('{"code":"AL","name":"وزن الأذرعة","type":"ALIGNMENT","sort":4}');
  l_x := NOONA_AUT_PKG.save_bay('{"code":"WS","name":"منطقة الغسيل","type":"WASH","sort":5}');
  SELECT MIN(id) INTO l_x FROM aut_bay WHERE company_id = NOONA_AUT_PKG.company AND code = 'L1'; bay('L1') := l_x;
  SELECT MIN(id) INTO l_x FROM aut_bay WHERE company_id = NOONA_AUT_PKG.company AND code = 'L2'; bay('L2') := l_x;
  te('AHMED') := NOONA_AUT_PKG.save_technician('{"code":"T01","name":"أحمد الميكانيكي","specialty":"ميكانيكا ومحركات","phone":"0551000101","hourly":45,"commission":10}');
  te('SAMI') := NOONA_AUT_PKG.save_technician('{"code":"T02","name":"سامي فني الكهرباء","specialty":"كهرباء وبرمجة","phone":"0551000102","hourly":50,"commission":12}');
  te('KHALED') := NOONA_AUT_PKG.save_technician('{"code":"T03","name":"خالد فني الزيوت","specialty":"زيوت وفلاتر","phone":"0551000103","hourly":30,"commission":8}');
  te('OMAR') := NOONA_AUT_PKG.save_technician('{"code":"T04","name":"عمر فني الإطارات","specialty":"إطارات ووزن أذرعة","phone":"0551000104","hourly":30,"commission":8}');
  te('YOUSEF') := NOONA_AUT_PKG.save_technician('{"code":"T05","name":"يوسف فني التكييف","specialty":"تكييف","phone":"0551000105","hourly":40,"commission":10}');
  te('HASSAN') := NOONA_AUT_PKG.save_technician('{"code":"T06","name":"حسن السمكري","specialty":"سمكرة ودهان","phone":"0551000106","hourly":55,"commission":15}');
  ins('NAT') := NOONA_AUT_PKG.save_insurer('{"code":"INS-NAT","name":"شركة التأمين الوطنية (تجريبي)","laborDisc":10,"partsDisc":5,"deductible":500,"claimDays":45,"contact":"إدارة المطالبات","phone":"920000001"}');
  ins('GULF') := NOONA_AUT_PKG.save_insurer('{"code":"INS-GLF","name":"تأمين الخليج المتحد (تجريبي)","laborDisc":15,"partsDisc":10,"deductible":300,"claimDays":60,"phone":"920000002"}');
  ins('AMAN') := NOONA_AUT_PKG.save_insurer('{"code":"INS-AMN","name":"أمان للتأمين التعاوني (تجريبي)","laborDisc":5,"partsDisc":0,"deductible":400,"claimDays":30,"phone":"920000003"}');

  -- ------------------------------------------------------------ قطع الغيار وأرصدتها
  part('OILF_T', 'فلتر زيت تويوتا', 'Toyota Genuine', '90915-YZZE1', 35, 18, 60, '[{"make":"Toyota","model":"Camry","from":2012,"to":2024},{"make":"Toyota","model":"Corolla","from":2010,"to":2024}]');
  part('OILF_D', 'فلتر زيت تويوتا بديل', 'Denso', 'DN-150-2010', 25, 11, 40, '[{"make":"Toyota"}]', '90915-YZZE1');
  part('OILF_H', 'فلتر زيت هيونداي وكيا', 'Mobis', '26300-35505', 32, 16, 50, '[{"make":"Hyundai"},{"make":"Kia"}]');
  part('OILF_N', 'فلتر زيت نيسان', 'Nissan Genuine', '15208-65F0E', 34, 17, 30, '[{"make":"Nissan"}]');
  part('OIL5W30', 'زيت محرك 5W-30 تخليقي (لتر)', 'Mobil 1', 'MOB-5W30-1L', 38, 22, 300);
  part('OIL10W40', 'زيت محرك 10W-40 (لتر)', 'Shell Helix', 'SHL-10W40-1L', 28, 15, 200);
  part('AIRF_T', 'فلتر هواء محرك كامري', 'Toyota Genuine', '17801-0V020', 65, 34, 25, '[{"make":"Toyota","model":"Camry","from":2018,"to":2024}]');
  part('ACF_T', 'فلتر مكيف كامري', 'Denso', 'DCF-583K', 55, 25, 25, '[{"make":"Toyota","model":"Camry"}]');
  part('PAD_F_T', 'فحمات فرامل أمامية كامري', 'Toyota Genuine', '04465-33471', 320, 190, 12, '[{"make":"Toyota","model":"Camry","from":2018,"to":2024}]');
  part('PAD_F_B', 'فحمات فرامل أمامية كامري تجاري', 'Brembo', 'BRM-P83165', 240, 130, 16, '[{"make":"Toyota","model":"Camry"}]', '04465-33471');
  part('PAD_F_H', 'فحمات فرامل أمامية إلنترا', 'Mobis', '58101-F2A00', 260, 150, 10, '[{"make":"Hyundai","model":"Elantra"}]');
  part('DISC_T', 'هوب فرامل أمامي كامري', 'Toyota Genuine', '43512-06190', 380, 230, 8, '[{"make":"Toyota","model":"Camry"}]');
  part('BRKFL', 'زيت فرامل DOT4 (500 مل)', 'Bosch', 'BSH-DOT4-05', 35, 18, 40);
  part('BATT70', 'بطارية 70 أمبير', 'Varta', 'VRT-570-901', 420, 290, 15);
  part('BATT90', 'بطارية 90 أمبير', 'AC Delco', 'ACD-90-MF', 520, 360, 8);
  part('SPARK', 'بوجيه إيريديوم', 'NGK', 'NGK-ILKAR7B11', 55, 28, 48, '[{"make":"Toyota"},{"make":"Hyundai"},{"make":"Nissan"}]');
  part('WIPER', 'مساحات زجاج أمامي (طقم)', 'Bosch', 'BSH-AERO-A', 95, 50, 20);
  part('COOL', 'سائل تبريد (4 لتر)', 'Prestone', 'PRS-AF-4L', 75, 40, 30);
  part('ACGAS', 'غاز مكيف R134a (كجم)', 'DuPont', 'DP-R134A-1K', 110, 55, 20);
  part('TIRE205', 'إطار 205/55R16', 'Michelin', 'MCH-2055516', 430, 300, 24);
  part('TIRE235', 'إطار 235/60R18', 'Bridgestone', 'BDG-2356018', 610, 430, 16);
  part('ATF', 'زيت ناقل حركة أوتوماتيك (لتر)', 'Toyota Genuine', '08886-02305', 60, 32, 40, '[{"make":"Toyota"}]');
  IF l_lines IS NOT NULL THEN
    l_n := NOONA_INV_PKG.save_stock_doc('{"type":"OPENING","date":"' || TO_CHAR(TRUNC(SYSDATE, 'MM') - 1, 'YYYY-MM-DD') || '","wh":' || l_wh
           || ',"action":"POST","lines":[' || l_lines || ']}');
  END IF;

  -- ------------------------------------------------------------ الفئات والخدمات (الكروت)
  category('OIL', 'زيوت وفلاتر', 'fa-tint', '#e65100', 1);
  category('MECH', 'ميكانيكا وفرامل', 'fa-cogs', '#1565c0', 2);
  category('ELEC', 'كهرباء وبطاريات', 'fa-bolt', '#f9a825', 3);
  category('DIAG', 'فحص وكمبيوتر', 'fa-laptop', '#6a1b9a', 4);
  category('TIRE', 'إطارات وميزان', 'fa-circle-o-notch', '#37474f', 5);
  category('AC', 'تكييف', 'fa-snowflake-o', '#0288d1', 6);
  category('BODY', 'سمكرة ودهان', 'fa-paint-brush', '#c62828', 7);
  category('WASH', 'غسيل وتلميع', 'fa-shower', '#2e7d32', 8);
  service('OIL-SYN', 'OIL', 'تغيير زيت تخليقي مع الفلتر (تويوتا)', 60, 30, 'fa-tint', pp('OILF_T') || ',' || pp('OIL5W30', 4) || ',' || pp('AIRF_T', 1, 'Y'), 180, 10000);
  service('OIL-STD', 'OIL', 'تغيير زيت عادي مع الفلتر (هيونداي/كيا)', 50, 30, 'fa-tint', pp('OILF_H') || ',' || pp('OIL10W40', 4), 90, 5000);
  service('OIL-NIS', 'OIL', 'تغيير زيت مع الفلتر (نيسان)', 50, 30, 'fa-tint', pp('OILF_N') || ',' || pp('OIL5W30', 4), 120, 7500);
  service('ATF', 'OIL', 'تغيير زيت القير', 120, 45, 'fa-exchange', pp('ATF', 4), 365, 40000);
  service('COOL', 'OIL', 'تغيير سائل التبريد', 80, 40, 'fa-thermometer-half', pp('COOL'), 730, 40000);
  service('BRK-F', 'MECH', 'تغيير فحمات أمامية', 150, 60, 'fa-stop-circle', pp('PAD_F_T') || ',' || pp('BRKFL', 1, 'Y'));
  service('BRK-DISC', 'MECH', 'خراطة / تغيير هوبات أمامية', 200, 90, 'fa-dot-circle-o');
  service('SUSP', 'MECH', 'فحص وإصلاح نظام التعليق', 250, 120, 'fa-car');
  service('SPARK', 'MECH', 'تغيير البواجي', 120, 45, 'fa-fire', pp('SPARK', 4), 730, 60000);
  service('BATT', 'ELEC', 'تركيب بطارية وفحص الشحن', 30, 15, 'fa-battery-full', pp('BATT70'));
  service('ELEC', 'ELEC', 'فحص كهرباء وأعطال الأضواء', 150, 60, 'fa-lightbulb-o');
  service('DIAG', 'DIAG', 'فحص كمبيوتر شامل', 150, 30, 'fa-laptop');
  service('INSP', 'DIAG', 'فحص ما قبل الشراء', 300, 90, 'fa-search');
  service('ALIGN', 'TIRE', 'ميزان أذرعة', 120, 40, 'fa-arrows-h', NULL, 180, 10000);
  service('BAL', 'TIRE', 'ترصيص الإطارات (4)', 60, 30, 'fa-circle-o-notch');
  service('TIRE-CH', 'TIRE', 'تركيب إطارات (4)', 80, 40, 'fa-circle', pp('TIRE205', 4, 'Y'));
  service('AC-GAS', 'AC', 'تعبئة غاز المكيف وفحص التسريب', 180, 60, 'fa-snowflake-o', pp('ACGAS') || ',' || pp('ACF_T', 1, 'Y'), 365);
  service('BODY-P', 'BODY', 'سمكرة ودهان قطعة', 650, 480, 'fa-paint-brush', NULL, NULL, NULL, 180);
  service('WASH', 'WASH', 'غسيل داخلي وخارجي', 70, 45, 'fa-shower', NULL, NULL, NULL, 0);
  service('POLISH', 'WASH', 'تلميع ونانو سيراميك', 450, 180, 'fa-diamond', NULL, NULL, NULL, 0);

  -- ------------------------------------------------------------ المركبات وملاكها
  vehicle('V01', 'أ ب ج 1234', 'Toyota', 'Camry', 2021, 'أبيض', 'محمد العتيبي', '0501110001', 45200);
  vehicle('V02', 'د ر س 5678', 'Hyundai', 'Elantra', 2020, 'فضي', 'سارة القحطاني', '0501110002', 61800, 'NAT');
  vehicle('V03', 'ط ع ق 9012', 'Nissan', 'Patrol', 2019, 'أسود', 'شركة النخبة للتجارة', '0501110003', 98400);
  vehicle('V04', 'ك ل م 3456', 'Toyota', 'Corolla', 2018, 'رمادي', 'عبدالله الشهري', '0501110004', 132000, 'GULF');
  vehicle('V05', 'ن ه و 7890', 'Kia', 'Sportage', 2022, 'أحمر', 'نورة الدوسري', '0501110005', 28700);
  vehicle('V06', 'ي أ ب 2468', 'Toyota', 'Land Cruiser', 2020, 'أبيض', 'فهد المطيري', '0501110006', 87600, 'NAT');
  vehicle('V07', 'ج د ر 1357', 'Hyundai', 'Tucson', 2021, 'أزرق', 'خالد الغامدي', '0501110007', 54300);
  vehicle('V08', 'س ط ع 8642', 'Nissan', 'Sunny', 2019, 'أبيض', 'ريم الزهراني', '0501110008', 112500, 'AMAN');
  vehicle('V09', 'ق ك ل 9753', 'Toyota', 'Hilux', 2017, 'أبيض', 'مؤسسة البناء الحديث', '0501110009', 201300);
  vehicle('V10', 'م ن ه 1122', 'Kia', 'K5', 2023, 'أسود', 'سلطان الحربي', '0501110010', 15400);
  vehicle('V11', 'و ي أ 3344', 'Toyota', 'Camry', 2019, 'ذهبي', 'منى السبيعي', '0501110011', 76500);
  vehicle('V12', 'ب ج د 5566', 'Hyundai', 'Accent', 2018, 'أبيض', 'تركي العنزي', '0501110012', 143900);

  -- ------------------------------------------------------------ أوامر منجزة خلال الشهر (مفوترة ومسلمة)
  FOR r IN (SELECT 'V01' v, 45300 odo, sv('OIL-SYN') || ',' || sv('WASH') s, 'KHALED' t, 24 d, 'CASH' m FROM dual UNION ALL
            SELECT 'V05', 28800, TO_CHAR(sv('OIL-STD')), 'KHALED', 22, 'CASH' FROM dual UNION ALL
            SELECT 'V03', 98500, sv('OIL-NIS') || ',' || sv('DIAG'), 'AHMED', 20, 'CREDIT' FROM dual UNION ALL
            SELECT 'V07', 54400, sv('OIL-STD') || ',' || sv('ALIGN') || ',' || sv('BAL'), 'OMAR', 18, 'CASH' FROM dual UNION ALL
            SELECT 'V09', 201400, sv('OIL-SYN') || ',' || sv('BRK-F') || ',' || sv('SUSP'), 'AHMED', 15, 'CREDIT' FROM dual UNION ALL
            SELECT 'V10', 15500, sv('POLISH') || ',' || sv('WASH'), 'OMAR', 13, 'CASH' FROM dual UNION ALL
            SELECT 'V11', 76600, sv('OIL-SYN') || ',' || sv('AC-GAS') || ',' || sv('SPARK'), 'YOUSEF', 11, 'CASH' FROM dual UNION ALL
            SELECT 'V12', 144000, sv('BATT') || ',' || sv('ELEC'), 'SAMI', 9, 'CASH' FROM dual UNION ALL
            SELECT 'V01', 45900, sv('BRK-F') || ',' || sv('BRK-DISC'), 'AHMED', 6, 'CASH' FROM dual UNION ALL
            SELECT 'V05', 29400, sv('DIAG') || ',' || sv('ELEC'), 'SAMI', 4, 'CASH' FROM dual UNION ALL
            SELECT 'V07', 54900, sv('TIRE-CH') || ',' || sv('BAL'), 'OMAR', 2, 'CASH' FROM dual) LOOP
    l_job := open_job(r.v, r.odo, r.s, 'صيانة دورية');
    work(l_job, r.t);
    IF r.s LIKE '%' || sv('TIRE-CH') || '%' THEN l_x := NOONA_AUT_PKG.add_part(l_job, it('TIRE205'), 4); END IF;
    l_inv := NOONA_AUT_PKG.invoice_job(l_job, CASE WHEN r.m = 'CASH' AND l_box <> 'BOX:' THEN '{"place":"' || l_box || '","method":"CASH"}' END);
    NOONA_AUT_PKG.deliver_job(l_job, r.odo + 3);
    backdate(l_job, r.d, 2 + MOD(l_job, 4));
    l_cnt := l_cnt + 1;
  END LOOP;
  -- مطالبة تأمين منجزة: حادث أمامي بتحمل العميل
  l_job := open_job('V04', 132200, sv('BODY-P') || ',' || sv('BRK-F'), 'حادث أمامي - تقرير نجم',
                    ',"payer":"INSURANCE","insurer":' || ins('GULF') || ',"claim":"CLM-24017","accident":"NJM-889120"');
  NOONA_AUT_PKG.set_claim('{"job":' || l_job || ',"claimStatus":"APPROVED","approved":1100}');
  work(l_job, 'HASSAN');
  l_inv := NOONA_AUT_PKG.invoice_job(l_job, CASE WHEN l_box <> 'BOX:' THEN '{"place":"' || l_box || '","method":"CASH"}' END);
  NOONA_AUT_PKG.deliver_job(l_job, 132210);
  backdate(l_job, 8, 26);
  l_cnt := l_cnt + 1;

  -- ------------------------------------------------------------ الوضع الحالي في الورشة
  l_job := open_job('V06', 87900, sv('AC-GAS') || ',' || sv('DIAG'), 'المكيف لا يبرد', ',"bay":' || bay('L1'));
  work(l_job, 'YOUSEF', FALSE);                                   -- قيد العمل
  l_job := open_job('V02', 62100, sv('BRK-F') || ',' || sv('SUSP'), 'صوت في الأمام عند المطبات - مطالبة تأمين',
                    ',"bay":' || bay('L2') || ',"payer":"INSURANCE","insurer":' || ins('NAT') || ',"claim":"CLM-24055","accident":"NJM-901233"');
  l_x := NOONA_AUT_PKG.add_part(l_job, it('PAD_F_H'), 1);
  NOONA_AUT_PKG.set_job_status(l_job, 'WAITING_PARTS');            -- بانتظار موافقة التأمين والقطع
  l_job := open_job('V08', 112700, sv('OIL-NIS') || ',' || sv('WASH'), 'تغيير زيت وغسيل');
  work(l_job, 'KHALED');                                           -- جاهزة للفوترة
  l_job := open_job('V03', 99100, sv('BATT') || ',' || sv('SPARK'), 'السيارة لا تشتغل صباحاً');
  work(l_job, 'SAMI');
  l_inv := NOONA_AUT_PKG.invoice_job(l_job);                       -- مفوترة آجل بانتظار التسليم

  -- ------------------------------------------------------------ الحجوزات
  l_x := NOONA_AUT_PKG.book('{"start":"' || TO_CHAR(TRUNC(SYSDATE) + 1 + 9 / 24, 'YYYY-MM-DD HH24:MI') || '","bay":' || bay('L1') || ',"vehicle":' || ve('V11')
         || ',"name":"منى السبيعي","phone":"0501110011","services":[' || sv('OIL-SYN') || '],"source":"WHATSAPP"}');
  l_x := NOONA_AUT_PKG.book('{"start":"' || TO_CHAR(TRUNC(SYSDATE) + 1 + 11 / 24, 'YYYY-MM-DD HH24:MI') || '","bay":' || bay('L2')
         || ',"plate":"ه و ي 7788","name":"بندر السهلي","phone":"0501110020","services":[' || sv('DIAG') || ',' || sv('ELEC') || '],"source":"PHONE","complaint":"لمبة المحرك مضاءة"}');
  l_x := NOONA_AUT_PKG.book('{"start":"' || TO_CHAR(TRUNC(SYSDATE) + 1 + 13 / 24, 'YYYY-MM-DD HH24:MI') || '","bay":' || bay('L1') || ',"vehicle":' || ve('V12')
         || ',"name":"تركي العنزي","phone":"0501110012","services":[' || sv('ALIGN') || ',' || sv('BAL') || '],"source":"WEB"}');
  IF TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) < 20 THEN
    l_x := NOONA_AUT_PKG.book('{"start":"' || TO_CHAR(SYSDATE + 2 / 24, 'YYYY-MM-DD HH24') || ':00","bay":' || bay('L2') || ',"vehicle":' || ve('V10')
           || ',"name":"سلطان الحربي","phone":"0501110010","services":[' || sv('WASH') || '],"source":"APP"}');
  END IF;

  COMMIT;
  say('مركز خدمة السيارات: ' || sv.COUNT || ' خدمة، ' || it.COUNT || ' قطعة، ' || ve.COUNT || ' مركبة، ' || l_cnt || ' أمر منجز و4 سيارات في الورشة');
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  RAISE;
END;
/
EXIT
