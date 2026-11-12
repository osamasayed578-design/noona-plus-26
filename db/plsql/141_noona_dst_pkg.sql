-- =============================================================================
-- NOONA PLUS ERP | NOONA_DST_PKG - التوزيع والمبيعات الميدانية (التطبيق 149 NOONA_DST)
--   * المندوبون: مستودع السيارة (مخزون متنقل) وعهدة نقدية، أساس العمولة والهدف الشهري
--   * خطوط السير وأيام الزيارة، والمحلات بمواقعها على الخريطة (تحفظ من جوال المندوب)
--   * خطة اليوم، والزيارة بتسجيل الوصول والموقع والبعد عن المحل
--   * البيع من السيارة (فاتورة مبيعات من مستودع السيارة)، أوامر التوريد المسبقة، المرتجعات، أسباب عدم الشراء
--   * التحصيل بطريقة الدفع ورقم المرجع: نقد (عهدة المندوب)، شبكة/محفظة (مرحل)، تحويل بنكي برقم الإشعار
--     وشيك (بانتظار تأكيد المحاسب ثم يرحل للبنك)
--   * تسوية نهاية اليوم: النقد المتوقع والمسلم والعجز، وتوريد النقد لصندوق الشركة
--   * العمولات الشهرية (مبيعات، تحصيل، زيارات) والهدف، وروابط واتساب للمحل
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_DST_PKG AUTHID DEFINER AS
  FUNCTION company RETURN NUMBER;
  FUNCTION quick_setup RETURN NUMBER;
  FUNCTION is_ready RETURN VARCHAR2;

  -- ---------------------------------------------------------- الإعداد
  -- {"id","code","name","employee","user","phone","vanWarehouse","cashBox","plate","credit":"Y","basis":"SALES","rate","perVisit","target","status"}
  --   مستودع السيارة وعهدة النقد ينشآن تلقائياً إن تركا فارغين
  FUNCTION save_rep(p_doc IN CLOB) RETURN NUMBER;
  -- {"id","code","name","rep","region","days":"SUN,WED","status"}
  FUNCTION save_route(p_doc IN CLOB) RETURN NUMBER;
  -- {"id","customer" | "name","tax","cr","limit","term", "type","owner","phone","whatsapp","route","seq","days","lat","lng","address","landmark","status","notes"}
  FUNCTION save_shop(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE set_shop_location(p_shop_id IN NUMBER, p_lat IN NUMBER, p_lng IN NUMBER);

  -- ---------------------------------------------------------- المندوب
  -- المندوب المرتبط بالمستخدم الحالي (أو NULL)
  FUNCTION my_rep RETURN NUMBER;
  FUNCTION day_code(p_date IN DATE) RETURN VARCHAR2;
  -- خطة اليوم: المحلات المستحقة مرتبة بخط السير مع حالة الزيارة؛ p_visit_url فيه #SHOP# يستبدل برقم المحل
  FUNCTION plan_html(p_rep_id IN NUMBER, p_date IN DATE, p_visit_url IN VARCHAR2) RETURN CLOB;
  -- تحميل أو تفريغ السيارة: {"rep","direction":"LOAD|UNLOAD","wh":مستودع الشركة,"lines":[{"i","q"}]}
  FUNCTION load_van(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION van_stock_html(p_rep_id IN NUMBER) RETURN CLOB;

  -- ---------------------------------------------------------- الزيارة
  -- {"rep","shop","lat","lng"}: يسجل الوصول وبعد المندوب عن المحل، ويحفظ موقع المحل إن لم يكن محفوظاً
  FUNCTION start_visit(p_doc IN CLOB) RETURN NUMBER;
  -- بيع من السيارة: {"visit","lines":[{"i","q","p"}],"pay":{"method","amount","ref","bank","chequeDate","bankAccount"}}
  --   يعيد رقم فاتورة المبيعات
  FUNCTION visit_sale(p_doc IN CLOB) RETURN NUMBER;
  -- تحصيل: {"visit" | "rep","shop", "amount","method":"CASH|BANK_TRANSFER|CHEQUE|CARD|WALLET","ref","bank","chequeDate",
  --   "bankAccount","invoice"}؛ النقد والشبكة يرحلان فوراً، والتحويل والشيك بانتظار تأكيد المحاسب
  FUNCTION collect(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE verify_collection(p_id IN NUMBER, p_bank_account_id IN NUMBER DEFAULT NULL);
  PROCEDURE reject_collection(p_id IN NUMBER, p_reason IN VARCHAR2);
  -- مرتجع من فاتورة سابقة للمحل: {"visit","invoice","reason","lines":[{"l":lineId,"q"}]} (يخفض رصيد المحل ويعود للسيارة)
  FUNCTION visit_return(p_doc IN CLOB) RETURN NUMBER;
  -- أمر توريد مسبق: {"visit" | "rep","shop", "date":تاريخ التسليم,"lines":[{"i","q","p"}]}
  FUNCTION place_order(p_doc IN CLOB) RETURN NUMBER;
  -- تسليم الأمر بفاتورة من مستودع (السيارة أو الرئيسي)
  FUNCTION deliver_order(p_order_id IN NUMBER, p_warehouse_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
  PROCEDURE cancel_order(p_order_id IN NUMBER, p_reason IN VARCHAR2);
  -- إنهاء الزيارة: بلا بيع يتطلب السبب
  PROCEDURE close_visit(p_visit_id IN NUMBER, p_no_sale_reason IN VARCHAR2 DEFAULT NULL, p_notes IN VARCHAR2 DEFAULT NULL);
  FUNCTION open_visit(p_rep_id IN NUMBER) RETURN NUMBER;

  -- ---------------------------------------------------------- نهاية اليوم والعمولات
  -- {"rep","date","counted","box":صندوق التوريد,"notes"}: يحسب اليوم ويورد النقد المسلم لصندوق الشركة
  FUNCTION settle_day(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE approve_settlement(p_id IN NUMBER);
  FUNCTION settlement_preview_html(p_rep_id IN NUMBER, p_date IN DATE) RETURN CLOB;
  FUNCTION calc_commissions(p_month IN DATE) RETURN NUMBER;

  -- ---------------------------------------------------------- الواجهة والتقارير
  FUNCTION shop_card_html(p_shop_id IN NUMBER) RETURN CLOB;
  FUNCTION visit_html(p_visit_id IN NUMBER) RETURN CLOB;
  FUNCTION rep_day_html(p_rep_id IN NUMBER, p_date IN DATE) RETURN CLOB;
  FUNCTION performance_html(p_from IN DATE, p_to IN DATE) RETURN CLOB;
  FUNCTION idle_shops_html(p_days IN NUMBER DEFAULT 14) RETURN CLOB;
  -- نقاط المحلات للخريطة: [{"id","n","lat","lng","r","s"}]
  FUNCTION shops_geo_json(p_route_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  -- رابط واتساب للمحل (wa.me) بنص جاهز
  FUNCTION whatsapp_url(p_phone IN VARCHAR2, p_text IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION statement_text(p_shop_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION invoice_text(p_invoice_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION distance_m(p_lat1 IN NUMBER, p_lng1 IN NUMBER, p_lat2 IN NUMBER, p_lng2 IN NUMBER) RETURN NUMBER;
  FUNCTION label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION badge(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION rep_label(p_rep_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION shop_label(p_shop_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION visit_status(p_visit_id IN NUMBER) RETURN VARCHAR2;
END NOONA_DST_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_DST_PKG AS

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(TO_CHAR(NVL(p, 0), 'FM999,999,999,990.00', 'NLS_NUMERIC_CHARACTERS=''.,'''));
  END fmt;
  FUNCTION qf(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN RTRIM(RTRIM(TO_CHAR(NVL(p, 0), 'FM999,999,999,990.999', 'NLS_NUMERIC_CHARACTERS=''.,'''), '0'), '.');
  END qf;

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

  FUNCTION next_no(p_type VARCHAR2, p_prefix VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT company, p_type, NULL, p_prefix, 1, 6, 'N', 'NEVER', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = p_type);
    RETURN NOONA_REFERENCE_PKG.next_doc_no(p_type, company, NULL, TRUNC(SYSDATE), p_type, NULL);
  END next_no;

  -- ================================================================ التسميات
  FUNCTION label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code
      WHEN 'CASH' THEN 'نقداً' WHEN 'BANK_TRANSFER' THEN 'تحويل بنكي' WHEN 'CHEQUE' THEN 'شيك' WHEN 'CARD' THEN 'شبكة / مدى'
      WHEN 'WALLET' THEN 'محفظة رقمية' WHEN 'PENDING_VERIFY' THEN 'بانتظار التأكيد' WHEN 'POSTED' THEN 'مرحل' WHEN 'REJECTED' THEN 'مرفوض'
      WHEN 'OPEN' THEN 'جارية' WHEN 'CLOSED' THEN 'منتهية' WHEN 'CANCELLED' THEN 'ملغاة' WHEN 'SUBMITTED' THEN 'مقدمة'
      WHEN 'APPROVED' THEN 'معتمدة' WHEN 'INVOICED' THEN 'مفوترة' WHEN 'SALE' THEN 'بيع' WHEN 'ORDER' THEN 'أمر توريد'
      WHEN 'COLLECTION' THEN 'تحصيل' WHEN 'RETURN' THEN 'مرتجع' WHEN 'NO_SALE' THEN 'لا شراء' WHEN 'MIXED' THEN 'بيع وتحصيل'
      WHEN 'GROCERY' THEN 'بقالة' WHEN 'SUPERMARKET' THEN 'سوبرماركت' WHEN 'PHARMACY' THEN 'صيدلية' WHEN 'RESTAURANT' THEN 'مطعم'
      WHEN 'CAFE' THEN 'مقهى' WHEN 'WHOLESALE' THEN 'جملة' WHEN 'KIOSK' THEN 'كشك' WHEN 'STATION' THEN 'محطة' WHEN 'OTHER' THEN 'أخرى'
      WHEN 'STOCKED' THEN 'لديه بضاعة' WHEN 'NO_CASH' THEN 'لا يوجد سيولة' WHEN 'OWNER_ABSENT' THEN 'صاحب المحل غائب'
      WHEN 'COMPETITOR' THEN 'يشتري من منافس' WHEN 'PRICE' THEN 'السعر' WHEN 'LOAD' THEN 'تحميل' WHEN 'UNLOAD' THEN 'تفريغ'
      WHEN 'ACTIVE' THEN 'نشط' WHEN 'INACTIVE' THEN 'موقوف' WHEN 'BLOCKED' THEN 'محظور' WHEN 'SALES' THEN 'من المبيعات'
      WHEN 'VISIT' THEN 'لكل زيارة' WHEN 'NONE' THEN 'بدون' WHEN 'CALCULATED' THEN 'محسوبة'
      ELSE p_code END;
  END label;

  FUNCTION badge(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<span class="nn-badge ' || CASE
             WHEN p_code IN ('POSTED', 'CLOSED', 'APPROVED', 'INVOICED', 'ACTIVE', 'SALE', 'MIXED') THEN 'is-success'
             WHEN p_code IN ('OPEN', 'SUBMITTED', 'ORDER', 'COLLECTION') THEN 'is-info'
             WHEN p_code IN ('PENDING_VERIFY', 'NO_SALE', 'RETURN') THEN 'is-warning'
             WHEN p_code IN ('REJECTED', 'CANCELLED', 'BLOCKED', 'INACTIVE') THEN 'is-danger' ELSE 'is-muted' END
        || '">' || esc(label(p_code)) || '</span>';
  END badge;

  FUNCTION rep_label(p_rep_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT MAX(full_name || ' (' || code || ')') INTO l FROM dst_rep WHERE id = p_rep_id;
    RETURN l;
  END rep_label;

  FUNCTION shop_label(p_shop_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT MAX(NOONA_SAL_PKG.customer_label(customer_account_id)) INTO l FROM dst_shop WHERE id = p_shop_id;
    RETURN l;
  END shop_label;

  FUNCTION visit_status(p_visit_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM dst_visit WHERE id = p_visit_id AND company_id = company;
    RETURN l;
  END visit_status;

  FUNCTION day_code(p_date IN DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(p_date, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');
  END day_code;

  -- المسافة بين نقطتين على الأرض (متر)
  FUNCTION distance_m(p_lat1 IN NUMBER, p_lng1 IN NUMBER, p_lat2 IN NUMBER, p_lng2 IN NUMBER) RETURN NUMBER IS
    c_r  CONSTANT NUMBER := 6371000;
    c_pi CONSTANT NUMBER := 3.14159265358979;
    l_a  NUMBER;
  BEGIN
    IF p_lat1 IS NULL OR p_lng1 IS NULL OR p_lat2 IS NULL OR p_lng2 IS NULL THEN RETURN NULL; END IF;
    l_a := POWER(SIN((p_lat2 - p_lat1) * c_pi / 360), 2)
         + COS(p_lat1 * c_pi / 180) * COS(p_lat2 * c_pi / 180) * POWER(SIN((p_lng2 - p_lng1) * c_pi / 360), 2);
    RETURN ROUND(2 * c_r * ATAN2(SQRT(l_a), SQRT(1 - l_a)));
  END distance_m;

  -- ================================================================ التجهيز
  FUNCTION is_ready RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN NOONA_SAL_PKG.is_ready = 'Y' AND NOONA_INV_PKG.default_warehouse IS NOT NULL THEN 'Y' ELSE 'N' END;
  END is_ready;

  FUNCTION quick_setup RETURN NUMBER IS
    l_n NUMBER := 0;
  BEGIN
    guard('DST_REP.CREATE');
    IF NOONA_INV_PKG.default_warehouse IS NULL THEN l_n := l_n + NOONA_INV_PKG.quick_setup; END IF;
    IF NOONA_SAL_PKG.is_ready = 'N' THEN l_n := l_n + NOONA_SAL_PKG.quick_setup; END IF;
    RETURN l_n;
  END quick_setup;

  FUNCTION rep_row(p_id NUMBER) RETURN dst_rep%ROWTYPE IS
    l dst_rep%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM dst_rep WHERE id = p_id AND company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-DST-001', 'المندوب غير موجود', 'Rep not found');
  END rep_row;

  FUNCTION shop_row(p_id NUMBER) RETURN dst_shop%ROWTYPE IS
    l dst_shop%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM dst_shop WHERE id = p_id AND company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-DST-002', 'المحل غير موجود', 'Shop not found');
  END shop_row;

  FUNCTION visit_row(p_id NUMBER, p_lock BOOLEAN DEFAULT FALSE) RETURN dst_visit%ROWTYPE IS
    l dst_visit%ROWTYPE;
  BEGIN
    IF p_lock THEN
      SELECT * INTO l FROM dst_visit WHERE id = p_id AND company_id = company FOR UPDATE;
    ELSE
      SELECT * INTO l FROM dst_visit WHERE id = p_id AND company_id = company;
    END IF;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-DST-003', 'الزيارة غير موجودة', 'Visit not found');
  END visit_row;

  -- ================================================================ الإعداد
  FUNCTION save_rep(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id  NUMBER := jn(l_o, 'id');
    l_cd  VARCHAR2(50) := UPPER(js(l_o, 'code'));
    l_nm  VARCHAR2(200) := js(l_o, 'name');
    l_wh  NUMBER := jn(l_o, 'vanWarehouse');
    l_box NUMBER := jn(l_o, 'cashBox');
    l_bas VARCHAR2(30) := NVL(js(l_o, 'basis'), 'SALES');
    l_usr VARCHAR2(128) := UPPER(js(l_o, 'user'));
    l_emp NUMBER := jn(l_o, 'employee');
    l_ph  VARCHAR2(30) := js(l_o, 'phone');
    l_pl  VARCHAR2(30) := js(l_o, 'plate');
    l_cr  VARCHAR2(1) := NVL(js(l_o, 'credit'), 'Y');
    l_rt  NUMBER := jn(l_o, 'rate');
    l_pv  NUMBER := jn(l_o, 'perVisit');
    l_tg  NUMBER := jn(l_o, 'target');
    l_st  VARCHAR2(30) := NVL(js(l_o, 'status'), 'ACTIVE');
    l_nt  VARCHAR2(4000) := js(l_o, 'notes');
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'DST_REP.CREATE' ELSE 'DST_REP.UPDATE' END);
    NOONA_CORE_PKG.assert(l_cd IS NOT NULL AND l_nm IS NOT NULL, 'NOONA-DST-010', 'رمز المندوب واسمه مطلوبان', 'Code and name required');
    NOONA_CORE_PKG.assert(l_bas IN ('SALES', 'COLLECTION', 'VISIT', 'NONE'), 'NOONA-DST-011', 'أساس العمولة غير صحيح', 'Invalid basis');
    NOONA_CORE_PKG.assert(NVL(l_rt, 0) BETWEEN 0 AND 100, 'NOONA-DST-012', 'نسبة العمولة بين 0 و 100', 'Rate 0-100');
    IF l_id IS NULL THEN
      -- مستودع السيارة وعهدة النقد للمندوب
      IF l_wh IS NULL THEN
        l_wh := NOONA_INV_PKG.create_warehouse('VAN-' || l_cd, 'سيارة ' || l_nm, 'STORE');
      END IF;
      IF l_box IS NULL THEN
        l_box := NOONA_CSH_PKG.create_cash_box('REP-' || l_cd, 'عهدة المندوب ' || l_nm, '1101', 'CUSTODY');
      END IF;
      INSERT INTO dst_rep (company_id, code, full_name, employee_id, user_name, phone, van_warehouse_id, cash_box_id, vehicle_plate,
                           credit_allowed, commission_basis, commission_rate, commission_per_visit, monthly_target, status_code, notes)
      VALUES (company, l_cd, l_nm, l_emp, l_usr, l_ph, l_wh, l_box, l_pl, l_cr, l_bas, l_rt, l_pv, l_tg, l_st, l_nt)
      RETURNING id INTO l_id;
    ELSE
      UPDATE dst_rep SET full_name = l_nm, employee_id = l_emp, user_name = l_usr, phone = l_ph,
             van_warehouse_id = NVL(l_wh, van_warehouse_id), cash_box_id = NVL(l_box, cash_box_id), vehicle_plate = l_pl,
             credit_allowed = l_cr, commission_basis = l_bas, commission_rate = l_rt, commission_per_visit = l_pv,
             monthly_target = l_tg, status_code = l_st, notes = l_nt
       WHERE id = l_id AND company_id = company;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-DST-001', 'المندوب غير موجود', 'Rep not found');
    END IF;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-DST-013', 'رمز المندوب أو مستخدمه مسجل لمندوب آخر', 'Rep code or user already used');
  END save_rep;

  FUNCTION save_route(p_doc IN CLOB) RETURN NUMBER IS
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id NUMBER := jn(l_o, 'id');
    l_cd VARCHAR2(50) := UPPER(js(l_o, 'code'));
    l_nm VARCHAR2(200) := js(l_o, 'name');
    l_rp NUMBER := jn(l_o, 'rep');
    l_rg VARCHAR2(100) := js(l_o, 'region');
    l_dy VARCHAR2(50) := UPPER(REPLACE(js(l_o, 'days'), ' '));
    l_st VARCHAR2(30) := NVL(js(l_o, 'status'), 'ACTIVE');
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'DST_ROUTE.CREATE' ELSE 'DST_ROUTE.UPDATE' END);
    NOONA_CORE_PKG.assert(l_cd IS NOT NULL AND l_nm IS NOT NULL, 'NOONA-DST-020', 'رمز الخط واسمه مطلوبان', 'Code and name required');
    NOONA_CORE_PKG.assert(l_dy IS NULL OR REGEXP_LIKE(l_dy, '^((SUN|MON|TUE|WED|THU|FRI|SAT),?)+$'), 'NOONA-DST-021',
      'أيام الزيارة: SUN,MON,TUE,WED,THU,FRI,SAT مفصولة بفاصلة', 'Invalid visit days');
    IF l_id IS NULL THEN
      INSERT INTO dst_route (company_id, code, name_ar, rep_id, region_name, visit_days, status_code)
      VALUES (company, l_cd, l_nm, l_rp, l_rg, l_dy, l_st) RETURNING id INTO l_id;
    ELSE
      UPDATE dst_route SET name_ar = l_nm, rep_id = l_rp, region_name = l_rg, visit_days = l_dy, status_code = l_st
       WHERE id = l_id AND company_id = company;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-DST-022', 'خط السير غير موجود', 'Route not found');
    END IF;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-DST-023', 'رمز خط السير مستخدم', 'Route code already used');
  END save_route;

  FUNCTION save_shop(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id  NUMBER := jn(l_o, 'id');
    l_acc NUMBER := jn(l_o, 'customer');
    l_c   JSON_OBJECT_T := JSON_OBJECT_T();
    l_lat NUMBER := jn(l_o, 'lat');
    l_lng NUMBER := jn(l_o, 'lng');
    l_dy  VARCHAR2(50) := UPPER(REPLACE(js(l_o, 'days'), ' '));
    l_tp  VARCHAR2(30) := NVL(js(l_o, 'type'), 'GROCERY');
    l_ow  VARCHAR2(200) := js(l_o, 'owner');
    l_ph  VARCHAR2(30) := js(l_o, 'phone');
    l_wa  VARCHAR2(30) := js(l_o, 'whatsapp');
    l_rt  NUMBER := jn(l_o, 'route');
    l_sq  NUMBER := jn(l_o, 'seq');
    l_ad  VARCHAR2(500) := js(l_o, 'address');
    l_lm  VARCHAR2(500) := js(l_o, 'landmark');
    l_st  VARCHAR2(30) := NVL(js(l_o, 'status'), 'ACTIVE');
    l_nt  VARCHAR2(4000) := js(l_o, 'notes');
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'DST_SHOP.CREATE' ELSE 'DST_SHOP.UPDATE' END);
    NOONA_CORE_PKG.assert((l_lat IS NULL AND l_lng IS NULL) OR (l_lat BETWEEN -90 AND 90 AND l_lng BETWEEN -180 AND 180),
      'NOONA-DST-030', 'إحداثيات الموقع غير صحيحة', 'Invalid coordinates');
    NOONA_CORE_PKG.assert(l_dy IS NULL OR REGEXP_LIKE(l_dy, '^((SUN|MON|TUE|WED|THU|FRI|SAT),?)+$'), 'NOONA-DST-021',
      'أيام الزيارة: SUN,MON,TUE,WED,THU,FRI,SAT مفصولة بفاصلة', 'Invalid visit days');
    IF l_id IS NULL AND l_acc IS NULL THEN
      -- محل جديد: ينشأ عميل في المبيعات (الطرف والحساب وحد الائتمان)
      NOONA_CORE_PKG.assert(js(l_o, 'name') IS NOT NULL, 'NOONA-DST-031', 'اسم المحل مطلوب', 'Shop name required');
      l_c.put('name', js(l_o, 'name'));
      l_c.put('person', 'N');
      IF js(l_o, 'tax') IS NOT NULL THEN l_c.put('tax', js(l_o, 'tax')); END IF;
      IF js(l_o, 'cr') IS NOT NULL THEN l_c.put('cr', js(l_o, 'cr')); END IF;
      IF l_ph IS NOT NULL THEN l_c.put('phone', l_ph); END IF;
      IF l_ad IS NOT NULL THEN l_c.put('address', l_ad); END IF;
      l_c.put('term', NVL(js(l_o, 'term'), 'NET30'));
      IF jn(l_o, 'limit') IS NOT NULL THEN l_c.put('limit', jn(l_o, 'limit')); END IF;
      l_acc := NOONA_SAL_PKG.save_customer(l_c.to_clob);
    END IF;
    IF l_id IS NULL THEN
      INSERT INTO dst_shop (company_id, customer_account_id, shop_type, owner_name, phone, whatsapp, route_id, route_seq, visit_days,
                            latitude, longitude, location_set_at, address_text, landmark, status_code, notes)
      VALUES (company, l_acc, l_tp, l_ow, l_ph, NVL(l_wa, l_ph), l_rt,
              NVL(l_sq, (SELECT NVL(MAX(route_seq), 0) + 1 FROM dst_shop WHERE route_id = l_rt AND company_id = company)),
              l_dy, l_lat, l_lng, CASE WHEN l_lat IS NOT NULL THEN SYSTIMESTAMP END, l_ad, l_lm, l_st, l_nt)
      RETURNING id INTO l_id;
    ELSE
      UPDATE dst_shop SET shop_type = l_tp, owner_name = l_ow, phone = l_ph, whatsapp = NVL(l_wa, l_ph), route_id = l_rt,
             route_seq = NVL(l_sq, route_seq), visit_days = l_dy, address_text = l_ad, landmark = l_lm, status_code = l_st, notes = l_nt,
             latitude = NVL(l_lat, latitude), longitude = NVL(l_lng, longitude),
             location_set_at = CASE WHEN l_lat IS NOT NULL THEN SYSTIMESTAMP ELSE location_set_at END
       WHERE id = l_id AND company_id = company;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-DST-002', 'المحل غير موجود', 'Shop not found');
    END IF;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-DST-032', 'العميل مسجل كمحل توزيع مسبقاً', 'Customer already registered as a shop');
  END save_shop;

  PROCEDURE set_shop_location(p_shop_id IN NUMBER, p_lat IN NUMBER, p_lng IN NUMBER) IS
  BEGIN
    guard('DST_SHOP.UPDATE');
    NOONA_CORE_PKG.assert(p_lat BETWEEN -90 AND 90 AND p_lng BETWEEN -180 AND 180, 'NOONA-DST-030', 'إحداثيات الموقع غير صحيحة', 'Invalid coordinates');
    UPDATE dst_shop SET latitude = p_lat, longitude = p_lng, location_set_at = SYSTIMESTAMP WHERE id = p_shop_id AND company_id = company;
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-DST-002', 'المحل غير موجود', 'Shop not found');
  END set_shop_location;

  -- ================================================================ المندوب
  FUNCTION my_rep RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM dst_rep
     WHERE company_id = company AND status_code = 'ACTIVE'
       AND user_name = UPPER(NVL(SYS_CONTEXT('APEX$SESSION', 'APP_USER'), NOONA_CTX_PKG.current_user_name));
    RETURN l;
  END my_rep;

  FUNCTION plan_html(p_rep_id IN NUMBER, p_date IN DATE, p_visit_url IN VARCHAR2) RETURN CLOB IS
    l_h    CLOB;
    l_day  VARCHAR2(3) := day_code(NVL(p_date, TRUNC(SYSDATE)));
    l_n    PLS_INTEGER := 0;
    l_done PLS_INTEGER := 0;
  BEGIN
    IF p_rep_id IS NULL THEN
      RETURN '<p class="nn-hint">حسابك غير مربوط بمندوب. يربطه مدير التوزيع من «المندوبون» بحقل مستخدم النظام.</p>';
    END IF;
    FOR s IN (SELECT s.id, s.latitude, s.longitude, s.address_text, s.landmark, s.phone, s.whatsapp, s.route_seq, r.name_ar route_name,
                     NOONA_SAL_PKG.customer_label(s.customer_account_id) nm, NOONA_SAL_PKG.customer_balance(s.customer_account_id) bal,
                     (SELECT MAX(v.status_code) KEEP (DENSE_RANK LAST ORDER BY v.id) FROM dst_visit v
                       WHERE v.shop_id = s.id AND v.doc_date = TRUNC(NVL(p_date, SYSDATE))) vst,
                     (SELECT MAX(v.outcome) KEEP (DENSE_RANK LAST ORDER BY v.id) FROM dst_visit v
                       WHERE v.shop_id = s.id AND v.doc_date = TRUNC(NVL(p_date, SYSDATE))) vout
                FROM dst_shop s JOIN dst_route r ON r.id = s.route_id
               WHERE s.company_id = company AND s.status_code = 'ACTIVE' AND r.status_code = 'ACTIVE' AND r.rep_id = p_rep_id
                 AND INSTR(',' || NVL(s.visit_days, r.visit_days) || ',', ',' || l_day || ',') > 0
               ORDER BY r.code, s.route_seq, s.id) LOOP
      l_n := l_n + 1;
      IF s.vst = 'CLOSED' THEN l_done := l_done + 1; END IF;
      l_h := l_h || '<div class="nn-dst-stop' || CASE WHEN s.vst = 'CLOSED' THEN ' is-done' WHEN s.vst = 'OPEN' THEN ' is-open' END || '">'
          || '<span class="nn-dst-seq">' || l_n || '</span><div class="nn-dst-stop-b"><b>' || esc(s.nm) || '</b>'
          || CASE WHEN s.vst IS NOT NULL THEN ' ' || badge(NVL(s.vout, s.vst)) END
          || '<small>' || esc(NVL(s.landmark, s.address_text)) || '</small>'
          || '<small>الرصيد: <b>' || fmt(s.bal) || '</b></small></div><div class="nn-dst-stop-a">'
          || CASE WHEN s.latitude IS NOT NULL THEN '<a class="nn-dst-btn" target="_blank" rel="noopener" href="https://www.google.com/maps/dir/?api=1&destination='
               || TO_CHAR(s.latitude, 'FM990.0000000') || ',' || TO_CHAR(s.longitude, 'FM990.0000000') || '"><span class="fa fa-location-arrow"></span> الطريق</a>' END
          || CASE WHEN s.phone IS NOT NULL THEN '<a class="nn-dst-btn" href="tel:' || esc(s.phone) || '"><span class="fa fa-phone"></span></a>' END
          || '<a class="nn-dst-btn nn-dst-go" href="' || REPLACE(p_visit_url, '#SHOP#', s.id) || '">'
          || CASE WHEN s.vst = 'OPEN' THEN 'متابعة' WHEN s.vst = 'CLOSED' THEN 'عرض' ELSE 'زيارة' END || '</a></div></div>';
    END LOOP;
    RETURN '<div class="nn-dst-plan-h"><b>خطة ' || TO_CHAR(NVL(p_date, SYSDATE), 'YYYY-MM-DD') || '</b> · ' || l_done || ' من ' || l_n
        || ' زيارة</div>' || NVL(l_h, '<p class="nn-hint">لا محلات مجدولة لهذا اليوم في خطوط سيرك.</p>');
  END plan_html;

  FUNCTION load_van(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_r    dst_rep%ROWTYPE;
    l_dir  VARCHAR2(10) := NVL(js(l_o, 'direction'), 'LOAD');
    l_wh   NUMBER := NVL(jn(l_o, 'wh'), NOONA_INV_PKG.default_warehouse);
    l_from NUMBER;
    l_to   NUMBER;
    l_doc  JSON_OBJECT_T := JSON_OBJECT_T();
    l_ln   JSON_ARRAY_T := JSON_ARRAY_T();
    l_x    JSON_OBJECT_T;
    l_txn  NUMBER;
    l_id   NUMBER;
    l_cnt  NUMBER := 0;
    l_qty  NUMBER := 0;
    l_no   VARCHAR2(50);
    l_nt   VARCHAR2(4000) := js(l_o, 'notes');
  BEGIN
    guard('DST_LOAD.CREATE');
    l_r := rep_row(NVL(jn(l_o, 'rep'), my_rep));
    NOONA_CORE_PKG.assert(l_dir IN ('LOAD', 'UNLOAD'), 'NOONA-DST-040', 'تحميل أو تفريغ', 'LOAD or UNLOAD');
    NOONA_CORE_PKG.assert(l_wh IS NOT NULL AND l_wh <> l_r.van_warehouse_id, 'NOONA-DST-041', 'اختر مستودع الشركة', 'Company warehouse required');
    l_from := CASE l_dir WHEN 'LOAD' THEN l_wh ELSE l_r.van_warehouse_id END;
    l_to := CASE l_dir WHEN 'LOAD' THEN l_r.van_warehouse_id ELSE l_wh END;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (i NUMBER PATH '$.i', q NUMBER PATH '$.q'))) LOOP
      CONTINUE WHEN r.i IS NULL OR NVL(r.q, 0) <= 0;
      l_x := JSON_OBJECT_T(); l_x.put('i', r.i); l_x.put('q', r.q); l_ln.append(l_x);
      l_cnt := l_cnt + 1; l_qty := l_qty + r.q;
    END LOOP;
    NOONA_CORE_PKG.assert(l_cnt > 0, 'NOONA-DST-042', 'أضف الأصناف والكميات', 'Add items');
    l_no := next_no('DST_LOAD', CASE l_dir WHEN 'LOAD' THEN 'LD-' ELSE 'UL-' END);
    l_doc.put('type', 'TRANSFER_OUT');
    l_doc.put('date', TO_CHAR(SYSDATE, 'YYYY-MM-DD'));
    l_doc.put('wh', l_from);
    l_doc.put('toWh', l_to);
    l_doc.put('reason', CASE l_dir WHEN 'LOAD' THEN 'تحميل سيارة ' ELSE 'تفريغ سيارة ' END || l_r.full_name);
    l_doc.put('desc', l_no || ' - ' || l_r.full_name);
    l_doc.put('action', 'POST');
    l_doc.put('lines', l_ln);
    l_txn := NOONA_INV_PKG.save_stock_doc(l_doc.to_clob);
    INSERT INTO dst_load (company_id, doc_no, doc_date, rep_id, direction, from_warehouse_id, to_warehouse_id, inv_txn_id, items_count,
                          total_qty, status_code, notes)
    VALUES (company, l_no, TRUNC(SYSDATE), l_r.id, l_dir, l_from, l_to, l_txn, l_cnt, l_qty, 'POSTED', l_nt)
    RETURNING id INTO l_id;
    RETURN l_id;
  END load_van;

  FUNCTION van_stock_html(p_rep_id IN NUMBER) RETURN CLOB IS
    l_h  CLOB;
    l_wh NUMBER;
    l_v  NUMBER := 0;
  BEGIN
    IF p_rep_id IS NULL THEN RETURN NULL; END IF;
    SELECT van_warehouse_id INTO l_wh FROM dst_rep WHERE id = p_rep_id AND company_id = company;
    FOR r IN (SELECT i.item_no, i.name_ar, SUM(o.on_hand_qty) q, MAX(NOONA_INV_PKG.avg_cost(i.id)) c
                FROM inv_onhand o JOIN inv_item i ON i.id = o.item_id
               WHERE o.company_id = company AND o.warehouse_id = l_wh GROUP BY i.item_no, i.name_ar HAVING SUM(o.on_hand_qty) <> 0
               ORDER BY i.name_ar) LOOP
      l_v := l_v + r.q * NVL(r.c, 0);
      l_h := l_h || '<tr><td>' || esc(r.item_no) || '</td><td>' || esc(r.name_ar) || '</td><td class="u-tE"><b>' || qf(r.q) || '</b></td></tr>';
    END LOOP;
    RETURN CASE WHEN l_h IS NULL THEN '<p class="nn-hint">السيارة فارغة: حمّلها من مستودع الشركة.</p>'
           ELSE '<table class="nn-table"><thead><tr><th>الرقم</th><th>الصنف</th><th>الكمية</th></tr></thead><tbody>' || l_h
             || '</tbody></table><p class="nn-hint">قيمة المخزون في السيارة بالتكلفة: <b>' || fmt(l_v) || '</b></p>' END;
  END van_stock_html;

  -- ================================================================ الزيارة
  FUNCTION open_visit(p_rep_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) INTO l FROM dst_visit WHERE rep_id = p_rep_id AND company_id = company AND status_code = 'OPEN';
    RETURN l;
  END open_visit;

  FUNCTION start_visit(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_r   dst_rep%ROWTYPE;
    l_s   dst_shop%ROWTYPE;
    l_lat NUMBER := jn(l_o, 'lat');
    l_lng NUMBER := jn(l_o, 'lng');
    l_id  NUMBER;
    l_no  VARCHAR2(50);
    l_old NUMBER;
  BEGIN
    guard('DST_VISIT.CREATE');
    l_r := rep_row(NVL(jn(l_o, 'rep'), my_rep));
    l_s := shop_row(jn(l_o, 'shop'));
    NOONA_CORE_PKG.assert(l_s.status_code = 'ACTIVE', 'NOONA-DST-050', 'المحل موقوف', 'Shop inactive');
    l_old := open_visit(l_r.id);
    IF l_old IS NOT NULL THEN
      SELECT MAX(id) INTO l_id FROM dst_visit WHERE id = l_old AND shop_id = l_s.id;
      IF l_id IS NOT NULL THEN RETURN l_id; END IF;          -- الزيارة الجارية لنفس المحل
      NOONA_CORE_PKG.raise_error('NOONA-DST-051', 'لديك زيارة جارية لمحل آخر؛ أنهها أولاً', 'Finish your open visit first');
    END IF;
    -- أول زيارة بموقع: يحفظ موقع المحل للتوزيع التالي
    IF l_s.latitude IS NULL AND l_lat IS NOT NULL THEN
      UPDATE dst_shop SET latitude = l_lat, longitude = l_lng, location_set_at = SYSTIMESTAMP WHERE id = l_s.id;
      l_s.latitude := l_lat; l_s.longitude := l_lng;
    END IF;
    l_no := next_no('DST_VISIT', 'VS-');
    INSERT INTO dst_visit (company_id, doc_no, doc_date, rep_id, shop_id, route_id, checkin_at, latitude, longitude, distance_m, status_code)
    VALUES (company, l_no, TRUNC(SYSDATE), l_r.id, l_s.id, l_s.route_id, SYSTIMESTAMP, l_lat, l_lng,
            distance_m(l_lat, l_lng, l_s.latitude, l_s.longitude), 'OPEN')
    RETURNING id INTO l_id;
    UPDATE dst_shop SET last_visit_at = SYSTIMESTAMP WHERE id = l_s.id;
    RETURN l_id;
  END start_visit;

  FUNCTION visit_for_doc(l_o JSON_OBJECT_T, p_rep OUT dst_rep%ROWTYPE, p_shop OUT dst_shop%ROWTYPE) RETURN NUMBER IS
    l_v dst_visit%ROWTYPE;
  BEGIN
    IF jn(l_o, 'visit') IS NOT NULL THEN
      l_v := visit_row(jn(l_o, 'visit'), TRUE);
      NOONA_CORE_PKG.assert(l_v.status_code = 'OPEN', 'NOONA-DST-052', 'الزيارة منتهية', 'Visit is closed');
      p_rep := rep_row(l_v.rep_id);
      p_shop := shop_row(l_v.shop_id);
      RETURN l_v.id;
    END IF;
    p_rep := rep_row(NVL(jn(l_o, 'rep'), my_rep));
    p_shop := shop_row(jn(l_o, 'shop'));
    RETURN NULL;
  END visit_for_doc;

  FUNCTION method_code(p_method VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_method WHEN 'CASH' THEN 'CASH' WHEN 'CARD' THEN 'MADA' WHEN 'WALLET' THEN 'STC_PAY'
                         WHEN 'BANK_TRANSFER' THEN 'BANK_APP' WHEN 'CHEQUE' THEN 'CHEQUE' END;
  END method_code;

  FUNCTION default_bank RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM csh_bank_account WHERE company_id = company AND status_code = 'ACTIVE';
    RETURN l;
  END default_bank;

  -- يرحل التحصيل بسند قبض في المبيعات (مخصص للفاتورة إن وجدت)
  PROCEDURE post_collection(p_id NUMBER, p_bank NUMBER) IS
    l_c   dst_collection%ROWTYPE;
    l_s   dst_shop%ROWTYPE;
    l_r   dst_rep%ROWTYPE;
    l_d   JSON_OBJECT_T := JSON_OBJECT_T();
    l_al  JSON_ARRAY_T := JSON_ARRAY_T();
    l_a   JSON_OBJECT_T;
    l_bk  NUMBER;
    l_rc  NUMBER;
    l_due NUMBER;
  BEGIN
    SELECT * INTO l_c FROM dst_collection WHERE id = p_id FOR UPDATE;
    l_s := shop_row(l_c.shop_id);
    l_r := rep_row(l_c.rep_id);
    l_d.put('cust', l_s.customer_account_id);
    l_d.put('date', TO_CHAR(SYSDATE, 'YYYY-MM-DD'));
    l_d.put('amount', l_c.amount);
    IF l_c.payment_method = 'CASH' THEN
      l_d.put('place', 'BOX:' || l_r.cash_box_id);
    ELSE
      l_bk := COALESCE(p_bank, l_c.bank_account_id, default_bank);
      NOONA_CORE_PKG.assert(l_bk IS NOT NULL, 'NOONA-DST-060', 'لا يوجد حساب بنكي للشركة لاستلام المبلغ', 'No company bank account');
      l_d.put('place', 'BANK:' || l_bk);
    END IF;
    l_d.put('method', method_code(l_c.payment_method));
    l_d.put('ref', SUBSTR(l_c.reference_no || CASE WHEN l_c.bank_name IS NOT NULL THEN ' - ' || l_c.bank_name END, 1, 200));
    l_d.put('notes', 'تحصيل ميداني ' || l_c.doc_no || ' - ' || l_r.full_name);
    IF l_c.sales_invoice_id IS NOT NULL THEN
      -- التخصيص على الذمة المفتوحة للفاتورة
      l_due := l_c.amount;
      FOR o IN (SELECT id, open_amount FROM ar_open_item
                 WHERE source_entity_type = 'SAL_INVOICE' AND source_entity_id = l_c.sales_invoice_id AND item_type = 'INVOICE'
                   AND open_amount > 0 ORDER BY due_date, id) LOOP
        EXIT WHEN l_due <= 0;
        l_a := JSON_OBJECT_T(); l_a.put('inv', o.id); l_a.put('a', LEAST(o.open_amount, l_due)); l_al.append(l_a);
        l_due := l_due - LEAST(o.open_amount, l_due);
      END LOOP;
      IF l_al.get_size > 0 THEN l_d.put('alloc', l_al); END IF;
    END IF;
    l_rc := NOONA_SAL_PKG.receive(l_d.to_clob);
    UPDATE dst_collection SET status_code = 'POSTED', ar_receipt_id = l_rc, bank_account_id = NVL(l_bk, bank_account_id),
           verified_by = CASE WHEN payment_method IN ('BANK_TRANSFER', 'CHEQUE') THEN NOONA_CTX_PKG.current_user_name END,
           verified_at = CASE WHEN payment_method IN ('BANK_TRANSFER', 'CHEQUE') THEN SYSTIMESTAMP END
     WHERE id = p_id;
  END post_collection;

  FUNCTION collect_core(p_rep dst_rep%ROWTYPE, p_shop dst_shop%ROWTYPE, p_visit NUMBER, p_pay JSON_OBJECT_T, p_invoice NUMBER) RETURN NUMBER IS
    l_m   VARCHAR2(30) := NVL(js(p_pay, 'method'), 'CASH');
    l_amt NUMBER := ROUND(jn(p_pay, 'amount'), 2);
    l_ref VARCHAR2(100) := SUBSTR(js(p_pay, 'ref'), 1, 100);
    l_id  NUMBER;
    l_no  VARCHAR2(50);
    l_bn  VARCHAR2(100) := SUBSTR(js(p_pay, 'bank'), 1, 100);
    l_cd  DATE := jd(p_pay, 'chequeDate');
    l_ba  NUMBER := jn(p_pay, 'bankAccount');
    l_nt  VARCHAR2(4000) := SUBSTR(js(p_pay, 'notes'), 1, 4000);
  BEGIN
    NOONA_CORE_PKG.assert(l_m IN ('CASH', 'BANK_TRANSFER', 'CHEQUE', 'CARD', 'WALLET'), 'NOONA-DST-061', 'طريقة الدفع غير صحيحة', 'Invalid method');
    NOONA_CORE_PKG.assert(NVL(l_amt, 0) > 0, 'NOONA-DST-062', 'المبلغ يجب أن يكون موجباً', 'Amount must be positive');
    NOONA_CORE_PKG.assert(l_m = 'CASH' OR l_ref IS NOT NULL, 'NOONA-DST-063',
      CASE l_m WHEN 'BANK_TRANSFER' THEN 'رقم الإشعار البنكي مطلوب' WHEN 'CHEQUE' THEN 'رقم الشيك مطلوب' ELSE 'رقم العملية مطلوب' END,
      'Reference number required');
    NOONA_CORE_PKG.assert(l_m <> 'CHEQUE' OR jd(p_pay, 'chequeDate') IS NOT NULL, 'NOONA-DST-064', 'تاريخ استحقاق الشيك مطلوب', 'Cheque date required');
    IF l_m IN ('BANK_TRANSFER', 'CHEQUE') THEN
      -- رقم المرجع لا يتكرر لنفس الطريقة (منع تسجيل الإشعار مرتين)
      SELECT COUNT(*) INTO l_id FROM dst_collection
       WHERE company_id = company AND payment_method = l_m AND UPPER(reference_no) = UPPER(l_ref) AND status_code <> 'REJECTED';
      NOONA_CORE_PKG.assert(l_id = 0, 'NOONA-DST-065', 'رقم المرجع مسجل في تحصيل سابق: ' || l_ref, 'Reference already used');
    END IF;
    l_no := next_no('DST_COLLECTION', 'CL-');
    INSERT INTO dst_collection (company_id, doc_no, doc_date, rep_id, shop_id, visit_id, amount, payment_method, reference_no, bank_name,
                                cheque_due_date, bank_account_id, sales_invoice_id, status_code, notes)
    VALUES (company, l_no, TRUNC(SYSDATE), p_rep.id, p_shop.id, p_visit, l_amt, l_m, l_ref, l_bn, l_cd, l_ba, p_invoice,
            'PENDING_VERIFY', l_nt)
    RETURNING id INTO l_id;
    IF l_m IN ('CASH', 'CARD', 'WALLET') THEN
      post_collection(l_id, jn(p_pay, 'bankAccount'));
    END IF;
    IF p_visit IS NOT NULL THEN
      UPDATE dst_visit SET collected_amount = collected_amount + l_amt WHERE id = p_visit;
    END IF;
    RETURN l_id;
  END collect_core;

  FUNCTION collect(p_doc IN CLOB) RETURN NUMBER IS
    l_o JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_r dst_rep%ROWTYPE;
    l_s dst_shop%ROWTYPE;
    l_v NUMBER;
  BEGIN
    guard('DST_COLLECTION.CREATE');
    l_v := visit_for_doc(l_o, l_r, l_s);
    RETURN collect_core(l_r, l_s, l_v, l_o, jn(l_o, 'invoice'));
  END collect;

  PROCEDURE verify_collection(p_id IN NUMBER, p_bank_account_id IN NUMBER DEFAULT NULL) IS
    l_st VARCHAR2(30);
  BEGIN
    guard('DST_COLLECTION.UPDATE');
    SELECT MAX(status_code) INTO l_st FROM dst_collection WHERE id = p_id AND company_id = company;
    NOONA_CORE_PKG.assert(l_st = 'PENDING_VERIFY', 'NOONA-DST-066', 'التحصيل ليس بانتظار التأكيد', 'Not pending verification');
    post_collection(p_id, p_bank_account_id);
  END verify_collection;

  PROCEDURE reject_collection(p_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_c dst_collection%ROWTYPE;
  BEGIN
    guard('DST_COLLECTION.UPDATE');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-DST-067', 'سبب الرفض مطلوب', 'Reason required');
    SELECT * INTO l_c FROM dst_collection WHERE id = p_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_c.status_code = 'PENDING_VERIFY', 'NOONA-DST-066', 'التحصيل ليس بانتظار التأكيد', 'Not pending verification');
    UPDATE dst_collection SET status_code = 'REJECTED', verified_by = NOONA_CTX_PKG.current_user_name, verified_at = SYSTIMESTAMP,
           notes = SUBSTR(NVL2(notes, notes || ' | ', '') || 'رفض: ' || p_reason, 1, 4000)
     WHERE id = p_id;
    IF l_c.visit_id IS NOT NULL THEN
      UPDATE dst_visit SET collected_amount = GREATEST(collected_amount - l_c.amount, 0) WHERE id = l_c.visit_id;
    END IF;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-DST-068', 'التحصيل غير موجود', 'Collection not found');
  END reject_collection;

  FUNCTION invoice_total(p_inv NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT total_amount INTO l FROM sal_invoice WHERE id = p_inv;
    RETURN l;
  END invoice_total;

  FUNCTION visit_sale(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_r    dst_rep%ROWTYPE;
    l_s    dst_shop%ROWTYPE;
    l_v    NUMBER;
    l_pay  JSON_OBJECT_T;
    l_m    VARCHAR2(30);
    l_pamt NUMBER;
    l_inv  JSON_OBJECT_T := JSON_OBJECT_T();
    l_ln   JSON_ARRAY_T := JSON_ARRAY_T();
    l_x    JSON_OBJECT_T;
    l_id   NUMBER;
    l_tot  NUMBER;
    l_full BOOLEAN;
    l_n    PLS_INTEGER := 0;
    l_c    NUMBER;
    l_no   VARCHAR2(50);
  BEGIN
    guard('DST_VISIT.UPDATE');
    l_v := visit_for_doc(l_o, l_r, l_s);
    NOONA_CORE_PKG.assert(l_v IS NOT NULL, 'NOONA-DST-053', 'البيع يكون ضمن زيارة؛ سجل الوصول للمحل أولاً', 'Start a visit first');
    IF l_o.has('pay') AND NOT l_o.get('pay').is_null THEN l_pay := l_o.get_object('pay'); END IF;
    l_m := CASE WHEN l_pay IS NOT NULL THEN NVL(js(l_pay, 'method'), 'CASH') END;
    l_pamt := CASE WHEN l_pay IS NOT NULL THEN NVL(ROUND(jn(l_pay, 'amount'), 2), 0) ELSE 0 END;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (i NUMBER PATH '$.i', q NUMBER PATH '$.q', p NUMBER PATH '$.p'))) LOOP
      CONTINUE WHEN r.i IS NULL OR NVL(r.q, 0) <= 0;
      l_x := JSON_OBJECT_T(); l_x.put('i', r.i); l_x.put('q', r.q);
      IF r.p IS NOT NULL THEN l_x.put('p', r.p); l_x.put('inc', 'Y'); END IF;
      l_ln.append(l_x);
      l_n := l_n + 1;
    END LOOP;
    NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-DST-054', 'أضف الأصناف والكميات', 'Add items');
    l_inv.put('cust', l_s.customer_account_id);
    l_inv.put('date', TO_CHAR(SYSDATE, 'YYYY-MM-DD'));
    l_inv.put('wh', l_r.van_warehouse_id);
    l_inv.put('notes', 'بيع ميداني - ' || l_r.full_name);
    l_inv.put('action', 'POST');
    l_inv.put('lines', l_ln);
    -- آجل حتى يسدد بالتحصيل (النقد والشبكة يرحلان فوراً، والتحويل والشيك بعد التأكيد)
    l_inv.put('mode', 'CREDIT');
    BEGIN
      l_id := NOONA_SAL_PKG.save_invoice(l_inv.to_clob);
    EXCEPTION WHEN OTHERS THEN
      -- محل بلا رصيد ائتماني يدفع نقداً كاملاً: فاتورة نقدية على عهدة المندوب
      IF INSTR(SQLERRM, 'NOONA-SAL-031') > 0 AND l_m = 'CASH' THEN
        l_inv.put('mode', 'CASH'); l_inv.put('place', 'BOX:' || l_r.cash_box_id); l_inv.put('method', 'CASH');
        l_id := NOONA_SAL_PKG.save_invoice(l_inv.to_clob);
        l_tot := invoice_total(l_id);
        NOONA_CORE_PKG.assert(l_pamt >= l_tot, 'NOONA-DST-055', 'تجاوز حد الائتمان: يجب سداد الفاتورة كاملة', 'Credit limit exceeded');
        l_no := next_no('DST_COLLECTION', 'CL-');
        INSERT INTO dst_collection (company_id, doc_no, doc_date, rep_id, shop_id, visit_id, amount, payment_method, sales_invoice_id, status_code)
        VALUES (company, l_no, TRUNC(SYSDATE), l_r.id, l_s.id, l_v, l_tot, 'CASH', l_id, 'POSTED');
        UPDATE dst_visit SET sales_invoice_id = l_id, sales_amount = sales_amount + l_tot, collected_amount = collected_amount + l_tot WHERE id = l_v;
        UPDATE dst_shop SET last_sale_at = SYSTIMESTAMP WHERE id = l_s.id;
        RETURN l_id;
      END IF;
      RAISE;
    END;
    NOONA_CORE_PKG.assert(l_r.credit_allowed = 'Y' OR l_pamt >= invoice_total(l_id), 'NOONA-DST-056',
      'المندوب غير مصرح له بالبيع الآجل: السداد الكامل مطلوب', 'Rep may not sell on credit');
    l_tot := invoice_total(l_id);
    UPDATE dst_visit SET sales_invoice_id = l_id, sales_amount = sales_amount + l_tot WHERE id = l_v;
    UPDATE dst_shop SET last_sale_at = SYSTIMESTAMP WHERE id = l_s.id;
    IF l_pamt > 0 THEN
      l_c := collect_core(l_r, l_s, l_v, l_pay, l_id);
    END IF;
    RETURN l_id;
  END visit_sale;

  FUNCTION visit_return(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_r   dst_rep%ROWTYPE;
    l_s   dst_shop%ROWTYPE;
    l_v   NUMBER;
    l_inv NUMBER := jn(l_o, 'invoice');
    l_n   NUMBER;
    l_id  NUMBER;
    l_amt NUMBER;
    l_d   JSON_OBJECT_T := JSON_OBJECT_T();
    l_ln  JSON_ARRAY_T := JSON_ARRAY_T();
    l_x   JSON_OBJECT_T;
  BEGIN
    guard('DST_VISIT.UPDATE');
    l_v := visit_for_doc(l_o, l_r, l_s);
    NOONA_CORE_PKG.assert(l_v IS NOT NULL, 'NOONA-DST-053', 'المرتجع يكون ضمن زيارة؛ سجل الوصول للمحل أولاً', 'Start a visit first');
    SELECT COUNT(*) INTO l_n FROM sal_invoice WHERE id = l_inv AND customer_account_id = l_s.customer_account_id AND company_id = company;
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-DST-070', 'الفاتورة لا تخص هذا المحل', 'Invoice does not belong to the shop');
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (l NUMBER PATH '$.l', q NUMBER PATH '$.q'))) LOOP
      CONTINUE WHEN r.l IS NULL OR NVL(r.q, 0) <= 0;
      l_x := JSON_OBJECT_T(); l_x.put('l', r.l); l_x.put('q', r.q); l_ln.append(l_x);
    END LOOP;
    l_d.put('inv', l_inv);
    l_d.put('date', TO_CHAR(SYSDATE, 'YYYY-MM-DD'));
    l_d.put('reason', NVL(js(l_o, 'reason'), 'مرتجع ميداني - ' || l_r.full_name));
    l_d.put('lines', l_ln);
    l_id := NOONA_SAL_PKG.post_return(l_d.to_clob);
    SELECT NVL(MAX(ABS(total_amount)), 0) INTO l_amt FROM sal_invoice WHERE id = l_id;
    UPDATE dst_visit SET returns_amount = returns_amount + l_amt WHERE id = l_v;
    RETURN l_id;
  END visit_return;

  FUNCTION place_order(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_r   dst_rep%ROWTYPE;
    l_s   dst_shop%ROWTYPE;
    l_v   NUMBER;
    l_id  NUMBER;
    l_tot NUMBER := 0;
    l_p   NUMBER;
    l_inc VARCHAR2(1);
    l_tc  NUMBER;
    l_net NUMBER;
    l_tx  NUMBER;
    l_no  VARCHAR2(50);
    l_dd  DATE := NVL(jd(l_o, 'date'), TRUNC(SYSDATE) + 1);
    l_nt  VARCHAR2(4000) := js(l_o, 'notes');
  BEGIN
    guard('DST_ORDER.CREATE');
    l_v := visit_for_doc(l_o, l_r, l_s);
    l_no := next_no('DST_ORDER', 'OR-');
    INSERT INTO dst_order (company_id, doc_no, doc_date, rep_id, shop_id, visit_id, delivery_date, status_code, notes)
    VALUES (company, l_no, TRUNC(SYSDATE), l_r.id, l_s.id, l_v, l_dd, 'SUBMITTED', l_nt)
    RETURNING id INTO l_id;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (i NUMBER PATH '$.i', q NUMBER PATH '$.q', p NUMBER PATH '$.p'))) LOOP
      CONTINUE WHEN r.i IS NULL OR NVL(r.q, 0) <= 0;
      l_p := r.p; l_inc := CASE WHEN r.p IS NOT NULL THEN 'Y' END; l_tc := NULL;
      NOONA_SAL_PKG.price_line(r.i, r.q, l_p, 0, l_inc, l_tc, TRUNC(SYSDATE), l_net, l_tx);
      INSERT INTO dst_order_line (company_id, order_id, item_id, quantity, unit_price, amount)
      VALUES (company, l_id, r.i, r.q, l_p, ROUND(l_net + l_tx, 2));
      l_tot := l_tot + ROUND(l_net + l_tx, 2);
    END LOOP;
    NOONA_CORE_PKG.assert(l_tot > 0, 'NOONA-DST-054', 'أضف الأصناف والكميات', 'Add items');
    UPDATE dst_order SET total_amount = l_tot WHERE id = l_id;
    RETURN l_id;
  END place_order;

  FUNCTION deliver_order(p_order_id IN NUMBER, p_warehouse_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_or  dst_order%ROWTYPE;
    l_s   dst_shop%ROWTYPE;
    l_inv JSON_OBJECT_T := JSON_OBJECT_T();
    l_ln  JSON_ARRAY_T := JSON_ARRAY_T();
    l_x   JSON_OBJECT_T;
    l_id  NUMBER;
  BEGIN
    guard('DST_ORDER.UPDATE');
    SELECT * INTO l_or FROM dst_order WHERE id = p_order_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_or.status_code IN ('SUBMITTED', 'APPROVED'), 'NOONA-DST-080', 'الأمر مفوتر أو ملغى', 'Order closed');
    l_s := shop_row(l_or.shop_id);
    FOR r IN (SELECT item_id, quantity, unit_price FROM dst_order_line WHERE order_id = p_order_id ORDER BY id) LOOP
      l_x := JSON_OBJECT_T(); l_x.put('i', r.item_id); l_x.put('q', r.quantity); l_x.put('p', r.unit_price); l_ln.append(l_x);
    END LOOP;
    l_inv.put('cust', l_s.customer_account_id);
    l_inv.put('date', TO_CHAR(SYSDATE, 'YYYY-MM-DD'));
    l_inv.put('wh', NVL(p_warehouse_id, NOONA_INV_PKG.default_warehouse));
    l_inv.put('mode', 'CREDIT');
    l_inv.put('notes', 'تسليم أمر التوريد ' || l_or.doc_no);
    l_inv.put('action', 'POST');
    l_inv.put('lines', l_ln);
    l_id := NOONA_SAL_PKG.save_invoice(l_inv.to_clob);
    UPDATE dst_order SET status_code = 'INVOICED', sales_invoice_id = l_id WHERE id = p_order_id;
    UPDATE dst_shop SET last_sale_at = SYSTIMESTAMP WHERE id = l_s.id;
    RETURN l_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-DST-081', 'أمر التوريد غير موجود', 'Order not found');
  END deliver_order;

  PROCEDURE cancel_order(p_order_id IN NUMBER, p_reason IN VARCHAR2) IS
  BEGIN
    guard('DST_ORDER.UPDATE');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-DST-082', 'سبب الإلغاء مطلوب', 'Reason required');
    UPDATE dst_order SET status_code = 'CANCELLED', notes = SUBSTR(NVL2(notes, notes || ' | ', '') || 'إلغاء: ' || p_reason, 1, 4000)
     WHERE id = p_order_id AND company_id = company AND status_code IN ('SUBMITTED', 'APPROVED');
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-DST-080', 'الأمر مفوتر أو ملغى', 'Order closed');
  END cancel_order;

  PROCEDURE close_visit(p_visit_id IN NUMBER, p_no_sale_reason IN VARCHAR2 DEFAULT NULL, p_notes IN VARCHAR2 DEFAULT NULL) IS
    l_v   dst_visit%ROWTYPE;
    l_ord NUMBER;
    l_out VARCHAR2(30);
  BEGIN
    guard('DST_VISIT.UPDATE');
    l_v := visit_row(p_visit_id, TRUE);
    NOONA_CORE_PKG.assert(l_v.status_code = 'OPEN', 'NOONA-DST-052', 'الزيارة منتهية', 'Visit is closed');
    SELECT COUNT(*) INTO l_ord FROM dst_order WHERE visit_id = p_visit_id AND status_code <> 'CANCELLED';
    l_out := CASE
      WHEN l_v.sales_amount > 0 AND l_v.collected_amount > 0 AND l_v.collected_amount > l_v.sales_amount THEN 'MIXED'
      WHEN l_v.sales_amount > 0 THEN 'SALE'
      WHEN l_ord > 0 THEN 'ORDER'
      WHEN l_v.collected_amount > 0 THEN 'COLLECTION'
      WHEN l_v.returns_amount > 0 THEN 'RETURN'
      ELSE 'NO_SALE' END;
    NOONA_CORE_PKG.assert(l_out <> 'NO_SALE' OR p_no_sale_reason IS NOT NULL, 'NOONA-DST-057',
      'اختر سبب عدم الشراء', 'No-sale reason required');
    NOONA_CORE_PKG.assert(p_no_sale_reason IS NULL OR p_no_sale_reason IN ('CLOSED', 'STOCKED', 'NO_CASH', 'OWNER_ABSENT', 'COMPETITOR', 'PRICE', 'OTHER'),
      'NOONA-DST-058', 'سبب غير صحيح', 'Invalid reason');
    UPDATE dst_visit SET status_code = 'CLOSED', checkout_at = SYSTIMESTAMP, outcome = l_out,
           no_sale_reason = CASE WHEN l_out = 'NO_SALE' THEN p_no_sale_reason END, notes = NVL(p_notes, notes)
     WHERE id = p_visit_id;
  END close_visit;

  -- ================================================================ نهاية اليوم
  FUNCTION day_totals(p_rep NUMBER, p_date DATE, p_planned OUT NUMBER, p_done OUT NUMBER, p_sales OUT NUMBER, p_credit OUT NUMBER,
                      p_returns OUT NUMBER, p_cash OUT NUMBER, p_trans OUT NUMBER, p_cheq OUT NUMBER, p_cards OUT NUMBER) RETURN NUMBER IS
    l_day VARCHAR2(3) := day_code(p_date);
  BEGIN
    SELECT COUNT(*) INTO p_planned FROM dst_shop s JOIN dst_route r ON r.id = s.route_id
     WHERE s.company_id = company AND s.status_code = 'ACTIVE' AND r.rep_id = p_rep AND r.status_code = 'ACTIVE'
       AND INSTR(',' || NVL(s.visit_days, r.visit_days) || ',', ',' || l_day || ',') > 0;
    SELECT COUNT(DISTINCT shop_id), NVL(SUM(sales_amount), 0), NVL(SUM(returns_amount), 0)
      INTO p_done, p_sales, p_returns FROM dst_visit WHERE rep_id = p_rep AND doc_date = p_date AND status_code = 'CLOSED';
    SELECT NVL(SUM(CASE WHEN payment_method = 'CASH' AND status_code = 'POSTED' THEN amount END), 0),
           NVL(SUM(CASE WHEN payment_method = 'BANK_TRANSFER' AND status_code <> 'REJECTED' THEN amount END), 0),
           NVL(SUM(CASE WHEN payment_method = 'CHEQUE' AND status_code <> 'REJECTED' THEN amount END), 0),
           NVL(SUM(CASE WHEN payment_method IN ('CARD', 'WALLET') AND status_code = 'POSTED' THEN amount END), 0)
      INTO p_cash, p_trans, p_cheq, p_cards
      FROM dst_collection WHERE rep_id = p_rep AND doc_date = p_date AND settlement_id IS NULL;
    p_credit := GREATEST(p_sales - p_cash - p_trans - p_cheq - p_cards, 0);
    RETURN p_cash;
  END day_totals;

  FUNCTION settlement_preview_html(p_rep_id IN NUMBER, p_date IN DATE) RETURN CLOB IS
    l_pl NUMBER; l_dn NUMBER; l_sa NUMBER; l_cr NUMBER; l_rt NUMBER; l_ca NUMBER; l_tr NUMBER; l_ch NUMBER; l_cd NUMBER; l_x NUMBER;
  BEGIN
    IF p_rep_id IS NULL THEN RETURN NULL; END IF;
    l_x := day_totals(p_rep_id, NVL(p_date, TRUNC(SYSDATE)), l_pl, l_dn, l_sa, l_cr, l_rt, l_ca, l_tr, l_ch, l_cd);
    RETURN '<div class="nn-kpis"><div class="nn-kpi"><span>الزيارات</span><b>' || l_dn || ' / ' || l_pl || '</b></div>'
        || '<div class="nn-kpi"><span>المبيعات</span><b>' || fmt(l_sa) || '</b></div>'
        || '<div class="nn-kpi"><span>منها آجل</span><b>' || fmt(l_cr) || '</b></div>'
        || '<div class="nn-kpi"><span>المرتجعات</span><b>' || fmt(l_rt) || '</b></div>'
        || '<div class="nn-kpi"><span>النقد المطلوب تسليمه</span><b>' || fmt(l_ca) || '</b></div>'
        || '<div class="nn-kpi"><span>إشعارات التحويل</span><b>' || fmt(l_tr) || '</b></div>'
        || '<div class="nn-kpi"><span>الشيكات</span><b>' || fmt(l_ch) || '</b></div>'
        || '<div class="nn-kpi"><span>الشبكة والمحافظ</span><b>' || fmt(l_cd) || '</b></div></div>';
  END settlement_preview_html;

  FUNCTION settle_day(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_r   dst_rep%ROWTYPE;
    l_dt  DATE := NVL(jd(l_o, 'date'), TRUNC(SYSDATE));
    l_cnt NUMBER := NVL(ROUND(jn(l_o, 'counted'), 2), 0);
    l_box NUMBER := jn(l_o, 'box');
    l_pl NUMBER; l_dn NUMBER; l_sa NUMBER; l_cr NUMBER; l_rt NUMBER; l_ca NUMBER; l_tr NUMBER; l_ch NUMBER; l_cd NUMBER; l_x NUMBER;
    l_id  NUMBER;
    l_no  VARCHAR2(50);
    l_ra  NUMBER;
    l_ba  NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_nt  VARCHAR2(4000) := js(l_o, 'notes');
    l_ev  NUMBER;
  BEGIN
    guard('DST_SETTLEMENT.CREATE');
    l_r := rep_row(NVL(jn(l_o, 'rep'), my_rep));
    SELECT COUNT(*) INTO l_x FROM dst_visit WHERE rep_id = l_r.id AND status_code = 'OPEN';
    NOONA_CORE_PKG.assert(l_x = 0, 'NOONA-DST-090', 'أنهِ الزيارة الجارية قبل تسوية اليوم', 'Close the open visit first');
    l_x := day_totals(l_r.id, l_dt, l_pl, l_dn, l_sa, l_cr, l_rt, l_ca, l_tr, l_ch, l_cd);
    NOONA_CORE_PKG.assert(l_cnt >= 0, 'NOONA-DST-091', 'النقد المسلم لا يكون سالباً', 'Counted cash must not be negative');
    IF l_box IS NULL THEN
      SELECT MIN(id) INTO l_box FROM csh_cash_box WHERE company_id = company AND status_code = 'ACTIVE' AND box_type = 'MAIN';
    END IF;
    NOONA_CORE_PKG.assert(l_cnt = 0 OR (l_box IS NOT NULL AND l_box <> l_r.cash_box_id), 'NOONA-DST-092',
      'اختر صندوق الشركة المستلم للنقد', 'Deposit box required');
    l_no := next_no('DST_SETTLEMENT', 'ST-');
    INSERT INTO dst_settlement (company_id, doc_no, doc_date, rep_id, settle_date, visits_planned, visits_done, sales_amount, credit_sales,
                                returns_amount, cash_expected, cash_counted, cash_diff, transfers_amount, cheques_amount, cards_amount,
                                deposit_box_id, status_code, notes)
    VALUES (company, l_no, TRUNC(SYSDATE), l_r.id, l_dt, l_pl, l_dn, l_sa, l_cr, l_rt, l_ca, l_cnt, l_cnt - l_ca, l_tr, l_ch, l_cd,
            l_box, 'SUBMITTED', l_nt)
    RETURNING id INTO l_id;
    UPDATE dst_collection SET settlement_id = l_id WHERE rep_id = l_r.id AND doc_date = l_dt AND settlement_id IS NULL;
    -- توريد النقد المسلم من عهدة المندوب إلى صندوق الشركة (والعجز يبقى في عهدته)
    IF l_cnt > 0 THEN
      l_ra := NOONA_CSH_PKG.place_account('BOX:' || l_r.cash_box_id);
      l_ba := NOONA_CSH_PKG.place_account('BOX:' || l_box);
      -- قيد التوريد (ولو كان الصندوقان على الحساب نفسه) لتظهر الحركتان في رصيد كل صندوق
      BEGIN
        l_lines.EXTEND(2);
        l_lines(1).account_id := l_ba; l_lines(1).debit := l_cnt; l_lines(1).credit := 0; l_lines(1).description := 'توريد عهدة ' || l_r.full_name;
        l_lines(2).account_id := l_ra; l_lines(2).debit := 0; l_lines(2).credit := l_cnt; l_lines(2).description := 'توريد عهدة ' || l_r.full_name;
        l_x := NOONA_ACE_PKG.post_source('CSH_TXN_SETTLED', 'CASH', 'DST_SETTLEMENT', l_id, l_dt, 'توريد نقدية المندوب ' || l_no,
                                         NOONA_GL_PKG.ledger_currency, 1, l_lines, l_no, NULL);
        SELECT MAX(id) INTO l_x FROM ace_accounting_event WHERE journal_id = l_x;
      END;
      l_ev := l_x;
      l_x := NOONA_CSH_PKG.record_settlement('PAYMENT', 'BOX:' || l_r.cash_box_id, l_dt, l_cnt, NULL, l_r.full_name, 'DST_SETTLEMENT', l_id,
                                             l_no || '-O', 'توريد نقدية المندوب', l_ev, 'CASH');
      l_x := NOONA_CSH_PKG.record_settlement('RECEIPT', 'BOX:' || l_box, l_dt, l_cnt, NULL, l_r.full_name, 'DST_SETTLEMENT', l_id,
                                             l_no || '-I', 'توريد نقدية المندوب ' || l_r.full_name, l_ev, 'CASH');
    END IF;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-DST-093', 'سويت هذا اليوم للمندوب مسبقاً', 'Day already settled');
  END settle_day;

  PROCEDURE approve_settlement(p_id IN NUMBER) IS
  BEGIN
    guard('DST_SETTLEMENT.UPDATE');
    UPDATE dst_settlement SET status_code = 'APPROVED', approved_by = NOONA_CTX_PKG.current_user_name, approved_at = SYSTIMESTAMP
     WHERE id = p_id AND company_id = company AND status_code = 'SUBMITTED';
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-DST-094', 'التسوية معتمدة أو غير موجودة', 'Settlement not pending');
  END approve_settlement;

  FUNCTION calc_commissions(p_month IN DATE) RETURN NUMBER IS
    l_f DATE := TRUNC(NVL(p_month, SYSDATE), 'MM');
    l_t DATE := ADD_MONTHS(TRUNC(NVL(p_month, SYSDATE), 'MM'), 1);
    l_n NUMBER := 0;
    l_base NUMBER; l_vis NUMBER; l_sales NUMBER; l_amt NUMBER;
  BEGIN
    guard('DST_COMMISSION.CREATE');
    FOR r IN (SELECT * FROM dst_rep WHERE company_id = company AND status_code = 'ACTIVE') LOOP
      SELECT NVL(SUM(sales_amount - returns_amount), 0), COUNT(*) INTO l_sales, l_vis FROM dst_visit
       WHERE rep_id = r.id AND status_code = 'CLOSED' AND doc_date >= l_f AND doc_date < l_t;
      SELECT NVL(SUM(amount), 0) INTO l_base FROM dst_collection
       WHERE rep_id = r.id AND status_code = 'POSTED' AND doc_date >= l_f AND doc_date < l_t;
      l_base := CASE r.commission_basis WHEN 'SALES' THEN l_sales WHEN 'COLLECTION' THEN l_base ELSE 0 END;
      l_amt := ROUND(CASE r.commission_basis WHEN 'VISIT' THEN l_vis * NVL(r.commission_per_visit, 0)
                                             WHEN 'NONE' THEN 0 ELSE l_base * NVL(r.commission_rate, 0) / 100 END, 2);
      MERGE INTO dst_commission c
      USING (SELECT r.id rep_id FROM dual) x ON (c.company_id = company AND c.rep_id = x.rep_id AND c.period_start = l_f)
       WHEN MATCHED THEN UPDATE SET basis = r.commission_basis, base_amount = l_base, visits_count = l_vis, target_amount = r.monthly_target,
                                    achievement_pct = CASE WHEN r.monthly_target > 0 THEN ROUND(l_sales * 100 / r.monthly_target, 1) END,
                                    commission_amount = l_amt
                         WHERE c.status_code = 'CALCULATED'
       WHEN NOT MATCHED THEN INSERT (company_id, rep_id, period_start, basis, base_amount, visits_count, target_amount, achievement_pct,
                                     commission_amount, status_code)
            VALUES (company, r.id, l_f, r.commission_basis, l_base, l_vis, r.monthly_target,
                    CASE WHEN r.monthly_target > 0 THEN ROUND(l_sales * 100 / r.monthly_target, 1) END, l_amt, 'CALCULATED');
      l_n := l_n + 1;
    END LOOP;
    RETURN l_n;
  END calc_commissions;

  -- ================================================================ واتساب
  FUNCTION whatsapp_url(p_phone IN VARCHAR2, p_text IN VARCHAR2) RETURN VARCHAR2 IS
    l_d  VARCHAR2(40) := REGEXP_REPLACE(p_phone, '[^0-9]', '');
    l_cc VARCHAR2(5);
  BEGIN
    IF l_d IS NULL THEN RETURN NULL; END IF;
    IF l_d LIKE '00%' THEN
      l_d := SUBSTR(l_d, 3);
    ELSIF l_d LIKE '0%' THEN
      SELECT MAX(CASE country_code WHEN 'SA' THEN '966' WHEN 'AE' THEN '971' WHEN 'BH' THEN '973' WHEN 'OM' THEN '968' WHEN 'QA' THEN '974'
                                   WHEN 'KW' THEN '965' WHEN 'EG' THEN '20' WHEN 'SD' THEN '249' WHEN 'JO' THEN '962' END)
        INTO l_cc FROM org_company WHERE id = company;
      l_d := NVL(l_cc, '966') || SUBSTR(l_d, 2);
    END IF;
    RETURN 'https://wa.me/' || l_d || '?text=' || UTL_URL.ESCAPE(p_text, TRUE, 'AL32UTF8');
  END whatsapp_url;

  FUNCTION statement_text(p_shop_id IN NUMBER) RETURN VARCHAR2 IS
    l_s dst_shop%ROWTYPE := shop_row(p_shop_id);
    l_t VARCHAR2(2000);
  BEGIN
    l_t := 'السلام عليكم ' || NVL(l_s.owner_name, NOONA_SAL_PKG.customer_label(l_s.customer_account_id)) || chr(10)
        || 'رصيد حسابكم لدى ' || NOONA_SAL_PKG.seller_name || ' حتى ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ': '
        || fmt(NOONA_SAL_PKG.customer_balance(l_s.customer_account_id)) || ' ريال.' || chr(10) || 'آخر الفواتير:';
    FOR r IN (SELECT * FROM (SELECT doc_no, doc_date, total_amount FROM sal_invoice
                              WHERE customer_account_id = l_s.customer_account_id AND status_code IN ('POSTED', 'ISSUED', 'PAID', 'PARTIALLY_PAID')
                              ORDER BY doc_date DESC, id DESC) WHERE ROWNUM <= 5) LOOP
      l_t := l_t || chr(10) || '• ' || r.doc_no || ' (' || TO_CHAR(r.doc_date, 'YYYY-MM-DD') || '): ' || fmt(r.total_amount);
    END LOOP;
    RETURN l_t || chr(10) || 'شكراً لتعاملكم معنا.';
  END statement_text;

  FUNCTION invoice_text(p_invoice_id IN NUMBER) RETURN VARCHAR2 IS
    l_t VARCHAR2(2000);
  BEGIN
    FOR i IN (SELECT doc_no, doc_date, total_amount, tax_amount, customer_account_id FROM sal_invoice WHERE id = p_invoice_id AND company_id = company) LOOP
      l_t := 'فاتورة ' || i.doc_no || ' بتاريخ ' || TO_CHAR(i.doc_date, 'YYYY-MM-DD') || ' من ' || NOONA_SAL_PKG.seller_name || chr(10);
      FOR l IN (SELECT description, quantity, net_amount + tax_amount amt FROM sal_invoice_line WHERE invoice_id = p_invoice_id ORDER BY line_no) LOOP
        l_t := l_t || '• ' || l.description || ' × ' || qf(l.quantity) || ' = ' || fmt(l.amt) || chr(10);
      END LOOP;
      l_t := l_t || 'الإجمالي شامل الضريبة: ' || fmt(i.total_amount) || ' ريال (الضريبة ' || fmt(i.tax_amount) || ')' || chr(10)
          || 'رصيدكم الحالي: ' || fmt(NOONA_SAL_PKG.customer_balance(i.customer_account_id)) || ' ريال';
    END LOOP;
    RETURN l_t;
  END invoice_text;

  -- ================================================================ الواجهة والتقارير
  FUNCTION shop_card_html(p_shop_id IN NUMBER) RETURN CLOB IS
    l_s   dst_shop%ROWTYPE;
    l_h   CLOB;
    l_bal NUMBER;
    l_wa  VARCHAR2(4000);
  BEGIN
    IF p_shop_id IS NULL THEN RETURN NULL; END IF;
    l_s := shop_row(p_shop_id);
    l_bal := NOONA_SAL_PKG.customer_balance(l_s.customer_account_id);
    l_wa := whatsapp_url(NVL(l_s.whatsapp, l_s.phone), statement_text(p_shop_id));
    l_h := '<div class="nn-dst-card"><div class="nn-dst-card-h"><b>' || esc(NOONA_SAL_PKG.customer_label(l_s.customer_account_id)) || '</b> '
        || badge(l_s.status_code) || '<small>' || esc(label(l_s.shop_type)) || CASE WHEN l_s.owner_name IS NOT NULL THEN ' · ' || esc(l_s.owner_name) END
        || '</small></div><div class="nn-kpis"><div class="nn-kpi"><span>الرصيد المستحق</span><b>' || fmt(l_bal) || '</b></div>'
        || '<div class="nn-kpi"><span>الحد الائتماني</span><b>' || NVL(fmt(NOONA_SAL_PKG.credit_limit(l_s.customer_account_id)), 'مفتوح') || '</b></div>'
        || '<div class="nn-kpi"><span>آخر شراء</span><b>' || NVL(TO_CHAR(l_s.last_sale_at, 'YYYY-MM-DD'), '—') || '</b></div></div>'
        || '<div class="nn-dst-actions">'
        || CASE WHEN l_s.latitude IS NOT NULL THEN '<a class="nn-dst-btn" target="_blank" rel="noopener" href="https://www.google.com/maps/dir/?api=1&destination='
             || TO_CHAR(l_s.latitude, 'FM990.0000000') || ',' || TO_CHAR(l_s.longitude, 'FM990.0000000') || '"><span class="fa fa-location-arrow"></span> الطريق</a>'
             ELSE '<span class="nn-badge is-warning">الموقع غير محفوظ: يحفظ عند تسجيل الوصول</span>' END
        || CASE WHEN l_s.phone IS NOT NULL THEN '<a class="nn-dst-btn" href="tel:' || esc(l_s.phone) || '"><span class="fa fa-phone"></span> اتصال</a>' END
        || CASE WHEN l_wa IS NOT NULL THEN '<a class="nn-dst-btn nn-dst-wa" target="_blank" rel="noopener" href="' || esc(l_wa)
             || '"><span class="fa fa-whatsapp"></span> كشف الحساب واتساب</a>' END
        || '</div>';
    FOR r IN (SELECT * FROM (SELECT v.doc_date, v.outcome, v.sales_amount, v.collected_amount, rp.full_name
                               FROM dst_visit v JOIN dst_rep rp ON rp.id = v.rep_id
                              WHERE v.shop_id = p_shop_id AND v.status_code = 'CLOSED' ORDER BY v.id DESC) WHERE ROWNUM <= 5) LOOP
      l_h := l_h || '<div class="nn-dst-hist">' || TO_CHAR(r.doc_date, 'YYYY-MM-DD') || ' ' || badge(r.outcome) || ' بيع ' || fmt(r.sales_amount)
          || ' · تحصيل ' || fmt(r.collected_amount) || ' · ' || esc(r.full_name) || '</div>';
    END LOOP;
    RETURN l_h || '</div>';
  END shop_card_html;

  FUNCTION visit_html(p_visit_id IN NUMBER) RETURN CLOB IS
    l_v  dst_visit%ROWTYPE;
    l_h  CLOB;
    l_s  dst_shop%ROWTYPE;
    l_wa VARCHAR2(4000);
  BEGIN
    IF p_visit_id IS NULL THEN RETURN NULL; END IF;
    l_v := visit_row(p_visit_id);
    l_s := shop_row(l_v.shop_id);
    l_h := '<div class="nn-kpis"><div class="nn-kpi"><span>' || esc(l_v.doc_no) || '</span><b>' || badge(NVL(l_v.outcome, l_v.status_code)) || '</b></div>'
        || '<div class="nn-kpi"><span>المبيعات</span><b>' || fmt(l_v.sales_amount) || '</b></div>'
        || '<div class="nn-kpi"><span>المحصل</span><b>' || fmt(l_v.collected_amount) || '</b></div>'
        || '<div class="nn-kpi"><span>المرتجعات</span><b>' || fmt(l_v.returns_amount) || '</b></div>'
        || '<div class="nn-kpi"><span>البعد عن المحل</span><b>' || CASE WHEN l_v.distance_m IS NULL THEN '—'
             WHEN l_v.distance_m > 300 THEN '<span class="nn-badge is-danger">' || l_v.distance_m || ' م</span>' ELSE l_v.distance_m || ' م' END
        || '</b></div></div>';
    IF l_v.sales_invoice_id IS NOT NULL THEN
      l_wa := whatsapp_url(NVL(l_s.whatsapp, l_s.phone), invoice_text(l_v.sales_invoice_id));
      IF l_wa IS NOT NULL THEN
        l_h := l_h || '<a class="nn-dst-btn nn-dst-wa" target="_blank" rel="noopener" href="' || esc(l_wa)
            || '"><span class="fa fa-whatsapp"></span> إرسال الفاتورة للمحل واتساب</a>';
      END IF;
    END IF;
    FOR c IN (SELECT doc_no, amount, payment_method, reference_no, status_code FROM dst_collection WHERE visit_id = p_visit_id ORDER BY id) LOOP
      l_h := l_h || '<div class="nn-dst-hist">' || esc(c.doc_no) || ' · ' || esc(label(c.payment_method)) || ' ' || fmt(c.amount)
          || CASE WHEN c.reference_no IS NOT NULL THEN ' · مرجع ' || esc(c.reference_no) END || ' ' || badge(c.status_code) || '</div>';
    END LOOP;
    RETURN l_h;
  END visit_html;

  FUNCTION rep_day_html(p_rep_id IN NUMBER, p_date IN DATE) RETURN CLOB IS
    l_h CLOB;
  BEGIN
    FOR v IN (SELECT v.doc_no, v.checkin_at, v.checkout_at, v.outcome, v.no_sale_reason, v.sales_amount, v.collected_amount, v.distance_m,
                     NOONA_SAL_PKG.customer_label(s.customer_account_id) nm
                FROM dst_visit v JOIN dst_shop s ON s.id = v.shop_id
               WHERE v.rep_id = p_rep_id AND v.doc_date = NVL(p_date, TRUNC(SYSDATE)) ORDER BY v.checkin_at) LOOP
      l_h := l_h || '<tr><td>' || TO_CHAR(v.checkin_at, 'HH24:MI') || '</td><td>' || esc(v.nm) || '</td><td>' || badge(NVL(v.outcome, 'OPEN'))
          || CASE WHEN v.no_sale_reason IS NOT NULL THEN ' ' || esc(label(v.no_sale_reason)) END || '</td><td class="u-tE">' || fmt(v.sales_amount)
          || '</td><td class="u-tE">' || fmt(v.collected_amount) || '</td><td class="u-tE">' || NVL(TO_CHAR(v.distance_m), '—') || '</td><td>'
          || NVL(TO_CHAR(ROUND((CAST(v.checkout_at AS DATE) - CAST(v.checkin_at AS DATE)) * 1440)), '—') || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_h IS NULL THEN '<p class="nn-hint">لا زيارات.</p>'
           ELSE '<table class="nn-table"><thead><tr><th>الوصول</th><th>المحل</th><th>النتيجة</th><th>المبيعات</th><th>المحصل</th>'
             || '<th>البعد (م)</th><th>المدة (د)</th></tr></thead><tbody>' || l_h || '</tbody></table>' END;
  END rep_day_html;

  FUNCTION performance_html(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_h CLOB;
    l_f DATE := NVL(p_from, TRUNC(SYSDATE, 'MM'));
    l_t DATE := NVL(p_to, TRUNC(SYSDATE));
  BEGIN
    FOR r IN (SELECT rp.full_name, rp.monthly_target,
                     COUNT(v.id) visits, SUM(CASE WHEN v.outcome IN ('SALE', 'MIXED', 'ORDER') THEN 1 ELSE 0 END) productive,
                     SUM(CASE WHEN v.outcome = 'NO_SALE' THEN 1 ELSE 0 END) nosale,
                     NVL(SUM(v.sales_amount), 0) sales, NVL(SUM(v.returns_amount), 0) rets,
                     SUM(CASE WHEN v.distance_m > 300 THEN 1 ELSE 0 END) far,
                     (SELECT NVL(SUM(c.amount), 0) FROM dst_collection c WHERE c.rep_id = rp.id AND c.status_code = 'POSTED'
                         AND c.doc_date BETWEEN l_f AND l_t) coll,
                     (SELECT NVL(SUM(s.cash_diff), 0) FROM dst_settlement s WHERE s.rep_id = rp.id AND s.settle_date BETWEEN l_f AND l_t) diff
                FROM dst_rep rp LEFT JOIN dst_visit v ON v.rep_id = rp.id AND v.status_code = 'CLOSED' AND v.doc_date BETWEEN l_f AND l_t
               WHERE rp.company_id = company
               GROUP BY rp.id, rp.full_name, rp.monthly_target
               ORDER BY NVL(SUM(v.sales_amount), 0) DESC) LOOP
      l_h := l_h || '<tr><td><b>' || esc(r.full_name) || '</b></td><td class="u-tE">' || r.visits || '</td><td class="u-tE">'
          || CASE WHEN r.visits > 0 THEN ROUND(r.productive * 100 / r.visits) || '%' ELSE '-' END || '</td><td class="u-tE">' || r.nosale
          || '</td><td class="u-tE">' || fmt(r.sales) || '</td><td class="u-tE">' || fmt(r.rets) || '</td><td class="u-tE">' || fmt(r.coll)
          || '</td><td class="u-tE">' || CASE WHEN r.monthly_target > 0 THEN ROUND(r.sales * 100 / r.monthly_target) || '%' ELSE '-' END
          || '</td><td class="u-tE">' || CASE WHEN r.far > 0 THEN '<span class="nn-badge is-warning">' || r.far || '</span>' ELSE '0' END
          || '</td><td class="u-tE">' || CASE WHEN r.diff < 0 THEN '<span class="nn-badge is-danger">' || fmt(r.diff) || '</span>' ELSE fmt(r.diff) END
          || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_h IS NULL THEN '<p class="nn-hint">لا مندوبين.</p>'
           ELSE '<table class="nn-table"><thead><tr><th>المندوب</th><th>الزيارات</th><th>الزيارات المنتجة</th><th>لا شراء</th><th>المبيعات</th>'
             || '<th>المرتجعات</th><th>التحصيل</th><th>تحقيق الهدف</th><th>زيارات بعيدة عن المحل</th><th>عجز/زيادة النقد</th></tr></thead><tbody>'
             || l_h || '</tbody></table><p class="nn-hint">الزيارة البعيدة: تسجيل الوصول على بعد أكثر من 300 متر من موقع المحل المحفوظ.</p>' END;
  END performance_html;

  FUNCTION idle_shops_html(p_days IN NUMBER DEFAULT 14) RETURN CLOB IS
    l_h CLOB;
  BEGIN
    FOR s IN (SELECT NOONA_SAL_PKG.customer_label(s.customer_account_id) nm, r.name_ar route_name, s.last_sale_at, s.last_visit_at, s.phone,
                     NOONA_SAL_PKG.customer_balance(s.customer_account_id) bal
                FROM dst_shop s LEFT JOIN dst_route r ON r.id = s.route_id
               WHERE s.company_id = company AND s.status_code = 'ACTIVE'
                 AND (s.last_sale_at IS NULL OR s.last_sale_at < SYSTIMESTAMP - NUMTODSINTERVAL(NVL(p_days, 14), 'DAY'))
               ORDER BY s.last_sale_at NULLS FIRST) LOOP
      l_h := l_h || '<tr><td>' || esc(s.nm) || '</td><td>' || esc(s.route_name) || '</td><td>' || NVL(TO_CHAR(s.last_sale_at, 'YYYY-MM-DD'), 'لم يشتر بعد')
          || '</td><td>' || NVL(TO_CHAR(s.last_visit_at, 'YYYY-MM-DD'), '—') || '</td><td class="u-tE">' || fmt(s.bal) || '</td><td>' || esc(s.phone) || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_h IS NULL THEN '<p class="nn-hint">كل المحلات اشترت خلال ' || NVL(p_days, 14) || ' يوماً.</p>'
           ELSE '<table class="nn-table"><thead><tr><th>المحل</th><th>الخط</th><th>آخر شراء</th><th>آخر زيارة</th><th>الرصيد</th><th>الجوال</th>'
             || '</tr></thead><tbody>' || l_h || '</tbody></table>' END;
  END idle_shops_html;

  FUNCTION shops_geo_json(p_route_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l CLOB;
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE s.id, 'n' VALUE NOONA_SAL_PKG.customer_label(s.customer_account_id),
                                     'lat' VALUE s.latitude, 'lng' VALUE s.longitude, 'r' VALUE r.name_ar,
                                     's' VALUE CASE WHEN s.last_sale_at > SYSTIMESTAMP - INTERVAL '14' DAY THEN 'A' ELSE 'I' END)
                         RETURNING CLOB)
      INTO l FROM dst_shop s LEFT JOIN dst_route r ON r.id = s.route_id
     WHERE s.company_id = company AND s.status_code = 'ACTIVE' AND s.latitude IS NOT NULL
       AND (p_route_id IS NULL OR s.route_id = p_route_id);
    RETURN NVL(l, '[]');
  END shops_geo_json;

END NOONA_DST_PKG;
/
