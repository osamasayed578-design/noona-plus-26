-- =============================================================================
-- NOONA PLUS ERP | NOONA_RE_PKG - السجل العقاري الموحد
--   * العقار/المجمع ← المبنى ← الطابق ← الوحدة؛ يستخدمه البيع والتأجير والضيافة والصيانة دون تكرار
--   * معالج إضافة عقار بخطوة واحدة: بيانات العقار، المباني وعدد طوابقها، توليد الوحدات بترقيم تلقائي
--     (رقم الطابق + تسلسل الوحدة: 101، 102...)، وإنشاء غرف الضيافة من الوحدات عند الحاجة
--   * مخطط الوحدات (Stacking plan) لكل مبنى ملون حسب حالة الوحدة، وبطاقة العقار ومؤشراته
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_RE_PKG AUTHID DEFINER AS

  FUNCTION company RETURN NUMBER;
  -- JSON: id, code, name_ar, name_en, type, branch, city, address, phone, description, management_mode, owner_party,
  --   usage_mix, total_area, star_rating, license, checkin_time, checkout_time, status ؛ يعيد رقم العقار
  FUNCTION save_property(p_doc IN CLOB) RETURN NUMBER;
  -- ينشئ المبنى وطوابقه (الأرضي 0 اختيارياً ثم 1..n)؛ يعيد رقم المبنى
  FUNCTION add_building(p_property_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_floors IN NUMBER,
                        p_ground IN VARCHAR2 DEFAULT 'N') RETURN NUMBER;
  -- JSON: building, floor_from, floor_to, per_floor, start_no, prefix, unit_type, usage_type, bedrooms, bathrooms,
  --   area, furnishing, view, price, room_type (ينشئ غرفة ضيافة لكل وحدة) ؛ يعيد عدد الوحدات المنشأة (يتجاوز الموجود)
  FUNCTION generate_units(p_doc IN CLOB) RETURN NUMBER;
  -- معالج كامل: حقول العقار + buildings:[{code,name,floors,ground}] + units:{...كما في generate_units لكل مبنى}
  --   + hospitality:{room_type_name, base_rate, max_adults} ؛ يعيد رقم العقار
  FUNCTION setup_wizard(p_doc IN CLOB) RETURN NUMBER;
  -- JSON: id, name_ar, unit_type, usage_type, bedrooms, bathrooms, net_area, gross_area, furnishing, view, price, amenities, notes, deed
  PROCEDURE save_unit(p_doc IN CLOB);
  PROCEDURE set_unit_status(p_unit_id IN NUMBER, p_status IN VARCHAR2);

  FUNCTION property_type_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION unit_type_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION usage_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION unit_status_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION property_name(p_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION unit_label(p_unit_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION registry_summary RETURN CLOB;
  FUNCTION property_card_html(p_property_id IN NUMBER) RETURN CLOB;
  -- مخطط الوحدات: p_link يحتوي #ID# لرابط الوحدة
  FUNCTION stacking_html(p_property_id IN NUMBER, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
END NOONA_RE_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_RE_PKG AS

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION fnum(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL THEN '' ELSE TO_CHAR(ROUND(p, 2), 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.,''') END;
  END fnum;

  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  FUNCTION js(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_k) AND NOT p_o.get(p_k).is_null THEN TRIM(p_o.get_string(p_k)) END;
  END js;
  FUNCTION jnum(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN NUMBER IS
    l VARCHAR2(100) := js(p_o, p_k);
  BEGIN
    RETURN CASE WHEN l IS NOT NULL THEN TO_NUMBER(REPLACE(l, ',', ''), '999999999999990.999999', 'NLS_NUMERIC_CHARACTERS=''.,''') END;
  END jnum;

  -- ================================================================ المسميات
  FUNCTION property_type_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'COMPOUND' THEN 'مجمع سكني' WHEN 'TOWER' THEN 'برج' WHEN 'BUILDING' THEN 'عمارة'
      WHEN 'VILLA_COMPOUND' THEN 'مجمع فلل' WHEN 'MALL' THEN 'مركز تجاري' WHEN 'OFFICE_PARK' THEN 'مجمع مكاتب'
      WHEN 'HOTEL' THEN 'فندق' WHEN 'SERVICED_APARTMENTS' THEN 'شقق فندقية' WHEN 'WAREHOUSE_PARK' THEN 'مستودعات'
      WHEN 'LAND_SUBDIVISION' THEN 'مخطط أراض' ELSE p_code END;
  END property_type_label;

  FUNCTION unit_type_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'APARTMENT' THEN 'شقة' WHEN 'VILLA' THEN 'فيلا' WHEN 'TOWNHOUSE' THEN 'تاون هاوس' WHEN 'OFFICE' THEN 'مكتب'
      WHEN 'SHOP' THEN 'محل' WHEN 'SHOWROOM' THEN 'معرض' WHEN 'WAREHOUSE' THEN 'مستودع' WHEN 'ROOM' THEN 'غرفة'
      WHEN 'SUITE' THEN 'جناح' WHEN 'STUDIO' THEN 'استوديو' WHEN 'PARKING' THEN 'موقف' WHEN 'STORAGE' THEN 'مخزن'
      WHEN 'LAND_PLOT' THEN 'قطعة أرض' ELSE p_code END;
  END unit_type_label;

  FUNCTION usage_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'SALE' THEN 'للبيع' WHEN 'LEASE' THEN 'للتأجير' WHEN 'HOSPITALITY' THEN 'ضيافة/فندقي'
      WHEN 'MIXED' THEN 'متعدد' WHEN 'OWNER_USE' THEN 'استخدام المالك' ELSE p_code END;
  END usage_label;

  FUNCTION unit_status_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'PLANNED' THEN 'مخطط' WHEN 'UNDER_CONSTRUCTION' THEN 'تحت الإنشاء' WHEN 'AVAILABLE' THEN 'متاحة'
      WHEN 'RESERVED' THEN 'محجوزة' WHEN 'SOLD' THEN 'مباعة' WHEN 'HANDED_OVER' THEN 'مسلمة' WHEN 'LEASED' THEN 'مؤجرة'
      WHEN 'OCCUPIED' THEN 'مشغولة' WHEN 'UNDER_MAINTENANCE' THEN 'تحت الصيانة' WHEN 'BLOCKED' THEN 'موقوفة'
      WHEN 'OPERATIONAL' THEN 'تشغيلي' WHEN 'UNDER_DEVELOPMENT' THEN 'تحت التطوير' WHEN 'UNDER_RENOVATION' THEN 'تحت التجديد'
      WHEN 'SOLD_OUT' THEN 'مباع بالكامل' WHEN 'INACTIVE' THEN 'غير نشط' ELSE p_code END;
  END unit_status_label;

  FUNCTION property_name(p_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT MAX(name_ar) INTO l FROM re_property WHERE id = p_id AND company_id = company;
    RETURN l;
  END property_name;

  FUNCTION unit_label(p_unit_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(600);
  BEGIN
    SELECT MAX(p.name_ar || ' - ' || NVL(b.name_ar || ' - ', '') || u.code) INTO l
      FROM re_unit u JOIN re_property p ON p.id = u.property_id LEFT JOIN re_building b ON b.id = u.building_id
     WHERE u.id = p_unit_id AND u.company_id = company;
    RETURN l;
  END unit_label;

  -- ================================================================ العقار
  FUNCTION save_property(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := jnum(l_o, 'id');
    l_code VARCHAR2(50) := UPPER(js(l_o, 'code'));
    l_name VARCHAR2(200) := js(l_o, 'name_ar');
    l_type VARCHAR2(30) := NVL(js(l_o, 'type'), 'BUILDING');
    l_en   VARCHAR2(200) := js(l_o, 'name_en');
    l_br   NUMBER := jnum(l_o, 'branch');
    l_city NUMBER := jnum(l_o, 'city');
    l_addr VARCHAR2(500) := js(l_o, 'address');
    l_ph   VARCHAR2(30) := js(l_o, 'phone');
    l_desc VARCHAR2(2000) := js(l_o, 'description');
    l_mm   VARCHAR2(30) := NVL(js(l_o, 'management_mode'), 'OWNED');
    l_own  NUMBER := jnum(l_o, 'owner_party');
    l_mix  VARCHAR2(200) := js(l_o, 'usage_mix');
    l_area NUMBER := jnum(l_o, 'total_area');
    l_star NUMBER := jnum(l_o, 'star_rating');
    l_lic  VARCHAR2(100) := js(l_o, 'license');
    l_cin  VARCHAR2(5) := NVL(js(l_o, 'checkin_time'), '15:00');
    l_cout VARCHAR2(5) := NVL(js(l_o, 'checkout_time'), '12:00');
    l_st   VARCHAR2(30) := NVL(js(l_o, 'status'), 'OPERATIONAL');
    l_n    NUMBER;
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'RE_PROPERTY.CREATE' ELSE 'RE_PROPERTY.UPDATE' END);
    NOONA_CORE_PKG.assert(l_name IS NOT NULL, 'NOONA-RE-001', 'اسم العقار مطلوب', 'Property name is required');
    NOONA_CORE_PKG.assert(l_mm <> 'MANAGED_FOR_OWNER' OR l_own IS NOT NULL, 'NOONA-RE-002', 'حدد المالك للعقار المدار لصالح الغير',
      'Owner required for managed property');
    NOONA_CORE_PKG.assert(REGEXP_LIKE(l_cin, '^[0-2][0-9]:[0-5][0-9]$') AND REGEXP_LIKE(l_cout, '^[0-2][0-9]:[0-5][0-9]$'), 'NOONA-RE-003',
      'وقت الدخول والمغادرة بصيغة HH:MI', 'Times must be HH:MI');
    IF l_code IS NULL THEN
      SELECT 'PR' || LPAD(NVL(MAX(TO_NUMBER(SUBSTR(code, 3))), 0) + 1, 3, '0') INTO l_code
        FROM re_property WHERE company_id = company AND REGEXP_LIKE(code, '^PR[0-9]{1,6}$');
    END IF;
    IF l_id IS NULL THEN
      SELECT COUNT(*) INTO l_n FROM re_property WHERE company_id = company AND code = l_code;
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-RE-004', 'رمز العقار مستخدم: ' || l_code, 'Property code exists');
      INSERT INTO re_property (company_id, branch_id, code, name_ar, name_en, property_type, management_mode, owner_party_id, usage_mix,
                               total_area_sqm, city_id, address_text, phone, description, star_rating, tourism_license_no,
                               checkin_time, checkout_time, status_code)
      VALUES (company, l_br, l_code, l_name, l_en, l_type, l_mm, l_own, l_mix, l_area, l_city, l_addr, l_ph, l_desc, l_star, l_lic,
              l_cin, l_cout, l_st)
      RETURNING id INTO l_id;
      NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'RE_PROPERTY', l_id, 'CREATE', 'SUCCESS');
    ELSE
      UPDATE re_property SET branch_id = l_br, code = l_code, name_ar = l_name, name_en = l_en, property_type = l_type,
             management_mode = l_mm, owner_party_id = l_own, usage_mix = l_mix, total_area_sqm = l_area, city_id = l_city,
             address_text = l_addr, phone = l_ph, description = l_desc, star_rating = l_star, tourism_license_no = l_lic,
             checkin_time = l_cin, checkout_time = l_cout, status_code = l_st
       WHERE id = l_id AND company_id = company;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-RE-005', 'العقار غير موجود', 'Property not found');
    END IF;
    RETURN l_id;
  END save_property;

  FUNCTION add_building(p_property_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_floors IN NUMBER,
                        p_ground IN VARCHAR2 DEFAULT 'N') RETURN NUMBER IS
    l_id   NUMBER;
    l_n    NUMBER;
    l_code VARCHAR2(50) := UPPER(TRIM(p_code));
  BEGIN
    guard('RE_BUILDING.CREATE');
    SELECT COUNT(*) INTO l_n FROM re_property WHERE id = p_property_id AND company_id = company;
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-RE-005', 'العقار غير موجود', 'Property not found');
    NOONA_CORE_PKG.assert(NVL(p_floors, 0) BETWEEN 1 AND 200, 'NOONA-RE-006', 'عدد الطوابق من 1 إلى 200', 'Floors 1-200');
    IF l_code IS NULL THEN
      SELECT CHR(65 + COUNT(*)) INTO l_code FROM re_building WHERE property_id = p_property_id;
    END IF;
    SELECT COUNT(*) INTO l_n FROM re_building WHERE property_id = p_property_id AND code = l_code;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-RE-007', 'رمز المبنى مستخدم في العقار: ' || l_code, 'Building code exists');
    INSERT INTO re_building (company_id, property_id, code, name_ar, floors_count, status_code)
    VALUES (company, p_property_id, l_code, NVL(TRIM(p_name_ar), 'مبنى ' || l_code), p_floors, 'OPERATIONAL')
    RETURNING id INTO l_id;
    IF NVL(p_ground, 'N') = 'Y' THEN
      INSERT INTO re_floor (company_id, building_id, code, name_ar, floor_no, sort_order) VALUES (company, l_id, 'G', 'الدور الأرضي', 0, 0);
    END IF;
    FOR f IN 1 .. p_floors LOOP
      INSERT INTO re_floor (company_id, building_id, code, name_ar, floor_no, sort_order)
      VALUES (company, l_id, TO_CHAR(f), 'الدور ' || f, f, f);
    END LOOP;
    RETURN l_id;
  END add_building;

  FUNCTION generate_units(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_b     re_building%ROWTYPE;
    l_from  NUMBER := jnum(l_o, 'floor_from');
    l_to    NUMBER := jnum(l_o, 'floor_to');
    l_per   NUMBER := NVL(jnum(l_o, 'per_floor'), 1);
    l_start NUMBER := NVL(jnum(l_o, 'start_no'), 1);
    l_pref  VARCHAR2(20) := js(l_o, 'prefix');
    l_type  VARCHAR2(30) := NVL(js(l_o, 'unit_type'), 'APARTMENT');
    l_use   VARCHAR2(30) := NVL(js(l_o, 'usage_type'), 'LEASE');
    l_bed   NUMBER := jnum(l_o, 'bedrooms');
    l_bath  NUMBER := jnum(l_o, 'bathrooms');
    l_area  NUMBER := jnum(l_o, 'area');
    l_furn  VARCHAR2(30) := js(l_o, 'furnishing');
    l_view  VARCHAR2(30) := js(l_o, 'view');
    l_price NUMBER := jnum(l_o, 'price');
    l_rt    NUMBER := jnum(l_o, 'room_type');
    l_code  VARCHAR2(50);
    l_uid   NUMBER;
    l_n     NUMBER := 0;
    l_ex    NUMBER;
  BEGIN
    guard('RE_UNIT.CREATE');
    l_ex := jnum(l_o, 'building');
    SELECT * INTO l_b FROM re_building WHERE id = l_ex AND company_id = company;
    NOONA_CORE_PKG.assert(l_per BETWEEN 1 AND 99, 'NOONA-RE-008', 'عدد الوحدات في الطابق من 1 إلى 99', 'Units per floor 1-99');
    IF l_rt IS NOT NULL THEN
      SELECT COUNT(*) INTO l_ex FROM hsp_room_type WHERE id = l_rt AND property_id = l_b.property_id;
      NOONA_CORE_PKG.assert(l_ex = 1, 'NOONA-RE-009', 'نوع الغرفة لا يتبع هذا العقار', 'Room type does not belong to property');
    END IF;
    FOR f IN (SELECT id, floor_no FROM re_floor WHERE building_id = l_b.id
                AND floor_no BETWEEN NVL(l_from, -99) AND NVL(l_to, 999) ORDER BY floor_no) LOOP
      FOR i IN 0 .. l_per - 1 LOOP
        l_code := l_pref || CASE WHEN f.floor_no = 0 THEN 'G' || LPAD(l_start + i, 2, '0')
                                 ELSE TO_CHAR(f.floor_no) || LPAD(l_start + i, 2, '0') END;
        SELECT COUNT(*) INTO l_ex FROM re_unit WHERE property_id = l_b.property_id AND code = l_code;
        CONTINUE WHEN l_ex > 0;
        INSERT INTO re_unit (company_id, property_id, building_id, floor_id, code, name_ar, unit_type, usage_type, net_area_sqm,
                             gross_area_sqm, bedrooms, bathrooms, view_code, furnishing, list_price, status_code)
        VALUES (company, l_b.property_id, l_b.id, f.id, l_code, unit_type_label(l_type) || ' ' || l_code, l_type, l_use, l_area,
                l_area, l_bed, l_bath, l_view, l_furn, l_price, 'AVAILABLE')
        RETURNING id INTO l_uid;
        IF l_rt IS NOT NULL THEN
          INSERT INTO hsp_room (company_id, property_id, room_type_id, unit_id, room_no, code, floor_id, front_desk_status,
                                housekeeping_status, status_code)
          VALUES (company, l_b.property_id, l_rt, l_uid, l_code, l_code, f.id, 'VACANT', 'CLEAN', 'ACTIVE');
        END IF;
        l_n := l_n + 1;
      END LOOP;
    END LOOP;
    RETURN l_n;
  END generate_units;

  FUNCTION setup_wizard(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_bs  JSON_ARRAY_T;
    l_b   JSON_OBJECT_T;
    l_u   JSON_OBJECT_T;
    l_h   JSON_OBJECT_T;
    l_pid NUMBER;
    l_bid NUMBER;
    l_rt  NUMBER;
    l_n   NUMBER;
    l_rtn VARCHAR2(200);
    l_rate NUMBER;
    l_max NUMBER;
  BEGIN
    l_pid := save_property(p_doc);
    IF l_o.has('hospitality') AND NOT l_o.get('hospitality').is_null THEN
      l_h := l_o.get_object('hospitality');
      l_rtn := NVL(js(l_h, 'room_type_name'), 'غرفة قياسية');
      l_rate := jnum(l_h, 'base_rate');
      l_max := NVL(jnum(l_h, 'max_adults'), 2);
      INSERT INTO hsp_room_type (company_id, property_id, code, name_ar, max_adults, max_children, base_rate, is_active)
      VALUES (company, l_pid, 'STD' || l_pid, l_rtn, l_max, 1, l_rate, 'Y')
      RETURNING id INTO l_rt;
    END IF;
    IF l_o.has('buildings') THEN
      l_bs := l_o.get_array('buildings');
      FOR i IN 0 .. l_bs.get_size - 1 LOOP
        l_b := TREAT(l_bs.get(i) AS JSON_OBJECT_T);
        l_bid := add_building(l_pid, js(l_b, 'code'), js(l_b, 'name'), jnum(l_b, 'floors'), NVL(js(l_b, 'ground'), 'N'));
        IF l_o.has('units') AND NOT l_o.get('units').is_null THEN
          l_u := l_o.get_object('units').clone;
          l_u.put('building', l_bid);
          IF l_rt IS NOT NULL THEN l_u.put('room_type', l_rt); END IF;
          l_n := generate_units(l_u.to_clob);
        END IF;
      END LOOP;
    END IF;
    RETURN l_pid;
  END setup_wizard;

  PROCEDURE save_unit(p_doc IN CLOB) IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := jnum(l_o, 'id');
    l_name VARCHAR2(200) := js(l_o, 'name_ar');
    l_type VARCHAR2(30) := js(l_o, 'unit_type');
    l_use  VARCHAR2(30) := js(l_o, 'usage_type');
    l_bed  NUMBER := jnum(l_o, 'bedrooms');
    l_bath NUMBER := jnum(l_o, 'bathrooms');
    l_na   NUMBER := jnum(l_o, 'net_area');
    l_ga   NUMBER := jnum(l_o, 'gross_area');
    l_furn VARCHAR2(30) := js(l_o, 'furnishing');
    l_view VARCHAR2(30) := js(l_o, 'view');
    l_pr   NUMBER := jnum(l_o, 'price');
    l_am   VARCHAR2(1000) := js(l_o, 'amenities');
    l_nt   VARCHAR2(1000) := js(l_o, 'notes');
    l_deed VARCHAR2(100) := js(l_o, 'deed');
  BEGIN
    guard('RE_UNIT.UPDATE');
    UPDATE re_unit SET name_ar = NVL(l_name, name_ar), unit_type = NVL(l_type, unit_type), usage_type = NVL(l_use, usage_type),
           bedrooms = l_bed, bathrooms = l_bath, net_area_sqm = l_na, gross_area_sqm = l_ga, furnishing = l_furn, view_code = l_view,
           list_price = l_pr, amenities = l_am, notes = l_nt, title_deed_no = l_deed
     WHERE id = l_id AND company_id = company;
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-RE-010', 'الوحدة غير موجودة', 'Unit not found');
  END save_unit;

  PROCEDURE set_unit_status(p_unit_id IN NUMBER, p_status IN VARCHAR2) IS
  BEGIN
    guard('RE_UNIT.UPDATE');
    UPDATE re_unit SET status_code = p_status WHERE id = p_unit_id AND company_id = company;
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-RE-010', 'الوحدة غير موجودة', 'Unit not found');
  END set_unit_status;

  -- ================================================================ العرض
  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_cls VARCHAR2 DEFAULT 'is-info') RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_cls || '"><span class="nn-kpi-icon fa ' || p_icon || '"></span><div><div class="nn-kpi-value">'
        || p_value || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION registry_summary RETURN CLOB IS
    l_p NUMBER; l_u NUMBER; l_av NUMBER; l_oc NUMBER; l_mt NUMBER; l_r NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_p FROM re_property WHERE company_id = company AND status_code <> 'INACTIVE';
    SELECT COUNT(*), COUNT(CASE WHEN status_code = 'AVAILABLE' THEN 1 END),
           COUNT(CASE WHEN status_code IN ('LEASED', 'OCCUPIED', 'SOLD', 'HANDED_OVER', 'RESERVED') THEN 1 END),
           COUNT(CASE WHEN status_code IN ('UNDER_MAINTENANCE', 'BLOCKED') THEN 1 END)
      INTO l_u, l_av, l_oc, l_mt FROM re_unit WHERE company_id = company;
    SELECT COUNT(*) INTO l_r FROM hsp_room WHERE company_id = company AND status_code <> 'INACTIVE';
    RETURN '<div class="nn-kpis">' || kpi('العقارات', l_p, 'fa-building') || kpi('الوحدات', l_u, 'fa-th-large')
        || kpi('متاحة', l_av, 'fa-check-circle', 'is-success') || kpi('مشغولة/مؤجرة/مباعة', l_oc, 'fa-key', 'is-info')
        || kpi('تحت الصيانة أو موقوفة', l_mt, 'fa-wrench', CASE WHEN l_mt > 0 THEN 'is-warning' ELSE 'is-info' END)
        || kpi('غرف وشقق فندقية', l_r, 'fa-bed') || '</div>';
  END registry_summary;

  FUNCTION property_card_html(p_property_id IN NUMBER) RETURN CLOB IS
    l_p  re_property%ROWTYPE;
    l_b  NUMBER; l_u NUMBER; l_av NUMBER; l_oc NUMBER; l_r NUMBER;
    l_city VARCHAR2(200);
  BEGIN
    SELECT * INTO l_p FROM re_property WHERE id = p_property_id AND company_id = company;
    SELECT COUNT(*) INTO l_b FROM re_building WHERE property_id = p_property_id;
    SELECT COUNT(*), COUNT(CASE WHEN status_code = 'AVAILABLE' THEN 1 END),
           COUNT(CASE WHEN status_code IN ('LEASED', 'OCCUPIED', 'SOLD', 'HANDED_OVER', 'RESERVED') THEN 1 END)
      INTO l_u, l_av, l_oc FROM re_unit WHERE property_id = p_property_id;
    SELECT COUNT(*) INTO l_r FROM hsp_room WHERE property_id = p_property_id AND status_code <> 'INACTIVE';
    SELECT MAX(name_ar) INTO l_city FROM ref_city WHERE id = l_p.city_id;
    RETURN '<div class="nn-re-head"><div class="nn-re-title"><span class="fa ' || CASE WHEN l_p.property_type IN ('HOTEL', 'SERVICED_APARTMENTS')
        THEN 'fa-bed' ELSE 'fa-building' END || '"></span><div><b>' || esc(l_p.name_ar) || '</b><small>' || esc(l_p.code) || ' · '
        || property_type_label(l_p.property_type) || CASE WHEN l_p.star_rating IS NOT NULL THEN ' · ' || RPAD('★', l_p.star_rating, '★') END
        || CASE WHEN l_city IS NOT NULL THEN ' · ' || esc(l_city) END || CASE WHEN l_p.address_text IS NOT NULL THEN ' · ' || esc(l_p.address_text) END
        || '</small></div></div><span class="nn-badge is-info">' || unit_status_label(l_p.status_code) || '</span></div>'
        || '<div class="nn-kpis">' || kpi('المباني', l_b, 'fa-building-o') || kpi('الوحدات', l_u, 'fa-th-large')
        || kpi('متاحة', l_av, 'fa-check-circle', 'is-success') || kpi('مشغولة/مؤجرة/مباعة', l_oc, 'fa-key')
        || kpi('نسبة الإشغال', CASE WHEN l_u > 0 THEN ROUND(l_oc * 100 / l_u) || '%' ELSE '-' END, 'fa-pie-chart')
        || CASE WHEN l_r > 0 THEN kpi('غرف الضيافة', l_r, 'fa-bed') END || '</div>'
        || CASE WHEN l_p.description IS NOT NULL THEN '<p class="nn-hint">' || esc(l_p.description) || '</p>' END;
  END property_card_html;

  FUNCTION stacking_html(p_property_id IN NUMBER, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_out CLOB := '<div class="nn-stack-legend">';
    l_n   PLS_INTEGER := 0;
  BEGIN
    FOR s IN (SELECT 'AVAILABLE' c FROM dual UNION ALL SELECT 'RESERVED' FROM dual UNION ALL SELECT 'LEASED' FROM dual
              UNION ALL SELECT 'OCCUPIED' FROM dual UNION ALL SELECT 'SOLD' FROM dual UNION ALL SELECT 'UNDER_MAINTENANCE' FROM dual
              UNION ALL SELECT 'BLOCKED' FROM dual) LOOP
      l_out := l_out || ('<span class="nn-u-' || LOWER(s.c) || '">' || unit_status_label(s.c) || '</span>');
    END LOOP;
    l_out := l_out || ('</div>');
    FOR b IN (SELECT id, code, name_ar FROM re_building WHERE property_id = p_property_id AND company_id = company ORDER BY code) LOOP
      l_out := l_out || ('<div class="nn-stack"><div class="nn-stack-h">' || esc(b.name_ar) || '</div>');
      FOR f IN (SELECT id, floor_no, name_ar FROM re_floor WHERE building_id = b.id ORDER BY floor_no DESC) LOOP
        l_out := l_out || ('<div class="nn-stack-row"><span class="nn-stack-f">' || esc(f.name_ar) || '</span><div class="nn-stack-units">');
        FOR u IN (SELECT id, code, unit_type, status_code, bedrooms FROM re_unit WHERE floor_id = f.id ORDER BY code) LOOP
          l_out := l_out || (CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', u.id) || '"' ELSE '<span' END
                || ' class="nn-u nn-u-' || LOWER(u.status_code) || '" title="' || unit_type_label(u.unit_type) || ' · '
                || unit_status_label(u.status_code) || '"><b>' || esc(u.code) || '</b><small>' || unit_type_label(u.unit_type)
                || CASE WHEN u.bedrooms IS NOT NULL THEN ' ' || u.bedrooms || 'غ' END || '</small>'
                || CASE WHEN p_link IS NOT NULL THEN '</a>' ELSE '</span>' END);
          l_n := l_n + 1;
        END LOOP;
        l_out := l_out || ('</div></div>');
      END LOOP;
      l_out := l_out || ('</div>');
    END LOOP;
    -- وحدات بلا مبنى (فلل، أراض)
    FOR u IN (SELECT id, code, unit_type, status_code FROM re_unit WHERE property_id = p_property_id AND building_id IS NULL ORDER BY code) LOOP
      IF l_n >= 0 AND u.id IS NOT NULL THEN
        l_out := l_out || (CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', u.id) || '"' ELSE '<span' END
              || ' class="nn-u nn-u-' || LOWER(u.status_code) || '"><b>' || esc(u.code) || '</b><small>' || unit_type_label(u.unit_type)
              || '</small>' || CASE WHEN p_link IS NOT NULL THEN '</a>' ELSE '</span>' END);
        l_n := l_n + 1;
      END IF;
    END LOOP;
    IF l_n = 0 THEN
      RETURN '<div class="nn-empty">لا توجد وحدات بعد؛ أضف مبنى وولّد وحداته</div>';
    END IF;
    RETURN l_out;
  END stacking_html;

END NOONA_RE_PKG;
/
