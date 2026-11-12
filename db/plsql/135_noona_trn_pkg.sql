-- =============================================================================
-- NOONA PLUS ERP | NOONA_TRN_PKG - النقل والشحن والترحيل (التطبيق 147 NOONA_TRN)
--   * الأسطول (العربات بحمولتها وتراخيصها) والسائقون (الرخص والمواد الخطرة)، المدن والمواقع، المسارات بالمسافة والزمن
--   * أنواع الشحنات ووحداتها؛ التحويل بين الطن المتري والقصير والطويل والكيلوجرام
--   * تعرفة الترحيل: لكل طن متري/قصير/طويل، كجم، م³، لتر، كم، طن-كم، رحلة، حاوية، طبلية، قطعة؛ أدنى ترحيل؛ أولوية الأخص
--   * أمر الشحن: التسعير التلقائي، التأكيد، التحميل على الرحلة، التسليم والعجز والأضرار والمستلم، الفوترة في المبيعات
--   * الرحلة: التحقق من التوفر والرخص والتأمين والحمولة ونوع العربة والمواد الخطرة، زمن الوصول المتوقع من المسار ونقاط
--     التوقف والتأخير، التحرك والوصول والإقفال بالعداد والوقود، المصروفات، وتحديث حالة العربة والسائق
--   * الأعطال والبلاغات: التسجيل والاستلام والاستجابة والحل، زمن الاستجابة، مدة التوقف تؤخر الوصول المتوقع، التكلفة مصروف رحلة
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_TRN_PKG AUTHID DEFINER AS
  c_rev CONSTANT VARCHAR2(10) := '4170';
  FUNCTION company RETURN NUMBER;
  FUNCTION qf(p IN NUMBER) RETURN VARCHAR2;

  -- التجهيز: حساب إيرادات النقل وأنواع شحنات افتراضية
  FUNCTION quick_setup RETURN NUMBER;
  FUNCTION is_ready RETURN VARCHAR2;

  -- البيانات الأساسية (JSON؛ "id" للتعديل)
  FUNCTION save_location(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION save_route(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION save_cargo_type(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION save_vehicle(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE set_vehicle_status(p_id IN NUMBER, p_status IN VARCHAR2);
  FUNCTION save_driver(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE set_driver_status(p_id IN NUMBER, p_status IN VARCHAR2);
  FUNCTION save_rate(p_doc IN CLOB) RETURN NUMBER;

  -- الوحدات والترحيل
  FUNCTION to_kg(p_qty IN NUMBER, p_uom IN VARCHAR2) RETURN NUMBER;
  FUNCTION convert_weight(p_qty IN NUMBER, p_from IN VARCHAR2, p_to IN VARCHAR2) RETURN NUMBER;
  FUNCTION freight(p_basis IN VARCHAR2, p_rate IN NUMBER, p_qty IN NUMBER, p_uom IN VARCHAR2, p_weight_kg IN NUMBER,
                   p_volume IN NUMBER, p_distance IN NUMBER, p_min IN NUMBER DEFAULT NULL) RETURN NUMBER;
  FUNCTION find_rate(p_customer IN NUMBER, p_route IN NUMBER, p_cargo IN NUMBER, p_date IN DATE DEFAULT NULL) RETURN NUMBER;
  FUNCTION find_route(p_from IN NUMBER, p_to IN NUMBER) RETURN NUMBER;
  -- {"customer","from","to","cargo","qty","uom","weightKg","volume","rateId"|"basis"+"rate"} ← {rateId,basis,rate,weightKg,distanceKm,freight}
  FUNCTION quote_json(p_doc IN CLOB) RETURN CLOB;

  -- أوامر الشحن
  FUNCTION save_order(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE confirm_order(p_id IN NUMBER);
  PROCEDURE cancel_order(p_id IN NUMBER, p_reason IN VARCHAR2);

  -- الرحلات
  -- {"vehicle","driver","coDriver","from","to","route","departure":"YYYY-MM-DD HH24:MI","orders":[ids],"notes"}
  FUNCTION create_trip(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE add_order(p_trip_id IN NUMBER, p_order_id IN NUMBER);
  PROCEDURE remove_order(p_trip_id IN NUMBER, p_order_id IN NUMBER);
  FUNCTION add_stop(p_trip_id IN NUMBER, p_location_id IN NUMBER, p_purpose IN VARCHAR2, p_minutes IN NUMBER DEFAULT 0,
                    p_sort IN NUMBER DEFAULT NULL) RETURN NUMBER;
  PROCEDURE remove_stop(p_stop_id IN NUMBER);
  PROCEDURE depart(p_trip_id IN NUMBER, p_odometer IN NUMBER DEFAULT NULL, p_at IN TIMESTAMP DEFAULT NULL);
  PROCEDURE stop_arrive(p_stop_id IN NUMBER, p_at IN TIMESTAMP DEFAULT NULL);
  PROCEDURE stop_depart(p_stop_id IN NUMBER, p_at IN TIMESTAMP DEFAULT NULL);
  PROCEDURE arrive(p_trip_id IN NUMBER, p_at IN TIMESTAMP DEFAULT NULL);
  -- التسليم والتفريغ: الكمية المسلمة (والعجز تلقائياً) والمستلم والأضرار
  PROCEDURE deliver_order(p_trip_id IN NUMBER, p_order_id IN NUMBER, p_delivered_qty IN NUMBER, p_receiver IN VARCHAR2,
                          p_damage IN VARCHAR2 DEFAULT NULL, p_at IN TIMESTAMP DEFAULT NULL);
  PROCEDURE complete_trip(p_trip_id IN NUMBER, p_odometer_end IN NUMBER, p_fuel_liters IN NUMBER DEFAULT NULL);
  PROCEDURE cancel_trip(p_trip_id IN NUMBER, p_reason IN VARCHAR2);
  FUNCTION add_expense(p_trip_id IN NUMBER, p_type IN VARCHAR2, p_amount IN NUMBER, p_liters IN NUMBER DEFAULT NULL,
                       p_date IN DATE DEFAULT NULL, p_ref IN VARCHAR2 DEFAULT NULL, p_notes IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  -- زمن الوصول المتوقع: التحرك + الزمن القياسي + التوقفات المخططة + التأخير
  FUNCTION eta_of(p_trip_id IN NUMBER) RETURN TIMESTAMP;
  PROCEDURE recalc_trip(p_trip_id IN NUMBER);
  -- ON_TIME | LATE | EARLY | AT_RISK (لم تصل وتجاوزت الوقت المتوقع)
  FUNCTION timeliness(p_trip_id IN NUMBER) RETURN VARCHAR2;

  -- الأعطال والبلاغات
  -- {"trip","vehicle","driver","type","severity","description","location","locationText","reportedBy","at"}
  FUNCTION report_incident(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE acknowledge_incident(p_id IN NUMBER, p_assigned_to IN VARCHAR2);
  PROCEDURE respond_incident(p_id IN NUMBER, p_action IN VARCHAR2);
  PROCEDURE resolve_incident(p_id IN NUMBER, p_action IN VARCHAR2, p_downtime_minutes IN NUMBER, p_cost IN NUMBER DEFAULT NULL);
  PROCEDURE close_incident(p_id IN NUMBER);

  -- الفوترة: أوامر مسلمة لعميل واحد ← فاتورة مبيعات آجلة مرحلة
  FUNCTION invoice_orders(p_order_ids IN VARCHAR2) RETURN NUMBER;

  -- الواجهة
  -- ---------------------------------------------------------- صيانة الأسطول
  -- برنامج دوري: JSON id, service, vehicle (فارغ = كل العربات)، vehicleType، everyKm، everyDays، cost، status، notes
  FUNCTION save_maint_plan(p_doc IN CLOB) RETURN NUMBER;
  -- أمر صيانة: JSON vehicle, type, plan, incident, workshop (INTERNAL|EXTERNAL), vendor, warehouse (مستودع قطع الغيار)، description, odometer, notes
  --   تدخل العربة «في الصيانة» ولا تسند لرحلة حتى الإقفال
  FUNCTION open_maint(p_doc IN CLOB) RETURN NUMBER;
  -- p_type: PART | LABOR | OIL | TIRE | OTHER ؛ الصنف المخزني يصرف فوراً من مستودع الأمر بالمتوسط المرجح
  --   (قيد: صيانة تحت التنفيذ 1116 / المخزون)، وحذف بنده يعيده للمخزون
  FUNCTION add_maint_line(p_order_id IN NUMBER, p_type IN VARCHAR2, p_desc IN VARCHAR2, p_qty IN NUMBER, p_unit_cost IN NUMBER,
                          p_item_id IN NUMBER DEFAULT NULL, p_life_km IN NUMBER DEFAULT NULL, p_life_days IN NUMBER DEFAULT NULL) RETURN NUMBER;
  PROCEDURE remove_maint_line(p_line_id IN NUMBER);
  -- الإقفال: JSON date, odometer, downtimeHours, treatment (EXPENSE|CAPITALIZE)، lifeExtension (أشهر)، vat,
  --   funding (BANK|CASH|PAYABLE|ACCOUNT)، bankAccount, cashBox, account, vendor (للآجل في الورشة الداخلية)، reference
  --   يرحل التكلفة عبر صيانة الأصول: مصروف صيانة، أو إضافة رأسمالية على أصل العربة مع تمديد عمرها؛ تعود العربة متاحة
  PROCEDURE complete_maint(p_order_id IN NUMBER, p_doc IN CLOB);
  PROCEDURE cancel_maint(p_order_id IN NUMBER, p_reason IN VARCHAR2);
  FUNCTION maint_type_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  -- الصيانات الدورية المستحقة حسب الكيلومترات أو الأيام لكل عربة
  FUNCTION maint_due_html RETURN CLOB;
  FUNCTION maint_due_count RETURN NUMBER;
  FUNCTION maint_order_status(p_id IN NUMBER) RETURN VARCHAR2;
  -- عمر الاستبدال الافتراضي للصنف (زيت كل 10,000 كم، إطار كل 60,000 كم، بطارية كل 730 يوماً...)
  PROCEDURE set_part_life(p_item_id IN NUMBER, p_km IN NUMBER, p_days IN NUMBER);
  -- تنبيهات الصيانة (مهمة يومية NOONA_TRN_MAINT_ALERTS): القطع التي اقترب أو حان موعد استبدالها بالمسافة أو بالمدة
  --   (الإطارات بالأقرب منهما، البطاريات بالمدة) والصيانات الدورية المستحقة؛ إشعار داخل النظام لمسؤولي الأسطول
  --   (مدير المؤسسة ومن له صلاحية أوامر الصيانة)، مرة عند الاقتراب ومرة عند التجاوز، وملخص بالبريد إن كان مفعلاً
  FUNCTION run_maint_alerts(p_company_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
  -- مصروفات قطع الغيار والزيوت والإطارات لكل عربة خلال فترة، والعمر الفعلي للقطعة بين استبدالين
  FUNCTION parts_report_html(p_from IN DATE, p_to IN DATE, p_vehicle_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  -- أداء العربات: الرحلات والكيلومترات والوقود والأعطال وتكلفة الصيانة لكل كيلومتر
  FUNCTION vehicle_perf_html(p_from IN DATE, p_to IN DATE, p_vehicle_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  -- أداء السائقين: الرحلات والكيلومترات والوقود والحوادث والأعطال، وتكلفة الصيانة المنسوبة (مباشرة من بلاغاته،
  --   وموزعة من إصلاح الأعطال حسب كيلومتراته على كل عربة)
  FUNCTION driver_perf_html(p_from IN DATE, p_to IN DATE) RETURN CLOB;
  FUNCTION maint_order_html(p_order_id IN NUMBER) RETURN CLOB;
  -- تكلفة الصيانة لكل عربة: العدد والتكلفة والتوقف والتكلفة لكل كيلومتر (من تاريخ)
  FUNCTION maint_cost_html(p_from IN DATE DEFAULT NULL) RETURN CLOB;

  FUNCTION status_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION badge(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION uom_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION basis_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION board_html RETURN CLOB;
  -- عملاء شحنات الرحلة (أسماء مختصرة مفصولة بفاصلة)
  FUNCTION trip_customers(p_trip_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION trip_html(p_trip_id IN NUMBER) RETURN CLOB;
  FUNCTION order_label(p_order_id IN NUMBER) RETURN VARCHAR2;
  -- حالة المستند للشاشات (شروط العرض)
  FUNCTION incident_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION severity_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION order_status(p_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION trip_status(p_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION incident_status(p_id IN NUMBER) RETURN VARCHAR2;
  -- شاشات السائق على الهاتف
  FUNCTION my_driver RETURN NUMBER;
  FUNCTION driver_trips_html(p_driver_id IN NUMBER, p_trip_url IN VARCHAR2) RETURN CLOB;
  FUNCTION driver_trip_html(p_trip_id IN NUMBER) RETURN CLOB;
  -- {"trip","order","receiver","phone","qty","damage","photo":"data:image/jpeg;base64,...","signature":"data:image/png;base64,...","lat","lng","notes"}
  FUNCTION save_pod(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION trip_status(p_trip_id IN NUMBER) RETURN VARCHAR2;
END NOONA_TRN_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_TRN_PKG AS

  c_ord  CONSTANT VARCHAR2(30) := 'TRN_ORDER';
  c_trip CONSTANT VARCHAR2(30) := 'TRN_TRIP';
  c_inc  CONSTANT VARCHAR2(30) := 'TRN_INCIDENT';
  c_short CONSTANT NUMBER := 907.18474;
  c_long  CONSTANT NUMBER := 1016.0469088;

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION jt(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_CORE_PKG.json_text(p); END jt;
  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(TO_CHAR(NVL(p, 0), 'FM999,999,999,990.00', 'NLS_NUMERIC_CHARACTERS=''.,'''));
  END fmt;
  FUNCTION qf(p IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN RTRIM(RTRIM(TO_CHAR(NVL(p, 0), 'FM999,999,999,990.999', 'NLS_NUMERIC_CHARACTERS=''.,'''), '0'), '.');
  END qf;
  FUNCTION num(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL THEN 'null' ELSE RTRIM(TO_CHAR(p, 'FM9999999999990.999999', 'NLS_NUMERIC_CHARACTERS=''.,'''), '.') END;
  END num;
  FUNCTION ts(p TIMESTAMP) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD HH24:MI'); END ts;

  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    IF p_permission NOT LIKE '%.VIEW' THEN
      NOONA_CORE_PKG.assert_tenant_writable;
    END IF;
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  FUNCTION js(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_k) AND NOT p_o.get(p_k).is_null THEN TRIM(p_o.get_string(p_k)) END;
  END js;
  FUNCTION jn(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_k) AND NOT p_o.get(p_k).is_null THEN p_o.get_number(p_k) END;
  EXCEPTION WHEN OTHERS THEN
    RETURN TO_NUMBER(REPLACE(p_o.get_string(p_k), ',', ''));
  END jn;
  FUNCTION jd(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN DATE IS
  BEGIN
    RETURN TO_DATE(SUBSTR(js(p_o, p_k), 1, 10), 'YYYY-MM-DD');
  END jd;
  FUNCTION jts(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN TIMESTAMP IS
    l VARCHAR2(40) := REPLACE(js(p_o, p_k), 'T', ' ');
  BEGIN
    IF l IS NULL THEN RETURN NULL; END IF;
    RETURN TO_TIMESTAMP(SUBSTR(l, 1, 16), 'YYYY-MM-DD HH24:MI');
  END jts;

  FUNCTION next_no(p_type VARCHAR2, p_prefix VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT company, p_type, NULL, p_prefix, 1, 6, 'N', 'NEVER', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = p_type);
    RETURN NOONA_REFERENCE_PKG.next_doc_no(p_type, company, NULL, TRUNC(SYSDATE), p_type, NULL);
  END next_no;

  -- ================================================================ التسميات
  FUNCTION status_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code
      WHEN 'DRAFT' THEN 'مسودة' WHEN 'CONFIRMED' THEN 'مؤكد' WHEN 'PLANNED' THEN 'مجدول' WHEN 'DISPATCHED' THEN 'مرسل'
      WHEN 'IN_TRANSIT' THEN 'في الطريق' WHEN 'ARRIVED' THEN 'وصلت' WHEN 'DELIVERED' THEN 'سُلّم' WHEN 'INVOICED' THEN 'مفوتر'
      WHEN 'COMPLETED' THEN 'مكتملة' WHEN 'CANCELLED' THEN 'ملغى' WHEN 'AVAILABLE' THEN 'متاح' WHEN 'ON_TRIP' THEN 'في رحلة'
      WHEN 'MAINTENANCE' THEN 'في الصيانة' WHEN 'OUT_OF_SERVICE' THEN 'خارج الخدمة' WHEN 'SOLD' THEN 'مباعة'
      WHEN 'OFF_DUTY' THEN 'خارج الدوام' WHEN 'SUSPENDED' THEN 'موقوف' WHEN 'LEFT' THEN 'ترك العمل'
      WHEN 'REPORTED' THEN 'مُبلّغ' WHEN 'ACKNOWLEDGED' THEN 'مستلم' WHEN 'IN_PROGRESS' THEN 'قيد المعالجة' WHEN 'RESOLVED' THEN 'تم الحل'
      WHEN 'CLOSED' THEN 'مغلق' WHEN 'ON_TIME' THEN 'في الموعد' WHEN 'LATE' THEN 'متأخرة' WHEN 'EARLY' THEN 'مبكرة'
      WHEN 'AT_RISK' THEN 'تجاوزت الموعد' WHEN 'ACTIVE' THEN 'نشطة' WHEN 'INACTIVE' THEN 'موقوفة'
      WHEN 'OPEN' THEN 'مفتوح' WHEN 'PAUSED' THEN 'متوقف مؤقتاً'
      ELSE p_code END;
  END status_label;

  FUNCTION badge(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<span class="nn-badge ' || CASE
             WHEN p_code IN ('DELIVERED', 'COMPLETED', 'AVAILABLE', 'RESOLVED', 'CLOSED', 'ON_TIME', 'EARLY', 'INVOICED', 'ACTIVE') THEN 'is-success'
             WHEN p_code IN ('IN_TRANSIT', 'DISPATCHED', 'ON_TRIP', 'CONFIRMED', 'PLANNED', 'ACKNOWLEDGED', 'IN_PROGRESS', 'ARRIVED', 'OPEN') THEN 'is-info'
             WHEN p_code IN ('MAINTENANCE', 'REPORTED', 'LATE', 'OFF_DUTY', 'DRAFT', 'PAUSED') THEN 'is-warning'
             WHEN p_code IN ('CANCELLED', 'OUT_OF_SERVICE', 'SUSPENDED', 'AT_RISK', 'LEFT', 'SOLD', 'INACTIVE') THEN 'is-danger' ELSE 'is-muted' END
        || '">' || esc(status_label(p_code)) || '</span>';
  END badge;

  FUNCTION uom_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'METRIC_TON' THEN 'طن متري' WHEN 'SHORT_TON' THEN 'طن قصير' WHEN 'LONG_TON' THEN 'طن طويل' WHEN 'KG' THEN 'كجم'
      WHEN 'M3' THEN 'م³' WHEN 'LITER' THEN 'لتر' WHEN 'CONTAINER' THEN 'حاوية' WHEN 'PALLET' THEN 'طبلية' WHEN 'PIECE' THEN 'قطعة'
      WHEN 'TRIP' THEN 'رحلة' ELSE p_code END;
  END uom_label;

  FUNCTION basis_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'PER_METRIC_TON' THEN 'للطن المتري' WHEN 'PER_SHORT_TON' THEN 'للطن القصير' WHEN 'PER_LONG_TON' THEN 'للطن الطويل'
      WHEN 'PER_KG' THEN 'للكيلوجرام' WHEN 'PER_M3' THEN 'للمتر المكعب' WHEN 'PER_LITER' THEN 'للتر' WHEN 'PER_KM' THEN 'للكيلومتر'
      WHEN 'PER_TON_KM' THEN 'للطن-كيلومتر' WHEN 'PER_TRIP' THEN 'للرحلة' WHEN 'PER_CONTAINER' THEN 'للحاوية' WHEN 'PER_PALLET' THEN 'للطبلية'
      WHEN 'PER_PIECE' THEN 'للقطعة' ELSE p_code END;
  END basis_label;

  -- ================================================================ التجهيز
  FUNCTION is_ready RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN NOONA_INV_PKG.acc_id(c_rev) IS NOT NULL THEN 'Y' ELSE 'N' END;
  END is_ready;

  FUNCTION quick_setup RETURN NUMBER IS
    l_n NUMBER;
    PROCEDURE ct(k VARCHAR2, n VARCHAR2, c VARCHAR2, u VARCHAR2, v VARCHAR2 DEFAULT NULL) IS
    BEGIN
      INSERT INTO trn_cargo_type (company_id, code, name_ar, cargo_category, default_unit, required_vehicle_type)
      VALUES (company, k, n, c, u, v);
    END ct;
  BEGIN
    guard('TRN_CARGO_TYPE.CREATE');
    IF NOONA_INV_PKG.acc_id(c_rev) IS NULL THEN
      l_n := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, c_rev, 'إيرادات النقل والشحن', '4', 'REVENUE', 'Y', NULL);
    END IF;
    SELECT COUNT(*) INTO l_n FROM trn_cargo_type WHERE company_id = company;
    IF l_n = 0 THEN
      ct('GEN', 'بضائع عامة', 'GENERAL', 'METRIC_TON');
      ct('BULK', 'بضائع سائبة (أسمنت، حبوب، رمل)', 'BULK', 'METRIC_TON', 'TIPPER');
      ct('FUEL', 'وقود ومواد سائلة', 'LIQUID', 'LITER', 'TANKER');
      ct('COLD', 'مبردة ومجمدة', 'REFRIGERATED', 'METRIC_TON', 'REFRIGERATED');
      ct('CONT', 'حاويات', 'CONTAINER', 'CONTAINER', 'CONTAINER_CARRIER');
      ct('HAZ', 'مواد خطرة', 'HAZARDOUS', 'METRIC_TON');
      ct('HEAVY', 'معدات ثقيلة', 'OVERSIZED', 'PIECE', 'LOWBED');
    END IF;
    SELECT COUNT(*) INTO l_n FROM trn_cargo_type WHERE company_id = company;
    RETURN l_n;
  END quick_setup;

  -- ================================================================ البيانات الأساسية
  FUNCTION save_location(p_doc IN CLOB) RETURN NUMBER IS
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    x_lat_jn NUMBER;
    x_lng_jn NUMBER;
    x_address_js VARCHAR2(4000);
    x_city_js VARCHAR2(4000);
    x_code_js VARCHAR2(4000);
    x_contact_js VARCHAR2(4000);
    x_country_js VARCHAR2(4000);
    x_name_js VARCHAR2(4000);
    x_phone_js VARCHAR2(4000);
    x_region_js VARCHAR2(4000);
    x_type_js VARCHAR2(4000);
    l_id NUMBER := jn(l_o, 'id');
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'TRN_LOCATION.CREATE' ELSE 'TRN_LOCATION.UPDATE' END);
    NOONA_CORE_PKG.assert(js(l_o, 'code') IS NOT NULL AND js(l_o, 'name') IS NOT NULL, 'NOONA-TRN-001', 'رمز الموقع واسمه مطلوبان', 'Code and name required');
    IF l_id IS NULL THEN
      x_lat_jn := jn(l_o, 'lat');
      x_lng_jn := jn(l_o, 'lng');
      x_address_js := js(l_o, 'address');
      x_city_js := js(l_o, 'city');
      x_code_js := js(l_o, 'code');
      x_contact_js := js(l_o, 'contact');
      x_country_js := js(l_o, 'country');
      x_name_js := js(l_o, 'name');
      x_phone_js := js(l_o, 'phone');
      x_region_js := js(l_o, 'region');
      x_type_js := js(l_o, 'type');
      INSERT INTO trn_location (company_id, code, name_ar, location_type, city_name, region_name, country_code, address_text, latitude, longitude,
                                contact_name, phone)
      VALUES (company, UPPER(x_code_js), x_name_js, NVL(x_type_js, 'CITY'), NVL(x_city_js, x_name_js),
              x_region_js, x_country_js, x_address_js, x_lat_jn, x_lng_jn, x_contact_js, x_phone_js)
      RETURNING id INTO l_id;
    ELSE
      x_lat_jn := jn(l_o, 'lat');
      x_lng_jn := jn(l_o, 'lng');
      x_address_js := js(l_o, 'address');
      x_city_js := js(l_o, 'city');
      x_contact_js := js(l_o, 'contact');
      x_country_js := js(l_o, 'country');
      x_name_js := js(l_o, 'name');
      x_phone_js := js(l_o, 'phone');
      x_region_js := js(l_o, 'region');
      x_type_js := js(l_o, 'type');
      UPDATE trn_location SET name_ar = x_name_js, location_type = NVL(x_type_js, location_type), city_name = x_city_js,
             region_name = x_region_js, country_code = x_country_js, address_text = x_address_js,
             latitude = x_lat_jn, longitude = x_lng_jn, contact_name = x_contact_js, phone = x_phone_js
       WHERE id = l_id AND company_id = company;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-TRN-002', 'الموقع غير موجود', 'Location not found');
    END IF;
    RETURN l_id;
  END save_location;

  FUNCTION find_route(p_from IN NUMBER, p_to IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN from_location_id = p_from THEN 0 ELSE 1 END, id) INTO l
      FROM trn_route
     WHERE company_id = company AND is_active = 'Y'
       AND ((from_location_id = p_from AND to_location_id = p_to) OR (from_location_id = p_to AND to_location_id = p_from));
    RETURN l;
  END find_route;

  FUNCTION save_route(p_doc IN CLOB) RETURN NUMBER IS
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    x_toll_jn NUMBER;
    x_code_js VARCHAR2(4000);
    x_name_js VARCHAR2(4000);
    x_roadType_js VARCHAR2(4000);
    l_id NUMBER := jn(l_o, 'id');
    l_f  NUMBER := jn(l_o, 'from');
    l_t  NUMBER := jn(l_o, 'to');
    l_d  NUMBER := jn(l_o, 'distance');
    l_h  NUMBER := jn(l_o, 'hours');
    l_n  NUMBER;
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'TRN_ROUTE.CREATE' ELSE 'TRN_ROUTE.UPDATE' END);
    NOONA_CORE_PKG.assert(l_f IS NOT NULL AND l_t IS NOT NULL AND l_f <> l_t, 'NOONA-TRN-003', 'اختر مدينتين مختلفتين للمسار', 'Choose two different locations');
    NOONA_CORE_PKG.assert(NVL(l_d, 0) > 0, 'NOONA-TRN-004', 'المسافة بالكيلومتر مطلوبة', 'Distance required');
    -- الزمن القياسي الافتراضي بسرعة متوسطة 70 كم/س
    l_h := NVL(l_h, ROUND(l_d / 70, 1));
    NOONA_CORE_PKG.assert(l_h > 0, 'NOONA-TRN-005', 'زمن الرحلة القياسي مطلوب', 'Standard hours required');
    SELECT COUNT(*) INTO l_n FROM trn_location WHERE id IN (l_f, l_t) AND company_id = company;
    NOONA_CORE_PKG.assert(l_n = 2, 'NOONA-TRN-002', 'الموقع غير موجود', 'Location not found');
    IF l_id IS NULL THEN
      x_toll_jn := jn(l_o, 'toll');
      x_code_js := js(l_o, 'code');
      x_name_js := js(l_o, 'name');
      x_roadType_js := js(l_o, 'roadType');
      INSERT INTO trn_route (company_id, code, name_ar, from_location_id, to_location_id, distance_km, standard_hours, toll_amount, road_type)
      VALUES (company, NVL(UPPER(x_code_js), 'R' || l_f || '-' || l_t),
              NVL(x_name_js, (SELECT name_ar FROM trn_location WHERE id = l_f) || ' ← ' || (SELECT name_ar FROM trn_location WHERE id = l_t)),
              l_f, l_t, l_d, l_h, x_toll_jn, NVL(x_roadType_js, 'HIGHWAY'))
      RETURNING id INTO l_id;
    ELSE
      x_toll_jn := jn(l_o, 'toll');
      x_name_js := js(l_o, 'name');
      x_roadType_js := js(l_o, 'roadType');
      UPDATE trn_route SET name_ar = NVL(x_name_js, name_ar), from_location_id = l_f, to_location_id = l_t, distance_km = l_d,
             standard_hours = l_h, toll_amount = x_toll_jn, road_type = NVL(x_roadType_js, road_type)
       WHERE id = l_id AND company_id = company;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-TRN-006', 'المسار غير موجود', 'Route not found');
    END IF;
    RETURN l_id;
  END save_route;

  FUNCTION save_cargo_type(p_doc IN CLOB) RETURN NUMBER IS
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    x_category_js VARCHAR2(4000);
    x_code_js VARCHAR2(4000);
    x_handling_js VARCHAR2(4000);
    x_hazardClass_js VARCHAR2(4000);
    x_name_js VARCHAR2(4000);
    x_unit_js VARCHAR2(4000);
    x_vehicleType_js VARCHAR2(4000);
    l_id NUMBER := jn(l_o, 'id');
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'TRN_CARGO_TYPE.CREATE' ELSE 'TRN_CARGO_TYPE.UPDATE' END);
    NOONA_CORE_PKG.assert(js(l_o, 'code') IS NOT NULL AND js(l_o, 'name') IS NOT NULL, 'NOONA-TRN-001', 'الرمز والاسم مطلوبان', 'Code and name required');
    IF l_id IS NULL THEN
      x_category_js := js(l_o, 'category');
      x_code_js := js(l_o, 'code');
      x_handling_js := js(l_o, 'handling');
      x_hazardClass_js := js(l_o, 'hazardClass');
      x_name_js := js(l_o, 'name');
      x_unit_js := js(l_o, 'unit');
      x_vehicleType_js := js(l_o, 'vehicleType');
      INSERT INTO trn_cargo_type (company_id, code, name_ar, cargo_category, default_unit, required_vehicle_type, hazard_class, handling_notes)
      VALUES (company, UPPER(x_code_js), x_name_js, NVL(x_category_js, 'GENERAL'), NVL(x_unit_js, 'METRIC_TON'),
              x_vehicleType_js, x_hazardClass_js, x_handling_js)
      RETURNING id INTO l_id;
    ELSE
      x_category_js := js(l_o, 'category');
      x_handling_js := js(l_o, 'handling');
      x_hazardClass_js := js(l_o, 'hazardClass');
      x_name_js := js(l_o, 'name');
      x_unit_js := js(l_o, 'unit');
      x_vehicleType_js := js(l_o, 'vehicleType');
      UPDATE trn_cargo_type SET name_ar = x_name_js, cargo_category = NVL(x_category_js, cargo_category),
             default_unit = NVL(x_unit_js, default_unit), required_vehicle_type = x_vehicleType_js,
             hazard_class = x_hazardClass_js, handling_notes = x_handling_js
       WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  END save_cargo_type;

  -- العربة المملوكة تسجل أصلاً ثابتاً في فئة «السيارات ووسائل النقل» وترسمل بقيد الاقتناء (حسب مصدر التمويل)
  FUNCTION vehicle_asset(p_o JSON_OBJECT_T, p_plate VARCHAR2, p_type VARCHAR2) RETURN NUMBER IS
    l_cost NUMBER := jn(p_o, 'purchaseCost');
    l_cat  NUMBER;
    l_n    NUMBER;
    l_d    JSON_OBJECT_T := JSON_OBJECT_T();
  BEGIN
    NOONA_CORE_PKG.assert(NVL(l_cost, 0) > 0, 'NOONA-TRN-060',
      'العربة المملوكة تضاف للأصول الثابتة: أدخل تكلفة الشراء أو اختر أصلاً مسجلاً', 'Purchase cost required for an owned vehicle');
    SELECT MIN(id) INTO l_cat FROM fa_category WHERE company_id = company AND code = 'VEHICLES' AND is_active = 'Y';
    IF l_cat IS NULL THEN
      l_n := NOONA_FA_PKG.quick_setup;
      SELECT MIN(id) INTO l_cat FROM fa_category WHERE company_id = company AND code = 'VEHICLES' AND is_active = 'Y';
    END IF;
    NOONA_CORE_PKG.assert(l_cat IS NOT NULL, 'NOONA-TRN-061', 'فئة الأصول «السيارات ووسائل النقل» غير موجودة', 'VEHICLES asset category missing');
    l_d.put('name_ar', CASE p_type WHEN 'TRAILER' THEN 'مقطورة' WHEN 'TANKER' THEN 'صهريج' WHEN 'PICKUP' THEN 'سيارة نقل خفيف'
                         WHEN 'VAN' THEN 'سيارة فان' ELSE 'شاحنة' END || ' ' || p_plate
                       || CASE WHEN js(p_o, 'make') IS NOT NULL THEN ' - ' || js(p_o, 'make') || ' ' || js(p_o, 'model') END);
    l_d.put('category', l_cat);
    l_d.put('cost', l_cost);
    l_d.put('acquisition_date', TO_CHAR(NVL(jd(p_o, 'purchaseDate'), TRUNC(SYSDATE)), 'YYYY-MM-DD'));
    l_d.put('funding', NVL(js(p_o, 'funding'), 'BANK'));
    IF jn(p_o, 'bankAccount') IS NOT NULL THEN l_d.put('bank_account', jn(p_o, 'bankAccount')); END IF;
    IF jn(p_o, 'cashBox') IS NOT NULL THEN l_d.put('cash_box', jn(p_o, 'cashBox')); END IF;
    IF jn(p_o, 'supplier') IS NOT NULL THEN l_d.put('party', jn(p_o, 'supplier')); END IF;
    IF jn(p_o, 'vat') IS NOT NULL THEN l_d.put('vat', jn(p_o, 'vat')); END IF;
    IF jn(p_o, 'openingAccum') IS NOT NULL THEN l_d.put('opening_accum', jn(p_o, 'openingAccum')); END IF;
    IF jn(p_o, 'branch') IS NOT NULL THEN l_d.put('branch', jn(p_o, 'branch')); END IF;
    l_d.put('tag', p_plate);
    l_d.put('serial', js(p_o, 'vin'));
    l_d.put('manufacturer', js(p_o, 'make'));
    l_d.put('model', js(p_o, 'model'));
    l_d.put('reference', js(p_o, 'purchaseRef'));
    l_d.put('location', 'أسطول النقل');
    l_d.put('capitalize', 'Y');
    RETURN NOONA_FA_PKG.create_asset(l_d.to_clob);
  END vehicle_asset;

  FUNCTION save_vehicle(p_doc IN CLOB) RETURN NUMBER IS
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    x_insuranceExpiry_jd DATE;
    x_licenseExpiry_jd DATE;
    x_assetId_jn NUMBER;
    x_branch_jn NUMBER;
    x_capacityM3_jn NUMBER;
    x_capacityTons_jn NUMBER;
    x_fuelPer100_jn NUMBER;
    x_odometer_jn NUMBER;
    x_year_jn NUMBER;
    x_code_js VARCHAR2(4000);
    x_fuel_js VARCHAR2(4000);
    x_make_js VARCHAR2(4000);
    x_model_js VARCHAR2(4000);
    x_notes_js VARCHAR2(4000);
    x_type_js VARCHAR2(4000);
    l_id NUMBER := jn(l_o, 'id');
    l_pl VARCHAR2(30) := UPPER(REGEXP_REPLACE(js(l_o, 'plate'), '\s+', ' '));
    l_own VARCHAR2(30) := NVL(js(l_o, 'ownership'), 'OWNED');
    l_n  NUMBER;
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'TRN_VEHICLE.CREATE' ELSE 'TRN_VEHICLE.UPDATE' END);
    NOONA_CORE_PKG.assert(l_pl IS NOT NULL, 'NOONA-TRN-007', 'رقم اللوحة مطلوب', 'Plate number required');
    NOONA_CORE_PKG.assert(NVL(jn(l_o, 'capacityTons'), 0) > 0, 'NOONA-TRN-008', 'الحمولة القصوى بالطن مطلوبة', 'Capacity required');
    SELECT COUNT(*) INTO l_n FROM trn_vehicle WHERE company_id = company AND plate_no = l_pl AND id <> NVL(l_id, -1);
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-TRN-009', 'رقم اللوحة مسجل لعربة أخرى', 'Plate already registered');
    IF l_id IS NULL THEN
      x_insuranceExpiry_jd := jd(l_o, 'insuranceExpiry');
      x_licenseExpiry_jd := jd(l_o, 'licenseExpiry');
      x_assetId_jn := jn(l_o, 'assetId');
      x_branch_jn := jn(l_o, 'branch');
      x_capacityM3_jn := jn(l_o, 'capacityM3');
      x_capacityTons_jn := jn(l_o, 'capacityTons');
      x_fuelPer100_jn := jn(l_o, 'fuelPer100');
      x_odometer_jn := jn(l_o, 'odometer');
      x_year_jn := jn(l_o, 'year');
      x_code_js := js(l_o, 'code');
      x_fuel_js := js(l_o, 'fuel');
      x_make_js := js(l_o, 'make');
      x_model_js := js(l_o, 'model');
      x_notes_js := js(l_o, 'notes');
      x_type_js := js(l_o, 'type');
      IF l_own = 'OWNED' AND x_assetId_jn IS NULL THEN
        x_assetId_jn := vehicle_asset(l_o, l_pl, NVL(x_type_js, 'TRUCK'));
      END IF;
      INSERT INTO trn_vehicle (company_id, code, plate_no, vehicle_type, make, model, model_year, capacity_tons, capacity_m3, odometer_km,
                               fuel_type, fuel_l_per_100km, license_expiry, insurance_expiry, asset_id, branch_id, status_code, notes, ownership)
      VALUES (company, NVL(UPPER(x_code_js), REPLACE(l_pl, ' ', '')), l_pl, NVL(x_type_js, 'TRUCK'), x_make_js, x_model_js,
              x_year_jn, x_capacityTons_jn, x_capacityM3_jn, NVL(x_odometer_jn, 0), NVL(x_fuel_js, 'DIESEL'),
              x_fuelPer100_jn, x_licenseExpiry_jd, x_insuranceExpiry_jd, x_assetId_jn,
              NVL(x_branch_jn, NOONA_CTX_PKG.branch_id), 'AVAILABLE', x_notes_js, l_own)
      RETURNING id INTO l_id;
    ELSE
      x_insuranceExpiry_jd := jd(l_o, 'insuranceExpiry');
      x_licenseExpiry_jd := jd(l_o, 'licenseExpiry');
      x_assetId_jn := jn(l_o, 'assetId');
      x_branch_jn := jn(l_o, 'branch');
      x_capacityM3_jn := jn(l_o, 'capacityM3');
      x_capacityTons_jn := jn(l_o, 'capacityTons');
      x_fuelPer100_jn := jn(l_o, 'fuelPer100');
      x_odometer_jn := jn(l_o, 'odometer');
      x_year_jn := jn(l_o, 'year');
      x_fuel_js := js(l_o, 'fuel');
      x_make_js := js(l_o, 'make');
      x_model_js := js(l_o, 'model');
      x_notes_js := js(l_o, 'notes');
      x_type_js := js(l_o, 'type');
      -- عربة مملوكة بلا أصل (مسجلة قبل الربط): تضاف للأصول عند إدخال تكلفة الشراء
      IF l_own = 'OWNED' AND x_assetId_jn IS NULL THEN
        SELECT MAX(asset_id) INTO x_assetId_jn FROM trn_vehicle WHERE id = l_id AND company_id = company;
        IF x_assetId_jn IS NULL AND jn(l_o, 'purchaseCost') IS NOT NULL THEN
          x_assetId_jn := vehicle_asset(l_o, l_pl, NVL(x_type_js, 'TRUCK'));
        END IF;
      END IF;
      UPDATE trn_vehicle SET ownership = l_own, plate_no = l_pl, vehicle_type = NVL(x_type_js, vehicle_type), make = x_make_js, model = x_model_js,
             model_year = x_year_jn, capacity_tons = x_capacityTons_jn, capacity_m3 = x_capacityM3_jn,
             odometer_km = NVL(x_odometer_jn, odometer_km), fuel_type = NVL(x_fuel_js, fuel_type), fuel_l_per_100km = x_fuelPer100_jn,
             license_expiry = x_licenseExpiry_jd, insurance_expiry = x_insuranceExpiry_jd, asset_id = x_assetId_jn,
             branch_id = NVL(x_branch_jn, branch_id), notes = x_notes_js
       WHERE id = l_id AND company_id = company;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-TRN-010', 'العربة غير موجودة', 'Vehicle not found');
    END IF;
    RETURN l_id;
  END save_vehicle;

  PROCEDURE set_vehicle_status(p_id IN NUMBER, p_status IN VARCHAR2) IS
    l_n NUMBER;
  BEGIN
    guard('TRN_VEHICLE.UPDATE');
    NOONA_CORE_PKG.assert(p_status IN ('AVAILABLE', 'MAINTENANCE', 'OUT_OF_SERVICE', 'SOLD'), 'NOONA-TRN-011', 'حالة غير صحيحة', 'Invalid status');
    SELECT COUNT(*) INTO l_n FROM trn_trip WHERE vehicle_id = p_id AND status_code IN ('DISPATCHED', 'IN_TRANSIT', 'ARRIVED');
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-TRN-012', 'العربة في رحلة جارية؛ أكمل الرحلة أولاً', 'Vehicle is on an active trip');
    UPDATE trn_vehicle SET status_code = p_status WHERE id = p_id AND company_id = company;
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-TRN-010', 'العربة غير موجودة', 'Vehicle not found');
  END set_vehicle_status;

  -- ================================================================ صيانة الأسطول
  FUNCTION maint_type_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'PREVENTIVE' THEN 'وقائية دورية' WHEN 'CORRECTIVE' THEN 'إصلاح عطل' WHEN 'OVERHAUL' THEN 'عمرة'
      WHEN 'INSPECTION' THEN 'فحص' WHEN 'ACCIDENT' THEN 'إصلاح حادث' WHEN 'TIRES' THEN 'إطارات' WHEN 'UPGRADE' THEN 'تطوير وتحسين'
      WHEN 'PART' THEN 'قطع غيار' WHEN 'LABOR' THEN 'عمالة' WHEN 'OIL' THEN 'زيوت وفلاتر' WHEN 'TIRE' THEN 'إطارات' WHEN 'OTHER' THEN 'أخرى'
      WHEN 'INTERNAL' THEN 'ورشة داخلية' WHEN 'EXTERNAL' THEN 'ورشة خارجية' WHEN 'EXPENSE' THEN 'مصروف صيانة'
      WHEN 'CAPITALIZE' THEN 'رأسمالية (تضاف للأصل)' ELSE p_code END;
  END maint_type_label;

  FUNCTION save_maint_plan(p_doc IN CLOB) RETURN NUMBER IS
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id NUMBER := jn(l_o, 'id');
    l_sv VARCHAR2(200) := SUBSTR(js(l_o, 'service'), 1, 200);
    l_v  NUMBER := jn(l_o, 'vehicle');
    l_vt VARCHAR2(30) := js(l_o, 'vehicleType');
    l_km NUMBER := jn(l_o, 'everyKm');
    l_dy NUMBER := jn(l_o, 'everyDays');
    l_c  NUMBER := jn(l_o, 'cost');
    l_st VARCHAR2(30) := NVL(js(l_o, 'status'), 'ACTIVE');
    l_nt VARCHAR2(4000) := js(l_o, 'notes');
    l_n  NUMBER;
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'TRN_MAINT_PLAN.CREATE' ELSE 'TRN_MAINT_PLAN.UPDATE' END);
    NOONA_CORE_PKG.assert(l_sv IS NOT NULL, 'NOONA-TRN-100', 'اسم الخدمة مطلوب', 'Service name required');
    NOONA_CORE_PKG.assert(NVL(l_km, 0) > 0 OR NVL(l_dy, 0) > 0, 'NOONA-TRN-101',
      'حدد التكرار بالكيلومترات أو بالأيام', 'Set a km or days interval');
    IF l_v IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM trn_vehicle WHERE id = l_v AND company_id = company;
      NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-TRN-010', 'العربة غير موجودة', 'Vehicle not found');
    END IF;
    IF l_id IS NULL THEN
      INSERT INTO trn_maint_plan (company_id, service_name, vehicle_id, vehicle_type, every_km, every_days, estimated_cost, status_code, notes)
      VALUES (company, l_sv, l_v, CASE WHEN l_v IS NULL THEN l_vt END, l_km, l_dy, l_c, l_st, l_nt)
      RETURNING id INTO l_id;
    ELSE
      UPDATE trn_maint_plan SET service_name = l_sv, vehicle_id = l_v, vehicle_type = CASE WHEN l_v IS NULL THEN l_vt END,
             every_km = l_km, every_days = l_dy, estimated_cost = l_c, status_code = l_st, notes = l_nt
       WHERE id = l_id AND company_id = company;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-TRN-102', 'البرنامج غير موجود', 'Program not found');
    END IF;
    RETURN l_id;
  END save_maint_plan;

  FUNCTION open_maint(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_vid NUMBER := jn(l_o, 'vehicle');
    l_v   trn_vehicle%ROWTYPE;
    l_pl  NUMBER := jn(l_o, 'plan');
    l_inc NUMBER := jn(l_o, 'incident');
    l_ws  VARCHAR2(30) := NVL(js(l_o, 'workshop'), 'INTERNAL');
    l_tp  VARCHAR2(30) := NVL(js(l_o, 'type'), CASE WHEN jn(l_o, 'plan') IS NOT NULL THEN 'PREVENTIVE' ELSE 'CORRECTIVE' END);
    l_ds  VARCHAR2(2000) := SUBSTR(js(l_o, 'description'), 1, 2000);
    l_n   NUMBER;
    l_id  NUMBER;
    l_no  VARCHAR2(50);
    l_vnd NUMBER := jn(l_o, 'vendor');
    l_odo NUMBER := jn(l_o, 'odometer');
    l_at  TIMESTAMP := NVL(jts(l_o, 'openedAt'), SYSTIMESTAMP);
    l_nt  VARCHAR2(4000) := js(l_o, 'notes');
    l_wh  NUMBER := jn(l_o, 'warehouse');
  BEGIN
    guard('TRN_MAINT_ORDER.CREATE');
    BEGIN
      SELECT * INTO l_v FROM trn_vehicle WHERE id = l_vid AND company_id = company FOR UPDATE;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-TRN-010', 'العربة غير موجودة', 'Vehicle not found');
    END;
    NOONA_CORE_PKG.assert(l_v.status_code <> 'SOLD', 'NOONA-TRN-103', 'العربة مباعة', 'Vehicle sold');
    NOONA_CORE_PKG.assert(l_ws = 'INTERNAL' OR l_vnd IS NOT NULL, 'NOONA-TRN-108',
      'حدد الورشة الخارجية (المورد)', 'External workshop vendor required');
    SELECT COUNT(*) INTO l_n FROM trn_trip WHERE vehicle_id = l_vid AND status_code IN ('DISPATCHED', 'IN_TRANSIT', 'ARRIVED');
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-TRN-012', 'العربة في رحلة جارية؛ أكمل الرحلة أولاً', 'Vehicle is on an active trip');
    SELECT COUNT(*) INTO l_n FROM trn_maint_order WHERE vehicle_id = l_vid AND status_code IN ('OPEN', 'IN_PROGRESS');
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-TRN-104', 'للعربة أمر صيانة مفتوح؛ أضف عليه أو أقفله', 'Vehicle already has an open order');
    IF l_pl IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM trn_maint_plan WHERE id = l_pl AND company_id = company
         AND (vehicle_id = l_vid OR (vehicle_id IS NULL AND NVL(vehicle_type, l_v.vehicle_type) = l_v.vehicle_type));
      NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-TRN-105', 'البرنامج الدوري لا ينطبق على هذه العربة', 'Program does not apply to the vehicle');
      IF l_ds IS NULL THEN SELECT service_name INTO l_ds FROM trn_maint_plan WHERE id = l_pl; END IF;
    END IF;
    IF l_inc IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM trn_incident WHERE id = l_inc AND company_id = company AND vehicle_id = l_vid;
      NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-TRN-106', 'البلاغ لا يخص هذه العربة', 'Incident does not belong to the vehicle');
      IF l_ds IS NULL THEN SELECT SUBSTR(description, 1, 2000) INTO l_ds FROM trn_incident WHERE id = l_inc; END IF;
    END IF;
    NOONA_CORE_PKG.assert(l_ds IS NOT NULL, 'NOONA-TRN-107', 'وصف العمل مطلوب', 'Description required');
    l_no := next_no('TRN_MAINT_ORDER', 'MNT-');
    IF l_wh IS NULL AND l_ws = 'INTERNAL' THEN
      l_wh := NOONA_INV_PKG.default_warehouse;
    END IF;
    INSERT INTO trn_maint_order (company_id, branch_id, doc_no, doc_date, vehicle_id, plan_id, incident_id, maint_type, workshop,
                                 vendor_party_id, warehouse_id, description, opened_at, odometer_km, prev_status, status_code, notes)
    VALUES (company, NVL(l_v.branch_id, NOONA_CTX_PKG.branch_id), l_no, TRUNC(SYSDATE), l_vid, l_pl, l_inc,
            l_tp, l_ws, l_vnd, l_wh, l_ds, l_at, GREATEST(NVL(l_odo, l_v.odometer_km), l_v.odometer_km), l_v.status_code, 'OPEN', l_nt)
    RETURNING id INTO l_id;
    UPDATE trn_vehicle SET status_code = 'MAINTENANCE' WHERE id = l_vid;
    RETURN l_id;
  END open_maint;

  FUNCTION order_row(p_id NUMBER) RETURN trn_maint_order%ROWTYPE IS
    l trn_maint_order%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM trn_maint_order WHERE id = p_id AND company_id = company FOR UPDATE;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-TRN-109', 'أمر الصيانة غير موجود', 'Maintenance order not found');
  END order_row;

  PROCEDURE recalc_maint(p_id NUMBER) IS
  BEGIN
    UPDATE trn_maint_order o SET
      parts_cost = (SELECT NVL(SUM(amount), 0) FROM trn_maint_line l WHERE l.order_id = o.id AND l.line_type IN ('PART', 'OIL', 'TIRE')),
      labor_cost = (SELECT NVL(SUM(amount), 0) FROM trn_maint_line l WHERE l.order_id = o.id AND l.line_type = 'LABOR'),
      other_cost = (SELECT NVL(SUM(amount), 0) FROM trn_maint_line l WHERE l.order_id = o.id AND l.line_type = 'OTHER'),
      total_cost = (SELECT NVL(SUM(amount), 0) FROM trn_maint_line l WHERE l.order_id = o.id),
      stock_cost = (SELECT NVL(SUM(amount), 0) FROM trn_maint_line l WHERE l.order_id = o.id AND l.from_stock = 'Y')
     WHERE id = p_id;
  END recalc_maint;

  FUNCTION add_maint_line(p_order_id IN NUMBER, p_type IN VARCHAR2, p_desc IN VARCHAR2, p_qty IN NUMBER, p_unit_cost IN NUMBER,
                          p_item_id IN NUMBER DEFAULT NULL, p_life_km IN NUMBER DEFAULT NULL, p_life_days IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_m  trn_maint_order%ROWTYPE;
    l_id NUMBER;
    l_d  VARCHAR2(500) := SUBSTR(TRIM(p_desc), 1, 500);
    l_wh NUMBER;
    l_tx NUMBER;
    l_tot NUMBER;
    l_pl VARCHAR2(30);
    l_lkm NUMBER := p_life_km;
    l_ldy NUMBER := p_life_days;
  BEGIN
    guard('TRN_MAINT_ORDER.UPDATE');
    l_m := order_row(p_order_id);
    NOONA_CORE_PKG.assert(l_m.status_code IN ('OPEN', 'IN_PROGRESS'), 'NOONA-TRN-110', 'أمر الصيانة مقفل', 'Order is closed');
    NOONA_CORE_PKG.assert(NVL(p_type, 'PART') IN ('PART', 'LABOR', 'OIL', 'TIRE', 'OTHER'), 'NOONA-TRN-111', 'نوع البند غير صحيح', 'Invalid line type');
    NOONA_CORE_PKG.assert(NVL(p_qty, 1) > 0 AND NVL(p_unit_cost, 0) >= 0, 'NOONA-TRN-112',
      'الكمية موجبة والتكلفة لا تكون سالبة', 'Invalid quantity or cost');
    IF l_d IS NULL AND p_item_id IS NOT NULL THEN
      SELECT MAX(name_ar) INTO l_d FROM inv_item WHERE id = p_item_id;
    END IF;
    NOONA_CORE_PKG.assert(l_d IS NOT NULL, 'NOONA-TRN-113', 'بيان البند مطلوب', 'Description required');
    NOONA_CORE_PKG.assert(NVL(l_lkm, 0) >= 0 AND NVL(l_ldy, 0) >= 0, 'NOONA-TRN-120', 'عمر الاستبدال لا يكون سالباً', 'Invalid life');
    IF p_item_id IS NOT NULL THEN
      SELECT NVL(l_lkm, MAX(service_life_km)), NVL(l_ldy, MAX(service_life_days)) INTO l_lkm, l_ldy FROM inv_item WHERE id = p_item_id;
    END IF;
    INSERT INTO trn_maint_line (company_id, order_id, line_type, description, item_id, quantity, unit_cost, amount,
                                life_km, life_days, next_due_km, next_due_date)
    VALUES (company, p_order_id, NVL(p_type, 'PART'), l_d, p_item_id, NVL(p_qty, 1), NVL(p_unit_cost, 0),
            ROUND(NVL(p_qty, 1) * NVL(p_unit_cost, 0), 2), NULLIF(l_lkm, 0), NULLIF(l_ldy, 0),
            CASE WHEN l_lkm > 0 THEN l_m.odometer_km + l_lkm END, CASE WHEN l_ldy > 0 THEN TRUNC(SYSDATE) + l_ldy END)
    RETURNING id INTO l_id;
    -- قطع الغيار والزيوت المخزنية: صرف من مستودع الورشة بتكلفة المتوسط المرجح
    IF p_item_id IS NOT NULL AND NOONA_INV_PKG.is_stocked(p_item_id) = 'Y' THEN
      l_wh := NVL(l_m.warehouse_id, NOONA_INV_PKG.default_warehouse);
      NOONA_CORE_PKG.assert(l_wh IS NOT NULL, 'NOONA-TRN-119', 'حدد مستودع قطع الغيار لأمر الصيانة', 'Warehouse required');
      SELECT plate_no INTO l_pl FROM trn_vehicle WHERE id = l_m.vehicle_id;
      l_tx := NOONA_INV_PKG.maint_stock('MAINT_ISSUE', l_wh, p_item_id, NVL(p_qty, 1), NULL, TRUNC(SYSDATE), p_order_id,
                                        l_m.doc_no || ' - ' || l_pl || ': ' || l_d, l_tot);
      UPDATE trn_maint_line SET from_stock = 'Y', inv_txn_id = l_tx, amount = l_tot, unit_cost = ROUND(l_tot / NVL(p_qty, 1), 6)
       WHERE id = l_id;
      UPDATE trn_maint_order SET warehouse_id = l_wh WHERE id = p_order_id AND warehouse_id IS NULL;
    END IF;
    UPDATE trn_maint_order SET status_code = 'IN_PROGRESS' WHERE id = p_order_id AND status_code = 'OPEN';
    recalc_maint(p_order_id);
    RETURN l_id;
  END add_maint_line;

  PROCEDURE remove_maint_line(p_line_id IN NUMBER) IS
    l_oid NUMBER;
    l_m   trn_maint_order%ROWTYPE;
    l_ln  trn_maint_line%ROWTYPE;
    l_tx  NUMBER;
    l_tot NUMBER;
  BEGIN
    guard('TRN_MAINT_ORDER.UPDATE');
    SELECT MAX(order_id) INTO l_oid FROM trn_maint_line WHERE id = p_line_id AND company_id = company;
    NOONA_CORE_PKG.assert(l_oid IS NOT NULL, 'NOONA-TRN-114', 'البند غير موجود', 'Line not found');
    l_m := order_row(l_oid);
    NOONA_CORE_PKG.assert(l_m.status_code IN ('OPEN', 'IN_PROGRESS'), 'NOONA-TRN-110', 'أمر الصيانة مقفل', 'Order is closed');
    SELECT * INTO l_ln FROM trn_maint_line WHERE id = p_line_id;
    IF l_ln.from_stock = 'Y' AND l_ln.amount > 0 THEN
      -- إرجاع القطعة غير المستخدمة للمخزون بتكلفة صرفها
      l_tx := NOONA_INV_PKG.maint_stock('MAINT_RETURN', l_m.warehouse_id, l_ln.item_id, l_ln.quantity, l_ln.amount / l_ln.quantity,
                                        TRUNC(SYSDATE), l_oid, l_m.doc_no || ': إرجاع ' || l_ln.description, l_tot);
    END IF;
    DELETE FROM trn_maint_line WHERE id = p_line_id;
    recalc_maint(l_oid);
  END remove_maint_line;

  PROCEDURE complete_maint(p_order_id IN NUMBER, p_doc IN CLOB) IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(NVL(p_doc, '{}'));
    l_m    trn_maint_order%ROWTYPE;
    l_v    trn_vehicle%ROWTYPE;
    l_tr   VARCHAR2(30) := NVL(js(l_o, 'treatment'), 'EXPENSE');
    l_ext  NUMBER := NVL(jn(l_o, 'lifeExtension'), 0);
    l_vat  NUMBER := NVL(jn(l_o, 'vat'), 0);
    l_odo  NUMBER := jn(l_o, 'odometer');
    l_at   TIMESTAMP := NVL(jts(l_o, 'completedAt'), SYSTIMESTAMP);
    l_fam  NUMBER;
    l_down NUMBER := jn(l_o, 'downtimeHours');
    l_d    JSON_OBJECT_T := JSON_OBJECT_T();
  BEGIN
    guard('TRN_MAINT_ORDER.UPDATE');
    l_m := order_row(p_order_id);
    NOONA_CORE_PKG.assert(l_m.status_code IN ('OPEN', 'IN_PROGRESS'), 'NOONA-TRN-110', 'أمر الصيانة مقفل', 'Order is closed');
    SELECT * INTO l_v FROM trn_vehicle WHERE id = l_m.vehicle_id FOR UPDATE;
    recalc_maint(p_order_id);
    SELECT * INTO l_m FROM trn_maint_order WHERE id = p_order_id;
    NOONA_CORE_PKG.assert(l_odo IS NULL OR l_odo >= l_m.odometer_km, 'NOONA-TRN-115',
      'عداد الخروج أقل من عداد الدخول (' || qf(l_m.odometer_km) || ')', 'Odometer below entry reading');
    NOONA_CORE_PKG.assert(l_m.total_cost > 0 OR (l_vat = 0 AND l_tr = 'EXPENSE' AND l_ext = 0), 'NOONA-TRN-116',
      'أضف بنود التكلفة قبل الترحيل', 'Add cost lines first');
    NOONA_CORE_PKG.assert(l_tr = 'EXPENSE' OR l_v.asset_id IS NOT NULL, 'NOONA-TRN-117',
      'العربة غير مسجلة في الأصول الثابتة (مستأجرة أو قديمة)؛ الصيانة الرأسمالية تتطلب أصلاً — سجل تكلفة شرائها أولاً',
      'Capitalized maintenance requires the vehicle fixed asset');
    IF l_m.total_cost > 0 THEN
      IF l_v.asset_id IS NOT NULL THEN l_d.put('asset', l_v.asset_id); END IF;
      l_d.put('date', TO_CHAR(CAST(l_at AS DATE), 'YYYY-MM-DD'));
      l_d.put('maint_type', CASE l_m.maint_type WHEN 'TIRES' THEN 'CORRECTIVE' ELSE l_m.maint_type END);
      l_d.put('treatment', l_tr);
      l_d.put('description', SUBSTR('صيانة العربة ' || l_v.plate_no || ' (' || l_m.doc_no || '): ' || l_m.description, 1, 1000));
      l_d.put('amount', l_m.total_cost);
      IF l_m.stock_cost > 0 THEN
        l_d.put('stock_amount', l_m.stock_cost);
        l_d.put('stock_account', NOONA_INV_PKG.maint_wip_account);
      END IF;
      l_d.put('vat', l_vat);
      l_d.put('funding', NVL(js(l_o, 'funding'), CASE WHEN l_m.workshop = 'EXTERNAL' THEN 'PAYABLE' ELSE 'CASH' END));
      IF jn(l_o, 'bankAccount') IS NOT NULL THEN l_d.put('bank_account', jn(l_o, 'bankAccount')); END IF;
      IF jn(l_o, 'cashBox') IS NOT NULL THEN l_d.put('cash_box', jn(l_o, 'cashBox')); END IF;
      IF jn(l_o, 'account') IS NOT NULL THEN l_d.put('account', jn(l_o, 'account')); END IF;
      -- المورد: ورشة الأمر الخارجية، أو من يستحق العمالة/الخدمة في الورشة الداخلية (vendor عند الإقفال)
      IF NVL(jn(l_o, 'vendor'), l_m.vendor_party_id) IS NOT NULL THEN l_d.put('party', NVL(jn(l_o, 'vendor'), l_m.vendor_party_id)); END IF;
      IF l_ext > 0 THEN l_d.put('life_extension', l_ext); END IF;
      l_d.put('branch', l_m.branch_id);
      l_d.put('reference', NVL(js(l_o, 'reference'), l_m.doc_no));
      l_d.put('source_module', 'TRN');
      l_d.put('source_id', p_order_id);
      l_fam := NOONA_FA_PKG.record_maintenance(l_d.to_clob);
    END IF;
    UPDATE trn_maint_order SET status_code = 'COMPLETED', completed_at = l_at, odometer_km = NVL(l_odo, odometer_km),
           downtime_hours = NVL(l_down,
                                ROUND((CAST(l_at AS DATE) - CAST(opened_at AS DATE)) * 24, 1)),
           vat_amount = l_vat, treatment = l_tr, life_extension_months = l_ext, fa_maintenance_id = l_fam
     WHERE id = p_order_id;
    -- موعد الاستبدال التالي لكل قطعة لها عمر: من عداد الخروج وتاريخه
    UPDATE trn_maint_line SET next_due_km = CASE WHEN life_km > 0 THEN NVL(l_odo, l_m.odometer_km) + life_km END,
                              next_due_date = CASE WHEN life_days > 0 THEN TRUNC(CAST(l_at AS DATE)) + life_days END
     WHERE order_id = p_order_id;
    UPDATE trn_vehicle SET status_code = CASE WHEN l_m.prev_status = 'OUT_OF_SERVICE' THEN 'OUT_OF_SERVICE' ELSE 'AVAILABLE' END,
           odometer_km = GREATEST(odometer_km, NVL(l_odo, 0))
     WHERE id = l_m.vehicle_id;
  END complete_maint;

  PROCEDURE cancel_maint(p_order_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_m trn_maint_order%ROWTYPE;
  BEGIN
    guard('TRN_MAINT_ORDER.UPDATE');
    l_m := order_row(p_order_id);
    NOONA_CORE_PKG.assert(l_m.status_code IN ('OPEN', 'IN_PROGRESS'), 'NOONA-TRN-110', 'أمر الصيانة مقفل', 'Order is closed');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-TRN-118', 'سبب الإلغاء مطلوب', 'Reason required');
    FOR r IN (SELECT id FROM trn_maint_line WHERE order_id = p_order_id AND from_stock = 'Y') LOOP
      remove_maint_line(r.id);       -- تعود القطع المصروفة للمخزون
    END LOOP;
    UPDATE trn_maint_order SET status_code = 'CANCELLED', notes = SUBSTR(NVL2(notes, notes || ' | ', '') || 'إلغاء: ' || p_reason, 1, 4000)
     WHERE id = p_order_id;
    UPDATE trn_vehicle SET status_code = CASE WHEN l_m.prev_status IN ('AVAILABLE', 'OUT_OF_SERVICE') THEN l_m.prev_status ELSE 'AVAILABLE' END
     WHERE id = l_m.vehicle_id AND status_code = 'MAINTENANCE';
  END cancel_maint;

  -- آخر تنفيذ لكل (عربة، برنامج) ومقدار المتبقي بالكيلومترات والأيام
  FUNCTION maint_due_html RETURN CLOB IS
    l_h CLOB;
    l_p CLOB;
  BEGIN
    FOR r IN (
      WITH x AS (
        SELECT v.id vid, v.plate_no, v.odometer_km odo, v.status_code vst, p.id pid, p.service_name, p.every_km, p.every_days, p.estimated_cost,
               (SELECT MAX(o.odometer_km) KEEP (DENSE_RANK LAST ORDER BY o.completed_at) FROM trn_maint_order o
                 WHERE o.vehicle_id = v.id AND o.plan_id = p.id AND o.status_code = 'COMPLETED') last_km,
               (SELECT MAX(CAST(o.completed_at AS DATE)) FROM trn_maint_order o
                 WHERE o.vehicle_id = v.id AND o.plan_id = p.id AND o.status_code = 'COMPLETED') last_dt,
               (SELECT COUNT(*) FROM trn_maint_order o WHERE o.vehicle_id = v.id AND o.plan_id = p.id
                   AND o.status_code IN ('OPEN', 'IN_PROGRESS')) open_n
          FROM trn_maint_plan p JOIN trn_vehicle v ON v.company_id = p.company_id
         WHERE p.company_id = company AND p.status_code = 'ACTIVE' AND v.status_code <> 'SOLD'
           AND (p.vehicle_id = v.id OR (p.vehicle_id IS NULL AND NVL(p.vehicle_type, v.vehicle_type) = v.vehicle_type)))
      SELECT x.*, CASE WHEN every_km > 0 AND last_dt IS NOT NULL THEN last_km + every_km - odo END km_left,
             CASE WHEN every_days > 0 AND last_dt IS NOT NULL THEN TRUNC(last_dt + every_days - SYSDATE) END days_left
        FROM x) LOOP
      IF r.last_km IS NULL AND r.last_dt IS NULL OR NVL(r.km_left, 1e9) <= r.every_km * 0.1 OR NVL(r.days_left, 1e9) <= 7 THEN
        l_h := l_h || '<tr><td><b>' || esc(r.plate_no) || '</b></td><td>' || esc(r.service_name) || '</td><td>'
            || CASE WHEN r.last_dt IS NULL THEN 'لم تنفذ سابقاً' ELSE TO_CHAR(r.last_dt, 'YYYY-MM-DD') || ' عند ' || qf(r.last_km) || ' كم' END
            || '</td><td class="u-tE">' || qf(r.odo) || '</td><td>'
            || CASE WHEN r.km_left IS NOT NULL THEN CASE WHEN r.km_left < 0 THEN '<span class="nn-badge is-danger">تجاوز ' || qf(-r.km_left) || ' كم</span>'
                                                     ELSE 'باقي ' || qf(r.km_left) || ' كم' END END
            || CASE WHEN r.days_left IS NOT NULL THEN ' ' || CASE WHEN r.days_left < 0 THEN '<span class="nn-badge is-danger">متأخرة ' || -r.days_left || ' يوم</span>'
                                                     ELSE 'باقي ' || r.days_left || ' يوم' END END
            || '</td><td>' || CASE WHEN r.open_n > 0 THEN badge('IN_PROGRESS') WHEN r.vst = 'ON_TRIP' THEN badge('ON_TRIP') ELSE badge('MAINTENANCE') END
            || '</td><td class="u-tE">' || fmt(r.estimated_cost) || '</td></tr>';
      END IF;
    END LOOP;
    -- قطع لها عمر استبدال: آخر تركيب لكل (عربة، صنف) اقترب أو تجاوز موعده بالكيلومتر أو التاريخ
    FOR r IN (
      SELECT * FROM (
        SELECT v.plate_no, v.odometer_km odo, ln.description, ln.next_due_km, ln.next_due_date, ln.life_km, o.completed_at, o.odometer_km done_km,
               ROW_NUMBER() OVER (PARTITION BY o.vehicle_id, NVL(TO_CHAR(ln.item_id), ln.description) ORDER BY o.completed_at DESC, ln.id DESC) rn
          FROM trn_maint_line ln JOIN trn_maint_order o ON o.id = ln.order_id JOIN trn_vehicle v ON v.id = o.vehicle_id
         WHERE o.company_id = company AND o.status_code = 'COMPLETED' AND v.status_code <> 'SOLD'
           AND (ln.next_due_km IS NOT NULL OR ln.next_due_date IS NOT NULL))
       WHERE rn = 1
         AND (odo >= next_due_km - NVL(life_km, 0) * 0.1 OR next_due_date <= TRUNC(SYSDATE) + 7)
       ORDER BY plate_no) LOOP
      l_p := l_p || '<tr><td><b>' || esc(r.plate_no) || '</b></td><td>' || esc(r.description) || '</td><td>'
          || TO_CHAR(r.completed_at, 'YYYY-MM-DD') || ' عند ' || qf(r.done_km) || ' كم</td><td class="u-tE">' || qf(r.odo) || '</td><td>'
          || CASE WHEN r.next_due_km IS NOT NULL THEN CASE WHEN r.odo >= r.next_due_km
                    THEN '<span class="nn-badge is-danger">تجاوز ' || qf(r.odo - r.next_due_km) || ' كم</span>'
                    ELSE 'عند ' || qf(r.next_due_km) || ' كم (باقي ' || qf(r.next_due_km - r.odo) || ')' END END
          || CASE WHEN r.next_due_date IS NOT NULL THEN ' ' || CASE WHEN r.next_due_date < TRUNC(SYSDATE)
                    THEN '<span class="nn-badge is-danger">انتهى عمرها ' || TO_CHAR(r.next_due_date, 'YYYY-MM-DD') || '</span>'
                    ELSE 'بتاريخ ' || TO_CHAR(r.next_due_date, 'YYYY-MM-DD') END END || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_h IS NULL THEN '<p class="nn-hint">لا توجد صيانات دورية مستحقة الآن.</p>'
           ELSE '<table class="nn-table"><thead><tr><th>العربة</th><th>الخدمة</th><th>آخر تنفيذ</th><th>العداد الحالي</th><th>الاستحقاق</th>'
             || '<th>الوضع</th><th>التكلفة التقديرية</th></tr></thead><tbody>' || l_h || '</tbody></table>' END
        || CASE WHEN l_p IS NOT NULL THEN '<h4>قطع حان استبدالها (حسب عمر القطعة)</h4><table class="nn-table"><thead><tr><th>العربة</th>'
             || '<th>القطعة</th><th>آخر تركيب</th><th>العداد الحالي</th><th>الاستبدال</th></tr></thead><tbody>' || l_p || '</tbody></table>' END;
  END maint_due_html;

  PROCEDURE set_part_life(p_item_id IN NUMBER, p_km IN NUMBER, p_days IN NUMBER) IS
  BEGIN
    guard('TRN_MAINT_PLAN.UPDATE');
    NOONA_CORE_PKG.assert(NVL(p_km, 0) >= 0 AND NVL(p_days, 0) >= 0, 'NOONA-TRN-120', 'عمر الاستبدال لا يكون سالباً', 'Invalid life');
    UPDATE inv_item SET service_life_km = NULLIF(p_km, 0), service_life_days = NULLIF(p_days, 0) WHERE id = p_item_id;
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-TRN-121', 'الصنف غير موجود', 'Item not found');
  END set_part_life;

  FUNCTION parts_report_html(p_from IN DATE, p_to IN DATE, p_vehicle_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_h   CLOB;
    l_veh VARCHAR2(30) := '#';
    l_vt  NUMBER := 0;
    l_gt  NUMBER := 0;
    l_f   DATE := NVL(p_from, TRUNC(SYSDATE, 'YYYY'));
    l_t   DATE := NVL(p_to, TRUNC(SYSDATE));
    PROCEDURE sub IS
    BEGIN
      IF l_veh <> '#' THEN
        l_h := l_h || '<tr class="nn-subtotal"><td colspan="7"><b>إجمالي ' || esc(l_veh) || '</b></td><td class="u-tE"><b>' || fmt(l_vt)
            || '</b></td><td colspan="2"></td></tr>';
      END IF;
    END sub;
  BEGIN
    FOR r IN (
      SELECT x.* FROM (
        SELECT v.plate_no, o.doc_no, CAST(o.completed_at AS DATE) done, o.odometer_km, ln.line_type, ln.description, ln.quantity,
               ln.unit_cost, ln.amount, ln.from_stock, o.vehicle_id,
               o.odometer_km - LAG(o.odometer_km) OVER (PARTITION BY o.vehicle_id, NVL(TO_CHAR(ln.item_id), ln.description)
                                                       ORDER BY o.completed_at, ln.id) km_used,
               TRUNC(CAST(o.completed_at AS DATE)) - TRUNC(CAST(LAG(o.completed_at) OVER (PARTITION BY o.vehicle_id,
                     NVL(TO_CHAR(ln.item_id), ln.description) ORDER BY o.completed_at, ln.id) AS DATE)) days_used
          FROM trn_maint_line ln JOIN trn_maint_order o ON o.id = ln.order_id JOIN trn_vehicle v ON v.id = o.vehicle_id
         WHERE o.company_id = company AND o.status_code = 'COMPLETED' AND ln.line_type IN ('PART', 'OIL', 'TIRE')
           AND (p_vehicle_id IS NULL OR o.vehicle_id = p_vehicle_id)) x
       WHERE x.done BETWEEN l_f AND l_t + 1 - 1/86400
       ORDER BY x.plate_no, x.done, x.doc_no) LOOP
      IF r.plate_no <> l_veh THEN sub; l_veh := r.plate_no; l_vt := 0; END IF;
      l_vt := l_vt + r.amount; l_gt := l_gt + r.amount;
      l_h := l_h || '<tr><td>' || esc(r.plate_no) || '</td><td>' || TO_CHAR(r.done, 'YYYY-MM-DD') || '</td><td>' || esc(r.doc_no)
          || '</td><td>' || esc(maint_type_label(r.line_type)) || '</td><td>' || esc(r.description)
          || CASE WHEN r.from_stock = 'Y' THEN ' <span class="nn-badge is-info">مخزون</span>' END
          || '</td><td class="u-tE">' || qf(r.quantity) || '</td><td class="u-tE">' || fmt(r.unit_cost) || '</td><td class="u-tE">'
          || fmt(r.amount) || '</td><td class="u-tE">' || qf(r.odometer_km) || '</td><td>'
          || CASE WHEN r.km_used IS NOT NULL THEN qf(r.km_used) || ' كم / ' || r.days_used || ' يوم' ELSE 'أول تركيب' END || '</td></tr>';
    END LOOP;
    sub;
    RETURN CASE WHEN l_h IS NULL THEN '<p class="nn-hint">لا مصروفات قطع غيار في الفترة.</p>'
           ELSE '<table class="nn-table"><thead><tr><th>العربة</th><th>التاريخ</th><th>الأمر</th><th>النوع</th><th>القطعة</th><th>الكمية</th>'
             || '<th>التكلفة</th><th>المبلغ</th><th>العداد</th><th>عمر القطعة السابقة</th></tr></thead><tbody>' || l_h
             || '<tr class="nn-total"><td colspan="7"><b>إجمالي قطع الغيار والزيوت والإطارات</b></td><td class="u-tE"><b>' || fmt(l_gt)
             || '</b></td><td colspan="2"></td></tr></tbody></table>' END;
  END parts_report_html;

  FUNCTION vehicle_perf_html(p_from IN DATE, p_to IN DATE, p_vehicle_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_f DATE := NVL(p_from, TRUNC(SYSDATE, 'YYYY'));
    l_t DATE := NVL(p_to, TRUNC(SYSDATE)) + 1;
  BEGIN
    FOR r IN (
      SELECT v.plate_no,
             (SELECT COUNT(*) FROM trn_trip t WHERE t.vehicle_id = v.id AND t.status_code = 'COMPLETED' AND t.actual_departure >= l_f AND t.actual_departure < l_t) trips,
             (SELECT NVL(SUM(t.actual_distance_km), 0) FROM trn_trip t WHERE t.vehicle_id = v.id AND t.status_code = 'COMPLETED' AND t.actual_departure >= l_f AND t.actual_departure < l_t) km,
             (SELECT NVL(SUM(t.fuel_liters), 0) FROM trn_trip t WHERE t.vehicle_id = v.id AND t.status_code = 'COMPLETED' AND t.actual_departure >= l_f AND t.actual_departure < l_t) fuel,
             (SELECT COUNT(*) FROM trn_incident i WHERE i.vehicle_id = v.id AND i.incident_type IN ('BREAKDOWN', 'TIRE', 'ACCIDENT') AND i.reported_at >= l_f AND i.reported_at < l_t) faults,
             COUNT(o.id) orders,
             SUM(CASE WHEN o.maint_type IN ('CORRECTIVE', 'ACCIDENT', 'TIRES') THEN 1 ELSE 0 END) repairs,
             NVL(SUM(o.parts_cost), 0) parts, NVL(SUM(o.labor_cost + o.other_cost), 0) labor, NVL(SUM(o.total_cost), 0) total,
             NVL(SUM(o.downtime_hours), 0) down
        FROM trn_vehicle v
        LEFT JOIN trn_maint_order o ON o.vehicle_id = v.id AND o.status_code = 'COMPLETED' AND o.completed_at >= l_f AND o.completed_at < l_t
       WHERE v.company_id = company AND (p_vehicle_id IS NULL OR v.id = p_vehicle_id) AND v.status_code <> 'SOLD'
       GROUP BY v.id, v.plate_no
       ORDER BY NVL(SUM(o.total_cost), 0) DESC, v.plate_no) LOOP
      l_h := l_h || '<tr><td><b>' || esc(r.plate_no) || '</b></td><td class="u-tE">' || r.trips || '</td><td class="u-tE">' || qf(r.km)
          || '</td><td class="u-tE">' || CASE WHEN r.km > 0 AND r.fuel > 0 THEN TO_CHAR(ROUND(r.fuel * 100 / r.km, 1), 'FM9990.0') ELSE '-' END
          || '</td><td class="u-tE">' || r.faults || '</td><td class="u-tE">' || r.orders || ' (' || r.repairs || ' إصلاح)</td><td class="u-tE">'
          || fmt(r.parts) || '</td><td class="u-tE">' || fmt(r.labor) || '</td><td class="u-tE"><b>' || fmt(r.total) || '</b></td><td class="u-tE">'
          || CASE WHEN r.km > 0 THEN TO_CHAR(ROUND(r.total / r.km, 3), 'FM999990.000') ELSE '-' END || '</td><td class="u-tE">' || qf(r.down) || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_h IS NULL THEN '<p class="nn-hint">لا عربات.</p>'
           ELSE '<table class="nn-table"><thead><tr><th>العربة</th><th>الرحلات</th><th>الكيلومترات</th><th>لتر/100كم</th><th>الأعطال والحوادث</th>'
             || '<th>أوامر الصيانة</th><th>قطع الغيار</th><th>العمالة والأخرى</th><th>تكلفة الصيانة</th><th>التكلفة/كم</th><th>التوقف (س)</th>'
             || '</tr></thead><tbody>' || l_h || '</tbody></table>' END;
  END vehicle_perf_html;

  FUNCTION driver_perf_html(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_h CLOB;
    l_f DATE := NVL(p_from, TRUNC(SYSDATE, 'YYYY'));
    l_t DATE := NVL(p_to, TRUNC(SYSDATE)) + 1;
  BEGIN
    FOR r IN (
      WITH trips AS (
        SELECT t.driver_id, t.vehicle_id, COUNT(*) n, NVL(SUM(t.actual_distance_km), 0) km, NVL(SUM(t.fuel_liters), 0) fuel
          FROM trn_trip t
         WHERE t.company_id = company AND t.status_code = 'COMPLETED' AND t.actual_departure >= l_f AND t.actual_departure < l_t
         GROUP BY t.driver_id, t.vehicle_id),
      vkm AS (SELECT vehicle_id, SUM(km) km FROM trips GROUP BY vehicle_id),
      -- إصلاح الأعطال غير المرتبط ببلاغ سائق: يوزع على السائقين بنسبة كيلومتراتهم على العربة
      rep AS (SELECT o.vehicle_id, SUM(o.total_cost) cost FROM trn_maint_order o
               WHERE o.company_id = company AND o.status_code = 'COMPLETED' AND o.completed_at >= l_f AND o.completed_at < l_t
                 AND o.maint_type IN ('CORRECTIVE', 'ACCIDENT', 'TIRES')
                 AND (o.incident_id IS NULL OR EXISTS (SELECT 1 FROM trn_incident i WHERE i.id = o.incident_id AND i.driver_id IS NULL))
               GROUP BY o.vehicle_id),
      alloc AS (SELECT tr.driver_id, SUM(CASE WHEN vk.km > 0 THEN rp.cost * tr.km / vk.km ELSE 0 END) cost
                  FROM trips tr JOIN vkm vk ON vk.vehicle_id = tr.vehicle_id JOIN rep rp ON rp.vehicle_id = tr.vehicle_id
                 GROUP BY tr.driver_id),
      direct AS (SELECT i.driver_id, SUM(o.total_cost) cost FROM trn_maint_order o JOIN trn_incident i ON i.id = o.incident_id
                  WHERE o.company_id = company AND o.status_code = 'COMPLETED' AND o.completed_at >= l_f AND o.completed_at < l_t
                    AND i.driver_id IS NOT NULL GROUP BY i.driver_id),
      inc AS (SELECT i.driver_id, COUNT(*) n, SUM(CASE WHEN i.incident_type = 'ACCIDENT' THEN 1 ELSE 0 END) acc,
                     SUM(CASE WHEN i.incident_type IN ('BREAKDOWN', 'TIRE') THEN 1 ELSE 0 END) brk
                FROM trn_incident i WHERE i.company_id = company AND i.driver_id IS NOT NULL AND i.reported_at >= l_f AND i.reported_at < l_t
               GROUP BY i.driver_id)
      SELECT d.full_name, NVL(SUM(tr.n), 0) trips, NVL(SUM(tr.km), 0) km, NVL(SUM(tr.fuel), 0) fuel,
             MAX(NVL(ic.n, 0)) incs, MAX(NVL(ic.acc, 0)) acc, MAX(NVL(ic.brk, 0)) brk,
             MAX(NVL(dr.cost, 0)) direct_cost, MAX(NVL(al.cost, 0)) alloc_cost
        FROM trn_driver d
        LEFT JOIN trips tr ON tr.driver_id = d.id
        LEFT JOIN inc ic ON ic.driver_id = d.id
        LEFT JOIN direct dr ON dr.driver_id = d.id
        LEFT JOIN alloc al ON al.driver_id = d.id
       WHERE d.company_id = company
       GROUP BY d.id, d.full_name
      HAVING NVL(SUM(tr.n), 0) > 0 OR MAX(NVL(ic.n, 0)) > 0
       ORDER BY MAX(NVL(dr.cost, 0)) + MAX(NVL(al.cost, 0)) DESC) LOOP
      l_h := l_h || '<tr><td><b>' || esc(r.full_name) || '</b></td><td class="u-tE">' || r.trips || '</td><td class="u-tE">' || qf(r.km)
          || '</td><td class="u-tE">' || CASE WHEN r.km > 0 AND r.fuel > 0 THEN TO_CHAR(ROUND(r.fuel * 100 / r.km, 1), 'FM9990.0') ELSE '-' END
          || '</td><td class="u-tE">' || r.incs || '</td><td class="u-tE">' || r.acc || '</td><td class="u-tE">' || r.brk
          || '</td><td class="u-tE">' || fmt(r.direct_cost) || '</td><td class="u-tE">' || fmt(r.alloc_cost) || '</td><td class="u-tE"><b>'
          || fmt(r.direct_cost + r.alloc_cost) || '</b></td><td class="u-tE">'
          || CASE WHEN r.km > 0 THEN TO_CHAR(ROUND((r.direct_cost + r.alloc_cost) / r.km, 3), 'FM999990.000') ELSE '-' END || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_h IS NULL THEN '<p class="nn-hint">لا رحلات أو بلاغات للسائقين في الفترة.</p>'
           ELSE '<table class="nn-table"><thead><tr><th>السائق</th><th>الرحلات</th><th>الكيلومترات</th><th>لتر/100كم</th><th>البلاغات</th>'
             || '<th>حوادث</th><th>أعطال</th><th>صيانة من بلاغاته</th><th>إصلاحات موزعة بالكيلومتر</th><th>تكلفة الصيانة المنسوبة</th>'
             || '<th>التكلفة/كم</th></tr></thead><tbody>' || l_h || '</tbody></table>'
             || '<p class="nn-hint">المنسوب للسائق: تكلفة أوامر الصيانة المفتوحة من بلاغاته مباشرة، وإصلاحات الأعطال والحوادث والإطارات '
             || 'غير المرتبطة ببلاغ سائق موزعة على السائقين بنسبة الكيلومترات التي قطعها كل منهم على العربة في الفترة. '
             || 'الصيانة الدورية والعمرات لا تنسب للسائق.</p>' END;
  END driver_perf_html;

  FUNCTION run_maint_alerts(p_company_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_total NUMBER := 0;
    l_new   PLS_INTEGER;
    l_list  VARCHAR2(32767);
    l_mails VARCHAR2(4000);
    l_ev    NUMBER;
    l_x     NUMBER;
    PROCEDURE alert(p_tenant NUMBER, p_company NUMBER, p_event VARCHAR2, p_entity VARCHAR2, p_id NUMBER, p_key VARCHAR2,
                    p_title VARCHAR2, p_due DATE) IS
      l_any BOOLEAN := FALSE;
    BEGIN
      SELECT MIN(id) INTO l_ev FROM ntf_event_type WHERE code = p_event;
      IF l_ev IS NULL THEN RETURN; END IF;
      FOR m IN (SELECT um.id, LOWER(u.email) email
                  FROM sec_user_membership um JOIN sec_user u ON u.id = um.user_id
                 WHERE um.tenant_id = p_tenant AND um.status_code = 'ACTIVE' AND u.status_code = 'ACTIVE'
                   AND (um.is_tenant_admin = 'Y' OR EXISTS (
                        SELECT 1 FROM sec_role_grant g
                          JOIN (SELECT CONNECT_BY_ROOT parent_role_id root_role_id, child_role_id role_id FROM sec_role_composite
                                CONNECT BY NOCYCLE PRIOR child_role_id = parent_role_id
                                UNION ALL SELECT id, id FROM sec_role) rc ON rc.root_role_id = g.role_id
                          JOIN sec_role_permission rp ON rp.role_id = rc.role_id AND NVL(rp.effect, 'ALLOW') <> 'DENY'
                          JOIN sec_permission pm ON pm.id = rp.permission_id AND pm.permission_code = 'TRN_MAINT_ORDER.CREATE'
                         WHERE g.membership_id = um.id AND g.status_code = 'ACTIVE'
                           AND TRUNC(SYSDATE) BETWEEN g.effective_from AND NVL(g.effective_to, DATE '9999-12-31')
                           AND (NOT EXISTS (SELECT 1 FROM sec_data_scope ds WHERE ds.role_grant_id = g.id)
                                OR EXISTS (SELECT 1 FROM sec_data_scope ds WHERE ds.role_grant_id = g.id
                                              AND (ds.scope_type = 'ALL_TENANT' OR ds.company_id = p_company)))))) LOOP
        BEGIN
          INSERT INTO ntf_notification (tenant_id, event_type_id, membership_id, source_entity_type, source_entity_id, title, link_url,
                                        idempotency_key, due_at, correlation_id, confidentiality_level)
          VALUES (p_tenant, l_ev, m.id, p_entity, p_id, SUBSTR(p_title, 1, 500), 'f?p=NOONA_TRN:MAINTENANCE',
                  SUBSTR('TRN:' || p_key || ':' || m.id, 1, 200), CAST(p_due AS TIMESTAMP), NOONA_CTX_PKG.correlation_id, 'INTERNAL');
          l_total := l_total + 1;
          l_any := TRUE;
          IF m.email LIKE '%@%' AND INSTR(',' || l_mails || ',', ',' || m.email || ',') = 0 AND NVL(LENGTH(l_mails), 0) < 3800 THEN
            l_mails := l_mails || CASE WHEN l_mails IS NOT NULL THEN ',' END || m.email;
          END IF;
        EXCEPTION WHEN DUP_VAL_ON_INDEX THEN NULL;         -- نبه سابقاً لنفس المستوى
        END;
      END LOOP;
      IF l_any THEN
        l_new := l_new + 1;
        IF LENGTH(l_list) < 30000 OR l_list IS NULL THEN l_list := l_list || '<li>' || esc(p_title) || '</li>'; END IF;
      END IF;
    END alert;
  BEGIN
    NOONA_CORE_PKG.begin_system;
    FOR c IN (SELECT DISTINCT tenant_id, company_id FROM trn_vehicle
               WHERE status_code <> 'SOLD' AND (p_company_id IS NULL OR company_id = p_company_id)) LOOP
      l_new := 0; l_list := NULL; l_mails := NULL;
      -- القطع: آخر تركيب لكل (عربة، قطعة)؛ المستوى 1 عند الاقتراب (10% من العمر بالكيلومتر أو 7 أيام)، 2 عند التجاوز
      FOR r IN (
        SELECT x.*, CASE WHEN odo >= next_due_km OR next_due_date <= TRUNC(SYSDATE) THEN 2 ELSE 1 END lvl FROM (
          SELECT ln.id, v.plate_no, v.odometer_km odo, ln.description, ln.next_due_km, ln.next_due_date, ln.life_km,
                 ROW_NUMBER() OVER (PARTITION BY o.vehicle_id, NVL(TO_CHAR(ln.item_id), ln.description) ORDER BY o.completed_at DESC, ln.id DESC) rn
            FROM trn_maint_line ln JOIN trn_maint_order o ON o.id = ln.order_id JOIN trn_vehicle v ON v.id = o.vehicle_id
           WHERE o.company_id = c.company_id AND o.status_code = 'COMPLETED' AND v.status_code <> 'SOLD'
             AND (ln.next_due_km IS NOT NULL OR ln.next_due_date IS NOT NULL)) x
         WHERE rn = 1 AND (odo >= next_due_km - NVL(life_km, 0) * 0.1 OR next_due_date <= TRUNC(SYSDATE) + 7)) LOOP
        alert(c.tenant_id, c.company_id, 'TRN_PART_DUE', 'TRN_MAINT_LINE', r.id, 'PART:' || r.id || ':' || r.lvl,
              CASE r.lvl WHEN 2 THEN 'تجاوز موعد استبدال ' ELSE 'اقترب موعد استبدال ' END || r.description || ' - العربة ' || r.plate_no
              || CASE WHEN r.next_due_km IS NOT NULL THEN ' (عند ' || qf(r.next_due_km) || ' كم، العداد ' || qf(r.odo) || ')' END
              || CASE WHEN r.next_due_date IS NOT NULL THEN ' (بتاريخ ' || TO_CHAR(r.next_due_date, 'YYYY-MM-DD') || ')' END,
              NVL(r.next_due_date, TRUNC(SYSDATE)));
      END LOOP;
      -- البرامج الدورية: آخر تنفيذ لكل (عربة، برنامج)
      FOR r IN (
        WITH x AS (
          SELECT v.id vid, v.plate_no, v.odometer_km odo, p.id pid, p.service_name, p.every_km, p.every_days,
                 (SELECT MAX(o.id) FROM trn_maint_order o WHERE o.vehicle_id = v.id AND o.plan_id = p.id AND o.status_code = 'COMPLETED') last_id,
                 (SELECT MAX(o.odometer_km) KEEP (DENSE_RANK LAST ORDER BY o.completed_at) FROM trn_maint_order o
                   WHERE o.vehicle_id = v.id AND o.plan_id = p.id AND o.status_code = 'COMPLETED') last_km,
                 (SELECT MAX(CAST(o.completed_at AS DATE)) FROM trn_maint_order o
                   WHERE o.vehicle_id = v.id AND o.plan_id = p.id AND o.status_code = 'COMPLETED') last_dt,
                 (SELECT COUNT(*) FROM trn_maint_order o WHERE o.vehicle_id = v.id AND o.plan_id = p.id AND o.status_code IN ('OPEN', 'IN_PROGRESS')) open_n
            FROM trn_maint_plan p JOIN trn_vehicle v ON v.company_id = p.company_id
           WHERE p.company_id = c.company_id AND p.status_code = 'ACTIVE' AND v.status_code <> 'SOLD'
             AND (p.vehicle_id = v.id OR (p.vehicle_id IS NULL AND NVL(p.vehicle_type, v.vehicle_type) = v.vehicle_type))),
        y AS (SELECT x.*, CASE WHEN every_km > 0 AND last_dt IS NOT NULL THEN last_km + every_km - odo END km_left,
                     CASE WHEN every_days > 0 AND last_dt IS NOT NULL THEN TRUNC(last_dt + every_days - SYSDATE) END days_left FROM x)
        SELECT y.*, CASE WHEN last_dt IS NULL OR km_left < 0 OR days_left < 0 THEN 2 ELSE 1 END lvl FROM y
         WHERE open_n = 0 AND (last_dt IS NULL OR NVL(km_left, 1e9) <= every_km * 0.1 OR NVL(days_left, 1e9) <= 7)) LOOP
        alert(c.tenant_id, c.company_id, 'TRN_SERVICE_DUE', 'TRN_MAINT_PLAN', r.pid,
              'PLAN:' || r.pid || ':' || r.vid || ':' || NVL(r.last_id, 0) || ':' || r.lvl,
              CASE r.lvl WHEN 2 THEN 'صيانة دورية مستحقة: ' ELSE 'تقترب صيانة دورية: ' END || r.service_name || ' - العربة ' || r.plate_no
              || CASE WHEN r.last_dt IS NULL THEN ' (لم تنفذ سابقاً لهذه العربة)' END
              || CASE WHEN r.km_left IS NOT NULL THEN CASE WHEN r.km_left < 0 THEN ' (تجاوز ' || qf(-r.km_left) || ' كم)' ELSE ' (باقي ' || qf(r.km_left) || ' كم)' END END
              || CASE WHEN r.days_left IS NOT NULL THEN CASE WHEN r.days_left < 0 THEN ' (متأخرة ' || -r.days_left || ' يوم)' ELSE ' (باقي ' || r.days_left || ' يوم)' END END,
              TRUNC(SYSDATE) + NVL(GREATEST(r.days_left, 0), 0));
      END LOOP;
      IF l_new > 0 AND l_mails IS NOT NULL AND NOONA_MAIL_PKG.enabled = 'Y' THEN
        BEGIN
          l_x := NOONA_MAIL_PKG.send(l_mails, 'تنبيهات صيانة الأسطول: ' || l_new || ' بند',
                   NOONA_MAIL_PKG.wrap('تنبيهات صيانة الأسطول', '<ul>' || l_list || '</ul>',
                                       NOONA_MAIL_PKG.url('NOONA_TRN', 'maintenance'), 'فتح صيانة الأسطول'), p_now => FALSE);
        EXCEPTION WHEN OTHERS THEN NULL;                   -- لا يمنع البريد التنبيهات داخل النظام
        END;
      END IF;
    END LOOP;
    NOONA_CORE_PKG.end_system;
    RETURN l_total;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END run_maint_alerts;

  FUNCTION maint_order_status(p_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM trn_maint_order WHERE id = p_id AND company_id = company;
    RETURN l;
  END maint_order_status;

  FUNCTION maint_due_count RETURN NUMBER IS
    l_h CLOB := maint_due_html;
  BEGIN
    RETURN (LENGTH(l_h) - LENGTH(REPLACE(l_h, '<tr><td><b>', ''))) / LENGTH('<tr><td><b>');
  END maint_due_count;

  FUNCTION maint_order_html(p_order_id IN NUMBER) RETURN CLOB IS
    l_m trn_maint_order%ROWTYPE;
    l_h CLOB;
    l_pl VARCHAR2(30);
  BEGIN
    IF p_order_id IS NULL THEN RETURN NULL; END IF;
    SELECT * INTO l_m FROM trn_maint_order WHERE id = p_order_id AND company_id = company;
    SELECT plate_no INTO l_pl FROM trn_vehicle WHERE id = l_m.vehicle_id;
    FOR r IN (SELECT * FROM trn_maint_line WHERE order_id = p_order_id ORDER BY id) LOOP
      l_h := l_h || '<tr><td>' || r.id || '</td><td>' || esc(maint_type_label(r.line_type)) || '</td><td>' || esc(r.description)
          || CASE WHEN r.from_stock = 'Y' THEN ' <span class="nn-badge is-info">من المخزون</span>' END
          || '</td><td class="u-tE">' || qf(r.quantity) || '</td><td class="u-tE">' || fmt(r.unit_cost) || '</td><td class="u-tE">'
          || fmt(r.amount) || '</td></tr>';
    END LOOP;
    RETURN '<div class="nn-kpis"><div class="nn-kpi"><span>' || esc(l_m.doc_no) || ' - ' || esc(l_pl) || '</span><b>' || badge(l_m.status_code)
        || '</b></div><div class="nn-kpi"><span>قطع الغيار والزيوت والإطارات</span><b>' || fmt(l_m.parts_cost) || '</b></div>'
        || '<div class="nn-kpi"><span>العمالة</span><b>' || fmt(l_m.labor_cost) || '</b></div>'
        || '<div class="nn-kpi"><span>الإجمالي دون الضريبة</span><b>' || fmt(l_m.total_cost) || '</b></div>'
        || CASE WHEN l_m.status_code = 'COMPLETED' THEN '<div class="nn-kpi"><span>المعالجة</span><b>' || esc(maint_type_label(l_m.treatment))
             || CASE WHEN l_m.life_extension_months > 0 THEN ' +' || l_m.life_extension_months || ' شهر' END || '</b></div>'
             || '<div class="nn-kpi"><span>التوقف</span><b>' || qf(l_m.downtime_hours) || ' ساعة</b></div>' END || '</div>'
        || '<p>' || esc(maint_type_label(l_m.maint_type)) || ' - ' || esc(maint_type_label(l_m.workshop)) || ': ' || esc(l_m.description) || '</p>'
        || CASE WHEN l_h IS NULL THEN '<p class="nn-hint">لا بنود بعد: أضف قطع الغيار والعمالة أدناه.</p>'
           ELSE '<table class="nn-table"><thead><tr><th>رقم البند</th><th>النوع</th><th>البيان</th><th>الكمية</th><th>التكلفة</th><th>المبلغ</th>'
             || '</tr></thead><tbody>' || l_h || '</tbody></table>' END;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END maint_order_html;

  FUNCTION maint_cost_html(p_from IN DATE DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_from DATE := NVL(p_from, TRUNC(SYSDATE, 'YYYY'));
    l_t NUMBER := 0;
  BEGIN
    FOR r IN (SELECT v.plate_no, v.ownership,
                     COUNT(o.id) n, NVL(SUM(o.total_cost), 0) cost, NVL(SUM(o.downtime_hours), 0) down,
                     NVL(SUM(CASE WHEN o.treatment = 'CAPITALIZE' THEN o.total_cost END), 0) cap,
                     (SELECT NVL(SUM(t.actual_distance_km), 0) FROM trn_trip t WHERE t.vehicle_id = v.id AND t.status_code = 'COMPLETED'
                         AND t.actual_departure >= l_from) km
                FROM trn_vehicle v
                LEFT JOIN trn_maint_order o ON o.vehicle_id = v.id AND o.status_code = 'COMPLETED' AND o.completed_at >= l_from
               WHERE v.company_id = company
               GROUP BY v.id, v.plate_no, v.ownership
              HAVING COUNT(o.id) > 0
               ORDER BY 4 DESC) LOOP
      l_t := l_t + r.cost;
      l_h := l_h || '<tr><td><b>' || esc(r.plate_no) || '</b></td><td class="u-tE">' || r.n || '</td><td class="u-tE">' || fmt(r.cost)
          || '</td><td class="u-tE">' || fmt(r.cap) || '</td><td class="u-tE">' || qf(r.down) || '</td><td class="u-tE">' || qf(r.km)
          || '</td><td class="u-tE">' || CASE WHEN r.km > 0 THEN TO_CHAR(ROUND(r.cost / r.km, 3), 'FM999990.000') ELSE '-' END || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_h IS NULL THEN '<p class="nn-hint">لا صيانات مقفلة منذ ' || TO_CHAR(l_from, 'YYYY-MM-DD') || '.</p>'
           ELSE '<table class="nn-table"><thead><tr><th>العربة</th><th>الأوامر</th><th>التكلفة</th><th>منها رأسمالية</th><th>التوقف (ساعة)</th>'
             || '<th>الكيلومترات</th><th>التكلفة/كم</th></tr></thead><tbody>' || l_h
             || '<tr><td><b>الإجمالي</b></td><td></td><td class="u-tE"><b>' || fmt(l_t) || '</b></td><td colspan="4"></td></tr></tbody></table>' END;
  END maint_cost_html;

  FUNCTION save_driver(p_doc IN CLOB) RETURN NUMBER IS
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    x_licenseExpiry_jd DATE;
    x_allowance_jn NUMBER;
    x_branch_jn NUMBER;
    x_employeeId_jn NUMBER;
    x_code_js VARCHAR2(4000);
    x_hazmat_js VARCHAR2(4000);
    x_licenseClass_js VARCHAR2(4000);
    x_licenseNo_js VARCHAR2(4000);
    x_name_js VARCHAR2(4000);
    x_nationalId_js VARCHAR2(4000);
    x_notes_js VARCHAR2(4000);
    x_phone_js VARCHAR2(4000);
    l_id NUMBER := jn(l_o, 'id');
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'TRN_DRIVER.CREATE' ELSE 'TRN_DRIVER.UPDATE' END);
    NOONA_CORE_PKG.assert(js(l_o, 'name') IS NOT NULL AND js(l_o, 'licenseNo') IS NOT NULL AND jd(l_o, 'licenseExpiry') IS NOT NULL,
      'NOONA-TRN-013', 'اسم السائق ورقم الرخصة وتاريخ انتهائها مطلوبة', 'Name, license and expiry required');
    IF l_id IS NULL THEN
      x_licenseExpiry_jd := jd(l_o, 'licenseExpiry');
      x_allowance_jn := jn(l_o, 'allowance');
      x_branch_jn := jn(l_o, 'branch');
      x_employeeId_jn := jn(l_o, 'employeeId');
      x_code_js := js(l_o, 'code');
      x_hazmat_js := js(l_o, 'hazmat');
      x_licenseClass_js := js(l_o, 'licenseClass');
      x_licenseNo_js := js(l_o, 'licenseNo');
      x_name_js := js(l_o, 'name');
      x_nationalId_js := js(l_o, 'nationalId');
      x_notes_js := js(l_o, 'notes');
      x_phone_js := js(l_o, 'phone');
      INSERT INTO trn_driver (company_id, code, full_name, employee_id, phone, national_id, license_no, license_class, license_expiry,
                              hazmat_certified, trip_allowance, branch_id, status_code, notes)
      VALUES (company, NVL(UPPER(x_code_js), 'D' || x_licenseNo_js), x_name_js, x_employeeId_jn, x_phone_js,
              x_nationalId_js, x_licenseNo_js, x_licenseClass_js, x_licenseExpiry_jd, NVL(x_hazmat_js, 'N'),
              x_allowance_jn, NVL(x_branch_jn, NOONA_CTX_PKG.branch_id), 'AVAILABLE', x_notes_js)
      RETURNING id INTO l_id;
    ELSE
      x_licenseExpiry_jd := jd(l_o, 'licenseExpiry');
      x_allowance_jn := jn(l_o, 'allowance');
      x_branch_jn := jn(l_o, 'branch');
      x_employeeId_jn := jn(l_o, 'employeeId');
      x_hazmat_js := js(l_o, 'hazmat');
      x_licenseClass_js := js(l_o, 'licenseClass');
      x_licenseNo_js := js(l_o, 'licenseNo');
      x_name_js := js(l_o, 'name');
      x_nationalId_js := js(l_o, 'nationalId');
      x_notes_js := js(l_o, 'notes');
      x_phone_js := js(l_o, 'phone');
      UPDATE trn_driver SET full_name = x_name_js, employee_id = x_employeeId_jn, phone = x_phone_js,
             national_id = x_nationalId_js, license_no = x_licenseNo_js, license_class = x_licenseClass_js,
             license_expiry = x_licenseExpiry_jd, hazmat_certified = NVL(x_hazmat_js, hazmat_certified),
             trip_allowance = x_allowance_jn, branch_id = NVL(x_branch_jn, branch_id), notes = x_notes_js
       WHERE id = l_id AND company_id = company;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-TRN-014', 'السائق غير موجود', 'Driver not found');
    END IF;
    RETURN l_id;
  END save_driver;

  PROCEDURE set_driver_status(p_id IN NUMBER, p_status IN VARCHAR2) IS
    l_n NUMBER;
  BEGIN
    guard('TRN_DRIVER.UPDATE');
    NOONA_CORE_PKG.assert(p_status IN ('AVAILABLE', 'OFF_DUTY', 'SUSPENDED', 'LEFT'), 'NOONA-TRN-011', 'حالة غير صحيحة', 'Invalid status');
    SELECT COUNT(*) INTO l_n FROM trn_trip WHERE (driver_id = p_id OR co_driver_id = p_id) AND status_code IN ('DISPATCHED', 'IN_TRANSIT', 'ARRIVED');
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-TRN-015', 'السائق في رحلة جارية', 'Driver is on an active trip');
    UPDATE trn_driver SET status_code = p_status WHERE id = p_id AND company_id = company;
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-TRN-014', 'السائق غير موجود', 'Driver not found');
  END set_driver_status;

  FUNCTION save_rate(p_doc IN CLOB) RETURN NUMBER IS
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    x_from_jd DATE;
    x_to_jd DATE;
    x_cargo_jn NUMBER;
    x_customer_jn NUMBER;
    x_minCharge_jn NUMBER;
    x_priority_jn NUMBER;
    x_rate_jn NUMBER;
    x_route_jn NUMBER;
    x_code_js VARCHAR2(4000);
    x_name_js VARCHAR2(4000);
    l_id NUMBER := jn(l_o, 'id');
    l_b  VARCHAR2(30) := UPPER(js(l_o, 'basis'));
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'TRN_RATE.CREATE' ELSE 'TRN_RATE.UPDATE' END);
    NOONA_CORE_PKG.assert(l_b IN ('PER_METRIC_TON', 'PER_SHORT_TON', 'PER_LONG_TON', 'PER_KG', 'PER_M3', 'PER_LITER', 'PER_KM', 'PER_TON_KM',
      'PER_TRIP', 'PER_CONTAINER', 'PER_PALLET', 'PER_PIECE'), 'NOONA-TRN-016', 'اختر أساس حساب الترحيل', 'Choose a rate basis');
    NOONA_CORE_PKG.assert(NVL(jn(l_o, 'rate'), -1) >= 0, 'NOONA-TRN-017', 'السعر مطلوب', 'Rate required');
    IF l_id IS NULL THEN
      x_from_jd := jd(l_o, 'from');
      x_to_jd := jd(l_o, 'to');
      x_cargo_jn := jn(l_o, 'cargo');
      x_customer_jn := jn(l_o, 'customer');
      x_minCharge_jn := jn(l_o, 'minCharge');
      x_priority_jn := jn(l_o, 'priority');
      x_rate_jn := jn(l_o, 'rate');
      x_route_jn := jn(l_o, 'route');
      x_code_js := js(l_o, 'code');
      x_name_js := js(l_o, 'name');
      INSERT INTO trn_rate (company_id, code, name_ar, customer_account_id, route_id, cargo_type_id, rate_basis, rate_amount, min_charge,
                            priority_no, effective_from, effective_to, status_code)
      VALUES (company, NVL(UPPER(x_code_js), 'RT-' || RAWTOHEX(SYS_GUID())), NVL(x_name_js, basis_label(l_b)),
              x_customer_jn, x_route_jn, x_cargo_jn, l_b, x_rate_jn, x_minCharge_jn, NVL(x_priority_jn, 100),
              NVL(x_from_jd, TRUNC(SYSDATE)), x_to_jd, 'ACTIVE')
      RETURNING id INTO l_id;
    ELSE
      x_to_jd := jd(l_o, 'to');
      x_cargo_jn := jn(l_o, 'cargo');
      x_customer_jn := jn(l_o, 'customer');
      x_minCharge_jn := jn(l_o, 'minCharge');
      x_priority_jn := jn(l_o, 'priority');
      x_rate_jn := jn(l_o, 'rate');
      x_route_jn := jn(l_o, 'route');
      x_name_js := js(l_o, 'name');
      UPDATE trn_rate SET name_ar = NVL(x_name_js, name_ar), customer_account_id = x_customer_jn, route_id = x_route_jn,
             cargo_type_id = x_cargo_jn, rate_basis = l_b, rate_amount = x_rate_jn, min_charge = x_minCharge_jn,
             priority_no = NVL(x_priority_jn, priority_no), effective_to = x_to_jd
       WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  END save_rate;

  -- ================================================================ الوحدات والترحيل
  FUNCTION to_kg(p_qty IN NUMBER, p_uom IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN ROUND(p_qty * CASE p_uom WHEN 'METRIC_TON' THEN 1000 WHEN 'SHORT_TON' THEN c_short WHEN 'LONG_TON' THEN c_long WHEN 'KG' THEN 1 END, 3);
  END to_kg;

  FUNCTION convert_weight(p_qty IN NUMBER, p_from IN VARCHAR2, p_to IN VARCHAR2) RETURN NUMBER IS
    l_kg NUMBER := to_kg(p_qty, p_from);
  BEGIN
    RETURN ROUND(l_kg / CASE p_to WHEN 'METRIC_TON' THEN 1000 WHEN 'SHORT_TON' THEN c_short WHEN 'LONG_TON' THEN c_long WHEN 'KG' THEN 1 END, 6);
  END convert_weight;

  FUNCTION freight(p_basis IN VARCHAR2, p_rate IN NUMBER, p_qty IN NUMBER, p_uom IN VARCHAR2, p_weight_kg IN NUMBER,
                   p_volume IN NUMBER, p_distance IN NUMBER, p_min IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_kg NUMBER := NVL(p_weight_kg, to_kg(p_qty, p_uom));
    l    NUMBER;
    PROCEDURE need(p_ok BOOLEAN, p_what VARCHAR2) IS
    BEGIN
      NOONA_CORE_PKG.assert(p_ok, 'NOONA-TRN-018', 'لحساب الترحيل ' || basis_label(p_basis) || ' أدخل ' || p_what, 'Missing measure for rate basis');
    END need;
  BEGIN
    CASE p_basis
      WHEN 'PER_METRIC_TON' THEN need(l_kg IS NOT NULL, 'الوزن'); l := p_rate * l_kg / 1000;
      WHEN 'PER_SHORT_TON' THEN need(l_kg IS NOT NULL, 'الوزن'); l := p_rate * l_kg / c_short;
      WHEN 'PER_LONG_TON' THEN need(l_kg IS NOT NULL, 'الوزن'); l := p_rate * l_kg / c_long;
      WHEN 'PER_KG' THEN need(l_kg IS NOT NULL, 'الوزن'); l := p_rate * l_kg;
      WHEN 'PER_M3' THEN need(NVL(p_volume, CASE WHEN p_uom = 'M3' THEN p_qty END) IS NOT NULL, 'الحجم بالمتر المكعب');
                        l := p_rate * NVL(p_volume, p_qty);
      WHEN 'PER_LITER' THEN need(p_uom = 'LITER', 'الكمية باللتر'); l := p_rate * p_qty;
      WHEN 'PER_KM' THEN need(p_distance IS NOT NULL, 'المسافة (اختر المسار)'); l := p_rate * p_distance;
      WHEN 'PER_TON_KM' THEN need(l_kg IS NOT NULL AND p_distance IS NOT NULL, 'الوزن والمسافة'); l := p_rate * l_kg / 1000 * p_distance;
      WHEN 'PER_TRIP' THEN l := p_rate * CASE WHEN p_uom = 'TRIP' THEN p_qty ELSE 1 END;
      WHEN 'PER_CONTAINER' THEN need(p_uom = 'CONTAINER', 'عدد الحاويات'); l := p_rate * p_qty;
      WHEN 'PER_PALLET' THEN need(p_uom = 'PALLET', 'عدد الطبليات'); l := p_rate * p_qty;
      WHEN 'PER_PIECE' THEN need(p_uom = 'PIECE', 'عدد القطع'); l := p_rate * p_qty;
      ELSE NOONA_CORE_PKG.raise_error('NOONA-TRN-016', 'اختر أساس حساب الترحيل', 'Choose a rate basis');
    END CASE;
    RETURN ROUND(GREATEST(l, NVL(p_min, 0)), 2);
  END freight;

  -- أخص تعرفة سارية: العميل ثم المسار ثم نوع الشحنة، ثم الأولوية
  FUNCTION find_rate(p_customer IN NUMBER, p_route IN NUMBER, p_cargo IN NUMBER, p_date IN DATE DEFAULT NULL) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY
             CASE WHEN customer_account_id IS NOT NULL THEN 0 ELSE 1 END, CASE WHEN route_id IS NOT NULL THEN 0 ELSE 1 END,
             CASE WHEN cargo_type_id IS NOT NULL THEN 0 ELSE 1 END, priority_no, id) INTO l
      FROM trn_rate
     WHERE company_id = company AND status_code = 'ACTIVE'
       AND NVL(p_date, TRUNC(SYSDATE)) BETWEEN effective_from AND NVL(effective_to, DATE '9999-12-31')
       AND (customer_account_id IS NULL OR customer_account_id = p_customer)
       AND (route_id IS NULL OR route_id = p_route)
       AND (cargo_type_id IS NULL OR cargo_type_id = p_cargo);
    RETURN l;
  END find_rate;

  -- يحسب الترحيل لأمر (أو مسودة): يعيد التعرفة والأساس والسعر والوزن والمسافة والقيمة
  PROCEDURE price(p_customer NUMBER, p_from NUMBER, p_to NUMBER, p_cargo NUMBER, p_qty NUMBER, p_uom VARCHAR2, p_kg NUMBER, p_vol NUMBER,
                  p_rate_id NUMBER, p_basis VARCHAR2, p_rate NUMBER, p_date DATE,
                  o_route OUT NUMBER, o_rate_id OUT NUMBER, o_basis OUT VARCHAR2, o_rate OUT NUMBER, o_kg OUT NUMBER, o_dist OUT NUMBER,
                  o_freight OUT NUMBER) IS
    r trn_rate%ROWTYPE;
  BEGIN
    o_route := find_route(p_from, p_to);
    IF o_route IS NOT NULL THEN SELECT distance_km INTO o_dist FROM trn_route WHERE id = o_route; END IF;
    o_kg := NVL(p_kg, to_kg(p_qty, p_uom));
    IF p_basis IS NOT NULL THEN
      -- سعر يدوي متفق عليه
      o_rate_id := NULL; o_basis := p_basis; o_rate := p_rate;
      o_freight := freight(o_basis, o_rate, p_qty, p_uom, o_kg, p_vol, o_dist);
    ELSE
      o_rate_id := NVL(p_rate_id, find_rate(p_customer, o_route, p_cargo, p_date));
      NOONA_CORE_PKG.assert(o_rate_id IS NOT NULL, 'NOONA-TRN-019',
        'لا توجد تعرفة سارية لهذا العميل والمسار ونوع الشحنة؛ أضف تعرفة أو أدخل السعر يدوياً', 'No applicable rate');
      SELECT * INTO r FROM trn_rate WHERE id = o_rate_id AND company_id = company;
      o_basis := r.rate_basis; o_rate := r.rate_amount;
      o_freight := freight(o_basis, o_rate, p_qty, p_uom, o_kg, p_vol, o_dist, r.min_charge);
    END IF;
  END price;

  FUNCTION quote_json(p_doc IN CLOB) RETURN CLOB IS
    l_o JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_route NUMBER; l_rid NUMBER; l_basis VARCHAR2(30); l_rate NUMBER; l_kg NUMBER; l_dist NUMBER; l_fr NUMBER;
  BEGIN
    guard('TRN_ORDER.VIEW');
    price(jn(l_o, 'customer'), jn(l_o, 'from'), jn(l_o, 'to'), jn(l_o, 'cargo'), jn(l_o, 'qty'), js(l_o, 'uom'), jn(l_o, 'weightKg'),
          jn(l_o, 'volume'), jn(l_o, 'rateId'), js(l_o, 'basis'), jn(l_o, 'rate'), NVL(jd(l_o, 'date'), TRUNC(SYSDATE)),
          l_route, l_rid, l_basis, l_rate, l_kg, l_dist, l_fr);
    RETURN '{"routeId":' || num(l_route) || ',"rateId":' || num(l_rid) || ',"basis":"' || l_basis || '","basisLabel":' || jt(basis_label(l_basis))
        || ',"rate":' || num(l_rate) || ',"weightKg":' || num(l_kg) || ',"distanceKm":' || num(l_dist) || ',"freight":' || num(l_fr) || '}';
  END quote_json;

  -- ================================================================ أوامر الشحن
  FUNCTION get_order(p_id NUMBER, p_lock BOOLEAN DEFAULT FALSE) RETURN trn_order%ROWTYPE IS
    r trn_order%ROWTYPE;
  BEGIN
    IF p_lock THEN
      SELECT * INTO r FROM trn_order WHERE id = p_id AND company_id = company FOR UPDATE;
    ELSE
      SELECT * INTO r FROM trn_order WHERE id = p_id AND company_id = company;
    END IF;
    RETURN r;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-TRN-020', 'أمر الشحن غير موجود', 'Shipment order not found');
  END get_order;

  FUNCTION order_label(p_order_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(1000);
  BEGIN
    SELECT o.doc_no || ' · ' || c.name_ar || ' · ' || qf(o.quantity) || ' ' || uom_label(o.uom_code) || ' · '
           || f.name_ar || ' ← ' || t.name_ar INTO l
      FROM trn_order o JOIN trn_cargo_type c ON c.id = o.cargo_type_id
      JOIN trn_location f ON f.id = o.from_location_id JOIN trn_location t ON t.id = o.to_location_id
     WHERE o.id = p_order_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
  END order_label;

  FUNCTION save_order(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_no VARCHAR2(50);
    x_date_jd DATE;
    x_deliveryDate_jd DATE;
    x_pickupDate_jd DATE;
    x_declaredValue_jn NUMBER;
    x_packages_jn NUMBER;
    x_volume_jn NUMBER;
    x_customerRef_js VARCHAR2(4000);
    x_description_js VARCHAR2(4000);
    x_notes_js VARCHAR2(4000);
    l_id   NUMBER := jn(l_o, 'id');
    l_cust NUMBER := jn(l_o, 'customer');
    l_f    NUMBER := jn(l_o, 'from');
    l_t    NUMBER := jn(l_o, 'to');
    l_cg   NUMBER := jn(l_o, 'cargo');
    l_q    NUMBER := jn(l_o, 'qty');
    l_u    VARCHAR2(30) := UPPER(js(l_o, 'uom'));
    l_oc   NUMBER := NVL(jn(l_o, 'otherCharges'), 0);
    l_route NUMBER; l_rid NUMBER; l_basis VARCHAR2(30); l_rate NUMBER; l_kg NUMBER; l_dist NUMBER; l_fr NUMBER;
    l_n    NUMBER;
    r      trn_order%ROWTYPE;
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'TRN_ORDER.CREATE' ELSE 'TRN_ORDER.UPDATE' END);
    NOONA_CORE_PKG.assert(l_cust IS NOT NULL, 'NOONA-TRN-021', 'اختر العميل', 'Customer required');
    SELECT COUNT(*) INTO l_n FROM ar_customer_account WHERE id = l_cust AND company_id = company;
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-TRN-021', 'العميل غير موجود في الشركة', 'Customer not found');
    NOONA_CORE_PKG.assert(l_f IS NOT NULL AND l_t IS NOT NULL AND l_f <> l_t, 'NOONA-TRN-022', 'اختر مكان التحميل ومكان التفريغ (مختلفين)', 'Choose pickup and delivery');
    NOONA_CORE_PKG.assert(l_cg IS NOT NULL, 'NOONA-TRN-023', 'اختر نوع الشحنة', 'Cargo type required');
    NOONA_CORE_PKG.assert(NVL(l_q, 0) > 0, 'NOONA-TRN-024', 'الكمية أكبر من صفر', 'Quantity must be positive');
    IF l_u IS NULL THEN SELECT default_unit INTO l_u FROM trn_cargo_type WHERE id = l_cg; END IF;
    NOONA_CORE_PKG.assert(l_u IN ('METRIC_TON', 'SHORT_TON', 'LONG_TON', 'KG', 'M3', 'LITER', 'CONTAINER', 'PALLET', 'PIECE', 'TRIP'),
      'NOONA-TRN-025', 'وحدة القياس غير صحيحة', 'Invalid unit');
    NOONA_CORE_PKG.assert(jd(l_o, 'deliveryDate') IS NULL OR jd(l_o, 'pickupDate') IS NULL OR jd(l_o, 'deliveryDate') >= jd(l_o, 'pickupDate'),
      'NOONA-TRN-026', 'تاريخ التسليم قبل تاريخ التحميل', 'Delivery before pickup');
    price(l_cust, l_f, l_t, l_cg, l_q, l_u, jn(l_o, 'weightKg'), jn(l_o, 'volume'), jn(l_o, 'rateId'), UPPER(js(l_o, 'basis')), jn(l_o, 'rate'),
          NVL(jd(l_o, 'pickupDate'), TRUNC(SYSDATE)), l_route, l_rid, l_basis, l_rate, l_kg, l_dist, l_fr);
    IF l_id IS NULL THEN
      x_date_jd := jd(l_o, 'date');
      x_deliveryDate_jd := jd(l_o, 'deliveryDate');
      x_pickupDate_jd := jd(l_o, 'pickupDate');
      x_declaredValue_jn := jn(l_o, 'declaredValue');
      x_packages_jn := jn(l_o, 'packages');
      x_volume_jn := jn(l_o, 'volume');
      x_customerRef_js := js(l_o, 'customerRef');
      x_description_js := js(l_o, 'description');
      x_notes_js := js(l_o, 'notes');
      l_no := next_no(c_ord, 'SHP-');
      INSERT INTO trn_order (company_id, branch_id, doc_no, doc_date, customer_account_id, customer_ref, from_location_id, to_location_id, route_id,
                             cargo_type_id, cargo_description, quantity, uom_code, weight_kg, volume_m3, packages_count, declared_value, rate_id,
                             rate_basis, rate_amount, freight_amount, other_charges, total_amount, pickup_date, required_delivery_date, status_code, notes)
      VALUES (company, NOONA_CTX_PKG.branch_id, l_no, NVL(x_date_jd, TRUNC(SYSDATE)), l_cust, x_customerRef_js,
              l_f, l_t, l_route, l_cg, x_description_js, l_q, l_u, l_kg, x_volume_jn, x_packages_jn, x_declaredValue_jn,
              l_rid, l_basis, l_rate, l_fr, l_oc, l_fr + l_oc, x_pickupDate_jd, x_deliveryDate_jd, 'DRAFT', x_notes_js)
      RETURNING id INTO l_id;
    ELSE
      r := get_order(l_id, TRUE);
      NOONA_CORE_PKG.assert(r.status_code IN ('DRAFT', 'CONFIRMED'), 'NOONA-TRN-027', 'لا يعدل أمر شحن بعد جدولته في رحلة', 'Order already scheduled');
      x_deliveryDate_jd := jd(l_o, 'deliveryDate');
      x_pickupDate_jd := jd(l_o, 'pickupDate');
      x_declaredValue_jn := jn(l_o, 'declaredValue');
      x_packages_jn := jn(l_o, 'packages');
      x_volume_jn := jn(l_o, 'volume');
      x_customerRef_js := js(l_o, 'customerRef');
      x_description_js := js(l_o, 'description');
      x_notes_js := js(l_o, 'notes');
      UPDATE trn_order SET customer_account_id = l_cust, customer_ref = x_customerRef_js, from_location_id = l_f, to_location_id = l_t,
             route_id = l_route, cargo_type_id = l_cg, cargo_description = x_description_js, quantity = l_q, uom_code = l_u, weight_kg = l_kg,
             volume_m3 = x_volume_jn, packages_count = x_packages_jn, declared_value = x_declaredValue_jn, rate_id = l_rid,
             rate_basis = l_basis, rate_amount = l_rate, freight_amount = l_fr, other_charges = l_oc, total_amount = l_fr + l_oc,
             pickup_date = x_pickupDate_jd, required_delivery_date = x_deliveryDate_jd, notes = x_notes_js
       WHERE id = l_id;
    END IF;
    RETURN l_id;
  END save_order;

  PROCEDURE confirm_order(p_id IN NUMBER) IS
    r trn_order%ROWTYPE;
  BEGIN
    guard('TRN_ORDER.UPDATE');
    r := get_order(p_id, TRUE);
    NOONA_CORE_PKG.assert(r.status_code = 'DRAFT', 'NOONA-TRN-028', 'الأمر مؤكد مسبقاً', 'Order already confirmed');
    NOONA_CORE_PKG.assert(r.total_amount > 0, 'NOONA-TRN-029', 'قيمة الترحيل صفر؛ راجع التعرفة', 'Freight is zero');
    UPDATE trn_order SET status_code = 'CONFIRMED' WHERE id = p_id;
  END confirm_order;

  PROCEDURE cancel_order(p_id IN NUMBER, p_reason IN VARCHAR2) IS
    r trn_order%ROWTYPE;
  BEGIN
    guard('TRN_ORDER.UPDATE');
    r := get_order(p_id, TRUE);
    NOONA_CORE_PKG.assert(r.status_code IN ('DRAFT', 'CONFIRMED'), 'NOONA-TRN-030', 'لا يلغى أمر مجدول في رحلة؛ أخرجه منها أولاً', 'Order is on a trip');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-TRN-031', 'سبب الإلغاء مطلوب', 'Reason required');
    UPDATE trn_order SET status_code = 'CANCELLED', notes = SUBSTR(notes || CHR(10) || 'إلغاء: ' || p_reason, 1, 4000) WHERE id = p_id;
  END cancel_order;

  -- ================================================================ الرحلات
  FUNCTION get_trip(p_id NUMBER, p_lock BOOLEAN DEFAULT FALSE) RETURN trn_trip%ROWTYPE IS
    r trn_trip%ROWTYPE;
  BEGIN
    IF p_lock THEN
      SELECT * INTO r FROM trn_trip WHERE id = p_id AND company_id = company FOR UPDATE;
    ELSE
      SELECT * INTO r FROM trn_trip WHERE id = p_id AND company_id = company;
    END IF;
    RETURN r;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-TRN-040', 'الرحلة غير موجودة', 'Trip not found');
  END get_trip;

  FUNCTION eta_of(p_trip_id IN NUMBER) RETURN TIMESTAMP IS
    t     trn_trip%ROWTYPE;
    l_h   NUMBER;
    l_min NUMBER;
  BEGIN
    SELECT * INTO t FROM trn_trip WHERE id = p_trip_id;
    IF t.route_id IS NOT NULL THEN
      SELECT standard_hours INTO l_h FROM trn_route WHERE id = t.route_id;
    ELSE
      l_h := NVL(t.planned_distance_km, 0) / 70;
    END IF;
    SELECT NVL(SUM(planned_minutes), 0) INTO l_min FROM trn_trip_stop WHERE trip_id = p_trip_id;
    RETURN NVL(t.actual_departure, t.planned_departure) + NUMTODSINTERVAL(l_h * 60 + l_min + NVL(t.delay_minutes, 0), 'MINUTE');
  END eta_of;

  PROCEDURE recalc_trip(p_trip_id IN NUMBER) IS
    l_eta TIMESTAMP;
  BEGIN
    UPDATE trn_trip t SET
      load_kg = (SELECT NVL(SUM(loaded_kg), 0) FROM trn_trip_order WHERE trip_id = t.id),
      revenue_amount = (SELECT NVL(SUM(o.total_amount), 0) FROM trn_trip_order x JOIN trn_order o ON o.id = x.order_id WHERE x.trip_id = t.id),
      expense_amount = (SELECT NVL(SUM(amount), 0) FROM trn_trip_expense WHERE trip_id = t.id)
     WHERE id = p_trip_id;
    l_eta := eta_of(p_trip_id);
    UPDATE trn_trip SET eta = l_eta WHERE id = p_trip_id AND actual_arrival IS NULL;
  END recalc_trip;

  FUNCTION timeliness(p_trip_id IN NUMBER) RETURN VARCHAR2 IS
    t trn_trip%ROWTYPE;
  BEGIN
    SELECT * INTO t FROM trn_trip WHERE id = p_trip_id;
    IF t.status_code IN ('PLANNED', 'CANCELLED') THEN RETURN NULL; END IF;
    IF t.actual_arrival IS NULL THEN
      RETURN CASE WHEN SYSTIMESTAMP > t.eta THEN 'AT_RISK' WHEN t.delay_minutes > 0 THEN 'LATE' ELSE 'ON_TIME' END;
    END IF;
    -- المقارنة بالموعد الأصلي (بلا تأخير الأعطال) مع سماحية 30 دقيقة
    RETURN CASE WHEN t.actual_arrival > t.eta - NUMTODSINTERVAL(t.delay_minutes, 'MINUTE') + INTERVAL '30' MINUTE THEN 'LATE'
                WHEN t.actual_arrival < t.eta - NUMTODSINTERVAL(t.delay_minutes, 'MINUTE') - INTERVAL '60' MINUTE THEN 'EARLY'
                ELSE 'ON_TIME' END;
  END timeliness;

  PROCEDURE check_vehicle_driver(p_vehicle NUMBER, p_driver NUMBER, p_codriver NUMBER, p_at TIMESTAMP, p_trip NUMBER) IS
    v trn_vehicle%ROWTYPE;
    d trn_driver%ROWTYPE;
    l_n NUMBER;
  BEGIN
    BEGIN
      SELECT * INTO v FROM trn_vehicle WHERE id = p_vehicle AND company_id = company;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-TRN-010', 'العربة غير موجودة', 'Vehicle not found');
    END;
    NOONA_CORE_PKG.assert(v.status_code IN ('AVAILABLE', 'ON_TRIP'), 'NOONA-TRN-041', 'العربة ' || v.plate_no || ' ' || status_label(v.status_code),
      'Vehicle not available');
    NOONA_CORE_PKG.assert(v.license_expiry IS NULL OR v.license_expiry >= TRUNC(CAST(p_at AS DATE)), 'NOONA-TRN-042',
      'ترخيص العربة ' || v.plate_no || ' منتهٍ في ' || TO_CHAR(v.license_expiry, 'YYYY-MM-DD'), 'Vehicle license expired');
    NOONA_CORE_PKG.assert(v.insurance_expiry IS NULL OR v.insurance_expiry >= TRUNC(CAST(p_at AS DATE)), 'NOONA-TRN-043',
      'تأمين العربة ' || v.plate_no || ' منتهٍ في ' || TO_CHAR(v.insurance_expiry, 'YYYY-MM-DD'), 'Vehicle insurance expired');
    SELECT COUNT(*) INTO l_n FROM trn_trip WHERE vehicle_id = p_vehicle AND id <> NVL(p_trip, -1)
       AND status_code IN ('DISPATCHED', 'IN_TRANSIT', 'ARRIVED');
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-TRN-044', 'العربة ' || v.plate_no || ' في رحلة جارية', 'Vehicle on another active trip');
    FOR x IN (SELECT p_driver id FROM dual UNION ALL SELECT p_codriver FROM dual WHERE p_codriver IS NOT NULL) LOOP
      BEGIN
        SELECT * INTO d FROM trn_driver WHERE id = x.id AND company_id = company;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        NOONA_CORE_PKG.raise_error('NOONA-TRN-014', 'السائق غير موجود', 'Driver not found');
      END;
      NOONA_CORE_PKG.assert(d.status_code IN ('AVAILABLE', 'ON_TRIP'), 'NOONA-TRN-045', 'السائق ' || d.full_name || ' ' || status_label(d.status_code),
        'Driver not available');
      NOONA_CORE_PKG.assert(d.license_expiry >= TRUNC(CAST(p_at AS DATE)), 'NOONA-TRN-046',
        'رخصة السائق ' || d.full_name || ' منتهية في ' || TO_CHAR(d.license_expiry, 'YYYY-MM-DD'), 'Driver license expired');
      SELECT COUNT(*) INTO l_n FROM trn_trip WHERE (driver_id = x.id OR co_driver_id = x.id) AND id <> NVL(p_trip, -1)
         AND status_code IN ('DISPATCHED', 'IN_TRANSIT', 'ARRIVED');
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-TRN-047', 'السائق ' || d.full_name || ' في رحلة جارية', 'Driver on another active trip');
    END LOOP;
    NOONA_CORE_PKG.assert(p_codriver IS NULL OR p_codriver <> p_driver, 'NOONA-TRN-048', 'السائق المساعد هو نفسه السائق', 'Co-driver equals driver');
  END check_vehicle_driver;

  FUNCTION create_trip(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_no VARCHAR2(50);
    x_notes_js VARCHAR2(4000);
    l_v   NUMBER := jn(l_o, 'vehicle');
    l_d   NUMBER := jn(l_o, 'driver');
    l_cd  NUMBER := jn(l_o, 'coDriver');
    l_f   NUMBER := jn(l_o, 'from');
    l_t   NUMBER := jn(l_o, 'to');
    l_r   NUMBER := jn(l_o, 'route');
    l_at  TIMESTAMP := NVL(jts(l_o, 'departure'), SYSTIMESTAMP);
    l_id  NUMBER;
    l_dist NUMBER;
    l_ord JSON_ARRAY_T;
  BEGIN
    guard('TRN_TRIP.CREATE');
    IF l_r IS NOT NULL THEN
      SELECT from_location_id, to_location_id INTO l_f, l_t FROM trn_route WHERE id = l_r AND company_id = company;
    END IF;
    NOONA_CORE_PKG.assert(l_f IS NOT NULL AND l_t IS NOT NULL AND l_f <> l_t, 'NOONA-TRN-049', 'اختر المسار أو مدينتي البداية والوصول', 'Choose route');
    l_r := NVL(l_r, find_route(l_f, l_t));
    IF l_r IS NOT NULL THEN SELECT distance_km INTO l_dist FROM trn_route WHERE id = l_r; END IF;
    NOONA_CORE_PKG.assert(l_v IS NOT NULL AND l_d IS NOT NULL, 'NOONA-TRN-050', 'اختر العربة والسائق', 'Vehicle and driver required');
    check_vehicle_driver(l_v, l_d, l_cd, l_at, NULL);
    x_notes_js := js(l_o, 'notes');
    l_no := next_no(c_trip, 'TRP-');
    INSERT INTO trn_trip (company_id, branch_id, doc_no, doc_date, vehicle_id, driver_id, co_driver_id, route_id, from_location_id, to_location_id,
                          planned_departure, planned_distance_km, status_code, notes)
    VALUES (company, NOONA_CTX_PKG.branch_id, l_no, TRUNC(CAST(l_at AS DATE)), l_v, l_d, l_cd, l_r, l_f, l_t,
            l_at, l_dist, 'PLANNED', x_notes_js)
    RETURNING id INTO l_id;
    IF l_o.has('orders') THEN
      l_ord := l_o.get_array('orders');
      FOR i IN 0 .. l_ord.get_size - 1 LOOP
        add_order(l_id, l_ord.get_number(i));
      END LOOP;
    END IF;
    recalc_trip(l_id);
    RETURN l_id;
  END create_trip;

  PROCEDURE add_order(p_trip_id IN NUMBER, p_order_id IN NUMBER) IS
    t   trn_trip%ROWTYPE;
    o   trn_order%ROWTYPE;
    v   trn_vehicle%ROWTYPE;
    c   trn_cargo_type%ROWTYPE;
    l_load NUMBER;
    l_hz   NUMBER;
  BEGIN
    guard('TRN_TRIP.UPDATE');
    t := get_trip(p_trip_id, TRUE);
    NOONA_CORE_PKG.assert(t.status_code = 'PLANNED', 'NOONA-TRN-051', 'تضاف الشحنات قبل تحرك الرحلة فقط', 'Trip already departed');
    o := get_order(p_order_id, TRUE);
    NOONA_CORE_PKG.assert(o.status_code = 'CONFIRMED', 'NOONA-TRN-052', 'أمر الشحن ' || o.doc_no || ' غير مؤكد أو مجدول في رحلة أخرى', 'Order not confirmed');
    SELECT * INTO v FROM trn_vehicle WHERE id = t.vehicle_id;
    SELECT * INTO c FROM trn_cargo_type WHERE id = o.cargo_type_id;
    SELECT NVL(SUM(loaded_kg), 0) INTO l_load FROM trn_trip_order WHERE trip_id = p_trip_id;
    NOONA_CORE_PKG.assert(o.weight_kg IS NULL OR l_load + o.weight_kg <= v.capacity_tons * 1000, 'NOONA-TRN-053',
      'الحمولة تتجاوز طاقة العربة ' || v.plate_no || ': ' || qf((l_load + o.weight_kg) / 1000) || ' طن من ' || qf(v.capacity_tons) || ' طن',
      'Vehicle capacity exceeded');
    NOONA_CORE_PKG.assert(c.required_vehicle_type IS NULL OR c.required_vehicle_type = v.vehicle_type, 'NOONA-TRN-054',
      'الشحنة «' || c.name_ar || '» تتطلب عربة من نوع ' || c.required_vehicle_type, 'Cargo requires another vehicle type');
    IF c.cargo_category = 'HAZARDOUS' THEN
      SELECT COUNT(*) INTO l_hz FROM trn_driver WHERE id = t.driver_id AND hazmat_certified = 'Y';
      NOONA_CORE_PKG.assert(l_hz = 1, 'NOONA-TRN-055', 'المواد الخطرة تتطلب سائقاً مؤهلاً لنقلها', 'Hazmat certified driver required');
    END IF;
    INSERT INTO trn_trip_order (company_id, trip_id, order_id, loaded_qty, loaded_kg) VALUES (company, p_trip_id, p_order_id, o.quantity, NVL(o.weight_kg, 0));
    UPDATE trn_order SET status_code = 'PLANNED' WHERE id = p_order_id;
    -- محطتا التحميل والتفريغ للشحنة إذا كانت خارج طرفي الرحلة
    IF o.from_location_id <> t.from_location_id THEN
      INSERT INTO trn_trip_stop (company_id, trip_id, location_id, stop_purpose, planned_minutes, sort_order)
      SELECT company, p_trip_id, o.from_location_id, 'LOADING', 60, 10 FROM dual
       WHERE NOT EXISTS (SELECT 1 FROM trn_trip_stop WHERE trip_id = p_trip_id AND location_id = o.from_location_id AND stop_purpose = 'LOADING');
    END IF;
    IF o.to_location_id <> t.to_location_id THEN
      INSERT INTO trn_trip_stop (company_id, trip_id, location_id, stop_purpose, planned_minutes, sort_order)
      SELECT company, p_trip_id, o.to_location_id, 'UNLOADING', 60, 90 FROM dual
       WHERE NOT EXISTS (SELECT 1 FROM trn_trip_stop WHERE trip_id = p_trip_id AND location_id = o.to_location_id AND stop_purpose = 'UNLOADING');
    END IF;
    recalc_trip(p_trip_id);
  END add_order;

  PROCEDURE remove_order(p_trip_id IN NUMBER, p_order_id IN NUMBER) IS
    t trn_trip%ROWTYPE;
  BEGIN
    guard('TRN_TRIP.UPDATE');
    t := get_trip(p_trip_id, TRUE);
    NOONA_CORE_PKG.assert(t.status_code = 'PLANNED', 'NOONA-TRN-051', 'تعدل الشحنات قبل تحرك الرحلة فقط', 'Trip already departed');
    DELETE FROM trn_trip_order WHERE trip_id = p_trip_id AND order_id = p_order_id;
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-TRN-056', 'الشحنة ليست في هذه الرحلة', 'Order not on trip');
    UPDATE trn_order SET status_code = 'CONFIRMED' WHERE id = p_order_id;
    recalc_trip(p_trip_id);
  END remove_order;

  FUNCTION add_stop(p_trip_id IN NUMBER, p_location_id IN NUMBER, p_purpose IN VARCHAR2, p_minutes IN NUMBER DEFAULT 0,
                    p_sort IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    t    trn_trip%ROWTYPE;
    l_id NUMBER;
    l_s  NUMBER;
  BEGIN
    guard('TRN_TRIP.UPDATE');
    t := get_trip(p_trip_id, TRUE);
    NOONA_CORE_PKG.assert(t.status_code IN ('PLANNED', 'DISPATCHED', 'IN_TRANSIT'), 'NOONA-TRN-057', 'الرحلة مكتملة أو ملغاة', 'Trip closed');
    NOONA_CORE_PKG.assert(p_location_id IS NOT NULL, 'NOONA-TRN-058', 'اختر موقع التوقف', 'Choose stop location');
    NOONA_CORE_PKG.assert(NVL(p_minutes, 0) BETWEEN 0 AND 4320, 'NOONA-TRN-059', 'مدة التوقف بين 0 و 72 ساعة', 'Stop minutes 0-4320');
    SELECT NVL(MAX(sort_order), 0) + 10 INTO l_s FROM trn_trip_stop WHERE trip_id = p_trip_id;
    INSERT INTO trn_trip_stop (company_id, trip_id, location_id, stop_purpose, planned_minutes, sort_order)
    VALUES (company, p_trip_id, p_location_id, NVL(p_purpose, 'CHECKPOINT'), NVL(p_minutes, 0), NVL(p_sort, l_s))
    RETURNING id INTO l_id;
    recalc_trip(p_trip_id);
    RETURN l_id;
  END add_stop;

  PROCEDURE remove_stop(p_stop_id IN NUMBER) IS
    l_trip NUMBER;
  BEGIN
    guard('TRN_TRIP.UPDATE');
    SELECT trip_id INTO l_trip FROM trn_trip_stop WHERE id = p_stop_id AND company_id = company AND actual_arrival IS NULL;
    DELETE FROM trn_trip_stop WHERE id = p_stop_id;
    recalc_trip(l_trip);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-TRN-060', 'نقطة التوقف غير موجودة أو تم الوصول إليها', 'Stop not found or reached');
  END remove_stop;

  PROCEDURE depart(p_trip_id IN NUMBER, p_odometer IN NUMBER DEFAULT NULL, p_at IN TIMESTAMP DEFAULT NULL) IS
    t trn_trip%ROWTYPE;
    l_n NUMBER;
    l_odo NUMBER;
  BEGIN
    guard('TRN_TRIP.UPDATE');
    t := get_trip(p_trip_id, TRUE);
    NOONA_CORE_PKG.assert(t.status_code = 'PLANNED', 'NOONA-TRN-061', 'الرحلة تحركت مسبقاً أو أغلقت', 'Trip not planned');
    SELECT COUNT(*) INTO l_n FROM trn_trip_order WHERE trip_id = p_trip_id;
    NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-TRN-062', 'أضف شحنة واحدة على الأقل قبل التحرك', 'Add a shipment first');
    check_vehicle_driver(t.vehicle_id, t.driver_id, t.co_driver_id, NVL(p_at, SYSTIMESTAMP), p_trip_id);
    SELECT odometer_km INTO l_odo FROM trn_vehicle WHERE id = t.vehicle_id;
    NOONA_CORE_PKG.assert(p_odometer IS NULL OR p_odometer >= l_odo, 'NOONA-TRN-063', 'قراءة العداد أقل من آخر قراءة للعربة (' || qf(l_odo) || ')',
      'Odometer lower than last reading');
    UPDATE trn_trip SET status_code = 'IN_TRANSIT', actual_departure = NVL(p_at, SYSTIMESTAMP), odometer_start = NVL(p_odometer, l_odo)
     WHERE id = p_trip_id;
    UPDATE trn_vehicle SET status_code = 'ON_TRIP' WHERE id = t.vehicle_id;
    UPDATE trn_driver SET status_code = 'ON_TRIP' WHERE id IN (t.driver_id, t.co_driver_id);
    UPDATE trn_order SET status_code = 'IN_TRANSIT' WHERE id IN (SELECT order_id FROM trn_trip_order WHERE trip_id = p_trip_id);
    recalc_trip(p_trip_id);
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_trip, p_trip_id, 'DEPART', 'SUCCESS');
  END depart;

  PROCEDURE stop_arrive(p_stop_id IN NUMBER, p_at IN TIMESTAMP DEFAULT NULL) IS
    l_trip NUMBER;
  BEGIN
    guard('TRN_TRIP.UPDATE');
    UPDATE trn_trip_stop SET actual_arrival = NVL(p_at, SYSTIMESTAMP)
     WHERE id = p_stop_id AND company_id = company AND actual_arrival IS NULL RETURNING trip_id INTO l_trip;
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-TRN-060', 'نقطة التوقف غير موجودة أو سجل الوصول مسبقاً', 'Stop not found or reached');
  END stop_arrive;

  PROCEDURE stop_depart(p_stop_id IN NUMBER, p_at IN TIMESTAMP DEFAULT NULL) IS
    s     trn_trip_stop%ROWTYPE;
    l_ext NUMBER;
  BEGIN
    guard('TRN_TRIP.UPDATE');
    SELECT * INTO s FROM trn_trip_stop WHERE id = p_stop_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(s.actual_arrival IS NOT NULL AND s.actual_departure IS NULL, 'NOONA-TRN-064', 'سجل الوصول للنقطة أولاً', 'Record arrival first');
    UPDATE trn_trip_stop SET actual_departure = NVL(p_at, SYSTIMESTAMP) WHERE id = p_stop_id;
    -- تجاوز مدة التوقف المخططة يضاف للتأخير ويؤخر زمن الوصول المتوقع
    l_ext := GREATEST(ROUND((CAST(NVL(p_at, SYSTIMESTAMP) AS DATE) - CAST(s.actual_arrival AS DATE)) * 1440) - s.planned_minutes, 0);
    IF l_ext > 0 THEN
      UPDATE trn_trip SET delay_minutes = delay_minutes + l_ext WHERE id = s.trip_id;
    END IF;
    recalc_trip(s.trip_id);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-TRN-060', 'نقطة التوقف غير موجودة', 'Stop not found');
  END stop_depart;

  PROCEDURE arrive(p_trip_id IN NUMBER, p_at IN TIMESTAMP DEFAULT NULL) IS
    t trn_trip%ROWTYPE;
  BEGIN
    guard('TRN_TRIP.UPDATE');
    t := get_trip(p_trip_id, TRUE);
    NOONA_CORE_PKG.assert(t.status_code = 'IN_TRANSIT', 'NOONA-TRN-065', 'الرحلة ليست في الطريق', 'Trip not in transit');
    NOONA_CORE_PKG.assert(NVL(p_at, SYSTIMESTAMP) >= t.actual_departure, 'NOONA-TRN-066', 'وقت الوصول قبل وقت التحرك', 'Arrival before departure');
    UPDATE trn_trip SET status_code = 'ARRIVED', actual_arrival = NVL(p_at, SYSTIMESTAMP) WHERE id = p_trip_id;
  END arrive;

  PROCEDURE deliver_order(p_trip_id IN NUMBER, p_order_id IN NUMBER, p_delivered_qty IN NUMBER, p_receiver IN VARCHAR2,
                          p_damage IN VARCHAR2 DEFAULT NULL, p_at IN TIMESTAMP DEFAULT NULL) IS
    t trn_trip%ROWTYPE;
    o trn_order%ROWTYPE;
    l_n NUMBER;
  BEGIN
    guard('TRN_TRIP.UPDATE');
    t := get_trip(p_trip_id, TRUE);
    NOONA_CORE_PKG.assert(t.status_code IN ('IN_TRANSIT', 'ARRIVED'), 'NOONA-TRN-067', 'التسليم بعد تحرك الرحلة', 'Trip has not departed');
    SELECT COUNT(*) INTO l_n FROM trn_trip_order WHERE trip_id = p_trip_id AND order_id = p_order_id;
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-TRN-056', 'الشحنة ليست في هذه الرحلة', 'Order not on trip');
    o := get_order(p_order_id, TRUE);
    NOONA_CORE_PKG.assert(o.status_code = 'IN_TRANSIT', 'NOONA-TRN-068', 'الشحنة سلمت مسبقاً', 'Already delivered');
    NOONA_CORE_PKG.assert(p_delivered_qty BETWEEN 0 AND o.quantity, 'NOONA-TRN-069', 'الكمية المسلمة بين صفر والكمية المحملة ' || qf(o.quantity),
      'Delivered quantity out of range');
    NOONA_CORE_PKG.assert(TRIM(p_receiver) IS NOT NULL, 'NOONA-TRN-070', 'اسم المستلم مطلوب', 'Receiver required');
    UPDATE trn_order SET status_code = 'DELIVERED', delivered_qty = p_delivered_qty, shortage_qty = quantity - p_delivered_qty,
           receiver_name = p_receiver, damage_notes = p_damage, delivered_at = NVL(p_at, SYSTIMESTAMP)
     WHERE id = p_order_id;
  END deliver_order;

  PROCEDURE complete_trip(p_trip_id IN NUMBER, p_odometer_end IN NUMBER, p_fuel_liters IN NUMBER DEFAULT NULL) IS
    t trn_trip%ROWTYPE;
    l_n NUMBER;
  BEGIN
    guard('TRN_TRIP.UPDATE');
    t := get_trip(p_trip_id, TRUE);
    NOONA_CORE_PKG.assert(t.status_code IN ('IN_TRANSIT', 'ARRIVED'), 'NOONA-TRN-071', 'الرحلة لم تتحرك أو أغلقت', 'Trip not active');
    SELECT COUNT(*) INTO l_n FROM trn_trip_order x JOIN trn_order o ON o.id = x.order_id WHERE x.trip_id = p_trip_id AND o.status_code = 'IN_TRANSIT';
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-TRN-072', 'سجل تسليم كل الشحنات قبل إقفال الرحلة (' || l_n || ' متبقية)', 'Deliver all shipments first');
    NOONA_CORE_PKG.assert(p_odometer_end IS NOT NULL AND p_odometer_end >= NVL(t.odometer_start, 0), 'NOONA-TRN-073',
      'قراءة العداد عند العودة مطلوبة ولا تقل عن قراءة التحرك (' || qf(t.odometer_start) || ')', 'Odometer end required');
    UPDATE trn_trip SET status_code = 'COMPLETED', actual_arrival = NVL(actual_arrival, SYSTIMESTAMP), odometer_end = p_odometer_end,
           actual_distance_km = p_odometer_end - odometer_start, fuel_liters = NVL(p_fuel_liters, fuel_liters)
     WHERE id = p_trip_id;
    UPDATE trn_vehicle SET status_code = 'AVAILABLE', odometer_km = GREATEST(odometer_km, p_odometer_end)
     WHERE id = t.vehicle_id AND status_code = 'ON_TRIP';
    UPDATE trn_driver SET status_code = 'AVAILABLE' WHERE id IN (t.driver_id, t.co_driver_id) AND status_code = 'ON_TRIP';
    recalc_trip(p_trip_id);
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_trip, p_trip_id, 'COMPLETE', 'SUCCESS');
  END complete_trip;

  PROCEDURE cancel_trip(p_trip_id IN NUMBER, p_reason IN VARCHAR2) IS
    t trn_trip%ROWTYPE;
  BEGIN
    guard('TRN_TRIP.UPDATE');
    t := get_trip(p_trip_id, TRUE);
    NOONA_CORE_PKG.assert(t.status_code = 'PLANNED', 'NOONA-TRN-074', 'تلغى الرحلة قبل تحركها فقط', 'Only planned trips can be cancelled');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-TRN-031', 'سبب الإلغاء مطلوب', 'Reason required');
    UPDATE trn_order SET status_code = 'CONFIRMED' WHERE id IN (SELECT order_id FROM trn_trip_order WHERE trip_id = p_trip_id);
    DELETE FROM trn_trip_order WHERE trip_id = p_trip_id;
    UPDATE trn_trip SET status_code = 'CANCELLED', notes = SUBSTR(notes || CHR(10) || 'إلغاء: ' || p_reason, 1, 4000) WHERE id = p_trip_id;
    recalc_trip(p_trip_id);
  END cancel_trip;

  FUNCTION add_expense(p_trip_id IN NUMBER, p_type IN VARCHAR2, p_amount IN NUMBER, p_liters IN NUMBER DEFAULT NULL,
                       p_date IN DATE DEFAULT NULL, p_ref IN VARCHAR2 DEFAULT NULL, p_notes IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    t    trn_trip%ROWTYPE;
    l_id NUMBER;
  BEGIN
    guard('TRN_TRIP_EXPENSE.CREATE');
    t := get_trip(p_trip_id);
    NOONA_CORE_PKG.assert(t.status_code <> 'CANCELLED', 'NOONA-TRN-075', 'الرحلة ملغاة', 'Trip cancelled');
    NOONA_CORE_PKG.assert(p_type IN ('FUEL', 'TOLL', 'DRIVER_ALLOWANCE', 'LOADING', 'UNLOADING', 'PARKING', 'REPAIR', 'TIRES', 'FINE', 'WEIGHBRIDGE',
      'CUSTOMS', 'OTHER'), 'NOONA-TRN-076', 'نوع المصروف غير صحيح', 'Invalid expense type');
    NOONA_CORE_PKG.assert(NVL(p_amount, -1) > 0, 'NOONA-TRN-077', 'مبلغ المصروف أكبر من صفر', 'Amount must be positive');
    INSERT INTO trn_trip_expense (company_id, trip_id, expense_type, expense_date, amount, liters, reference_no, notes)
    VALUES (company, p_trip_id, p_type, NVL(p_date, TRUNC(SYSDATE)), p_amount, p_liters, p_ref, p_notes)
    RETURNING id INTO l_id;
    IF p_type = 'FUEL' AND p_liters IS NOT NULL THEN
      UPDATE trn_trip SET fuel_liters = NVL(fuel_liters, 0) + p_liters WHERE id = p_trip_id;
    END IF;
    recalc_trip(p_trip_id);
    RETURN l_id;
  END add_expense;

  -- ================================================================ الأعطال والبلاغات
  FUNCTION get_incident(p_id NUMBER) RETURN trn_incident%ROWTYPE IS
    r trn_incident%ROWTYPE;
  BEGIN
    SELECT * INTO r FROM trn_incident WHERE id = p_id AND company_id = company FOR UPDATE;
    RETURN r;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-TRN-080', 'البلاغ غير موجود', 'Incident not found');
  END get_incident;

  FUNCTION report_incident(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_no VARCHAR2(50);
    x_location_jn NUMBER;
    x_description_js VARCHAR2(4000);
    x_locationText_js VARCHAR2(4000);
    x_lat NUMBER := jn(l_o, 'lat');
    x_lng NUMBER := jn(l_o, 'lng');
    x_reportedBy_js VARCHAR2(4000);
    x_at_jts TIMESTAMP;
    l_trip NUMBER := jn(l_o, 'trip');
    l_v    NUMBER := jn(l_o, 'vehicle');
    l_d    NUMBER := jn(l_o, 'driver');
    l_tp   VARCHAR2(30) := UPPER(js(l_o, 'type'));
    l_sv   VARCHAR2(30) := NVL(UPPER(js(l_o, 'severity')), 'MEDIUM');
    l_id   NUMBER;
    t      trn_trip%ROWTYPE;
  BEGIN
    guard('TRN_INCIDENT.CREATE');
    IF l_trip IS NOT NULL THEN
      t := get_trip(l_trip);
      l_v := NVL(l_v, t.vehicle_id); l_d := NVL(l_d, t.driver_id);
    END IF;
    NOONA_CORE_PKG.assert(l_v IS NOT NULL, 'NOONA-TRN-081', 'اختر الرحلة أو العربة', 'Trip or vehicle required');
    NOONA_CORE_PKG.assert(l_tp IN ('BREAKDOWN', 'TIRE', 'ACCIDENT', 'DELAY', 'CARGO_DAMAGE', 'THEFT', 'POLICE', 'WEATHER', 'ROAD_CLOSURE', 'MEDICAL',
      'BORDER_HOLD', 'OTHER'), 'NOONA-TRN-082', 'نوع البلاغ غير صحيح', 'Invalid incident type');
    NOONA_CORE_PKG.assert(l_sv IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'), 'NOONA-TRN-083', 'درجة الخطورة غير صحيحة', 'Invalid severity');
    NOONA_CORE_PKG.assert(TRIM(js(l_o, 'description')) IS NOT NULL, 'NOONA-TRN-084', 'وصف البلاغ مطلوب', 'Description required');
    x_location_jn := jn(l_o, 'location');
    x_description_js := js(l_o, 'description');
    x_locationText_js := js(l_o, 'locationText');
    x_reportedBy_js := js(l_o, 'reportedBy');
    x_at_jts := jts(l_o, 'at');
    l_no := next_no(c_inc, 'INC-');
    INSERT INTO trn_incident (company_id, doc_no, doc_date, trip_id, vehicle_id, driver_id, incident_type, severity, reported_at, reported_by,
                              location_id, location_text, description, status_code, latitude, longitude)
    VALUES (company, l_no, TRUNC(SYSDATE), l_trip, l_v, l_d, l_tp, l_sv, NVL(x_at_jts, SYSTIMESTAMP),
            NVL(x_reportedBy_js, NOONA_APEX_PKG.display_name), x_location_jn, x_locationText_js, x_description_js, 'REPORTED', x_lat, x_lng)
    RETURNING id INTO l_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_inc, l_id, 'REPORT', 'SUCCESS');
    RETURN l_id;
  END report_incident;

  PROCEDURE acknowledge_incident(p_id IN NUMBER, p_assigned_to IN VARCHAR2) IS
    r trn_incident%ROWTYPE;
  BEGIN
    guard('TRN_INCIDENT.UPDATE');
    r := get_incident(p_id);
    NOONA_CORE_PKG.assert(r.status_code = 'REPORTED', 'NOONA-TRN-085', 'البلاغ مستلم مسبقاً', 'Already acknowledged');
    NOONA_CORE_PKG.assert(TRIM(p_assigned_to) IS NOT NULL, 'NOONA-TRN-086', 'حدد المكلف بالاستجابة', 'Assignee required');
    UPDATE trn_incident SET status_code = 'ACKNOWLEDGED', acknowledged_at = SYSTIMESTAMP, assigned_to = p_assigned_to WHERE id = p_id;
  END acknowledge_incident;

  PROCEDURE respond_incident(p_id IN NUMBER, p_action IN VARCHAR2) IS
    r trn_incident%ROWTYPE;
  BEGIN
    guard('TRN_INCIDENT.UPDATE');
    r := get_incident(p_id);
    NOONA_CORE_PKG.assert(r.status_code IN ('REPORTED', 'ACKNOWLEDGED'), 'NOONA-TRN-087', 'البلاغ قيد المعالجة أو محلول', 'Already in progress');
    UPDATE trn_incident SET status_code = 'IN_PROGRESS', responded_at = SYSTIMESTAMP, acknowledged_at = NVL(acknowledged_at, SYSTIMESTAMP),
           response_action = p_action
     WHERE id = p_id;
  END respond_incident;

  PROCEDURE resolve_incident(p_id IN NUMBER, p_action IN VARCHAR2, p_downtime_minutes IN NUMBER, p_cost IN NUMBER DEFAULT NULL) IS
    r    trn_incident%ROWTYPE;
    l_x  NUMBER;
  BEGIN
    guard('TRN_INCIDENT.UPDATE');
    r := get_incident(p_id);
    NOONA_CORE_PKG.assert(r.status_code IN ('REPORTED', 'ACKNOWLEDGED', 'IN_PROGRESS'), 'NOONA-TRN-088', 'البلاغ محلول مسبقاً', 'Already resolved');
    NOONA_CORE_PKG.assert(TRIM(p_action) IS NOT NULL, 'NOONA-TRN-089', 'اكتب إجراء الحل', 'Resolution action required');
    NOONA_CORE_PKG.assert(NVL(p_downtime_minutes, 0) >= 0 AND NVL(p_cost, 0) >= 0, 'NOONA-TRN-090', 'مدة التوقف والتكلفة لا تكون سالبة', 'Negative values');
    UPDATE trn_incident SET status_code = 'RESOLVED', resolved_at = SYSTIMESTAMP, acknowledged_at = NVL(acknowledged_at, SYSTIMESTAMP),
           responded_at = NVL(responded_at, SYSTIMESTAMP), response_action = SUBSTR(NVL2(response_action, response_action || CHR(10), NULL) || p_action, 1, 2000),
           downtime_minutes = p_downtime_minutes, cost_amount = p_cost
     WHERE id = p_id;
    IF r.trip_id IS NOT NULL THEN
      -- مدة التوقف تؤخر الوصول المتوقع، والتكلفة مصروف إصلاح على الرحلة
      UPDATE trn_trip SET delay_minutes = delay_minutes + NVL(p_downtime_minutes, 0) WHERE id = r.trip_id AND status_code NOT IN ('COMPLETED', 'CANCELLED');
      IF NVL(p_cost, 0) > 0 THEN
        l_x := add_expense(r.trip_id, CASE WHEN r.incident_type = 'TIRE' THEN 'TIRES' ELSE 'REPAIR' END, p_cost, NULL, TRUNC(SYSDATE), r.doc_no,
                           'بلاغ ' || r.doc_no);
      END IF;
      recalc_trip(r.trip_id);
    END IF;
  END resolve_incident;

  PROCEDURE close_incident(p_id IN NUMBER) IS
    r trn_incident%ROWTYPE;
  BEGIN
    guard('TRN_INCIDENT.UPDATE');
    r := get_incident(p_id);
    NOONA_CORE_PKG.assert(r.status_code = 'RESOLVED', 'NOONA-TRN-091', 'يغلق البلاغ بعد حله', 'Resolve first');
    UPDATE trn_incident SET status_code = 'CLOSED' WHERE id = p_id;
  END close_incident;

  -- ================================================================ الفوترة
  FUNCTION invoice_orders(p_order_ids IN VARCHAR2) RETURN NUMBER IS
    l_d    JSON_OBJECT_T := JSON_OBJECT_T();
    l_ls   JSON_ARRAY_T := JSON_ARRAY_T();
    l_x    JSON_OBJECT_T;
    l_cust NUMBER;
    l_n    NUMBER := 0;
    l_inv  NUMBER;
    l_docs VARCHAR2(4000);
  BEGIN
    guard('TRN_ORDER.UPDATE');
    NOONA_CORE_PKG.assert(is_ready = 'Y', 'NOONA-TRN-092', 'جهز النظام أولاً (حساب إيرادات النقل) من الإعداد', 'Run quick setup first');
    FOR o IN (SELECT o.*, c.name_ar cargo, f.name_ar fn, t.name_ar tn
                FROM trn_order o JOIN trn_cargo_type c ON c.id = o.cargo_type_id
                JOIN trn_location f ON f.id = o.from_location_id JOIN trn_location t ON t.id = o.to_location_id
               WHERE o.company_id = company AND INSTR(',' || REPLACE(p_order_ids, ' ', '') || ',', ',' || o.id || ',') > 0
               ORDER BY o.id FOR UPDATE OF o.status_code) LOOP
      NOONA_CORE_PKG.assert(o.status_code = 'DELIVERED', 'NOONA-TRN-093', 'الأمر ' || o.doc_no || ' غير مسلم أو مفوتر', 'Order not delivered');
      NOONA_CORE_PKG.assert(l_cust IS NULL OR l_cust = o.customer_account_id, 'NOONA-TRN-094', 'الأوامر لعملاء مختلفين؛ افترها منفصلة',
        'Orders belong to different customers');
      l_cust := o.customer_account_id;
      l_x := JSON_OBJECT_T();
      l_x.put('d', 'ترحيل ' || o.cargo || ' من ' || o.fn || ' إلى ' || o.tn || ' - أمر ' || o.doc_no || ' - ' || qf(o.quantity) || ' '
               || uom_label(o.uom_code) || CASE WHEN NVL(o.shortage_qty, 0) > 0 THEN ' (عجز ' || qf(o.shortage_qty) || ')' END);
      l_x.put('acc', c_rev); l_x.put('q', 1); l_x.put('p', o.total_amount); l_x.put('inc', 'N');
      l_ls.append(l_x);
      l_n := l_n + 1;
      l_docs := SUBSTR(l_docs || CASE WHEN l_docs IS NOT NULL THEN '، ' END || o.doc_no, 1, 3000);
    END LOOP;
    NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-TRN-095', 'اختر أوامر شحن مسلمة', 'Choose delivered orders');
    l_d.put('cust', l_cust); l_d.put('mode', 'CREDIT'); l_d.put('action', 'POST');
    l_d.put('notes', 'فاتورة ترحيل لأوامر الشحن: ' || l_docs);
    l_d.put('lines', l_ls);
    l_inv := NOONA_SAL_PKG.save_invoice(l_d.to_clob);
    UPDATE trn_order SET status_code = 'INVOICED', sales_invoice_id = l_inv
     WHERE company_id = company AND INSTR(',' || REPLACE(p_order_ids, ' ', '') || ',', ',' || id || ',') > 0;
    RETURN l_inv;
  END invoice_orders;

  -- ================================================================ الواجهة
  FUNCTION trip_customers(p_trip_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT SUBSTR(LISTAGG(DISTINCT NOONA_SAL_PKG.customer_label(o.customer_account_id), '، ') WITHIN GROUP (ORDER BY o.id), 1, 1000)
      INTO l FROM trn_trip_order x JOIN trn_order o ON o.id = x.order_id WHERE x.trip_id = p_trip_id;
    RETURN l;
  END trip_customers;

  FUNCTION board_html RETURN CLOB IS
    l   CLOB;
    l_n PLS_INTEGER := 0;
    l_t VARCHAR2(30);
  BEGIN
    guard('TRN_TRIP.VIEW');
    l_n := maint_due_count;
    IF l_n > 0 THEN
      l := '<div class="nn-hint" style="border-color:#d97706;background:#fff7ed"><span class="fa fa-bell"></span> <b>تنبيه صيانة:</b> '
        || l_n || ' بند (قطع حان استبدالها أو صيانات دورية مستحقة). <a href="f?p=' || v('APP_ID') || ':34:' || v('APP_SESSION')
        || '">افتح صيانة الأسطول</a></div>';
      l_n := 0;
    END IF;
    l := l || '<div class="nn-trn-kpis">';
    FOR k IN (SELECT 'في الطريق' t, COUNT(*) v, 'fa-truck' i FROM trn_trip WHERE company_id = company AND status_code IN ('DISPATCHED', 'IN_TRANSIT', 'ARRIVED')
              UNION ALL SELECT 'مجدولة', COUNT(*), 'fa-calendar' FROM trn_trip WHERE company_id = company AND status_code = 'PLANNED'
              UNION ALL SELECT 'شحنات بانتظار رحلة', COUNT(*), 'fa-cubes' FROM trn_order WHERE company_id = company AND status_code = 'CONFIRMED'
              UNION ALL SELECT 'بلاغات مفتوحة', COUNT(*), 'fa-exclamation-triangle' FROM trn_incident WHERE company_id = company AND status_code IN ('REPORTED', 'ACKNOWLEDGED', 'IN_PROGRESS')
              UNION ALL SELECT 'عربات متاحة', COUNT(*), 'fa-check-circle' FROM trn_vehicle WHERE company_id = company AND status_code = 'AVAILABLE'
              UNION ALL SELECT 'عربات في الصيانة', COUNT(*), 'fa-wrench' FROM trn_vehicle WHERE company_id = company AND status_code = 'MAINTENANCE') LOOP
      l := l || '<div class="nn-trn-kpi"><span class="fa ' || k.i || '" aria-hidden="true"></span><b>' || k.v || '</b><small>' || esc(k.t) || '</small></div>';
    END LOOP;
    l := l || '</div><h3 class="nn-rh-h"><span class="fa fa-road" aria-hidden="true"></span> الرحلات الجارية</h3><div class="nn-trn-trips">';
    FOR t IN (SELECT t.id, t.doc_no, t.status_code, t.eta, t.actual_departure, t.planned_departure, t.delay_minutes, t.load_kg, v.plate_no, v.capacity_tons,
                     d.full_name, f.name_ar fn, tl.name_ar tn,
                     (SELECT COUNT(*) FROM trn_incident i WHERE i.trip_id = t.id AND i.status_code IN ('REPORTED', 'ACKNOWLEDGED', 'IN_PROGRESS')) open_inc
                FROM trn_trip t JOIN trn_vehicle v ON v.id = t.vehicle_id JOIN trn_driver d ON d.id = t.driver_id
                JOIN trn_location f ON f.id = t.from_location_id JOIN trn_location tl ON tl.id = t.to_location_id
               WHERE t.company_id = company AND t.status_code IN ('PLANNED', 'DISPATCHED', 'IN_TRANSIT', 'ARRIVED')
               ORDER BY CASE t.status_code WHEN 'IN_TRANSIT' THEN 0 WHEN 'ARRIVED' THEN 1 ELSE 2 END, t.eta) LOOP
      l_n := l_n + 1;
      l_t := timeliness(t.id);
      l := l || '<a class="nn-trn-trip' || CASE WHEN l_t = 'AT_RISK' OR t.open_inc > 0 THEN ' is-alert' END || '" href="'
          || NOONA_UI_PKG.url('NOONA_TRN', 'TRIP', V('APP_SESSION'), 'P21_ID', t.id) || '">'
          || '<span class="nn-trn-trip-h"><b>' || esc(t.doc_no) || '</b>' || badge(t.status_code) || CASE WHEN l_t IS NOT NULL THEN ' ' || badge(l_t) END
          || CASE WHEN t.open_inc > 0 THEN ' <span class="nn-badge is-danger"><span class="fa fa-exclamation-triangle" aria-hidden="true"></span> ' || t.open_inc || ' بلاغ</span>' END
          || '</span><span class="nn-trn-route">' || esc(t.fn) || ' <span class="fa fa-long-arrow-right" aria-hidden="true"></span> ' || esc(t.tn) || '</span>'
          || '<span class="nn-trn-meta"><span class="fa fa-truck" aria-hidden="true"></span> ' || esc(t.plate_no)
          || ' · <span class="fa fa-user" aria-hidden="true"></span> ' || esc(t.full_name)
          || ' · الحمولة ' || qf(t.load_kg / 1000) || ' / ' || qf(t.capacity_tons) || ' طن</span>'
          || CASE WHEN trip_customers(t.id) IS NOT NULL THEN '<span class="nn-trn-meta"><span class="fa fa-building-o" aria-hidden="true"></span> العميل: '
                  || esc(trip_customers(t.id)) || '</span>' END
          || '<span class="nn-trn-eta">' || CASE WHEN t.actual_departure IS NULL THEN 'التحرك المخطط: ' || ts(t.planned_departure)
                                                ELSE 'الوصول المتوقع: <b>' || ts(t.eta) || '</b>' END
          || CASE WHEN t.delay_minutes > 0 THEN ' · تأخير ' || ROUND(t.delay_minutes / 60, 1) || ' ساعة' END || '</span></a>';
    END LOOP;
    IF l_n = 0 THEN
      l := l || '<div class="nn-empty">لا توجد رحلات جارية أو مجدولة</div>';
    END IF;
    RETURN l || '</div>';
  END board_html;

  FUNCTION trip_html(p_trip_id IN NUMBER) RETURN CLOB IS
    t   trn_trip%ROWTYPE;
    l   CLOB;
    l_v VARCHAR2(400); l_d VARCHAR2(400); l_cd VARCHAR2(400); l_f VARCHAR2(200); l_to VARCHAR2(200); l_cap NUMBER;
  BEGIN
    guard('TRN_TRIP.VIEW');
    t := get_trip(p_trip_id);
    SELECT plate_no || ' · ' || NVL(make, '') || ' ' || NVL(model, ''), capacity_tons INTO l_v, l_cap FROM trn_vehicle WHERE id = t.vehicle_id;
    SELECT full_name || NVL2(phone, ' · ' || phone, '') INTO l_d FROM trn_driver WHERE id = t.driver_id;
    SELECT MAX(full_name) INTO l_cd FROM trn_driver WHERE id = t.co_driver_id;
    SELECT name_ar INTO l_f FROM trn_location WHERE id = t.from_location_id;
    SELECT name_ar INTO l_to FROM trn_location WHERE id = t.to_location_id;
    l := '<div class="nn-trn-head"><div><div class="nn-hello-title">' || esc(t.doc_no) || ' ' || badge(t.status_code)
      || CASE WHEN timeliness(t.id) IS NOT NULL THEN ' ' || badge(timeliness(t.id)) END || '</div>'
      || '<div class="nn-trn-route">' || esc(l_f) || ' <span class="fa fa-long-arrow-right" aria-hidden="true"></span> ' || esc(l_to)
      || CASE WHEN t.planned_distance_km IS NOT NULL THEN ' · ' || qf(t.planned_distance_km) || ' كم' END || '</div></div>'
      || '<dl class="nn-trn-facts">'
      || '<div><dt>العربة</dt><dd>' || esc(l_v) || '</dd></div>'
      || '<div><dt>السائق</dt><dd>' || esc(l_d) || CASE WHEN l_cd IS NOT NULL THEN ' + ' || esc(l_cd) END || '</dd></div>'
      || '<div><dt>التحرك</dt><dd>' || ts(NVL(t.actual_departure, t.planned_departure)) || CASE WHEN t.actual_departure IS NULL THEN ' (مخطط)' END || '</dd></div>'
      || '<div><dt>الوصول المتوقع</dt><dd><b>' || ts(t.eta) || '</b>' || CASE WHEN t.delay_minutes > 0 THEN ' (تأخير ' || t.delay_minutes || ' دقيقة)' END || '</dd></div>'
      || CASE WHEN t.actual_arrival IS NOT NULL THEN '<div><dt>الوصول الفعلي</dt><dd>' || ts(t.actual_arrival) || '</dd></div>' END
      || '<div><dt>الحمولة</dt><dd>' || qf(t.load_kg / 1000) || ' من ' || qf(l_cap) || ' طن (' || ROUND(t.load_kg / 10 / l_cap) || '%)</dd></div>'
      || '<div><dt>الإيراد</dt><dd>' || fmt(t.revenue_amount) || '</dd></div>'
      || '<div><dt>المصروفات</dt><dd>' || fmt(t.expense_amount) || '</dd></div>'
      || '<div><dt>صافي الرحلة</dt><dd><b>' || fmt(t.revenue_amount - t.expense_amount) || '</b></dd></div>'
      || CASE WHEN t.actual_distance_km IS NOT NULL THEN '<div><dt>المسافة الفعلية</dt><dd>' || qf(t.actual_distance_km) || ' كم'
              || CASE WHEN t.fuel_liters > 0 AND t.actual_distance_km > 0 THEN ' · ' || ROUND(t.fuel_liters / t.actual_distance_km * 100, 1) || ' لتر/100كم' END
              || '</dd></div>' END
      || '</dl></div>';
    RETURN l;
  END trip_html;

  FUNCTION incident_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'BREAKDOWN' THEN 'عطل ميكانيكي' WHEN 'TIRE' THEN 'إطار' WHEN 'ACCIDENT' THEN 'حادث' WHEN 'DELAY' THEN 'تأخير'
      WHEN 'CARGO_DAMAGE' THEN 'تلف الشحنة' WHEN 'THEFT' THEN 'سرقة' WHEN 'POLICE' THEN 'إيقاف أمني/مروري' WHEN 'WEATHER' THEN 'طقس'
      WHEN 'ROAD_CLOSURE' THEN 'إغلاق طريق' WHEN 'MEDICAL' THEN 'حالة صحية' WHEN 'BORDER_HOLD' THEN 'احتجاز حدودي' WHEN 'OTHER' THEN 'أخرى'
      ELSE p_code END;
  END incident_label;

  FUNCTION severity_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'LOW' THEN 'منخفضة' WHEN 'MEDIUM' THEN 'متوسطة' WHEN 'HIGH' THEN 'عالية' WHEN 'CRITICAL' THEN 'حرجة' ELSE p_code END;
  END severity_label;

  FUNCTION order_status(p_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM trn_order WHERE id = p_id AND company_id = company;
    RETURN l;
  END order_status;

  FUNCTION trip_status(p_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM trn_trip WHERE id = p_id AND company_id = company;
    RETURN l;
  END trip_status;

  FUNCTION incident_status(p_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM trn_incident WHERE id = p_id AND company_id = company;
    RETURN l;
  END incident_status;
  -- ================================================================ شاشات السائق
  FUNCTION my_driver RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM trn_driver
     WHERE company_id = company AND status_code <> 'LEFT'
       AND UPPER(user_name) = UPPER(NVL(SYS_CONTEXT('APEX$SESSION', 'APP_USER'), NOONA_CTX_PKG.current_user_name));
    RETURN l;
  END my_driver;

  FUNCTION trip_status(p_trip_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM trn_trip WHERE id = p_trip_id AND company_id = company;
    RETURN l;
  END trip_status;

  FUNCTION driver_trips_html(p_driver_id IN NUMBER, p_trip_url IN VARCHAR2) RETURN CLOB IS
    l_h CLOB;
  BEGIN
    IF p_driver_id IS NULL THEN
      RETURN '<p class="nn-hint">حسابك غير مربوط بسائق. يربطه مسؤول الأسطول من «السائقون» بحقل مستخدم النظام.</p>';
    END IF;
    FOR t IN (SELECT t.id, t.doc_no, t.status_code, t.planned_departure, t.eta, v.plate_no, f.name_ar fr, tl.name_ar tl,
                     (SELECT COUNT(*) FROM trn_trip_order x WHERE x.trip_id = t.id) n_orders,
                     (SELECT COUNT(*) FROM trn_trip_order x JOIN trn_order o ON o.id = x.order_id WHERE x.trip_id = t.id AND o.status_code = 'DELIVERED') n_done
                FROM trn_trip t JOIN trn_vehicle v ON v.id = t.vehicle_id JOIN trn_location f ON f.id = t.from_location_id
                JOIN trn_location tl ON tl.id = t.to_location_id
               WHERE t.company_id = company AND (t.driver_id = p_driver_id OR t.co_driver_id = p_driver_id)
                 AND (t.status_code IN ('PLANNED', 'DISPATCHED', 'IN_TRANSIT', 'ARRIVED') OR (t.status_code = 'COMPLETED' AND t.actual_arrival > SYSTIMESTAMP - INTERVAL '2' DAY))
               ORDER BY DECODE(t.status_code, 'IN_TRANSIT', 0, 'ARRIVED', 1, 'DISPATCHED', 2, 'PLANNED', 3, 9), t.planned_departure) LOOP
      l_h := l_h || '<a class="nn-dst-stop' || CASE WHEN t.status_code IN ('IN_TRANSIT', 'ARRIVED') THEN ' is-open' WHEN t.status_code = 'COMPLETED' THEN ' is-done' END
          || '" href="' || REPLACE(p_trip_url, '#TRIP#', t.id) || '"><span class="nn-dst-seq"><span class="fa fa-truck"></span></span><div class="nn-dst-stop-b"><b>'
          || esc(t.doc_no) || ' · ' || esc(t.fr) || ' ← ' || esc(t.tl) || '</b> ' || badge(t.status_code)
          || '<small>' || esc(t.plate_no) || ' · التحرك ' || TO_CHAR(t.planned_departure, 'YYYY-MM-DD HH24:MI')
          || CASE WHEN t.eta IS NOT NULL THEN ' · الوصول المتوقع ' || TO_CHAR(t.eta, 'HH24:MI') END || '</small><small>الشحنات المسلمة '
          || t.n_done || ' من ' || t.n_orders || '</small></div></a>';
    END LOOP;
    RETURN NVL(l_h, '<p class="nn-hint">لا رحلات مسندة لك حالياً.</p>');
  END driver_trips_html;

  FUNCTION driver_trip_html(p_trip_id IN NUMBER) RETURN CLOB IS
    l_h CLOB;
    l_b64 CLOB;
  BEGIN
    FOR t IN (SELECT t.*, v.plate_no, f.name_ar fr, tl.name_ar tl, f.latitude flat, f.longitude flng, tl.latitude tlat, tl.longitude tlng
                FROM trn_trip t JOIN trn_vehicle v ON v.id = t.vehicle_id JOIN trn_location f ON f.id = t.from_location_id
                JOIN trn_location tl ON tl.id = t.to_location_id WHERE t.id = p_trip_id AND t.company_id = company) LOOP
      l_h := '<div class="nn-dst-card"><div class="nn-dst-card-h"><b>' || esc(t.doc_no) || ' · ' || esc(t.plate_no) || '</b>' || badge(t.status_code) || '</div>'
          || '<div>' || esc(t.fr) || ' ← ' || esc(t.tl) || '</div><small>التحرك ' || TO_CHAR(NVL(t.actual_departure, t.planned_departure), 'YYYY-MM-DD HH24:MI')
          || CASE WHEN t.odometer_start IS NOT NULL THEN ' · العداد ' || qf(t.odometer_start) END
          || CASE WHEN t.eta IS NOT NULL THEN ' · الوصول المتوقع ' || TO_CHAR(t.eta, 'YYYY-MM-DD HH24:MI') END || '</small>'
          || CASE WHEN t.tlat IS NOT NULL THEN '<div class="nn-dst-actions"><a class="nn-dst-btn" target="_blank" rel="noopener" href="https://www.google.com/maps/dir/?api=1&destination='
               || TO_CHAR(t.tlat, 'FM990.0000000') || ',' || TO_CHAR(t.tlng, 'FM990.0000000') || '"><span class="fa fa-location-arrow"></span> الطريق إلى الوجهة</a></div>' END
          || '</div><h3 class="nn-mgr-h">الشحنات</h3>';
      FOR o IN (SELECT o.id, o.doc_no, o.status_code, o.quantity, o.delivered_qty, o.receiver_name, NOONA_SAL_PKG.customer_label(o.customer_account_id) cust,
                       c.name_ar cargo, uom_label(o.uom_code) uom
                  FROM trn_trip_order x JOIN trn_order o ON o.id = x.order_id JOIN trn_cargo_type c ON c.id = o.cargo_type_id
                 WHERE x.trip_id = t.id ORDER BY o.id) LOOP
        l_h := l_h || '<div class="nn-dst-stop' || CASE WHEN o.status_code = 'DELIVERED' THEN ' is-done' END || '"><div class="nn-dst-stop-b"><b>'
            || esc(o.doc_no) || ' · ' || esc(o.cust) || '</b> ' || badge(o.status_code) || '<small>' || esc(o.cargo) || ' · ' || qf(o.quantity) || ' ' || esc(o.uom)
            || CASE WHEN o.status_code = 'DELIVERED' THEN ' · سلم ' || qf(o.delivered_qty) || ' إلى ' || esc(o.receiver_name) END || '</small>';
        FOR p IN (SELECT id, photo, signature, captured_at FROM trn_pod WHERE trip_id = t.id AND order_id = o.id ORDER BY id DESC FETCH FIRST 1 ROWS ONLY) LOOP
          l_h := l_h || '<div class="nn-pod">';
          IF p.photo IS NOT NULL AND DBMS_LOB.GETLENGTH(p.photo) < 600000 THEN
            l_b64 := APEX_WEB_SERVICE.blob2clobbase64(p.photo);
            l_h := l_h || '<img alt="صورة التسليم" src="data:image/jpeg;base64,' || REPLACE(REPLACE(l_b64, CHR(10)), CHR(13)) || '">';
          END IF;
          IF p.signature IS NOT NULL AND DBMS_LOB.GETLENGTH(p.signature) < 300000 THEN
            l_b64 := APEX_WEB_SERVICE.blob2clobbase64(p.signature);
            l_h := l_h || '<img alt="توقيع المستلم" class="is-sig" src="data:image/png;base64,' || REPLACE(REPLACE(l_b64, CHR(10)), CHR(13)) || '">';
          END IF;
          l_h := l_h || '<small>' || TO_CHAR(p.captured_at, 'YYYY-MM-DD HH24:MI') || '</small></div>';
        END LOOP;
        l_h := l_h || '</div></div>';
      END LOOP;
    END LOOP;
    RETURN l_h;
  END driver_trip_html;

  FUNCTION data_url_blob(p CLOB) RETURN BLOB IS
    l_i NUMBER;
  BEGIN
    IF p IS NULL OR DBMS_LOB.GETLENGTH(p) < 30 THEN RETURN NULL; END IF;
    l_i := DBMS_LOB.INSTR(p, ',');
    RETURN APEX_WEB_SERVICE.clobbase642blob(CASE WHEN l_i > 0 AND l_i < 100 THEN DBMS_LOB.SUBSTR(p, DBMS_LOB.GETLENGTH(p) - l_i, l_i + 1) ELSE p END);
  END data_url_blob;

  FUNCTION save_pod(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_t   NUMBER := jn(l_o, 'trip');
    l_ord NUMBER := jn(l_o, 'order');
    l_rc  VARCHAR2(200) := js(l_o, 'receiver');
    l_qty NUMBER := jn(l_o, 'qty');
    l_ph  BLOB;
    l_sg  BLOB;
    l_id  NUMBER;
    l_st  VARCHAR2(30);
    l_pm  VARCHAR2(100);
    l_oq  NUMBER;
    l_rp  VARCHAR2(30) := js(l_o, 'phone');
    l_la  NUMBER := jn(l_o, 'lat');
    l_ln  NUMBER := jn(l_o, 'lng');
    l_nt  VARCHAR2(4000) := js(l_o, 'notes');
    l_dm  VARCHAR2(4000) := js(l_o, 'damage');
  BEGIN
    guard('TRN_TRIP.UPDATE');
    IF l_o.has('photo') AND NOT l_o.get('photo').is_null THEN
      l_ph := data_url_blob(l_o.get_clob('photo'));
      l_pm := REGEXP_SUBSTR(DBMS_LOB.SUBSTR(l_o.get_clob('photo'), 60, 1), 'data:([a-z/+]+);', 1, 1, NULL, 1);
    END IF;
    IF l_o.has('signature') AND NOT l_o.get('signature').is_null THEN
      l_sg := data_url_blob(l_o.get_clob('signature'));
    END IF;
    NOONA_CORE_PKG.assert(l_sg IS NOT NULL OR l_ph IS NOT NULL, 'NOONA-TRN-120', 'التقط صورة التسليم أو توقيع المستلم', 'Photo or signature required');
    SELECT MAX(status_code), MAX(quantity) INTO l_st, l_oq FROM trn_order WHERE id = l_ord AND company_id = company;
    NOONA_CORE_PKG.assert(l_st IS NOT NULL, 'NOONA-TRN-121', 'الشحنة غير موجودة', 'Order not found');
    l_qty := NVL(l_qty, l_oq);
    IF l_st = 'IN_TRANSIT' THEN
      deliver_order(l_t, l_ord, l_qty, l_rc, l_dm);
    END IF;
    INSERT INTO trn_pod (company_id, trip_id, order_id, receiver_name, receiver_phone, delivered_qty, photo, photo_mime, signature, latitude, longitude, notes)
    VALUES (company, l_t, l_ord, l_rc, l_rp, l_qty, l_ph, l_pm, l_sg, l_la, l_ln, l_nt)
    RETURNING id INTO l_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'TRN_POD', l_id, 'CAPTURE', 'SUCCESS');
    RETURN l_id;
  END save_pod;

END NOONA_TRN_PKG;
/
SHOW ERRORS PACKAGE BODY NOONA_TRN_PKG
