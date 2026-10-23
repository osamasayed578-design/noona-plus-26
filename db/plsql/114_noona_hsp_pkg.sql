-- =============================================================================
-- NOONA PLUS ERP | NOONA_HSP_PKG - الضيافة (الفنادق والشقق الفندقية)
--   * التجهيز: حسابات ذمم النزلاء وحسابات الشركات وإيرادات الإيواء والخدمات، الترقيم
--   * الإعداد: أنواع الغرف، الغرف (أو من وحدات السجل العقاري)، خطط الأسعار (يومي/أسبوعي/شهري) وأسعارها بالفترات
--   * مخزون الغرف الزمني: صف لكل غرفة/ليلة بقيد فريد يمنع الحجز المزدوج
--   * الحجز ← الدخول ← التمديد/التقصير ← تغيير الغرفة ← المغادرة؛ الدخول السريع (Walk-in) بخطوة واحدة؛
--     الإلغاء وعدم الحضور
--   * حساب النزيل (Folio): رسوم الغرف ليلياً بالتدقيق الليلي، الخدمات (مغسلة، ميني بار، مطعم...)، التسويات،
--     الدفعات والاسترداد (نقد، شبكة، تحويل)، التحويل لحساب الشركة (City Ledger) عند المغادرة؛ كل حركة بقيد عبر المحرك المحاسبي
--   * التدبير الفندقي: حالة نظافة الغرفة، مهام التنظيف عند المغادرة وللغرف المشغولة يومياً، الإيقاف للصيانة وإعادة الخدمة
--   * التدقيق الليلي: عدم الحضور، ترحيل الليلة، الإشغال ومتوسط السعر، تقديم تاريخ العمل
--   * لوحة الاستقبال (Room Rack) ومخطط الحجوزات الزمني بصيغة JSON لواجهة سريعة
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_HSP_PKG AUTHID DEFINER AS

  c_vat CONSTANT NUMBER := 15;

  FUNCTION company RETURN NUMBER;
  FUNCTION quick_setup RETURN NUMBER;
  FUNCTION is_ready RETURN VARCHAR2;
  FUNCTION business_date(p_property_id IN NUMBER) RETURN DATE;
  FUNCTION default_property RETURN NUMBER;

  -- ---------------------------------------------------------- الإعداد
  FUNCTION save_room_type(p_id IN NUMBER, p_property_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_max_adults IN NUMBER,
                          p_max_children IN NUMBER, p_beds IN VARCHAR2, p_base_rate IN NUMBER) RETURN NUMBER;
  FUNCTION save_rate_plan(p_id IN NUMBER, p_property_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_stay_type IN VARCHAR2,
                          p_meal IN VARCHAR2, p_includes_tax IN VARCHAR2, p_policy IN VARCHAR2) RETURN NUMBER;
  FUNCTION set_rate(p_rate_plan_id IN NUMBER, p_room_type_id IN NUMBER, p_from IN DATE, p_to IN DATE, p_amount IN NUMBER,
                    p_extra_adult IN NUMBER DEFAULT NULL, p_min_stay IN NUMBER DEFAULT NULL) RETURN NUMBER;
  FUNCTION add_room(p_property_id IN NUMBER, p_room_type_id IN NUMBER, p_room_no IN VARCHAR2, p_floor_id IN NUMBER DEFAULT NULL,
                    p_unit_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
  -- غرفة لكل وحدة ضيافة في العقار لا غرفة لها
  FUNCTION rooms_from_units(p_property_id IN NUMBER, p_room_type_id IN NUMBER) RETURN NUMBER;
  -- سعر الليلة: سعر الخطة الساري للتاريخ (الأسبوعي ÷ 7، الشهري ÷ 30) وإلا السعر الأساسي للنوع
  FUNCTION nightly_rate(p_rate_plan_id IN NUMBER, p_room_type_id IN NUMBER, p_date IN DATE) RETURN NUMBER;
  FUNCTION is_free(p_room_id IN NUMBER, p_from IN DATE, p_to IN DATE, p_ignore_stay IN NUMBER DEFAULT NULL,
                   p_ignore_rr IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION free_room(p_property_id IN NUMBER, p_room_type_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN NUMBER;
  FUNCTION available_count(p_property_id IN NUMBER, p_room_type_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN NUMBER;

  -- ---------------------------------------------------------- النزلاء والحجوزات
  -- يبحث بالهوية ثم الجوال، وإلا ينشئ نزيلاً جديداً
  FUNCTION guest(p_name IN VARCHAR2, p_phone IN VARCHAR2, p_id_type IN VARCHAR2, p_id_no IN VARCHAR2, p_nationality IN VARCHAR2) RETURN NUMBER;
  -- JSON: property, guest | guest_name, phone, id_type, id_no, nationality ؛ company_party, channel, channel_ref, arrival, departure,
  --   adults, children, room_type, room, rate_plan, rate, requests, deposit, deposit_method, bank_account, cash_box, deposit_ref, status
  FUNCTION create_reservation(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE cancel_reservation(p_reservation_id IN NUMBER, p_reason IN VARCHAR2);
  PROCEDURE mark_no_show(p_reservation_id IN NUMBER);
  FUNCTION check_in(p_reservation_id IN NUMBER, p_room_id IN NUMBER DEFAULT NULL, p_force IN VARCHAR2 DEFAULT 'N') RETURN NUMBER;
  -- كالحجز (الوصول = تاريخ العمل) + الدخول + دفعة اختيارية (pay, pay_method) ؛ يعيد رقم الإقامة
  FUNCTION walk_in(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE change_departure(p_stay_id IN NUMBER, p_departure IN DATE);
  FUNCTION move_room(p_stay_id IN NUMBER, p_room_id IN NUMBER, p_reason IN VARCHAR2) RETURN NUMBER;

  -- ---------------------------------------------------------- حساب النزيل
  FUNCTION folio_of_stay(p_stay_id IN NUMBER) RETURN NUMBER;
  FUNCTION folio_of_reservation(p_reservation_id IN NUMBER) RETURN NUMBER;
  FUNCTION folio_balance(p_folio_id IN NUMBER) RETURN NUMBER;
  -- p_type: LAUNDRY, MINIBAR, F_AND_B, SERVICE_CHARGE, OTHER_CHARGE, ADJUSTMENT (سالب = خصم) ؛ المبلغ قبل الضريبة
  FUNCTION post_charge(p_folio_id IN NUMBER, p_type IN VARCHAR2, p_description IN VARCHAR2, p_amount IN NUMBER,
                       p_with_tax IN VARCHAR2 DEFAULT 'Y') RETURN NUMBER;
  -- p_method: CASH, CARD, BANK_TRANSFER ؛ المبلغ السالب استرداد
  FUNCTION post_payment(p_folio_id IN NUMBER, p_amount IN NUMBER, p_method IN VARCHAR2, p_bank_account_id IN NUMBER DEFAULT NULL,
                        p_cash_box_id IN NUMBER DEFAULT NULL, p_reference IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  -- يرحل الليالي المتبقية؛ الرصيد يجب أن يكون صفراً أو يحول لحساب الشركة p_city_ledger_party ؛ يعيد رقم الفوليو
  FUNCTION check_out(p_stay_id IN NUMBER, p_city_ledger_party IN NUMBER DEFAULT NULL) RETURN NUMBER;

  -- ---------------------------------------------------------- التدبير الفندقي والإيقاف
  PROCEDURE set_hk_status(p_room_id IN NUMBER, p_status IN VARCHAR2);
  PROCEDURE assign_hk(p_task_id IN NUMBER, p_employee_id IN NUMBER);
  PROCEDURE complete_hk(p_task_id IN NUMBER, p_inspected IN VARCHAR2 DEFAULT 'N');
  PROCEDURE set_out_of_order(p_room_id IN NUMBER, p_from IN DATE, p_to IN DATE, p_reason IN VARCHAR2, p_work_order_id IN NUMBER DEFAULT NULL);
  PROCEDURE return_to_service(p_room_id IN NUMBER);

  -- ---------------------------------------------------------- التدقيق الليلي
  FUNCTION night_audit(p_property_id IN NUMBER, p_no_shows IN VARCHAR2 DEFAULT 'Y') RETURN NUMBER;

  -- ---------------------------------------------------------- الواجهة والتقارير
  FUNCTION fd_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION hk_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION res_status_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION channel_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION guest_name(p_party_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION res_status(p_reservation_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION guest_phone(p_party_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION rack_json(p_property_id IN NUMBER) RETURN CLOB;
  FUNCTION chart_json(p_property_id IN NUMBER, p_from IN DATE, p_days IN NUMBER DEFAULT 14) RETURN CLOB;
  FUNCTION stay_json(p_stay_id IN NUMBER) RETURN CLOB;
  FUNCTION front_summary(p_property_id IN NUMBER) RETURN CLOB;
  FUNCTION folio_html(p_folio_id IN NUMBER) RETURN CLOB;
  FUNCTION occupancy_html(p_property_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN CLOB;
END NOONA_HSP_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_HSP_PKG AS

  TYPE t_ctx IS RECORD (folio hsp_folio%ROWTYPE, property NUMBER, branch NUMBER, bd DATE, room_no VARCHAR2(20));

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION me RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID')); END me;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION jt(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_CORE_PKG.json_text(p); END jt;
  FUNCTION jn(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL THEN 'null' ELSE RTRIM(RTRIM(TO_CHAR(ROUND(p, 4), 'FM999999999990.9999', 'NLS_NUMERIC_CHARACTERS=''.,'''), '0'), '.') END;
  END jn;
  FUNCTION jd(p DATE) RETURN VARCHAR2 IS BEGIN RETURN CASE WHEN p IS NULL THEN 'null' ELSE '"' || TO_CHAR(p, 'YYYY-MM-DD') || '"' END; END jd;
  FUNCTION fnum(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL THEN '' ELSE TO_CHAR(ROUND(p, 2), 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.,''') END;
  END fnum;
  FUNCTION fd(p DATE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD'); END fd;

  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  FUNCTION acc(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM gl_account WHERE coa_id = NOONA_GL_PKG.primary_coa AND account_code = p_code;
    RETURN l;
  END acc;

  FUNCTION need_acc(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER := acc(p_code);
  BEGIN
    NOONA_CORE_PKG.assert(l IS NOT NULL, 'NOONA-HSP-001', 'الحساب ' || p_code || ' غير موجود؛ نفذ «تجهيز الضيافة»',
      'Account ' || p_code || ' missing; run hospitality setup');
    RETURN l;
  END need_acc;

  FUNCTION ensure_account(p_code VARCHAR2, p_name VARCHAR2, p_parent VARCHAR2, p_type VARCHAR2) RETURN NUMBER IS
    l NUMBER := acc(p_code);
  BEGIN
    IF l IS NULL THEN
      l := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, p_code, p_name, p_parent, p_type, 'Y', NULL);
    END IF;
    RETURN l;
  END ensure_account;

  PROCEDURE ensure_sequence(p_type VARCHAR2, p_prefix VARCHAR2) IS
  BEGIN
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT company, p_type, NULL, p_prefix, 1, 6, 'N', 'NEVER', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = p_type);
  END ensure_sequence;

  FUNCTION next_no(p_type VARCHAR2, p_prefix VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    ensure_sequence(p_type, p_prefix);
    RETURN NOONA_REFERENCE_PKG.next_doc_no(p_type, company, NULL, TRUNC(SYSDATE), p_type, NULL);
  END next_no;

  -- ================================================================ المسميات
  FUNCTION fd_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'VACANT' THEN 'شاغرة' WHEN 'OCCUPIED' THEN 'مشغولة' WHEN 'DUE_OUT' THEN 'مغادرة اليوم'
      WHEN 'DUE_IN' THEN 'وصول اليوم' WHEN 'RESERVED' THEN 'محجوزة' WHEN 'BLOCKED' THEN 'موقوفة' WHEN 'OOO' THEN 'خارج الخدمة'
      ELSE p_code END;
  END fd_label;

  FUNCTION hk_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'CLEAN' THEN 'نظيفة' WHEN 'DIRTY' THEN 'تحت التنظيف' WHEN 'INSPECTED' THEN 'نظيفة ومفحوصة'
      WHEN 'IN_PROGRESS' THEN 'جاري التنظيف' WHEN 'OUT_OF_ORDER' THEN 'خارج الخدمة' ELSE p_code END;
  END hk_label;

  FUNCTION res_status_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'TENTATIVE' THEN 'مبدئي' WHEN 'CONFIRMED' THEN 'مؤكد' WHEN 'GUARANTEED' THEN 'مضمون بعربون'
      WHEN 'CHECKED_IN' THEN 'مقيم' WHEN 'CHECKED_OUT' THEN 'غادر' WHEN 'NO_SHOW' THEN 'لم يحضر' WHEN 'CANCELLED' THEN 'ملغى'
      WHEN 'WAITLIST' THEN 'قائمة انتظار' WHEN 'IN_HOUSE' THEN 'مقيم' WHEN 'ROOM_MOVED' THEN 'نقل لغرفة أخرى'
      WHEN 'OPEN' THEN 'مفتوح' WHEN 'SETTLED' THEN 'مسدد' WHEN 'CLOSED' THEN 'مقفل' WHEN 'TRANSFERRED' THEN 'محول لحساب الشركة'
      WHEN 'VOID' THEN 'ملغى' WHEN 'PENDING' THEN 'معلقة' WHEN 'ASSIGNED' THEN 'مسندة' WHEN 'DONE' THEN 'منفذة'
      WHEN 'INSPECTED' THEN 'مفحوصة' WHEN 'REJECTED' THEN 'مرفوضة' WHEN 'IN_PROGRESS' THEN 'جارية' ELSE p_code END;
  END res_status_label;

  FUNCTION channel_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'WALK_IN' THEN 'حضور مباشر' WHEN 'PHONE' THEN 'هاتف' WHEN 'EMAIL' THEN 'بريد' WHEN 'WEBSITE' THEN 'الموقع'
      WHEN 'OTA' THEN 'منصات الحجز' WHEN 'CORPORATE' THEN 'شركات' WHEN 'TRAVEL_AGENT' THEN 'وكيل سفر' ELSE p_code END;
  END channel_label;

  FUNCTION guest_name(p_party_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(200);
  BEGIN
    SELECT MAX(display_name_ar) INTO l FROM pty_party WHERE id = p_party_id;
    RETURN l;
  END guest_name;

  FUNCTION res_status(p_reservation_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM hsp_reservation WHERE id = p_reservation_id AND company_id = company;
    RETURN l;
  END res_status;

  FUNCTION guest_phone(p_party_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(50);
  BEGIN
    SELECT MAX(mobile) KEEP (DENSE_RANK FIRST ORDER BY CASE is_primary WHEN 'Y' THEN 0 ELSE 1 END, id) INTO l
      FROM ref_contact WHERE party_id = p_party_id;
    RETURN l;
  END guest_phone;

  -- ================================================================ التجهيز
  FUNCTION default_property RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(p.id) KEEP (DENSE_RANK FIRST ORDER BY p.code) INTO l FROM re_property p
     WHERE p.company_id = company AND p.status_code <> 'INACTIVE'
       AND EXISTS (SELECT 1 FROM hsp_room r WHERE r.property_id = p.id AND r.status_code <> 'INACTIVE');
    RETURN l;
  END default_property;

  FUNCTION business_date(p_property_id IN NUMBER) RETURN DATE IS
    l DATE;
  BEGIN
    SELECT MAX(business_date) INTO l FROM re_property WHERE id = p_property_id AND company_id = company;
    RETURN NVL(l, TRUNC(SYSDATE));
  END business_date;

  FUNCTION quick_setup RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    guard('HSP_ROOM_TYPE.CREATE');
    IF NOONA_GL_PKG.primary_ledger IS NULL THEN
      l_id := NOONA_GL_PKG.quick_setup;
    END IF;
    l_id := ensure_account('1112', 'ذمم النزلاء (الحسابات المفتوحة)', '11', 'ASSET');
    l_id := ensure_account('1113', 'ذمم الشركات والجهات (City Ledger)', '11', 'ASSET');
    l_id := ensure_account('4110', 'إيرادات الإيواء والغرف', '4', 'REVENUE');
    l_id := ensure_account('4111', 'إيرادات خدمات الضيافة', '4', 'REVENUE');
    ensure_sequence('HSP_RESERVATION', 'RS-');
    ensure_sequence('HSP_FOLIO', 'FO-');
    NOONA_AUDIT_PKG.log_event('CONFIG', 'HSP_ROOM_TYPE', NULL, 'QUICK_SETUP', 'SUCCESS');
    RETURN 4;
  END quick_setup;

  FUNCTION is_ready RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN acc('1112') IS NOT NULL AND acc('4110') IS NOT NULL THEN 'Y' ELSE 'N' END;
  END is_ready;

  -- ================================================================ الإعداد
  FUNCTION save_room_type(p_id IN NUMBER, p_property_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_max_adults IN NUMBER,
                          p_max_children IN NUMBER, p_beds IN VARCHAR2, p_base_rate IN NUMBER) RETURN NUMBER IS
    l_id NUMBER := p_id;
  BEGIN
    guard(CASE WHEN p_id IS NULL THEN 'HSP_ROOM_TYPE.CREATE' ELSE 'HSP_ROOM_TYPE.UPDATE' END);
    NOONA_CORE_PKG.assert(TRIM(p_code) IS NOT NULL AND TRIM(p_name_ar) IS NOT NULL, 'NOONA-HSP-002', 'الرمز والاسم مطلوبان', 'Code and name required');
    NOONA_CORE_PKG.assert(NVL(p_base_rate, 0) >= 0, 'NOONA-HSP-003', 'السعر لا يكون سالباً', 'Negative rate');
    IF l_id IS NULL THEN
      INSERT INTO hsp_room_type (company_id, property_id, code, name_ar, max_adults, max_children, bed_config, base_rate, is_active)
      VALUES (company, p_property_id, UPPER(TRIM(p_code)), TRIM(p_name_ar), NVL(p_max_adults, 2), NVL(p_max_children, 0), p_beds,
              p_base_rate, 'Y')
      RETURNING id INTO l_id;
    ELSE
      UPDATE hsp_room_type SET code = UPPER(TRIM(p_code)), name_ar = TRIM(p_name_ar), max_adults = NVL(p_max_adults, 2),
             max_children = NVL(p_max_children, 0), bed_config = p_beds, base_rate = p_base_rate
       WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  END save_room_type;

  FUNCTION save_rate_plan(p_id IN NUMBER, p_property_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_stay_type IN VARCHAR2,
                          p_meal IN VARCHAR2, p_includes_tax IN VARCHAR2, p_policy IN VARCHAR2) RETURN NUMBER IS
    l_id NUMBER := p_id;
  BEGIN
    guard(CASE WHEN p_id IS NULL THEN 'HSP_RATE_PLAN.CREATE' ELSE 'HSP_RATE_PLAN.UPDATE' END);
    NOONA_CORE_PKG.assert(TRIM(p_code) IS NOT NULL AND TRIM(p_name_ar) IS NOT NULL, 'NOONA-HSP-002', 'الرمز والاسم مطلوبان', 'Code and name required');
    IF l_id IS NULL THEN
      INSERT INTO hsp_rate_plan (company_id, property_id, code, name_ar, currency_code, stay_type, meal_plan, includes_tax,
                                 cancellation_policy, effective_from, is_active)
      VALUES (company, p_property_id, UPPER(TRIM(p_code)), TRIM(p_name_ar), NOONA_GL_PKG.ledger_currency, NVL(p_stay_type, 'DAILY'),
              NVL(p_meal, 'ROOM_ONLY'), NVL(p_includes_tax, 'N'), p_policy, DATE '2000-01-01', 'Y')
      RETURNING id INTO l_id;
    ELSE
      UPDATE hsp_rate_plan SET code = UPPER(TRIM(p_code)), name_ar = TRIM(p_name_ar), stay_type = NVL(p_stay_type, 'DAILY'),
             meal_plan = NVL(p_meal, 'ROOM_ONLY'), includes_tax = NVL(p_includes_tax, 'N'), cancellation_policy = p_policy
       WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  END save_rate_plan;

  FUNCTION set_rate(p_rate_plan_id IN NUMBER, p_room_type_id IN NUMBER, p_from IN DATE, p_to IN DATE, p_amount IN NUMBER,
                    p_extra_adult IN NUMBER DEFAULT NULL, p_min_stay IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    guard('HSP_RATE.CREATE');
    NOONA_CORE_PKG.assert(p_amount > 0 AND p_to >= p_from, 'NOONA-HSP-004', 'السعر موجب والفترة صحيحة', 'Positive rate and valid period');
    MERGE INTO hsp_rate r
    USING (SELECT p_rate_plan_id pl, p_room_type_id rt, p_from df FROM dual) x
       ON (r.rate_plan_id = x.pl AND r.room_type_id = x.rt AND r.date_from = x.df)
     WHEN MATCHED THEN UPDATE SET r.date_to = p_to, r.rate_amount = p_amount, r.extra_adult = p_extra_adult, r.min_stay_nights = p_min_stay
     WHEN NOT MATCHED THEN INSERT (company_id, rate_plan_id, room_type_id, date_from, date_to, rate_amount, extra_adult, min_stay_nights)
          VALUES (company, p_rate_plan_id, p_room_type_id, p_from, p_to, p_amount, p_extra_adult, p_min_stay);
    SELECT id INTO l_id FROM hsp_rate WHERE rate_plan_id = p_rate_plan_id AND room_type_id = p_room_type_id AND date_from = p_from;
    RETURN l_id;
  END set_rate;

  FUNCTION add_room(p_property_id IN NUMBER, p_room_type_id IN NUMBER, p_room_no IN VARCHAR2, p_floor_id IN NUMBER DEFAULT NULL,
                    p_unit_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_id NUMBER;
    l_n  NUMBER;
  BEGIN
    guard('HSP_ROOM.CREATE');
    NOONA_CORE_PKG.assert(TRIM(p_room_no) IS NOT NULL, 'NOONA-HSP-005', 'رقم الغرفة مطلوب', 'Room number required');
    SELECT COUNT(*) INTO l_n FROM hsp_room WHERE property_id = p_property_id AND room_no = TRIM(p_room_no);
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HSP-006', 'رقم الغرفة مستخدم: ' || p_room_no, 'Room number exists');
    INSERT INTO hsp_room (company_id, property_id, room_type_id, unit_id, room_no, code, floor_id, front_desk_status, housekeeping_status, status_code)
    VALUES (company, p_property_id, p_room_type_id, p_unit_id, TRIM(p_room_no), TRIM(p_room_no), p_floor_id, 'VACANT', 'CLEAN', 'ACTIVE')
    RETURNING id INTO l_id;
    RETURN l_id;
  END add_room;

  FUNCTION rooms_from_units(p_property_id IN NUMBER, p_room_type_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    guard('HSP_ROOM.CREATE');
    INSERT INTO hsp_room (company_id, property_id, room_type_id, unit_id, room_no, code, floor_id, front_desk_status, housekeeping_status, status_code)
    SELECT company, u.property_id, p_room_type_id, u.id, u.code, u.code, u.floor_id, 'VACANT', 'CLEAN', 'ACTIVE'
      FROM re_unit u
     WHERE u.property_id = p_property_id AND u.company_id = company AND u.usage_type IN ('HOSPITALITY', 'MIXED')
       AND NOT EXISTS (SELECT 1 FROM hsp_room r WHERE r.unit_id = u.id OR (r.property_id = u.property_id AND r.room_no = u.code));
    RETURN SQL%ROWCOUNT;
  END rooms_from_units;

  FUNCTION nightly_rate(p_rate_plan_id IN NUMBER, p_room_type_id IN NUMBER, p_date IN DATE) RETURN NUMBER IS
    l_amt  NUMBER;
    l_type VARCHAR2(30);
  BEGIN
    IF p_rate_plan_id IS NOT NULL THEN
      SELECT MAX(stay_type) INTO l_type FROM hsp_rate_plan WHERE id = p_rate_plan_id;
      SELECT MAX(rate_amount) KEEP (DENSE_RANK LAST ORDER BY date_from) INTO l_amt FROM hsp_rate
       WHERE rate_plan_id = p_rate_plan_id AND room_type_id = p_room_type_id AND p_date BETWEEN date_from AND date_to;
      IF l_amt IS NOT NULL THEN
        RETURN ROUND(l_amt / CASE l_type WHEN 'WEEKLY' THEN 7 WHEN 'MONTHLY' THEN 30 ELSE 1 END, 2);
      END IF;
    END IF;
    SELECT MAX(base_rate) INTO l_amt FROM hsp_room_type WHERE id = p_room_type_id;
    RETURN l_amt;
  END nightly_rate;

  FUNCTION is_free(p_room_id IN NUMBER, p_from IN DATE, p_to IN DATE, p_ignore_stay IN NUMBER DEFAULT NULL,
                   p_ignore_rr IN NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM hsp_room_block
     WHERE room_id = p_room_id AND stay_date >= p_from AND stay_date < p_to
       AND NVL(stay_id, -1) <> NVL(p_ignore_stay, -2) AND NVL(reservation_room_id, -1) <> NVL(p_ignore_rr, -2);
    RETURN CASE WHEN l = 0 THEN 'Y' ELSE 'N' END;
  END is_free;

  FUNCTION free_room(p_property_id IN NUMBER, p_room_type_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(r.id) KEEP (DENSE_RANK FIRST ORDER BY CASE r.housekeeping_status WHEN 'INSPECTED' THEN 0 WHEN 'CLEAN' THEN 1 ELSE 2 END,
                                                     r.room_no) INTO l
      FROM hsp_room r
     WHERE r.property_id = p_property_id AND r.room_type_id = p_room_type_id AND r.status_code = 'ACTIVE'
       AND NOT EXISTS (SELECT 1 FROM hsp_room_block b WHERE b.room_id = r.id AND b.stay_date >= p_from AND b.stay_date < p_to);
    RETURN l;
  END free_room;

  FUNCTION available_count(p_property_id IN NUMBER, p_room_type_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM hsp_room r
     WHERE r.property_id = p_property_id AND (p_room_type_id IS NULL OR r.room_type_id = p_room_type_id) AND r.status_code = 'ACTIVE'
       AND NOT EXISTS (SELECT 1 FROM hsp_room_block b WHERE b.room_id = r.id AND b.stay_date >= p_from AND b.stay_date < p_to);
    RETURN l;
  END available_count;

  -- يحجز الليالي [من، إلى) للغرفة؛ القيد الفريد (غرفة، ليلة) يمنع التداخل
  PROCEDURE block_nights(p_room NUMBER, p_from DATE, p_to DATE, p_type VARCHAR2, p_rr NUMBER, p_stay NUMBER) IS
    l_no VARCHAR2(20);
  BEGIN
    FOR i IN 0 .. TRUNC(p_to) - TRUNC(p_from) - 1 LOOP
      BEGIN
        INSERT INTO hsp_room_block (company_id, room_id, stay_date, block_type, reservation_room_id, stay_id)
        VALUES (company, p_room, TRUNC(p_from) + i, p_type, p_rr, p_stay);
      EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        SELECT MAX(room_no) INTO l_no FROM hsp_room WHERE id = p_room;
        NOONA_CORE_PKG.raise_error('NOONA-HSP-010', 'الغرفة ' || l_no || ' غير متاحة ليلة ' || fd(TRUNC(p_from) + i)
          || '؛ اختر غرفة أخرى أو غيّر التواريخ', 'Room not available for ' || fd(TRUNC(p_from) + i));
      END;
    END LOOP;
  END block_nights;

  PROCEDURE hk_task(p_room NUMBER, p_type VARCHAR2, p_date DATE) IS
  BEGIN
    INSERT INTO hsp_housekeeping_task (company_id, room_id, task_date, task_type, status_code)
    SELECT company, p_room, p_date, p_type, 'PENDING' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM hsp_housekeeping_task WHERE room_id = p_room AND task_date = p_date AND task_type = p_type
                          AND status_code IN ('PENDING', 'ASSIGNED', 'IN_PROGRESS'));
  END hk_task;

  -- ================================================================ النزلاء
  FUNCTION guest(p_name IN VARCHAR2, p_phone IN VARCHAR2, p_id_type IN VARCHAR2, p_id_no IN VARCHAR2, p_nationality IN VARCHAR2) RETURN NUMBER IS
    l_id   NUMBER;
    l_hash VARCHAR2(128);
    l_no   VARCHAR2(50) := REPLACE(TRIM(p_id_no), ' ');
    l_ph   VARCHAR2(30) := REPLACE(TRIM(p_phone), ' ');
  BEGIN
    IF l_no IS NOT NULL THEN
      l_hash := LOWER(RAWTOHEX(DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(UPPER(l_no)), DBMS_CRYPTO.HASH_SH256)));
      SELECT MIN(party_id) INTO l_id FROM pty_identification WHERE id_number_hash = l_hash;
      IF l_id IS NOT NULL THEN RETURN l_id; END IF;
    END IF;
    IF l_ph IS NOT NULL AND l_no IS NULL THEN
      SELECT MIN(c.party_id) INTO l_id FROM ref_contact c JOIN pty_party p ON p.id = c.party_id
       WHERE c.mobile = l_ph AND p.party_type = 'PERSON' AND p.display_name_ar = TRIM(p_name);
      IF l_id IS NOT NULL THEN RETURN l_id; END IF;
    END IF;
    NOONA_CORE_PKG.assert(TRIM(p_name) IS NOT NULL, 'NOONA-HSP-011', 'اسم النزيل مطلوب', 'Guest name required');
    INSERT INTO pty_party (party_no, party_type, display_name_ar, ownership_scope, owner_company_id, country_code, status_code)
    VALUES ('NEW-' || RAWTOHEX(SYS_GUID()), 'PERSON', TRIM(p_name), 'TENANT_SHARED', company, NVL(p_nationality, 'SA'), 'ACTIVE')
    RETURNING id INTO l_id;
    UPDATE pty_party SET party_no = 'P-' || LPAD(l_id, 6, '0') WHERE id = l_id;
    INSERT INTO pty_person (party_id, first_name_ar, nationality) VALUES (l_id, TRIM(p_name), NVL(p_nationality, 'SA'));
    INSERT INTO pty_party_role (party_id, role_code, company_id, status_code) VALUES (l_id, 'GUEST', company, 'ACTIVE');
    IF l_ph IS NOT NULL THEN
      INSERT INTO ref_contact (party_id, contact_role, contact_name, mobile, is_primary) VALUES (l_id, 'GENERAL', TRIM(p_name), l_ph, 'Y');
    END IF;
    IF l_no IS NOT NULL THEN
      INSERT INTO pty_identification (party_id, id_type_code, id_number_masked, id_number_hash, issuing_country, is_primary, status_code)
      VALUES (l_id, NVL(p_id_type, 'NATIONAL_ID'), RPAD('*', GREATEST(LENGTH(l_no) - 4, 0), '*') || SUBSTR(l_no, -4), l_hash,
              NVL(p_nationality, 'SA'), 'Y', 'ACTIVE');
    END IF;
    RETURN l_id;
  END guest;

  -- ================================================================ الحجوزات
  FUNCTION js(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_k) AND NOT p_o.get(p_k).is_null THEN TRIM(p_o.get_string(p_k)) END;
  END js;
  FUNCTION jnum(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN NUMBER IS
    l VARCHAR2(100) := js(p_o, p_k);
  BEGIN
    RETURN CASE WHEN l IS NOT NULL THEN TO_NUMBER(REPLACE(l, ',', ''), '999999999999990.999999', 'NLS_NUMERIC_CHARACTERS=''.,''') END;
  END jnum;
  FUNCTION jdate(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN DATE IS
    l VARCHAR2(30) := js(p_o, p_k);
  BEGIN
    RETURN CASE WHEN l IS NOT NULL THEN TO_DATE(SUBSTR(l, 1, 10), 'YYYY-MM-DD') END;
  END jdate;

  FUNCTION res_row(p_id NUMBER, p_lock BOOLEAN DEFAULT FALSE) RETURN hsp_reservation%ROWTYPE IS
    l hsp_reservation%ROWTYPE;
  BEGIN
    IF p_lock THEN
      SELECT * INTO l FROM hsp_reservation WHERE id = p_id AND company_id = company FOR UPDATE;
    ELSE
      SELECT * INTO l FROM hsp_reservation WHERE id = p_id AND company_id = company;
    END IF;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HSP-012', 'الحجز غير موجود', 'Reservation not found');
  END res_row;

  FUNCTION stay_row(p_id NUMBER) RETURN hsp_stay%ROWTYPE IS
    l hsp_stay%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM hsp_stay WHERE id = p_id AND company_id = company FOR UPDATE;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HSP-013', 'الإقامة غير موجودة', 'Stay not found');
  END stay_row;

  FUNCTION property_of_room(p_room NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT property_id INTO l FROM hsp_room WHERE id = p_room;
    RETURN l;
  END property_of_room;

  FUNCTION create_reservation(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_prop  NUMBER := jnum(l_o, 'property');
    l_guest NUMBER := jnum(l_o, 'guest');
    l_arr   DATE := jdate(l_o, 'arrival');
    l_dep   DATE := jdate(l_o, 'departure');
    l_rt    NUMBER := jnum(l_o, 'room_type');
    l_room  NUMBER := jnum(l_o, 'room');
    l_plan  NUMBER := jnum(l_o, 'rate_plan');
    l_rate  NUMBER := jnum(l_o, 'rate');
    l_ad    NUMBER := NVL(jnum(l_o, 'adults'), 1);
    l_ch    NUMBER := NVL(jnum(l_o, 'children'), 0);
    l_chan  VARCHAR2(30) := NVL(js(l_o, 'channel'), 'PHONE');
    l_cref  VARCHAR2(100) := js(l_o, 'channel_ref');
    l_cmp   NUMBER := jnum(l_o, 'company_party');
    l_req   VARCHAR2(2000) := js(l_o, 'requests');
    l_dep_a NUMBER := NVL(jnum(l_o, 'deposit'), 0);
    l_st    VARCHAR2(30) := NVL(js(l_o, 'status'), 'CONFIRMED');
    l_bd    DATE;
    l_max   NUMBER;
    l_id    NUMBER;
    l_rr    NUMBER;
    l_fol   NUMBER;
    l_tot   NUMBER := 0;
    l_line  NUMBER;
    l_no    VARCHAR2(50);
    l_fno   VARCHAR2(50);
  BEGIN
    guard('HSP_RESERVATION.CREATE');
    NOONA_CORE_PKG.assert(l_prop IS NOT NULL, 'NOONA-HSP-014', 'حدد الفندق أو العقار', 'Property required');
    l_bd := business_date(l_prop);
    NOONA_CORE_PKG.assert(l_arr IS NOT NULL AND l_dep > l_arr, 'NOONA-HSP-015', 'تاريخ المغادرة بعد تاريخ الوصول', 'Departure must follow arrival');
    NOONA_CORE_PKG.assert(l_arr >= l_bd, 'NOONA-HSP-016', 'تاريخ الوصول يسبق تاريخ العمل الفندقي (' || fd(l_bd) || ')',
      'Arrival before business date');
    IF l_guest IS NULL THEN
      l_guest := guest(js(l_o, 'guest_name'), js(l_o, 'phone'), js(l_o, 'id_type'), js(l_o, 'id_no'), js(l_o, 'nationality'));
    END IF;
    IF l_room IS NOT NULL THEN
      SELECT room_type_id INTO l_rt FROM hsp_room WHERE id = l_room AND property_id = l_prop AND status_code = 'ACTIVE';
    END IF;
    NOONA_CORE_PKG.assert(l_rt IS NOT NULL, 'NOONA-HSP-017', 'حدد نوع الغرفة أو الغرفة', 'Room type or room required');
    SELECT max_adults + max_children INTO l_max FROM hsp_room_type WHERE id = l_rt;
    NOONA_CORE_PKG.assert(l_ad + l_ch <= l_max + 1, 'NOONA-HSP-018', 'عدد النزلاء يتجاوز سعة الغرفة (' || l_max || ')', 'Guests exceed capacity');
    IF l_room IS NULL THEN
      l_room := free_room(l_prop, l_rt, l_arr, l_dep);
      NOONA_CORE_PKG.assert(l_room IS NOT NULL, 'NOONA-HSP-019', 'لا توجد غرفة متاحة من هذا النوع في الفترة المطلوبة',
        'No room of this type is available');
    END IF;
    IF l_plan IS NULL THEN
      SELECT MIN(id) INTO l_plan FROM hsp_rate_plan WHERE property_id = l_prop AND is_active = 'Y' AND stay_type = 'DAILY';
    END IF;
    IF l_rate IS NULL THEN
      l_rate := nightly_rate(l_plan, l_rt, l_arr);
    END IF;
    NOONA_CORE_PKG.assert(NVL(l_rate, 0) > 0, 'NOONA-HSP-020', 'لا يوجد سعر للغرفة؛ حدد السعر أو عرّف خطة الأسعار', 'No rate defined');
    FOR i IN 0 .. l_dep - l_arr - 1 LOOP
      l_tot := l_tot + l_rate;
    END LOOP;
    l_no := next_no('HSP_RESERVATION', 'RS-');
    INSERT INTO hsp_reservation (company_id, doc_no, doc_date, currency_code, property_id, guest_party_id, company_party_id, channel_code,
                                 channel_reference, arrival_date, departure_date, adults, children, rate_plan_id, total_estimate,
                                 deposit_amount, special_requests, status_code)
    VALUES (company, l_no, TRUNC(SYSDATE), NOONA_GL_PKG.ledger_currency, l_prop, l_guest, l_cmp, l_chan, l_cref, l_arr, l_dep, l_ad, l_ch,
            l_plan, l_tot, l_dep_a, l_req, CASE WHEN l_dep_a > 0 AND l_st = 'CONFIRMED' THEN 'GUARANTEED' ELSE l_st END)
    RETURNING id INTO l_id;
    INSERT INTO hsp_reservation_room (company_id, reservation_id, room_type_id, room_id, arrival_date, departure_date, nightly_rate, status_code)
    VALUES (company, l_id, l_rt, l_room, l_arr, l_dep, l_rate, 'ASSIGNED')
    RETURNING id INTO l_rr;
    block_nights(l_room, l_arr, l_dep, 'RESERVATION', l_rr, NULL);
    l_fno := next_no('HSP_FOLIO', 'FO-');
    INSERT INTO hsp_folio (company_id, folio_no, currency_code, reservation_id, folio_type, payer_party_id, balance, status_code)
    VALUES (company, l_fno, NOONA_GL_PKG.ledger_currency, l_id, 'GUEST', l_guest, 0, 'OPEN')
    RETURNING id INTO l_fol;
    IF l_dep_a > 0 THEN
      l_line := post_payment(l_fol, l_dep_a, NVL(js(l_o, 'deposit_method'), 'CASH'), jnum(l_o, 'bank_account'), jnum(l_o, 'cash_box'),
                             NVL(js(l_o, 'deposit_ref'), 'عربون ' || l_no));
    END IF;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'HSP_RESERVATION', l_id, 'CREATE', 'SUCCESS');
    RETURN l_id;
  END create_reservation;

  PROCEDURE release(p_reservation_id NUMBER) IS
  BEGIN
    DELETE FROM hsp_room_block WHERE stay_id IS NULL
       AND reservation_room_id IN (SELECT id FROM hsp_reservation_room WHERE reservation_id = p_reservation_id);
    UPDATE hsp_reservation_room SET status_code = 'CANCELLED' WHERE reservation_id = p_reservation_id AND status_code IN ('PENDING', 'ASSIGNED');
    UPDATE hsp_folio SET status_code = 'VOID' WHERE reservation_id = p_reservation_id AND stay_id IS NULL AND status_code = 'OPEN'
       AND NOT EXISTS (SELECT 1 FROM hsp_folio_line l WHERE l.folio_id = hsp_folio.id);
  END release;

  PROCEDURE cancel_reservation(p_reservation_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_r hsp_reservation%ROWTYPE := res_row(p_reservation_id, TRUE);
  BEGIN
    guard('HSP_RESERVATION.UPDATE');
    NOONA_CORE_PKG.assert(l_r.status_code IN ('TENTATIVE', 'CONFIRMED', 'GUARANTEED', 'WAITLIST'), 'NOONA-HSP-021',
      'لا يلغى حجز ' || res_status_label(l_r.status_code), 'Reservation cannot be cancelled');
    release(p_reservation_id);
    UPDATE hsp_reservation SET status_code = 'CANCELLED', cancelled_at = SYSTIMESTAMP,
           special_requests = SUBSTR(special_requests || CASE WHEN special_requests IS NOT NULL THEN ' | ' END || 'إلغاء: ' || p_reason, 1, 2000)
     WHERE id = p_reservation_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'HSP_RESERVATION', p_reservation_id, 'CANCEL', 'SUCCESS');
  END cancel_reservation;

  PROCEDURE mark_no_show(p_reservation_id IN NUMBER) IS
    l_r hsp_reservation%ROWTYPE := res_row(p_reservation_id, TRUE);
  BEGIN
    guard('HSP_RESERVATION.UPDATE');
    NOONA_CORE_PKG.assert(l_r.status_code IN ('TENTATIVE', 'CONFIRMED', 'GUARANTEED') AND l_r.arrival_date <= business_date(l_r.property_id),
      'NOONA-HSP-022', 'عدم الحضور لحجز وصل موعده ولم يسجل دخوله', 'No-show only for due arrivals');
    release(p_reservation_id);
    UPDATE hsp_reservation SET status_code = 'NO_SHOW' WHERE id = p_reservation_id;
  END mark_no_show;

  PROCEDURE set_room_fd(p_room NUMBER, p_fd VARCHAR2, p_hk VARCHAR2 DEFAULT NULL) IS
  BEGIN
    UPDATE hsp_room SET front_desk_status = p_fd, housekeeping_status = NVL(p_hk, housekeeping_status) WHERE id = p_room;
  END set_room_fd;

  FUNCTION check_in(p_reservation_id IN NUMBER, p_room_id IN NUMBER DEFAULT NULL, p_force IN VARCHAR2 DEFAULT 'N') RETURN NUMBER IS
    l_r    hsp_reservation%ROWTYPE := res_row(p_reservation_id, TRUE);
    l_rr   hsp_reservation_room%ROWTYPE;
    l_room hsp_room%ROWTYPE;
    l_bd   DATE;
    l_n    NUMBER;
    l_st   NUMBER;
    l_me   NUMBER := me;
  BEGIN
    guard('HSP_STAY.CREATE');
    l_bd := business_date(l_r.property_id);
    NOONA_CORE_PKG.assert(l_r.status_code IN ('TENTATIVE', 'CONFIRMED', 'GUARANTEED'), 'NOONA-HSP-023',
      'الحجز ' || res_status_label(l_r.status_code) || '؛ لا يسجل دخوله', 'Reservation cannot be checked in');
    NOONA_CORE_PKG.assert(l_r.arrival_date <= l_bd, 'NOONA-HSP-024', 'موعد الوصول ' || fd(l_r.arrival_date) || ' لم يحن بعد',
      'Arrival date not reached');
    NOONA_CORE_PKG.assert(l_r.departure_date > l_bd, 'NOONA-HSP-025', 'انتهت مدة الحجز؛ عدّل تاريخ المغادرة', 'Reservation period passed');
    SELECT * INTO l_rr FROM hsp_reservation_room WHERE reservation_id = p_reservation_id AND status_code IN ('PENDING', 'ASSIGNED')
       AND ROWNUM = 1 FOR UPDATE;
    -- الليالي السابقة لتاريخ العمل (وصول متأخر) تحرر
    DELETE FROM hsp_room_block WHERE reservation_room_id = l_rr.id AND stay_date < l_bd;
    IF p_room_id IS NOT NULL AND p_room_id <> NVL(l_rr.room_id, -1) THEN
      DELETE FROM hsp_room_block WHERE reservation_room_id = l_rr.id;
      block_nights(p_room_id, l_bd, l_r.departure_date, 'RESERVATION', l_rr.id, NULL);
      UPDATE hsp_reservation_room SET room_id = p_room_id, room_type_id = (SELECT room_type_id FROM hsp_room WHERE id = p_room_id)
       WHERE id = l_rr.id;
      l_rr.room_id := p_room_id;
    END IF;
    NOONA_CORE_PKG.assert(l_rr.room_id IS NOT NULL, 'NOONA-HSP-026', 'أسند غرفة للحجز أولاً', 'Assign a room first');
    SELECT * INTO l_room FROM hsp_room WHERE id = l_rr.room_id FOR UPDATE;
    NOONA_CORE_PKG.assert(l_room.status_code = 'ACTIVE', 'NOONA-HSP-027', 'الغرفة ' || l_room.room_no || ' خارج الخدمة', 'Room out of order');
    SELECT COUNT(*) INTO l_n FROM hsp_stay WHERE room_id = l_room.id AND status_code = 'IN_HOUSE';
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HSP-028', 'الغرفة ' || l_room.room_no || ' مشغولة بنزيل آخر', 'Room is occupied');
    NOONA_CORE_PKG.assert(l_room.housekeeping_status IN ('CLEAN', 'INSPECTED') OR p_force = 'Y', 'NOONA-HSP-029',
      'الغرفة ' || l_room.room_no || ' ' || hk_label(l_room.housekeeping_status) || '؛ نظفها أولاً أو اختر غرفة أخرى', 'Room is not clean');
    INSERT INTO hsp_stay (company_id, reservation_id, reservation_room_id, room_id, check_in_at, expected_check_out, checked_in_by_member_id,
                          nightly_rate, status_code)
    VALUES (company, p_reservation_id, l_rr.id, l_room.id, SYSTIMESTAMP, l_r.departure_date, l_me, l_rr.nightly_rate, 'IN_HOUSE')
    RETURNING id INTO l_st;
    -- عند الدخول قبل تاريخ الوصول المحجوز (لا يحدث) أو بعده: الليالي من تاريخ العمل
    UPDATE hsp_room_block SET block_type = 'STAY', stay_id = l_st WHERE reservation_room_id = l_rr.id;
    INSERT INTO hsp_stay_guest (company_id, stay_id, guest_party_id, is_primary) VALUES (company, l_st, l_r.guest_party_id, 'Y');
    UPDATE hsp_reservation_room SET status_code = 'CHECKED_IN' WHERE id = l_rr.id;
    UPDATE hsp_reservation SET status_code = 'CHECKED_IN', arrival_date = LEAST(arrival_date, l_bd) WHERE id = p_reservation_id;
    UPDATE hsp_folio SET stay_id = l_st WHERE reservation_id = p_reservation_id AND stay_id IS NULL AND status_code = 'OPEN';
    set_room_fd(l_room.id, 'OCCUPIED');
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'HSP_STAY', l_st, 'CHECK_IN', 'SUCCESS');
    RETURN l_st;
  END check_in;

  FUNCTION walk_in(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_prop NUMBER := jnum(l_o, 'property');
    l_res  NUMBER;
    l_st   NUMBER;
    l_pay  NUMBER := NVL(jnum(l_o, 'pay'), 0);
    l_line NUMBER;
    l_bd   DATE;
  BEGIN
    l_bd := business_date(l_prop);
    l_o.put('arrival', TO_CHAR(l_bd, 'YYYY-MM-DD'));
    IF NOT l_o.has('departure') OR l_o.get('departure').is_null THEN
      l_o.put('departure', TO_CHAR(l_bd + NVL(jnum(l_o, 'nights'), 1), 'YYYY-MM-DD'));
    END IF;
    IF NOT l_o.has('channel') THEN l_o.put('channel', 'WALK_IN'); END IF;
    l_o.put('deposit', 0);
    l_res := create_reservation(l_o.to_clob);
    l_st := check_in(l_res, NULL, NVL(js(l_o, 'force'), 'N'));
    IF l_pay <> 0 THEN
      l_line := post_payment(folio_of_stay(l_st), l_pay, NVL(js(l_o, 'pay_method'), 'CASH'), jnum(l_o, 'bank_account'),
                             jnum(l_o, 'cash_box'), js(l_o, 'pay_ref'));
    END IF;
    RETURN l_st;
  END walk_in;

  PROCEDURE change_departure(p_stay_id IN NUMBER, p_departure IN DATE) IS
    l_s  hsp_stay%ROWTYPE := stay_row(p_stay_id);
    l_bd DATE;
  BEGIN
    guard('HSP_STAY.UPDATE');
    NOONA_CORE_PKG.assert(l_s.status_code = 'IN_HOUSE', 'NOONA-HSP-030', 'النزيل ليس مقيماً', 'Guest is not in house');
    l_bd := business_date(property_of_room(l_s.room_id));
    NOONA_CORE_PKG.assert(p_departure > l_bd, 'NOONA-HSP-031', 'تاريخ المغادرة الجديد بعد تاريخ العمل (' || fd(l_bd) || ')',
      'New departure must be after business date');
    IF p_departure > l_s.expected_check_out THEN
      block_nights(l_s.room_id, l_s.expected_check_out, p_departure, 'STAY', l_s.reservation_room_id, p_stay_id);
    ELSE
      DELETE FROM hsp_room_block WHERE stay_id = p_stay_id AND stay_date >= p_departure;
    END IF;
    UPDATE hsp_stay SET expected_check_out = p_departure WHERE id = p_stay_id;
    UPDATE hsp_reservation_room SET departure_date = p_departure WHERE id = l_s.reservation_room_id;
    UPDATE hsp_reservation SET departure_date = p_departure,
           total_estimate = l_s.nightly_rate * (p_departure - arrival_date) WHERE id = l_s.reservation_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'HSP_STAY', p_stay_id, 'CHANGE_DEPARTURE', 'SUCCESS',
      p_new_values => '{"departure":"' || fd(p_departure) || '"}');
  END change_departure;

  FUNCTION move_room(p_stay_id IN NUMBER, p_room_id IN NUMBER, p_reason IN VARCHAR2) RETURN NUMBER IS
    l_s   hsp_stay%ROWTYPE := stay_row(p_stay_id);
    l_bd  DATE;
    l_new NUMBER;
    l_rm  hsp_room%ROWTYPE;
    l_me  NUMBER := me;
  BEGIN
    guard('HSP_STAY.UPDATE');
    NOONA_CORE_PKG.assert(l_s.status_code = 'IN_HOUSE', 'NOONA-HSP-030', 'النزيل ليس مقيماً', 'Guest is not in house');
    NOONA_CORE_PKG.assert(p_room_id <> l_s.room_id, 'NOONA-HSP-032', 'اختر غرفة مختلفة', 'Choose another room');
    SELECT * INTO l_rm FROM hsp_room WHERE id = p_room_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_rm.status_code = 'ACTIVE' AND l_rm.property_id = property_of_room(l_s.room_id), 'NOONA-HSP-033',
      'الغرفة الجديدة غير صالحة أو خارج الخدمة', 'Invalid target room');
    l_bd := business_date(l_rm.property_id);
    DELETE FROM hsp_room_block WHERE stay_id = p_stay_id AND stay_date >= l_bd;
    INSERT INTO hsp_stay (company_id, reservation_id, reservation_room_id, room_id, check_in_at, expected_check_out, checked_in_by_member_id,
                          previous_stay_id, nightly_rate, last_charged_date, status_code)
    VALUES (company, l_s.reservation_id, l_s.reservation_room_id, p_room_id, l_s.check_in_at, l_s.expected_check_out, l_me, p_stay_id,
            l_s.nightly_rate, l_s.last_charged_date, 'IN_HOUSE')
    RETURNING id INTO l_new;
    block_nights(p_room_id, l_bd, l_s.expected_check_out, 'STAY', l_s.reservation_room_id, l_new);
    INSERT INTO hsp_stay_guest (company_id, stay_id, guest_party_id, identification_id, is_primary)
    SELECT company, l_new, guest_party_id, identification_id, is_primary FROM hsp_stay_guest WHERE stay_id = p_stay_id;
    UPDATE hsp_stay SET status_code = 'ROOM_MOVED', check_out_at = SYSTIMESTAMP WHERE id = p_stay_id;
    UPDATE hsp_folio SET stay_id = l_new WHERE stay_id = p_stay_id;
    UPDATE hsp_reservation_room SET room_id = p_room_id, room_type_id = l_rm.room_type_id WHERE id = l_s.reservation_room_id;
    set_room_fd(l_s.room_id, 'VACANT', 'DIRTY');
    hk_task(l_s.room_id, 'DEPARTURE_CLEAN', l_bd);
    set_room_fd(p_room_id, 'OCCUPIED');
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'HSP_STAY', l_new, 'ROOM_MOVE', 'SUCCESS',
      p_new_values => '{"from_stay":' || p_stay_id || ',"reason":' || jt(p_reason) || '}');
    RETURN l_new;
  END move_room;

  -- ================================================================ حساب النزيل
  FUNCTION folio_of_stay(p_stay_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) INTO l FROM hsp_folio WHERE stay_id = p_stay_id AND company_id = company;
    RETURN l;
  END folio_of_stay;

  FUNCTION folio_of_reservation(p_reservation_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) INTO l FROM hsp_folio WHERE reservation_id = p_reservation_id AND company_id = company AND status_code <> 'VOID';
    RETURN l;
  END folio_of_reservation;

  FUNCTION folio_balance(p_folio_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(amount), 0) INTO l FROM hsp_folio_line WHERE folio_id = p_folio_id;
    RETURN ROUND(l, 2);
  END folio_balance;

  PROCEDURE add_line(p_lines IN OUT NOCOPY NOONA_GL_PKG.t_lines, p_acc NUMBER, p_dr NUMBER, p_cr NUMBER, p_desc VARCHAR2,
                     p_party NUMBER DEFAULT NULL, p_cc NUMBER DEFAULT NULL) IS
    l_amt NUMBER := ROUND(NVL(p_dr, 0) - NVL(p_cr, 0), 2);
  BEGIN
    IF l_amt = 0 THEN RETURN; END IF;
    p_lines.EXTEND;
    p_lines(p_lines.COUNT).account_id := p_acc;
    p_lines(p_lines.COUNT).debit := CASE WHEN l_amt > 0 THEN l_amt END;
    p_lines(p_lines.COUNT).credit := CASE WHEN l_amt < 0 THEN -l_amt END;
    p_lines(p_lines.COUNT).description := SUBSTR(p_desc, 1, 1000);
    p_lines(p_lines.COUNT).party_id := p_party;
    p_lines(p_lines.COUNT).cost_center_id := p_cc;
  END add_line;

  FUNCTION ctx(p_folio_id NUMBER) RETURN t_ctx IS
    l t_ctx;
  BEGIN
    SELECT * INTO l.folio FROM hsp_folio WHERE id = p_folio_id AND company_id = company FOR UPDATE;
    BEGIN
      SELECT r.property_id, r.room_no INTO l.property, l.room_no FROM hsp_stay s JOIN hsp_room r ON r.id = s.room_id WHERE s.id = l.folio.stay_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      SELECT property_id INTO l.property FROM hsp_reservation WHERE id = l.folio.reservation_id;
    END;
    SELECT branch_id INTO l.branch FROM re_property WHERE id = l.property;
    l.bd := business_date(l.property);
    RETURN l;
  END ctx;

  -- يرحل سطر رسوم (مع ضريبته) ويعيد رقم السطر
  FUNCTION charge_line(p_c t_ctx, p_type VARCHAR2, p_desc VARCHAR2, p_net NUMBER, p_tax NUMBER, p_date DATE, p_rev_acc NUMBER) RETURN NUMBER IS
    l_line  NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
  BEGIN
    INSERT INTO hsp_folio_line (company_id, folio_id, business_date, line_type, description, amount)
    VALUES (company, p_c.folio.id, p_date, p_type, SUBSTR(p_desc, 1, 500), p_net)
    RETURNING id INTO l_line;
    IF p_tax <> 0 THEN
      INSERT INTO hsp_folio_line (company_id, folio_id, business_date, line_type, description, amount)
      VALUES (company, p_c.folio.id, p_date, 'TAX', 'ضريبة القيمة المضافة ' || c_vat || '% - ' || SUBSTR(p_desc, 1, 400), p_tax);
    END IF;
    add_line(l_lines, need_acc('1112'), p_net + p_tax, 0, 'حساب النزيل ' || p_c.folio.folio_no || ' - ' || p_desc, p_c.folio.payer_party_id);
    add_line(l_lines, p_rev_acc, 0, p_net, p_desc || CASE WHEN p_c.room_no IS NOT NULL THEN ' - غرفة ' || p_c.room_no END);
    add_line(l_lines, need_acc('2104'), 0, p_tax, 'ضريبة القيمة المضافة - ' || p_c.folio.folio_no);
    l_j := NOONA_ACE_PKG.post_source('HSP_FOLIO_CHARGE', 'HOSPITALITY', 'HSP_FOLIO_LINE', l_line, p_c.bd,
             p_desc || ' - ' || p_c.folio.folio_no, NOONA_GL_PKG.ledger_currency, 1, l_lines, p_c.folio.folio_no, p_c.branch, 'HOSPITALITY');
    UPDATE hsp_folio SET balance = balance + p_net + p_tax WHERE id = p_c.folio.id;
    RETURN l_line;
  END charge_line;

  FUNCTION post_charge(p_folio_id IN NUMBER, p_type IN VARCHAR2, p_description IN VARCHAR2, p_amount IN NUMBER,
                       p_with_tax IN VARCHAR2 DEFAULT 'Y') RETURN NUMBER IS
    l_c   t_ctx;
    l_net NUMBER := ROUND(p_amount, 2);
  BEGIN
    guard('HSP_FOLIO.UPDATE');
    l_c := ctx(p_folio_id);
    NOONA_CORE_PKG.assert(l_c.folio.status_code = 'OPEN', 'NOONA-HSP-040', 'حساب النزيل مقفل', 'Folio is closed');
    NOONA_CORE_PKG.assert(p_type IN ('LAUNDRY', 'MINIBAR', 'F_AND_B', 'SERVICE_CHARGE', 'OTHER_CHARGE', 'ADJUSTMENT', 'ROOM_CHARGE'),
      'NOONA-HSP-041', 'نوع الرسوم غير صحيح', 'Invalid charge type');
    NOONA_CORE_PKG.assert(l_net <> 0 AND (l_net > 0 OR p_type = 'ADJUSTMENT'), 'NOONA-HSP-042', 'المبلغ موجب (السالب للتسوية/الخصم فقط)',
      'Amount must be positive');
    NOONA_CORE_PKG.assert(TRIM(p_description) IS NOT NULL, 'NOONA-HSP-043', 'البيان مطلوب', 'Description required');
    RETURN charge_line(l_c, p_type, p_description, l_net, CASE WHEN NVL(p_with_tax, 'Y') = 'Y' THEN ROUND(l_net * c_vat / 100, 2) ELSE 0 END,
                       l_c.bd, CASE WHEN p_type IN ('ROOM_CHARGE', 'ADJUSTMENT') THEN need_acc('4110') ELSE need_acc('4111') END);
  END post_charge;

  FUNCTION post_payment(p_folio_id IN NUMBER, p_amount IN NUMBER, p_method IN VARCHAR2, p_bank_account_id IN NUMBER DEFAULT NULL,
                        p_cash_box_id IN NUMBER DEFAULT NULL, p_reference IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_c     t_ctx;
    l_amt   NUMBER := ROUND(p_amount, 2);
    l_acc   NUMBER;
    l_line  NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
    l_lbl   VARCHAR2(100);
  BEGIN
    guard('HSP_FOLIO.UPDATE');
    l_c := ctx(p_folio_id);
    NOONA_CORE_PKG.assert(l_c.folio.status_code = 'OPEN', 'NOONA-HSP-040', 'حساب النزيل مقفل', 'Folio is closed');
    NOONA_CORE_PKG.assert(l_amt <> 0, 'NOONA-HSP-044', 'أدخل مبلغ الدفعة', 'Amount required');
    NOONA_CORE_PKG.assert(p_method IN ('CASH', 'CARD', 'BANK_TRANSFER'), 'NOONA-HSP-045', 'طريقة السداد غير صحيحة', 'Invalid payment method');
    IF p_method = 'CASH' THEN
      SELECT MAX(gl_account_id) INTO l_acc FROM csh_cash_box WHERE company_id = company AND status_code = 'ACTIVE'
         AND id = NVL(p_cash_box_id, (SELECT MIN(c.id) FROM csh_cash_box c WHERE c.company_id = company AND c.status_code = 'ACTIVE'));
      NOONA_CORE_PKG.assert(l_acc IS NOT NULL, 'NOONA-HSP-046', 'لا يوجد صندوق نقدية نشط', 'No active cash box');
    ELSE
      SELECT MAX(gl_account_id) INTO l_acc FROM csh_bank_account WHERE company_id = company AND status_code = 'ACTIVE'
         AND id = NVL(p_bank_account_id, (SELECT MIN(b.id) FROM csh_bank_account b WHERE b.company_id = company AND b.status_code = 'ACTIVE'));
      NOONA_CORE_PKG.assert(l_acc IS NOT NULL, 'NOONA-HSP-047', 'لا يوجد حساب بنكي نشط', 'No active bank account');
    END IF;
    l_lbl := CASE WHEN l_amt < 0 THEN 'استرداد ' ELSE 'دفعة ' END || CASE p_method WHEN 'CASH' THEN 'نقداً' WHEN 'CARD' THEN 'بالشبكة'
             ELSE 'بتحويل بنكي' END;
    INSERT INTO hsp_folio_line (company_id, folio_id, business_date, line_type, description, amount, payment_method, reference_no)
    VALUES (company, p_folio_id, l_c.bd, 'PAYMENT', l_lbl || CASE WHEN p_reference IS NOT NULL THEN ' - ' || SUBSTR(p_reference, 1, 100) END,
            -l_amt, p_method, SUBSTR(p_reference, 1, 100))
    RETURNING id INTO l_line;
    add_line(l_lines, l_acc, l_amt, 0, l_lbl || ' - ' || l_c.folio.folio_no);
    add_line(l_lines, need_acc('1112'), 0, l_amt, l_lbl || ' - ' || l_c.folio.folio_no, l_c.folio.payer_party_id);
    l_j := NOONA_ACE_PKG.post_source('HSP_FOLIO_PAYMENT', 'HOSPITALITY', 'HSP_FOLIO_LINE', l_line, l_c.bd,
             l_lbl || ' على حساب النزيل ' || l_c.folio.folio_no, NOONA_GL_PKG.ledger_currency, 1, l_lines,
             NVL(p_reference, l_c.folio.folio_no), l_c.branch, 'HOSPITALITY');
    UPDATE hsp_folio SET balance = balance - l_amt WHERE id = p_folio_id;
    RETURN l_line;
  END post_payment;

  -- رسوم الليالي غير المرحلة حتى الليلة p_to (شاملة) بسطر واحد عند المغادرة
  PROCEDURE charge_nights(p_s IN OUT NOCOPY hsp_stay%ROWTYPE, p_to DATE) IS
    l_c     t_ctx;
    l_from  DATE := NVL(p_s.last_charged_date + 1, TRUNC(p_s.check_in_at));
    l_n     NUMBER;
    l_net   NUMBER;
    l_tax   NUMBER;
    l_incl  VARCHAR2(1);
    l_line  NUMBER;
  BEGIN
    IF p_to < l_from THEN RETURN; END IF;
    l_n := p_to - l_from + 1;
    SELECT NVL(MAX(p.includes_tax), 'N') INTO l_incl FROM hsp_reservation r LEFT JOIN hsp_rate_plan p ON p.id = r.rate_plan_id
     WHERE r.id = p_s.reservation_id;
    l_net := p_s.nightly_rate * l_n;
    IF l_incl = 'Y' THEN
      l_net := ROUND(l_net * 100 / (100 + c_vat), 2);
      l_tax := ROUND(p_s.nightly_rate * l_n, 2) - l_net;
    ELSE
      l_net := ROUND(l_net, 2);
      l_tax := ROUND(l_net * c_vat / 100, 2);
    END IF;
    l_c := ctx(folio_of_stay(p_s.id));
    l_line := charge_line(l_c, 'ROOM_CHARGE', 'إقامة ' || l_n || ' ليلة (' || fd(l_from) || ' - ' || fd(p_to) || ') × ' || fnum(p_s.nightly_rate),
                          l_net, l_tax, l_c.bd, need_acc('4110'));
    UPDATE hsp_stay SET last_charged_date = p_to WHERE id = p_s.id;
    p_s.last_charged_date := p_to;
  END charge_nights;

  FUNCTION check_out(p_stay_id IN NUMBER, p_city_ledger_party IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_s     hsp_stay%ROWTYPE := stay_row(p_stay_id);
    l_fol   NUMBER;
    l_c     t_ctx;
    l_bal   NUMBER;
    l_bd    DATE;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
  BEGIN
    guard('HSP_STAY.UPDATE');
    NOONA_CORE_PKG.assert(l_s.status_code = 'IN_HOUSE', 'NOONA-HSP-030', 'النزيل ليس مقيماً', 'Guest is not in house');
    l_bd := business_date(property_of_room(l_s.room_id));
    -- الليالي حتى ليلة أمس بتاريخ العمل؛ الدخول والخروج في اليوم نفسه يحسب ليلة واحدة
    charge_nights(l_s, GREATEST(l_bd - 1, TRUNC(l_s.check_in_at)));
    l_fol := folio_of_stay(p_stay_id);
    l_bal := folio_balance(l_fol);
    IF l_bal <> 0 THEN
      NOONA_CORE_PKG.assert(p_city_ledger_party IS NOT NULL AND l_bal > 0, 'NOONA-HSP-050',
        CASE WHEN l_bal > 0 THEN 'رصيد مستحق على النزيل ' || fnum(l_bal) || '؛ حصّله أو حوّله لحساب الشركة'
             ELSE 'للنزيل رصيد دائن ' || fnum(-l_bal) || '؛ استرده قبل المغادرة' END, 'Folio balance must be settled');
      l_c := ctx(l_fol);
      INSERT INTO hsp_folio_line (company_id, folio_id, business_date, line_type, description, amount, payment_method)
      VALUES (company, l_fol, l_bd, 'TRANSFER', 'تحويل الرصيد لحساب ' || guest_name(p_city_ledger_party), -l_bal, 'CITY_LEDGER');
      add_line(l_lines, need_acc('1113'), l_bal, 0, 'حساب ' || guest_name(p_city_ledger_party) || ' - ' || l_c.folio.folio_no, p_city_ledger_party);
      add_line(l_lines, need_acc('1112'), 0, l_bal, 'تحويل حساب النزيل ' || l_c.folio.folio_no, l_c.folio.payer_party_id);
      l_j := NOONA_ACE_PKG.post_source('HSP_FOLIO_TRANSFER', 'HOSPITALITY', 'HSP_FOLIO', l_fol, l_bd,
               'تحويل حساب النزيل ' || l_c.folio.folio_no || ' إلى ' || guest_name(p_city_ledger_party), NOONA_GL_PKG.ledger_currency, 1,
               l_lines, l_c.folio.folio_no, l_c.branch, 'HOSPITALITY');
      UPDATE hsp_folio SET balance = 0, status_code = 'TRANSFERRED', payer_party_id = p_city_ledger_party WHERE id = l_fol;
    ELSE
      UPDATE hsp_folio SET balance = 0, status_code = 'SETTLED' WHERE id = l_fol;
    END IF;
    DELETE FROM hsp_room_block WHERE stay_id = p_stay_id AND stay_date >= l_bd;
    UPDATE hsp_stay SET status_code = 'CHECKED_OUT', check_out_at = SYSTIMESTAMP WHERE id = p_stay_id;
    UPDATE hsp_reservation_room SET status_code = 'CHECKED_OUT', departure_date = GREATEST(l_bd, arrival_date + 1) WHERE id = l_s.reservation_room_id;
    UPDATE hsp_reservation SET status_code = 'CHECKED_OUT' WHERE id = l_s.reservation_id
       AND NOT EXISTS (SELECT 1 FROM hsp_reservation_room x WHERE x.reservation_id = hsp_reservation.id AND x.status_code IN ('ASSIGNED', 'CHECKED_IN'));
    set_room_fd(l_s.room_id, 'VACANT', 'DIRTY');
    hk_task(l_s.room_id, 'DEPARTURE_CLEAN', l_bd);
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'HSP_STAY', p_stay_id, 'CHECK_OUT', 'SUCCESS');
    RETURN l_fol;
  END check_out;

  -- ================================================================ التدبير الفندقي
  PROCEDURE set_hk_status(p_room_id IN NUMBER, p_status IN VARCHAR2) IS
    l_bd DATE;
  BEGIN
    guard('HSP_HOUSEKEEPING_TASK.UPDATE');
    NOONA_CORE_PKG.assert(p_status IN ('CLEAN', 'DIRTY', 'INSPECTED', 'IN_PROGRESS'), 'NOONA-HSP-060', 'حالة غير صحيحة', 'Invalid status');
    UPDATE hsp_room SET housekeeping_status = p_status WHERE id = p_room_id AND company_id = company AND status_code = 'ACTIVE';
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-HSP-061', 'الغرفة غير موجودة أو خارج الخدمة', 'Room not found or out of order');
    l_bd := business_date(property_of_room(p_room_id));
    IF p_status IN ('CLEAN', 'INSPECTED') THEN
      UPDATE hsp_housekeeping_task SET status_code = CASE p_status WHEN 'INSPECTED' THEN 'INSPECTED' ELSE 'DONE' END,
             completed_at = NVL(completed_at, SYSTIMESTAMP),
             inspected_by = CASE WHEN p_status = 'INSPECTED' THEN NOONA_CTX_PKG.current_user_name END
       WHERE room_id = p_room_id AND status_code IN ('PENDING', 'ASSIGNED', 'IN_PROGRESS', 'DONE');
    ELSIF p_status = 'IN_PROGRESS' THEN
      UPDATE hsp_housekeeping_task SET status_code = 'IN_PROGRESS', started_at = SYSTIMESTAMP
       WHERE room_id = p_room_id AND status_code IN ('PENDING', 'ASSIGNED');
    ELSE
      hk_task(p_room_id, 'DEPARTURE_CLEAN', l_bd);
    END IF;
  END set_hk_status;

  PROCEDURE assign_hk(p_task_id IN NUMBER, p_employee_id IN NUMBER) IS
  BEGIN
    guard('HSP_HOUSEKEEPING_TASK.UPDATE');
    UPDATE hsp_housekeeping_task SET assigned_employee_id = p_employee_id, status_code = 'ASSIGNED'
     WHERE id = p_task_id AND company_id = company AND status_code IN ('PENDING', 'ASSIGNED');
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-HSP-062', 'المهمة غير موجودة أو منفذة', 'Task not found or done');
  END assign_hk;

  PROCEDURE complete_hk(p_task_id IN NUMBER, p_inspected IN VARCHAR2 DEFAULT 'N') IS
    l_room NUMBER;
  BEGIN
    SELECT room_id INTO l_room FROM hsp_housekeeping_task WHERE id = p_task_id AND company_id = company;
    set_hk_status(l_room, CASE WHEN p_inspected = 'Y' THEN 'INSPECTED' ELSE 'CLEAN' END);
  END complete_hk;

  PROCEDURE set_out_of_order(p_room_id IN NUMBER, p_from IN DATE, p_to IN DATE, p_reason IN VARCHAR2, p_work_order_id IN NUMBER DEFAULT NULL) IS
    l_n  NUMBER;
    l_to DATE;
    l_fr DATE;
  BEGIN
    guard('HSP_ROOM.UPDATE');
    l_fr := GREATEST(NVL(p_from, business_date(property_of_room(p_room_id))), business_date(property_of_room(p_room_id)));
    l_to := NVL(p_to, l_fr + 1);
    SELECT COUNT(*) INTO l_n FROM hsp_stay WHERE room_id = p_room_id AND status_code = 'IN_HOUSE';
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HSP-063', 'الغرفة مشغولة؛ انقل النزيل أولاً', 'Room is occupied; move the guest first');
    NOONA_CORE_PKG.assert(l_to > l_fr, 'NOONA-HSP-064', 'فترة الإيقاف غير صحيحة', 'Invalid period');
    block_nights(p_room_id, l_fr, l_to, CASE WHEN p_work_order_id IS NOT NULL THEN 'MAINTENANCE' ELSE 'OUT_OF_ORDER' END, NULL, NULL);
    UPDATE hsp_room_block SET maintenance_wo_id = p_work_order_id
     WHERE room_id = p_room_id AND stay_date >= l_fr AND stay_date < l_to AND stay_id IS NULL AND reservation_room_id IS NULL;
    UPDATE hsp_room SET status_code = 'OUT_OF_ORDER', housekeeping_status = 'OUT_OF_ORDER',
           notes = SUBSTR('خارج الخدمة: ' || p_reason, 1, 500)
     WHERE id = p_room_id AND company_id = company;
  END set_out_of_order;

  PROCEDURE return_to_service(p_room_id IN NUMBER) IS
  BEGIN
    guard('HSP_ROOM.UPDATE');
    DELETE FROM hsp_room_block WHERE room_id = p_room_id AND block_type IN ('OUT_OF_ORDER', 'MAINTENANCE');
    UPDATE hsp_room SET status_code = 'ACTIVE', housekeeping_status = 'DIRTY', front_desk_status = 'VACANT', notes = NULL
     WHERE id = p_room_id AND company_id = company AND status_code IN ('OUT_OF_ORDER', 'OUT_OF_SERVICE');
    IF SQL%ROWCOUNT = 1 THEN
      hk_task(p_room_id, 'DEEP_CLEAN', business_date(property_of_room(p_room_id)));
    END IF;
  END return_to_service;

  -- ================================================================ التدقيق الليلي
  FUNCTION night_audit(p_property_id IN NUMBER, p_no_shows IN VARCHAR2 DEFAULT 'Y') RETURN NUMBER IS
    l_bd    DATE := business_date(p_property_id);
    l_id    NUMBER;
    l_ns    NUMBER := 0;
    l_rev   NUMBER := 0;
    l_tax   NUMBER := 0;
    l_occ   NUMBER := 0;
    l_rooms NUMBER;
    l_net   NUMBER;
    l_t     NUMBER;
    l_incl  VARCHAR2(1);
    l_fol   hsp_folio%ROWTYPE;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
    l_ev    NUMBER;
    l_br    NUMBER;
    l_n     NUMBER;
    l_night DATE;
    l_desc  VARCHAR2(500);
  BEGIN
    guard('HSP_NIGHT_AUDIT.CREATE');
    NOONA_CORE_PKG.assert(l_bd <= TRUNC(SYSDATE), 'NOONA-HSP-070', 'يوم العمل ' || fd(l_bd) || ' لم ينته بعد', 'Business day not ended');
    SELECT COUNT(*) INTO l_n FROM hsp_night_audit WHERE property_id = p_property_id AND business_date = l_bd AND status_code = 'COMPLETED';
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HSP-071', 'تم تدقيق يوم ' || fd(l_bd) || ' سابقاً', 'Day already audited');
    SELECT branch_id INTO l_br FROM re_property WHERE id = p_property_id;
    DELETE FROM hsp_night_audit WHERE property_id = p_property_id AND business_date = l_bd;
    INSERT INTO hsp_night_audit (company_id, property_id, business_date, status_code)
    VALUES (company, p_property_id, l_bd, 'RUNNING')
    RETURNING id INTO l_id;
    -- عدم الحضور
    IF p_no_shows = 'Y' THEN
      FOR r IN (SELECT id FROM hsp_reservation WHERE property_id = p_property_id AND arrival_date <= l_bd
                   AND status_code IN ('TENTATIVE', 'CONFIRMED', 'GUARANTEED')) LOOP
        mark_no_show(r.id);
        l_ns := l_ns + 1;
      END LOOP;
    END IF;
    -- ترحيل ليلة اليوم لكل مقيم
    FOR s IN (SELECT s.id, s.nightly_rate, s.last_charged_date, s.check_in_at, s.reservation_id, r.room_no, s.room_id
                FROM hsp_stay s JOIN hsp_room r ON r.id = s.room_id
               WHERE r.property_id = p_property_id AND s.status_code = 'IN_HOUSE'
                 AND NVL(s.last_charged_date, TRUNC(s.check_in_at) - 1) < l_bd AND TRUNC(s.check_in_at) <= l_bd
               ORDER BY r.room_no FOR UPDATE OF s.last_charged_date) LOOP
      SELECT NVL(MAX(p.includes_tax), 'N') INTO l_incl FROM hsp_reservation x LEFT JOIN hsp_rate_plan p ON p.id = x.rate_plan_id
       WHERE x.id = s.reservation_id;
      SELECT * INTO l_fol FROM hsp_folio WHERE stay_id = s.id AND status_code = 'OPEN' AND ROWNUM = 1;
      FOR d IN 0 .. l_bd - NVL(s.last_charged_date + 1, TRUNC(s.check_in_at)) LOOP
        IF l_incl = 'Y' THEN
          l_net := ROUND(s.nightly_rate * 100 / (100 + c_vat), 2);
          l_t := ROUND(s.nightly_rate, 2) - l_net;
        ELSE
          l_net := ROUND(s.nightly_rate, 2);
          l_t := ROUND(l_net * c_vat / 100, 2);
        END IF;
        l_night := NVL(s.last_charged_date + 1, TRUNC(s.check_in_at)) + d;
        l_desc := 'رسوم الغرفة ' || s.room_no || ' ليلة ' || fd(l_night);
        INSERT INTO hsp_folio_line (company_id, folio_id, business_date, line_type, description, amount, night_audit_id)
        VALUES (company, l_fol.id, l_night, 'ROOM_CHARGE', l_desc, l_net, l_id);
        l_desc := 'ضريبة القيمة المضافة ' || c_vat || '% - غرفة ' || s.room_no;
        INSERT INTO hsp_folio_line (company_id, folio_id, business_date, line_type, description, amount, night_audit_id)
        VALUES (company, l_fol.id, l_night, 'TAX', l_desc, l_t, l_id);
        add_line(l_lines, need_acc('1112'), l_net + l_t, 0, 'حساب النزيل ' || l_fol.folio_no || ' - غرفة ' || s.room_no, l_fol.payer_party_id);
        UPDATE hsp_folio SET balance = balance + l_net + l_t WHERE id = l_fol.id;
        l_rev := l_rev + l_net;
        l_tax := l_tax + l_t;
      END LOOP;
      UPDATE hsp_stay SET last_charged_date = l_bd WHERE id = s.id;
      l_occ := l_occ + 1;
      -- الغرفة المشغولة تحتاج تنظيفاً يومياً
      UPDATE hsp_room SET housekeeping_status = 'DIRTY' WHERE id = s.room_id;
      hk_task(s.room_id, 'STAYOVER', l_bd + 1);
    END LOOP;
    IF l_rev > 0 THEN
      add_line(l_lines, need_acc('4110'), 0, l_rev, 'إيرادات الإيواء ليوم ' || fd(l_bd));
      add_line(l_lines, need_acc('2104'), 0, l_tax, 'ضريبة القيمة المضافة على الإيواء ليوم ' || fd(l_bd));
      l_j := NOONA_ACE_PKG.post_source('HSP_ROOM_CHARGE', 'HOSPITALITY', 'HSP_NIGHT_AUDIT', l_id, l_bd,
               'التدقيق الليلي - رسوم الغرف ليوم ' || fd(l_bd), NOONA_GL_PKG.ledger_currency, 1, l_lines, 'NA-' || fd(l_bd), l_br, 'HOSPITALITY');
      SELECT MAX(id) INTO l_ev FROM ace_accounting_event WHERE source_entity_type = 'HSP_NIGHT_AUDIT' AND source_entity_id = l_id
         AND status_code = 'POSTED';
    END IF;
    SELECT COUNT(*) INTO l_rooms FROM hsp_room WHERE property_id = p_property_id AND status_code = 'ACTIVE';
    UPDATE hsp_night_audit SET room_revenue = l_rev, occupancy_pct = CASE WHEN l_rooms > 0 THEN ROUND(l_occ * 100 / l_rooms, 2) ELSE 0 END,
           adr = CASE WHEN l_occ > 0 THEN ROUND(l_rev / l_occ, 2) END, no_shows = l_ns, accounting_event_id = l_ev, status_code = 'COMPLETED'
     WHERE id = l_id;
    UPDATE re_property SET business_date = l_bd + 1 WHERE id = p_property_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'HSP_NIGHT_AUDIT', l_id, 'COMPLETE', 'SUCCESS');
    RETURN l_id;
  END night_audit;

  -- ================================================================ الواجهة
  FUNCTION rack_json(p_property_id IN NUMBER) RETURN CLOB IS
    l_bd  DATE := business_date(p_property_id);
    l_out CLOB;
    l_sep VARCHAR2(1);
    l_fd  VARCHAR2(20);
  BEGIN
    l_out := '{"business_date":' || jd(l_bd) || ',"property":' || jt(NOONA_RE_PKG.property_name(p_property_id)) || ',"rooms":[';
    FOR r IN (
      SELECT r.id, r.room_no, r.status_code, r.housekeeping_status hk, r.notes, t.name_ar rtype, t.id rtype_id, f.name_ar floor_name,
             NVL(f.floor_no, 0) floor_no,
             s.id stay_id, s.expected_check_out, s.check_in_at, rs.guest_party_id sg, rs.adults,
             ar.id arr_res, ar.guest_party_id ag, ar.departure_date arr_dep,
             (SELECT COUNT(*) FROM mnt_request m WHERE m.room_id = r.id AND m.status_code NOT IN ('CLOSED', 'CANCELLED', 'REJECTED', 'VERIFIED', 'COMPLETED')) mnt,
             (SELECT NVL(SUM(l.amount), 0) FROM hsp_folio fo JOIN hsp_folio_line l ON l.folio_id = fo.id WHERE fo.stay_id = s.id) bal
        FROM hsp_room r JOIN hsp_room_type t ON t.id = r.room_type_id LEFT JOIN re_floor f ON f.id = r.floor_id
        LEFT JOIN hsp_stay s ON s.room_id = r.id AND s.status_code = 'IN_HOUSE'
        LEFT JOIN hsp_reservation rs ON rs.id = s.reservation_id
        LEFT JOIN (SELECT rr.room_id, x.id, x.guest_party_id, x.departure_date
                     FROM hsp_reservation_room rr JOIN hsp_reservation x ON x.id = rr.reservation_id
                    WHERE x.arrival_date <= l_bd AND x.status_code IN ('TENTATIVE', 'CONFIRMED', 'GUARANTEED') AND rr.status_code = 'ASSIGNED') ar
          ON ar.room_id = r.id AND s.id IS NULL
       WHERE r.property_id = p_property_id AND r.company_id = company AND r.status_code <> 'INACTIVE'
       ORDER BY NVL(f.floor_no, 0), r.room_no) LOOP
      l_fd := CASE WHEN r.status_code IN ('OUT_OF_ORDER', 'OUT_OF_SERVICE') THEN 'OOO'
                   WHEN r.stay_id IS NOT NULL AND r.expected_check_out <= l_bd THEN 'DUE_OUT'
                   WHEN r.stay_id IS NOT NULL THEN 'OCCUPIED'
                   WHEN r.arr_res IS NOT NULL THEN 'DUE_IN'
                   ELSE 'VACANT' END;
      l_out := l_out || l_sep || '{"id":' || r.id || ',"no":' || jt(r.room_no) || ',"floor":' || jt(r.floor_name) || ',"floor_no":' || r.floor_no
            || ',"type":' || jt(r.rtype) || ',"type_id":' || r.rtype_id || ',"fd":"' || l_fd || '","hk":"' || r.hk || '","notes":' || jt(r.notes)
            || ',"stay":' || jn(r.stay_id) || ',"res":' || jn(r.arr_res)
            || ',"guest":' || jt(guest_name(NVL(r.sg, r.ag))) || ',"dep":' || jd(NVL(r.expected_check_out, r.arr_dep))
            || ',"since":' || jd(TRUNC(CAST(r.check_in_at AS DATE))) || ',"bal":' || jn(r.bal) || ',"mnt":' || r.mnt || '}';
      l_sep := ',';
    END LOOP;
    RETURN l_out || ']}';
  END rack_json;

  FUNCTION chart_json(p_property_id IN NUMBER, p_from IN DATE, p_days IN NUMBER DEFAULT 14) RETURN CLOB IS
    l_from DATE := NVL(p_from, business_date(p_property_id));
    l_out  CLOB := '{"from":' || jd(NVL(p_from, business_date(p_property_id))) || ',"days":' || NVL(p_days, 14) || ',"rooms":[';
    l_sep  VARCHAR2(1);
  BEGIN
    FOR r IN (SELECT r.id, r.room_no, t.name_ar rtype FROM hsp_room r JOIN hsp_room_type t ON t.id = r.room_type_id
                LEFT JOIN re_floor f ON f.id = r.floor_id
               WHERE r.property_id = p_property_id AND r.company_id = company AND r.status_code <> 'INACTIVE'
               ORDER BY NVL(f.floor_no, 0), r.room_no) LOOP
      l_out := l_out || l_sep || '{"id":' || r.id || ',"no":' || jt(r.room_no) || ',"type":' || jt(r.rtype) || '}';
      l_sep := ',';
    END LOOP;
    l_out := l_out || '],"blocks":[';
    l_sep := NULL;
    FOR b IN (SELECT b.room_id, b.stay_date - l_from d, b.block_type, NVL(rr.reservation_id, s.reservation_id) res, b.stay_id,
                     NVL(x.guest_party_id, xs.guest_party_id) gp, NVL(x.doc_no, xs.doc_no) doc_no
                FROM hsp_room_block b JOIN hsp_room r ON r.id = b.room_id
                LEFT JOIN hsp_reservation_room rr ON rr.id = b.reservation_room_id LEFT JOIN hsp_reservation x ON x.id = rr.reservation_id
                LEFT JOIN hsp_stay s ON s.id = b.stay_id LEFT JOIN hsp_reservation xs ON xs.id = s.reservation_id
               WHERE r.property_id = p_property_id AND b.stay_date >= l_from AND b.stay_date < l_from + NVL(p_days, 14)
               ORDER BY b.room_id, b.stay_date) LOOP
      l_out := l_out || l_sep || '{"room":' || b.room_id || ',"d":' || b.d || ',"t":"' || b.block_type || '","res":' || jn(b.res)
            || ',"stay":' || jn(b.stay_id) || ',"g":' || jt(guest_name(b.gp)) || ',"no":' || jt(b.doc_no) || '}';
      l_sep := ',';
    END LOOP;
    RETURN l_out || ']}';
  END chart_json;

  FUNCTION stay_json(p_stay_id IN NUMBER) RETURN CLOB IS
    l_s   hsp_stay%ROWTYPE;
    l_r   hsp_reservation%ROWTYPE;
    l_fol NUMBER;
    l_out CLOB;
    l_sep VARCHAR2(1);
    l_no  VARCHAR2(20);
    l_fno VARCHAR2(50);
    l_pend NUMBER;
    l_n   NUMBER;
    l_incl VARCHAR2(1);
  BEGIN
    SELECT * INTO l_s FROM hsp_stay WHERE id = p_stay_id AND company_id = company;
    SELECT * INTO l_r FROM hsp_reservation WHERE id = l_s.reservation_id;
    -- رسوم الليالي غير المرحلة حتى المغادرة اليوم (تقديرية شاملة الضريبة)
    l_n := GREATEST(business_date(l_r.property_id) - 1, TRUNC(CAST(l_s.check_in_at AS DATE)))
           - NVL(l_s.last_charged_date, TRUNC(CAST(l_s.check_in_at AS DATE)) - 1);
    SELECT NVL(MAX(p.includes_tax), 'N') INTO l_incl FROM hsp_rate_plan p WHERE p.id = l_r.rate_plan_id;
    l_pend := CASE WHEN l_s.status_code = 'IN_HOUSE' AND l_n > 0 THEN
                ROUND(l_n * l_s.nightly_rate * CASE WHEN l_incl = 'Y' THEN 1 ELSE 1 + c_vat / 100 END, 2) END;
    SELECT room_no INTO l_no FROM hsp_room WHERE id = l_s.room_id;
    l_fol := folio_of_stay(p_stay_id);
    SELECT MAX(folio_no) INTO l_fno FROM hsp_folio WHERE id = l_fol;
    l_out := '{"id":' || l_s.id || ',"res":' || l_r.id || ',"res_no":' || jt(l_r.doc_no) || ',"room":' || jt(l_no) || ',"guest":'
          || jt(guest_name(l_r.guest_party_id)) || ',"phone":' || jt(guest_phone(l_r.guest_party_id)) || ',"since":'
          || jd(TRUNC(CAST(l_s.check_in_at AS DATE))) || ',"dep":' || jd(l_s.expected_check_out) || ',"rate":' || jn(l_s.nightly_rate)
          || ',"adults":' || l_r.adults || ',"channel":' || jt(channel_label(l_r.channel_code)) || ',"requests":' || jt(l_r.special_requests)
          || ',"status":"' || l_s.status_code || '","folio":' || jn(l_fol) || ',"folio_no":' || jt(l_fno) || ',"balance":'
          || jn(folio_balance(l_fol)) || ',"pending":' || jn(l_pend) || ',"lines":[';
    FOR l IN (SELECT business_date, line_type, description, amount FROM hsp_folio_line WHERE folio_id = l_fol ORDER BY business_date, id) LOOP
      l_out := l_out || l_sep || '{"d":' || jd(l.business_date) || ',"t":"' || l.line_type || '","x":' || jt(l.description) || ',"a":' || jn(l.amount) || '}';
      l_sep := ',';
    END LOOP;
    RETURN l_out || ']}';
  END stay_json;

  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_cls VARCHAR2 DEFAULT 'is-info') RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_cls || '"><span class="nn-kpi-icon fa ' || p_icon || '"></span><div><div class="nn-kpi-value">'
        || p_value || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION front_summary(p_property_id IN NUMBER) RETURN CLOB IS
    l_bd  DATE := business_date(p_property_id);
    l_tot NUMBER; l_occ NUMBER; l_arr NUMBER; l_dep NUMBER; l_dirty NUMBER; l_ooo NUMBER; l_rev NUMBER;
  BEGIN
    SELECT COUNT(*), COUNT(CASE WHEN housekeeping_status IN ('DIRTY', 'IN_PROGRESS') AND status_code = 'ACTIVE' THEN 1 END),
           COUNT(CASE WHEN status_code IN ('OUT_OF_ORDER', 'OUT_OF_SERVICE') THEN 1 END)
      INTO l_tot, l_dirty, l_ooo FROM hsp_room WHERE property_id = p_property_id AND status_code <> 'INACTIVE';
    SELECT COUNT(*), COUNT(CASE WHEN s.expected_check_out <= l_bd THEN 1 END) INTO l_occ, l_dep
      FROM hsp_stay s JOIN hsp_room r ON r.id = s.room_id WHERE r.property_id = p_property_id AND s.status_code = 'IN_HOUSE';
    SELECT COUNT(*) INTO l_arr FROM hsp_reservation WHERE property_id = p_property_id AND arrival_date <= l_bd
       AND status_code IN ('TENTATIVE', 'CONFIRMED', 'GUARANTEED');
    SELECT NVL(SUM(room_revenue), 0) INTO l_rev FROM hsp_night_audit WHERE property_id = p_property_id
       AND business_date >= TRUNC(l_bd, 'MM') AND status_code = 'COMPLETED';
    RETURN '<div class="nn-kpis">'
        || kpi('تاريخ العمل', fd(l_bd), 'fa-calendar')
        || kpi('الإشغال', l_occ || ' / ' || l_tot || CASE WHEN l_tot > 0 THEN ' (' || ROUND(l_occ * 100 / l_tot) || '%)' END, 'fa-bed', 'is-info')
        || kpi('وصول اليوم', l_arr, 'fa-sign-in', CASE WHEN l_arr > 0 THEN 'is-warning' ELSE 'is-info' END)
        || kpi('مغادرة اليوم', l_dep, 'fa-sign-out', CASE WHEN l_dep > 0 THEN 'is-warning' ELSE 'is-info' END)
        || kpi('شاغرة متاحة', available_count(p_property_id, NULL, l_bd, l_bd + 1), 'fa-check-circle', 'is-success')
        || kpi('تحت التنظيف', l_dirty, 'fa-paint-brush', CASE WHEN l_dirty > 0 THEN 'is-warning' ELSE 'is-info' END)
        || kpi('خارج الخدمة', l_ooo, 'fa-wrench', CASE WHEN l_ooo > 0 THEN 'is-danger' ELSE 'is-info' END)
        || kpi('إيراد الإيواء للشهر', fnum(l_rev), 'fa-money', 'is-success') || '</div>';
  END front_summary;

  FUNCTION folio_html(p_folio_id IN NUMBER) RETURN CLOB IS
    l_f   hsp_folio%ROWTYPE;
    l_r   hsp_reservation%ROWTYPE;
    l_p   re_property%ROWTYPE;
    l_room VARCHAR2(20);
    l_s   hsp_stay%ROWTYPE;
    l_out CLOB;
    l_chg NUMBER := 0;
    l_tax NUMBER := 0;
    l_pay NUMBER := 0;
    l_co  VARCHAR2(400);
    l_vat VARCHAR2(50);
  BEGIN
    SELECT * INTO l_f FROM hsp_folio WHERE id = p_folio_id AND company_id = company;
    SELECT * INTO l_r FROM hsp_reservation WHERE id = l_f.reservation_id;
    SELECT * INTO l_p FROM re_property WHERE id = l_r.property_id;
    BEGIN
      SELECT * INTO l_s FROM hsp_stay WHERE id = l_f.stay_id;
      SELECT room_no INTO l_room FROM hsp_room WHERE id = l_s.room_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
    SELECT MAX(NVL(trade_name_ar, legal_name_ar)) INTO l_co FROM org_company WHERE id = company;
    l_out := '<div class="nn-folio"><div class="nn-folio-h"><div><b>' || esc(l_p.name_ar) || '</b><small>' || esc(l_co)
          || CASE WHEN l_vat IS NOT NULL THEN ' · الرقم الضريبي ' || esc(l_vat) END || '</small></div><div class="nn-folio-t">فاتورة إقامة<br><small>'
          || esc(l_f.folio_no) || '</small></div></div><div class="nn-folio-id"><div><span>النزيل</span>' || esc(guest_name(l_r.guest_party_id))
          || '</div><div><span>الغرفة</span>' || esc(l_room) || '</div><div><span>الحجز</span>' || esc(l_r.doc_no) || '</div><div><span>الوصول</span>'
          || fd(NVL(TRUNC(CAST(l_s.check_in_at AS DATE)), l_r.arrival_date)) || '</div><div><span>المغادرة</span>'
          || fd(NVL(TRUNC(CAST(l_s.check_out_at AS DATE)), l_r.departure_date)) || '</div><div><span>الحالة</span>' || res_status_label(l_f.status_code)
          || '</div></div><table class="nn-rpt"><thead><tr><th>التاريخ</th><th>البيان</th><th>مدين</th><th>دائن</th></tr></thead><tbody>';
    FOR l IN (SELECT business_date, line_type, description, amount FROM hsp_folio_line WHERE folio_id = p_folio_id ORDER BY business_date, id) LOOP
      l_out := l_out || '<tr><td>' || fd(l.business_date) || '</td><td class="nn-rpt-text">' || esc(l.description) || '</td><td>'
            || CASE WHEN l.amount > 0 THEN fnum(l.amount) END || '</td><td>' || CASE WHEN l.amount < 0 THEN fnum(-l.amount) END || '</td></tr>';
      IF l.line_type = 'TAX' THEN l_tax := l_tax + l.amount;
      ELSIF l.line_type IN ('PAYMENT', 'TRANSFER') THEN l_pay := l_pay - l.amount;
      ELSE l_chg := l_chg + l.amount; END IF;
    END LOOP;
    RETURN l_out || '</tbody></table><table class="nn-rpt nn-folio-tot"><tbody><tr><td class="nn-rpt-text">الإجمالي قبل الضريبة</td><td>'
        || fnum(l_chg) || '</td></tr><tr><td class="nn-rpt-text">ضريبة القيمة المضافة ' || c_vat || '%</td><td>' || fnum(l_tax)
        || '</td></tr><tr class="nn-rpt-total"><td class="nn-rpt-text">الإجمالي شامل الضريبة</td><td>' || fnum(l_chg + l_tax)
        || '</td></tr><tr><td class="nn-rpt-text">المدفوع والمحول</td><td>' || fnum(l_pay) || '</td></tr><tr class="nn-rpt-total"><td class="nn-rpt-text">الرصيد</td><td>'
        || fnum(l_chg + l_tax - l_pay) || '</td></tr></tbody></table></div>';
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '<div class="nn-empty">حساب النزيل غير موجود</div>';
  END folio_html;

  FUNCTION occupancy_html(p_property_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_out CLOB := '<div class="nn-rpt-wrap"><table class="nn-rpt"><thead><tr><th>اليوم</th><th>الإشغال %</th><th>إيراد الغرف</th>'
               || '<th>متوسط سعر الغرفة (ADR)</th><th>الإيراد لكل غرفة متاحة (RevPAR)</th><th>عدم الحضور</th></tr></thead><tbody>';
    l_rev NUMBER := 0;
    l_occ NUMBER := 0;
    l_n   PLS_INTEGER := 0;
  BEGIN
    FOR a IN (SELECT business_date, occupancy_pct, room_revenue, adr, no_shows FROM hsp_night_audit
               WHERE property_id = p_property_id AND business_date BETWEEN p_from AND p_to AND status_code = 'COMPLETED' ORDER BY business_date) LOOP
      l_out := l_out || '<tr><td>' || fd(a.business_date) || '</td><td>' || fnum(a.occupancy_pct) || '</td><td>' || fnum(a.room_revenue)
            || '</td><td>' || fnum(a.adr) || '</td><td>' || fnum(CASE WHEN a.occupancy_pct > 0 THEN a.adr * a.occupancy_pct / 100 ELSE 0 END)
            || '</td><td>' || a.no_shows || '</td></tr>';
      l_rev := l_rev + NVL(a.room_revenue, 0);
      l_occ := l_occ + NVL(a.occupancy_pct, 0);
      l_n := l_n + 1;
    END LOOP;
    IF l_n = 0 THEN
      RETURN '<div class="nn-empty">لا توجد أيام مدققة في الفترة؛ يظهر التقرير بعد تشغيل التدقيق الليلي</div>';
    END IF;
    RETURN l_out || '<tr class="nn-rpt-total"><td>الإجمالي / المتوسط (' || l_n || ' يوم)</td><td>' || fnum(l_occ / l_n) || '</td><td>'
        || fnum(l_rev) || '</td><td></td><td></td><td></td></tr></tbody></table></div>';
  END occupancy_html;

END NOONA_HSP_PKG;
/
