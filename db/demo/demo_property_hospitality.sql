-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية للعقارات والضيافة والصيانة (بعد التحديث 23) - تشغل بحساب NOONA_APP ولا تكرر
-- (تكتشف العقار ذا الرمز DEMO-HTL):
--   sqlplus NOONA_APP@//host:1521/PDB @demo/demo_property_hospitality.sql ADMIN
-- المحتوى:
--   * فندق نونا بلس - الرياض: 4 أدوار × 6 غرف (ديلوكس وأجنحة تنفيذية)، خطة سعر يومي بإفطار وسعر الشركات
--   * شقق نونا الفندقية - جدة: 3 أدوار × 4 شقق غرفتين بخطط يومية وشهرية
--   * عمارة الياسمين السكنية: 5 أدوار × 4 شقق للتأجير (بعضها مؤجر)
--   * تشغيل ثلاثة أيام سابقة بالتدقيق الليلي: نزلاء مقيمون ومغادرون، خدمات ودفعات، تحويل لحساب شركة،
--     وصول اليوم وحجوزات قادمة، غرف تحت التنظيف وغرفة خارج الخدمة
--   * الصيانة: فريقان وفنيون، وبلاغات بكل الحالات والقنوات والأولويات
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

DECLARE
  c_admin CONSTANT VARCHAR2(128) := NVL(UPPER(TRIM('&ADMIN_USER')), 'ADMIN');
  l_co    NUMBER;
  l_n     NUMBER;
  l_htl   NUMBER;
  l_apt   NUMBER;
  l_bld   NUMBER;
  l_dlx   NUMBER;
  l_ste   NUMBER;
  l_a2    NUMBER;
  l_bar   NUMBER;
  l_corp  NUMBER;
  l_mon   NUMBER;
  l_d0    DATE := TRUNC(SYSDATE);
  l_st    NUMBER;
  l_res   NUMBER;
  l_fol   NUMBER;
  l_cmp   NUMBER;
  l_t1    NUMBER;
  l_t2    NUMBER;
  l_x1    NUMBER;
  l_x2    NUMBER;
  l_x3    NUMBER;
  l_req   NUMBER;
  l_room  NUMBER;
  l_unit  NUMBER;
  l_aud   NUMBER;
  TYPE t_ids IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  st      t_ids;

  PROCEDURE say(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
  FUNCTION d(p DATE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD'); END;
  FUNCTION room(p_prop NUMBER, p_no VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM hsp_room WHERE property_id = p_prop AND room_no = p_no;
    RETURN l;
  END room;
  FUNCTION cat(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM mnt_service_category WHERE code = p_code;
    RETURN l;
  END cat;
  FUNCTION walk(p_prop NUMBER, p_room VARCHAR2, p_name VARCHAR2, p_phone VARCHAR2, p_id VARCHAR2, p_nat VARCHAR2, p_nights NUMBER,
                p_plan NUMBER, p_pay NUMBER, p_method VARCHAR2 DEFAULT 'CASH') RETURN NUMBER IS
  BEGIN
    RETURN NOONA_HSP_PKG.walk_in('{"property":' || p_prop || ',"room":' || room(p_prop, p_room) || ',"guest_name":"' || p_name || '","phone":"'
      || p_phone || '","id_type":"' || CASE WHEN p_nat = 'SA' THEN 'NATIONAL_ID' ELSE 'PASSPORT' END || '","id_no":"' || p_id || '","nationality":"'
      || p_nat || '","nights":' || p_nights || ',"rate_plan":' || NVL(TO_CHAR(p_plan), 'null') || ',"adults":2,"pay":' || p_pay || ',"pay_method":"' || p_method
      || '","force":"Y"}');
  END walk;
BEGIN
  NOONA_APEX_PKG.cleanup_request;
  NOONA_APEX_PKG.post_auth(c_admin, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  SELECT COUNT(*) INTO l_n FROM re_property WHERE company_id = l_co AND code = 'DEMO-HTL';
  IF l_n > 0 THEN
    say('بيانات العقارات والضيافة التجريبية محملة سابقاً لهذه الشركة؛ لم يضف شيء.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;
  l_n := NOONA_HSP_PKG.quick_setup;
  l_n := NOONA_MNT_PKG.quick_setup;

  -- ================================================== العقارات
  l_htl := NOONA_RE_PKG.setup_wizard('{"code":"DEMO-HTL","name_ar":"فندق نونا بلس - الرياض","name_en":"Noona Plus Hotel Riyadh","type":"HOTEL",'
    || '"star_rating":4,"address":"الرياض - حي العليا - طريق الملك فهد","phone":"0112345678","license":"TL-1010-4471",'
    || '"description":"فندق أعمال: مطعم، قاعة اجتماعات، نادٍ رياضي، مواقف، واي فاي مجاني","checkin_time":"15:00","checkout_time":"12:00",'
    || '"buildings":[{"code":"A","name":"البرج الرئيسي","floors":4}],'
    || '"units":{"per_floor":6,"unit_type":"ROOM","usage_type":"HOSPITALITY","bedrooms":1,"bathrooms":1,"area":34,"furnishing":"FURNISHED"},'
    || '"hospitality":{"room_type_name":"غرفة ديلوكس","base_rate":420,"max_adults":2}}');
  SELECT MIN(id) INTO l_dlx FROM hsp_room_type WHERE property_id = l_htl;
  l_ste := NOONA_HSP_PKG.save_room_type(NULL, l_htl, 'STE', 'جناح تنفيذي', 3, 1, 'سرير كينج + أريكة سرير', 750);
  UPDATE hsp_room SET room_type_id = l_ste WHERE property_id = l_htl AND room_no LIKE '4%';
  UPDATE re_unit SET unit_type = 'SUITE', name_ar = 'جناح ' || code, net_area_sqm = 62, gross_area_sqm = 62 WHERE property_id = l_htl AND code LIKE '4%';
  l_bar := NOONA_HSP_PKG.save_rate_plan(NULL, l_htl, 'BAR', 'السعر اليومي مع الإفطار', 'DAILY', 'BREAKFAST', 'N', 'إلغاء مجاني قبل 24 ساعة من الوصول');
  l_corp := NOONA_HSP_PKG.save_rate_plan(NULL, l_htl, 'CORP', 'سعر الشركات', 'DAILY', 'BREAKFAST', 'N', 'حسب اتفاقية الشركة');
  l_n := NOONA_HSP_PKG.set_rate(l_bar, l_dlx, l_d0 - 60, l_d0 + 365, 450);
  l_n := NOONA_HSP_PKG.set_rate(l_bar, l_ste, l_d0 - 60, l_d0 + 365, 820);
  l_n := NOONA_HSP_PKG.set_rate(l_corp, l_dlx, l_d0 - 60, l_d0 + 365, 380);
  l_n := NOONA_HSP_PKG.set_rate(l_corp, l_ste, l_d0 - 60, l_d0 + 365, 690);

  l_apt := NOONA_RE_PKG.setup_wizard('{"code":"DEMO-APT","name_ar":"شقق نونا الفندقية - جدة","type":"SERVICED_APARTMENTS",'
    || '"address":"جدة - حي الشاطئ - طريق الكورنيش","phone":"0126543210","description":"شقق مفروشة بمطبخ متكامل، إقامة يومية وشهرية",'
    || '"buildings":[{"code":"A","name":"المبنى أ","floors":3}],'
    || '"units":{"per_floor":4,"unit_type":"APARTMENT","usage_type":"HOSPITALITY","bedrooms":2,"bathrooms":2,"area":95,"furnishing":"FURNISHED"},'
    || '"hospitality":{"room_type_name":"شقة غرفتين وصالة","base_rate":550,"max_adults":4}}');
  SELECT MIN(id) INTO l_a2 FROM hsp_room_type WHERE property_id = l_apt;
  l_n := NOONA_HSP_PKG.save_rate_plan(NULL, l_apt, 'DAY', 'إقامة يومية', 'DAILY', 'ROOM_ONLY', 'Y', 'غير مسترد قبل 48 ساعة');
  l_n := NOONA_HSP_PKG.set_rate(l_n, l_a2, l_d0 - 60, l_d0 + 365, 600);
  l_mon := NOONA_HSP_PKG.save_rate_plan(NULL, l_apt, 'MONTH', 'إقامة شهرية', 'MONTHLY', 'ROOM_ONLY', 'Y', 'إشعار قبل أسبوعين');
  l_n := NOONA_HSP_PKG.set_rate(l_mon, l_a2, l_d0 - 60, l_d0 + 365, 12000);

  l_bld := NOONA_RE_PKG.setup_wizard('{"code":"DEMO-RES","name_ar":"عمارة الياسمين السكنية","type":"BUILDING","address":"الرياض - حي الياسمين",'
    || '"description":"عمارة سكنية: مصعد، مواقف خاصة، حارس","buildings":[{"code":"A","name":"عمارة الياسمين","floors":5,"ground":"N"}],'
    || '"units":{"per_floor":4,"unit_type":"APARTMENT","usage_type":"LEASE","bedrooms":3,"bathrooms":2,"area":140,"furnishing":"UNFURNISHED","price":45000}}');
  UPDATE re_unit SET status_code = 'LEASED' WHERE property_id = l_bld AND MOD(TO_NUMBER(code), 3) <> 0;
  UPDATE re_unit SET status_code = 'UNDER_MAINTENANCE' WHERE property_id = l_bld AND code = '304';
  say('تم إنشاء 3 عقارات: فندق (24 غرفة)، شقق فندقية (12 شقة)، عمارة سكنية (20 شقة)');

  -- ================================================== تشغيل ثلاثة أيام سابقة
  l_cmp := NOONA_PTY_PKG.create_party('ORGANIZATION', 'شركة الأفق للتقنية', 'CUSTOMER');
  UPDATE re_property SET business_date = l_d0 - 3 WHERE id IN (l_htl, l_apt);
  -- اليوم -3
  st(1) := walk(l_htl, '101', 'خالد بن سعد الدوسري', '0551234001', '1023456701', 'SA', 4, l_bar, 900, 'CARD');
  st(2) := walk(l_htl, '102', 'John Smith', '0551234002', 'P8812345', 'GB', 2, l_corp, 0);
  st(3) := walk(l_htl, '401', 'م. فهد العنزي', '0551234003', '1023456703', 'SA', 5, l_bar, 2000, 'BANK_TRANSFER');
  st(4) := walk(l_apt, '101', 'عائلة العمري', '0551234004', '1023456704', 'SA', 30, l_mon, 12000, 'BANK_TRANSFER');
  l_aud := NOONA_HSP_PKG.night_audit(l_htl);
  l_aud := NOONA_HSP_PKG.night_audit(l_apt);
  -- اليوم -2
  st(5) := walk(l_htl, '201', 'أحمد ياسين', '0551234005', '2345678905', 'EG', 3, l_bar, 500);
  st(6) := walk(l_htl, '202', 'سلمان الشهري', '0551234006', '1023456706', 'SA', 2, l_bar, 0);
  st(7) := walk(l_apt, '102', 'Ahmed Raza', '0551234007', 'PK7765432', 'PK', 5, NULL, 1500, 'CARD');
  l_n := NOONA_HSP_PKG.post_charge(NOONA_HSP_PKG.folio_of_stay(st(1)), 'F_AND_B', 'عشاء في المطعم', 180);
  l_n := NOONA_HSP_PKG.post_charge(NOONA_HSP_PKG.folio_of_stay(st(3)), 'LAUNDRY', 'غسيل وكي ملابس', 95);
  l_aud := NOONA_HSP_PKG.night_audit(l_htl);
  l_aud := NOONA_HSP_PKG.night_audit(l_apt);
  -- اليوم -1
  l_fol := NOONA_HSP_PKG.check_out(st(2), l_cmp);            -- يحول لحساب الشركة
  st(8) := walk(l_htl, '301', 'نورة القحطاني', '0551234008', '1023456708', 'SA', 3, l_bar, 1000, 'CARD');
  st(9) := walk(l_htl, '302', 'Maria Garcia', '0551234009', 'ES1122334', 'ES', 2, l_bar, 600, 'CARD');
  l_n := NOONA_HSP_PKG.post_charge(NOONA_HSP_PKG.folio_of_stay(st(5)), 'MINIBAR', 'مشروبات الميني بار', 60);
  NOONA_HSP_PKG.change_departure(st(1), l_d0 + 2);          -- تمديد إقامة
  l_aud := NOONA_HSP_PKG.night_audit(l_htl);
  l_aud := NOONA_HSP_PKG.night_audit(l_apt);

  -- ================================================== اليوم
  -- مغادرة صباحية بعد السداد
  l_fol := NOONA_HSP_PKG.folio_of_stay(st(6));
  IF NOONA_HSP_PKG.folio_balance(l_fol) <> 0 THEN
    l_n := NOONA_HSP_PKG.post_payment(l_fol, NOONA_HSP_PKG.folio_balance(l_fol), 'CASH', NULL, NULL, 'سداد عند المغادرة');
  END IF;
  l_fol := NOONA_HSP_PKG.check_out(st(6));
  -- غرفة 202 تحت التنظيف، 203 جاري تنظيفها
  NOONA_HSP_PKG.set_hk_status(room(l_htl, '203'), 'IN_PROGRESS');
  NOONA_HSP_PKG.set_hk_status(room(l_htl, '104'), 'INSPECTED');
  -- وصول اليوم
  l_res := NOONA_HSP_PKG.create_reservation('{"property":' || l_htl || ',"guest_name":"د. عبدالرحمن الغامدي","phone":"0559876501","id_type":"NATIONAL_ID",'
    || '"id_no":"1098765401","room_type":' || l_dlx || ',"rate_plan":' || l_bar || ',"arrival":"' || d(l_d0) || '","departure":"' || d(l_d0 + 2)
    || '","adults":2,"channel":"OTA","channel_ref":"BKG-559102","deposit":450,"deposit_method":"CARD","requests":"غرفة بعيدة عن المصعد"}');
  l_res := NOONA_HSP_PKG.create_reservation('{"property":' || l_htl || ',"guest_name":"شركة الأفق - م. ريم","phone":"0559876502","room_type":'
    || l_ste || ',"rate_plan":' || l_corp || ',"arrival":"' || d(l_d0) || '","departure":"' || d(l_d0 + 3) || '","adults":1,"channel":"CORPORATE",'
    || '"company_party":' || l_cmp || '}');
  l_res := NOONA_HSP_PKG.create_reservation('{"property":' || l_apt || ',"guest_name":"عائلة الحربي","phone":"0559876503","room_type":' || l_a2
    || ',"arrival":"' || d(l_d0) || '","departure":"' || d(l_d0 + 4) || '","adults":4,"channel":"PHONE","deposit":600}');
  -- حجوزات قادمة
  FOR i IN 1 .. 5 LOOP
    l_res := NOONA_HSP_PKG.create_reservation('{"property":' || l_htl || ',"guest_name":"ضيف قادم ' || i || '","phone":"05598765' || LPAD(i, 2, '0')
      || '","room_type":' || CASE WHEN i = 3 THEN l_ste ELSE l_dlx END || ',"rate_plan":' || l_bar || ',"arrival":"' || d(l_d0 + i) || '","departure":"'
      || d(l_d0 + i + 2) || '","channel":"' || CASE MOD(i, 3) WHEN 0 THEN 'WEBSITE' WHEN 1 THEN 'OTA' ELSE 'PHONE' END || '"}');
  END LOOP;
  say('ضيافة: 3 أيام مدققة، ' || 7 || ' نزلاء مقيمين، مغادرتان، تحويل لحساب شركة، 3 وصول اليوم و5 حجوزات قادمة');

  -- ================================================== الصيانة
  l_t1 := NOONA_MNT_PKG.save_team(NULL, 'HVAC', 'فريق التكييف والكهرباء', 'تكييف مركزي وسبليت، كهرباء وإنارة', '0112345601', NULL);
  l_t2 := NOONA_MNT_PKG.save_team(NULL, 'PLB', 'فريق السباكة والنجارة', 'سباكة، أبواب وأقفال، أثاث', '0112345602', NULL);
  l_x1 := NOONA_MNT_PKG.add_technician(l_t1, NULL, 'م. وليد إبراهيم', 'فني تكييف أول', 75);
  l_x2 := NOONA_MNT_PKG.add_technician(l_t1, NULL, 'سامي حسن', 'كهربائي', 55);
  l_x3 := NOONA_MNT_PKG.add_technician(l_t2, NULL, 'محمد أكرم', 'سباك ونجار', 50);
  -- غرفة خارج الخدمة لحين إصلاح التكييف (قيد التنفيذ)
  l_req := NOONA_MNT_PKG.create_request('{"category":' || cat('HVAC') || ',"priority":"URGENT","title":"المكيف لا يبرد ويسرب ماء",'
    || '"description":"شكوى من نزيل سابق؛ تسريب ماء من وحدة المكيف على السجاد","channel":"FRONT_DESK","room":' || room(l_htl, '303')
    || ',"room_ooo":"Y","reporter_name":"موظف الاستقبال","team":' || l_t1 || ',"technician":' || l_x1 || '}');
  NOONA_MNT_PKG.start_work(l_req);
  -- جديد بانتظار الإسناد
  l_req := NOONA_MNT_PKG.create_request('{"category":' || cat('PLUMBING') || ',"title":"تسريب في حوض المطبخ",'
    || '"description":"تسريب تحت حوض المطبخ في الشقة","channel":"PHONE","room":' || room(l_apt, '101')
    || ',"reporter_name":"عائلة العمري","reporter_phone":"0551234004","chargeable_to":"OWNER"}');
  l_req := NOONA_MNT_PKG.create_request('{"category":' || cat('ELEVATOR') || ',"priority":"EMERGENCY","title":"المصعد متوقف بين الأدوار",'
    || '"description":"توقف المصعد في الدور الثالث؛ لا يوجد عالقون","channel":"PHONE","property":' || l_bld
    || ',"reporter_name":"حارس العمارة","reporter_phone":"0500001111"}');
  -- مسند
  SELECT id INTO l_unit FROM re_unit WHERE property_id = l_bld AND code = '304';
  l_req := NOONA_MNT_PKG.create_request('{"category":' || cat('PAINTING') || ',"priority":"LOW","title":"تجديد دهان قبل التأجير",'
    || '"description":"دهان كامل للشقة بعد إخلاء المستأجر","channel":"INSPECTION","unit":' || l_unit || ',"team":' || l_t2 || '}');
  -- معلق بانتظار قطع غيار
  l_req := NOONA_MNT_PKG.create_request('{"category":' || cat('APPLIANCES') || ',"title":"الثلاجة لا تبرد",'
    || '"description":"ثلاجة الشقة لا تبرد","channel":"APP","room":' || room(l_apt, '102') || ',"reporter_name":"Ahmed Raza"}');
  NOONA_MNT_PKG.assign(l_req, l_t1, l_x2);
  NOONA_MNT_PKG.hold(l_req, 'بانتظار كمبروسر من المورد');
  -- منجز ومغلق بتقييم
  l_req := NOONA_MNT_PKG.create_request('{"category":' || cat('ELECTRICAL') || ',"priority":"HIGH","title":"انقطاع الإنارة في الممر",'
    || '"description":"إنارة ممر الدور الثاني لا تعمل","channel":"INSPECTION","property":' || l_htl || ',"team":' || l_t1 || ',"technician":' || l_x2 || '}');
  NOONA_MNT_PKG.start_work(l_req);
  NOONA_MNT_PKG.complete(l_req, 'تغيير قاطع كهربائي و6 لمبات LED', 2, 180);
  NOONA_MNT_PKG.close_request(l_req, 5);
  l_req := NOONA_MNT_PKG.create_request('{"category":' || cat('CARPENTRY') || ',"title":"باب الحمام لا يغلق",'
    || '"description":"مقبض باب الحمام مكسور","channel":"FRONT_DESK","room":' || room(l_htl, '102') || ',"team":' || l_t2 || ',"technician":' || l_x3 || '}');
  NOONA_MNT_PKG.complete(l_req, 'تركيب مقبض جديد وضبط المفصلات', 1, 65);
  say('صيانة: فريقان و3 فنيين، 7 بلاغات (جديد، طارئ، مسند، قيد التنفيذ بغرفة موقوفة، معلق، منجز، مغلق بتقييم)');

  COMMIT;
  say('');
  say('تم تحميل بيانات العقارات والضيافة التجريبية. افتح «العقارات والضيافة» ← لوحة الاستقبال.');
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  RAISE;
END;
/
EXIT
