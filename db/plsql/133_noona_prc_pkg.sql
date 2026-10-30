-- =============================================================================
-- NOONA PLUS ERP | NOONA_PRC_PKG - التسعير الموحد لكل الموديولات
--   * التكلفة: الصنف بالمتوسط المرجح أو آخر شراء أو المعيارية؛ والخدمة (طبية أو سيارات) ببطاقة تكلفة =
--     موادها المعرفة في موديولها + عناصر إضافية (مواد، عمالة بالدقائق × تكلفة الساعة، أعباء ثابتة أو نسبة)
--   * سياسات سعر البيع لصنف أو فئة أو خدمة أو نوع خدمة أو الكل: نسبة على التكلفة (Markup)، هامش من سعر البيع
--     (Margin)، مبلغ ثابت فوق التكلفة، أو معامل؛ مع أدنى هامش (أدنى سعر بيع) والتقريب (0.05، 0.25، 0.5، 1، 5، 10، .99)
--   * إعادة التسعير: تشغيل يقترح الأسعار الجديدة مقابل الحالية والهامش، يراجع ثم يطبق، وسجل لكل تغيير سعر
--   * العروض والتخفيضات: نسبة، مبلغ، سعر خاص، اشتر X واحصل على Y، خصم على قيمة الفاتورة؛ بالفترة وأيام الأسبوع
--     والساعات والقنوات والفرع والكوبون وأقصى خصم، لأصناف أو فئات أو خدمات أو أنواع خدمات
--   * الباقات: مجموعة أصناف و/أو خدمات بسعر ثابت أو بنسبة أو مبلغ خصم من مجموعها، يوزع سعرها على مكوناتها
--   * محرك واحد تستدعيه نقاط البيع والمبيعات والمستشفيات وخدمة السيارات: السعر، أفضل عرض، الباقة
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_PRC_PKG AUTHID DEFINER AS
  FUNCTION company RETURN NUMBER;
  FUNCTION target_name(p_type IN VARCHAR2, p_id IN NUMBER) RETURN VARCHAR2;

  -- ---------------------------------------------------------------- التكلفة
  -- p_basis: AVERAGE, LAST_PURCHASE, STANDARD, COST_SHEET (فارغ = AVERAGE للصنف و COST_SHEET للخدمة)
  FUNCTION cost_of(p_type IN VARCHAR2, p_id IN NUMBER, p_basis IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  FUNCTION service_cost(p_type IN VARCHAR2, p_id IN NUMBER) RETURN NUMBER;
  FUNCTION cost_html(p_type IN VARCHAR2, p_id IN NUMBER) RETURN CLOB;
  FUNCTION save_cost_element(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE delete_cost_element(p_id IN NUMBER);

  -- ---------------------------------------------------------------- سعر البيع من التكلفة
  FUNCTION round_price(p_price IN NUMBER, p_rounding IN VARCHAR2) RETURN NUMBER DETERMINISTIC;
  FUNCTION price_from_cost(p_cost IN NUMBER, p_method IN VARCHAR2, p_value IN NUMBER, p_rounding IN VARCHAR2 DEFAULT 'NONE')
    RETURN NUMBER DETERMINISTIC;
  FUNCTION current_price(p_type IN VARCHAR2, p_id IN NUMBER) RETURN NUMBER;
  FUNCTION policy_for(p_type IN VARCHAR2, p_id IN NUMBER) RETURN NUMBER;
  -- {cost, policyId, policy, price, minPrice, current, margin}
  FUNCTION suggest_json(p_type IN VARCHAR2, p_id IN NUMBER) RETURN CLOB;
  FUNCTION save_policy(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE set_policy_status(p_id IN NUMBER, p_status IN VARCHAR2);
  FUNCTION policy_text(p_id IN NUMBER) RETURN VARCHAR2;

  -- ---------------------------------------------------------------- إعادة التسعير
  FUNCTION new_run(p_scope IN VARCHAR2, p_only_changed IN VARCHAR2 DEFAULT 'Y') RETURN NUMBER;
  PROCEDURE set_run_line(p_line_id IN NUMBER, p_selected IN VARCHAR2, p_price IN NUMBER DEFAULT NULL);
  FUNCTION apply_run(p_run_id IN NUMBER) RETURN NUMBER;
  PROCEDURE cancel_run(p_run_id IN NUMBER);
  PROCEDURE set_price(p_type IN VARCHAR2, p_id IN NUMBER, p_price IN NUMBER, p_min_price IN NUMBER DEFAULT NULL);
  -- تقرير الهوامش: التكلفة والسعر والهامش، ومن تحت أدنى هامش سياسته
  FUNCTION margin_html(p_scope IN VARCHAR2 DEFAULT 'ALL') RETURN CLOB;

  -- ---------------------------------------------------------------- العروض
  -- {code, name, type, value, buyQty, getQty, minQty, minAmount, maxDiscount, channels, branchId, days, hourFrom, hourTo,
  --  coupon, priority, stackable, from, to, status, targets:[{type, id, code}]}
  FUNCTION save_promotion(p_doc IN CLOB, p_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
  PROCEDURE set_promotion_status(p_id IN NUMBER, p_status IN VARCHAR2);
  -- الهدف بصيغة النوع-المعرف (ITEM-5، ITEM_CATEGORY-3، ALL_ITEMS، HIS_SERVICE_TYPE-LAB ...) كما في قوائم الاختيار
  PROCEDURE add_promotion_target(p_promo IN NUMBER, p_target IN VARCHAR2);
  PROCEDURE remove_promotion_target(p_target_id IN NUMBER);
  FUNCTION target_label(p_type IN VARCHAR2, p_id IN NUMBER, p_code IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION promotion_text(p_id IN NUMBER) RETURN VARCHAR2;
  -- أفضل عرض للسطر: {promoId, name, discount (لإجمالي السطر), freeQty, net (إجمالي السطر بعد الخصم)} أو {} بلا عرض
  FUNCTION line_promo(p_type IN VARCHAR2, p_id IN NUMBER, p_qty IN NUMBER, p_unit_price IN NUMBER, p_channel IN VARCHAR2,
                      p_coupon IN VARCHAR2 DEFAULT NULL, p_at IN DATE DEFAULT NULL, p_branch IN NUMBER DEFAULT NULL) RETURN CLOB;
  FUNCTION line_discount(p_type IN VARCHAR2, p_id IN NUMBER, p_qty IN NUMBER, p_unit_price IN NUMBER, p_channel IN VARCHAR2,
                         p_coupon IN VARCHAR2 DEFAULT NULL, p_at IN DATE DEFAULT NULL, p_branch IN NUMBER DEFAULT NULL) RETURN NUMBER;
  -- عرض قيمة الفاتورة: {promoId, name, discount} أو {}
  FUNCTION doc_promo(p_channel IN VARCHAR2, p_total IN NUMBER, p_coupon IN VARCHAR2 DEFAULT NULL, p_at IN DATE DEFAULT NULL,
                     p_branch IN NUMBER DEFAULT NULL) RETURN CLOB;
  -- السعر والعرض معاً: {price, promoId, promo, discount, net}
  FUNCTION price_line(p_type IN VARCHAR2, p_id IN NUMBER, p_qty IN NUMBER, p_channel IN VARCHAR2,
                      p_coupon IN VARCHAR2 DEFAULT NULL, p_branch IN NUMBER DEFAULT NULL) RETURN CLOB;
  -- تسعير سلة كاملة: {"coupon":"..","lines":[{"k":0,"t":"ITEM","id":5,"q":2,"p":10,"man":"N"}]}
  --   ← {"lines":[{"k":0,"disc":2,"promo":"..."}],"doc":{"disc":30,"name":"..."},"lineDisc":2,"docDisc":30}
  --   السطر اليدوي (man=Y) أو سطر الباقة لا يأخذ عرضاً تلقائياً؛ عرض قيمة الفاتورة يحسب على الإجمالي بعد خصومات الأسطر
  FUNCTION quote_cart(p_doc IN CLOB, p_channel IN VARCHAR2) RETURN CLOB;
  -- العروض السارية الآن لقناة: [{id, name, text, coupon}]
  FUNCTION active_promotions_json(p_channel IN VARCHAR2) RETURN CLOB;

  -- ---------------------------------------------------------------- الباقات
  -- {code, name, desc, channels, method, value, incl, from, to, status, lines:[{type, id, qty}]}
  FUNCTION save_bundle(p_doc IN CLOB, p_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
  PROCEDURE set_bundle_status(p_id IN NUMBER, p_status IN VARCHAR2);
  PROCEDURE add_bundle_line(p_bundle IN NUMBER, p_target IN VARCHAR2, p_qty IN NUMBER DEFAULT 1);
  PROCEDURE remove_bundle_line(p_line_id IN NUMBER);
  FUNCTION bundle_text(p_id IN NUMBER) RETURN VARCHAR2;
  -- السعر = list_total ثم bundle_price والتوفير، والمكونات بسعر الوحدة الأصلي والموزع:
  -- {id, code, name, listTotal, price, saving, lines:[{type, id, name, qty, unitList, unitNet, lineNet}]}
  FUNCTION bundle_json(p_id IN NUMBER) RETURN CLOB;
  FUNCTION bundle_price(p_id IN NUMBER) RETURN NUMBER;
  FUNCTION bundles_json(p_channel IN VARCHAR2) RETURN CLOB;
  FUNCTION bundle_html(p_id IN NUMBER) RETURN CLOB;
END NOONA_PRC_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_PRC_PKG AS

  TYPE t_alloc IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION jt(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_CORE_PKG.json_text(p); END jt;
  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(TO_CHAR(NVL(p, 0), 'FM999,999,999,990.00', 'NLS_NUMERIC_CHARACTERS=''.,'''));
  END fmt;
  FUNCTION num(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL THEN 'null' ELSE RTRIM(TO_CHAR(p, 'FM9999999999990.999999', 'NLS_NUMERIC_CHARACTERS=''.,'''), '.') END;
  END num;
  FUNCTION pct(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL THEN '—'
                ELSE RTRIM(RTRIM(TO_CHAR(p, 'FM9999990.99', 'NLS_NUMERIC_CHARACTERS=''.,'''), '0'), '.') || '%' END;
  END pct;

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

  PROCEDURE check_target(p_type VARCHAR2, p_id NUMBER) IS
    l NUMBER;
  BEGIN
    IF p_type = 'ITEM' THEN
      SELECT COUNT(*) INTO l FROM inv_item_company WHERE item_id = p_id AND company_id = company;
    ELSIF p_type = 'HIS_SERVICE' THEN
      SELECT COUNT(*) INTO l FROM his_service WHERE id = p_id AND company_id = company;
    ELSIF p_type = 'AUT_SERVICE' THEN
      SELECT COUNT(*) INTO l FROM aut_service WHERE id = p_id AND company_id = company;
    ELSE
      l := 0;
    END IF;
    NOONA_CORE_PKG.assert(l > 0, 'NOONA-PRC-001', 'الصنف أو الخدمة غير موجود في الشركة الحالية', 'Item or service not found');
  END check_target;

  FUNCTION target_name(p_type IN VARCHAR2, p_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(500);
  BEGIN
    IF p_type = 'ITEM' THEN
      SELECT MAX(item_no || ' - ' || name_ar) INTO l FROM inv_item WHERE id = p_id;
    ELSIF p_type = 'ITEM_CATEGORY' THEN
      SELECT MAX(name_ar) INTO l FROM inv_item_category WHERE id = p_id;
    ELSIF p_type = 'HIS_SERVICE' THEN
      SELECT MAX(code || ' - ' || name_ar) INTO l FROM his_service WHERE id = p_id;
    ELSIF p_type = 'AUT_SERVICE' THEN
      SELECT MAX(code || ' - ' || name_ar) INTO l FROM aut_service WHERE id = p_id;
    ELSIF p_type = 'AUT_CATEGORY' THEN
      SELECT MAX(name_ar) INTO l FROM aut_service_category WHERE id = p_id;
    END IF;
    RETURN l;
  END target_name;

  FUNCTION type_label(p_type VARCHAR2, p_code VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_type
      WHEN 'ITEM' THEN 'صنف' WHEN 'ITEM_CATEGORY' THEN 'فئة أصناف' WHEN 'ALL_ITEMS' THEN 'كل الأصناف'
      WHEN 'HIS_SERVICE' THEN 'خدمة طبية' WHEN 'HIS_SERVICE_TYPE' THEN 'نوع خدمة طبية: ' || p_code WHEN 'ALL_HIS' THEN 'كل الخدمات الطبية'
      WHEN 'AUT_SERVICE' THEN 'خدمة سيارات' WHEN 'AUT_CATEGORY' THEN 'فئة خدمات سيارات' WHEN 'ALL_AUT' THEN 'كل خدمات السيارات'
      ELSE p_type END;
  END type_label;

  -- ================================================================ التكلفة
  FUNCTION item_cost(p_item NUMBER, p_basis VARCHAR2) RETURN NUMBER IS
    l_avg NUMBER;
    l_lp  NUMBER;
    l_std NUMBER;
  BEGIN
    SELECT MAX(average_cost) INTO l_avg FROM inv_item_cost WHERE item_id = p_item AND company_id = company AND warehouse_id IS NULL;
    SELECT MAX(last_purchase_price), MAX(standard_cost) INTO l_lp, l_std FROM inv_item_company WHERE item_id = p_item AND company_id = company;
    IF p_basis = 'LAST_PURCHASE' THEN RETURN COALESCE(NULLIF(l_lp, 0), NULLIF(l_avg, 0), l_std, 0);
    ELSIF p_basis = 'STANDARD' THEN RETURN COALESCE(NULLIF(l_std, 0), NULLIF(l_avg, 0), l_lp, 0);
    END IF;
    -- المتوسط المرجح؛ وعند عدم وجود حركة: آخر شراء ثم المعيارية
    RETURN COALESCE(NULLIF(l_avg, 0), NULLIF(l_lp, 0), l_std, 0);
  END item_cost;

  -- عناصر بطاقة التكلفة: مجموع المباشر (مواد + عمالة + أعباء ثابتة + أخرى) ثم الأعباء النسبية عليه
  FUNCTION elements_cost(p_type VARCHAR2, p_id NUMBER, p_direct IN OUT NUMBER) RETURN NUMBER IS
    l_pct NUMBER := 0;
  BEGIN
    FOR e IN (SELECT element_type, item_id, quantity, minutes, hourly_rate, amount, pct
                FROM sal_cost_element WHERE target_type = p_type AND target_id = p_id AND company_id = company) LOOP
      IF e.element_type = 'MATERIAL' AND e.item_id IS NOT NULL THEN
        p_direct := p_direct + NVL(e.quantity, 1) * item_cost(e.item_id, 'AVERAGE');
      ELSIF e.element_type = 'LABOR' THEN
        p_direct := p_direct + NVL(e.minutes, 0) / 60 * NVL(e.hourly_rate, 0);
      ELSIF e.element_type = 'OVERHEAD_PCT' THEN
        l_pct := l_pct + NVL(e.pct, 0);
      ELSE
        p_direct := p_direct + NVL(e.amount, 0);
      END IF;
    END LOOP;
    RETURN ROUND(p_direct * (1 + l_pct / 100), 4);
  END elements_cost;

  FUNCTION service_cost(p_type IN VARCHAR2, p_id IN NUMBER) RETURN NUMBER IS
    l_direct NUMBER := 0;
  BEGIN
    IF p_type = 'HIS_SERVICE' THEN
      FOR m IN (SELECT item_id, quantity FROM his_service_material WHERE service_id = p_id AND company_id = company) LOOP
        l_direct := l_direct + m.quantity * item_cost(m.item_id, 'AVERAGE');
      END LOOP;
    ELSIF p_type = 'AUT_SERVICE' THEN
      FOR m IN (SELECT item_id, quantity FROM aut_service_part WHERE service_id = p_id AND company_id = company AND is_optional = 'N') LOOP
        l_direct := l_direct + m.quantity * item_cost(m.item_id, 'AVERAGE');
      END LOOP;
    END IF;
    RETURN elements_cost(p_type, p_id, l_direct);
  END service_cost;

  FUNCTION cost_of(p_type IN VARCHAR2, p_id IN NUMBER, p_basis IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_direct NUMBER := 0;
    l_sheet  NUMBER;
  BEGIN
    IF p_type = 'ITEM' THEN
      IF p_basis = 'COST_SHEET' THEN
        l_sheet := elements_cost('ITEM', p_id, l_direct);
        RETURN CASE WHEN l_sheet > 0 THEN l_sheet ELSE item_cost(p_id, 'AVERAGE') END;
      END IF;
      RETURN ROUND(item_cost(p_id, NVL(p_basis, 'AVERAGE')), 4);
    END IF;
    RETURN service_cost(p_type, p_id);
  END cost_of;

  FUNCTION cost_html(p_type IN VARCHAR2, p_id IN NUMBER) RETURN CLOB IS
    l     CLOB;
    l_dir NUMBER := 0;
    l_pct NUMBER := 0;
    l_c   NUMBER;
    PROCEDURE row_(p_kind VARCHAR2, p_desc VARCHAR2, p_calc VARCHAR2, p_amt NUMBER) IS
    BEGIN
      l := l || '<tr><td>' || p_kind || '</td><td>' || esc(p_desc) || '</td><td>' || p_calc || '</td><td class="nn-num">'
             || fmt(p_amt) || '</td></tr>';
    END row_;
  BEGIN
    guard('SAL_COST_ELEMENT.VIEW');
    l := '<table class="nn-rpt"><thead><tr><th>العنصر</th><th>البيان</th><th>الحساب</th><th>التكلفة</th></tr></thead><tbody>';
    IF p_type = 'HIS_SERVICE' THEN
      FOR m IN (SELECT m.item_id, m.quantity, i.name_ar FROM his_service_material m JOIN inv_item i ON i.id = m.item_id
                 WHERE m.service_id = p_id AND m.company_id = company ORDER BY i.name_ar) LOOP
        l_c := item_cost(m.item_id, 'AVERAGE');
        row_('مادة الخدمة', m.name_ar, num(m.quantity) || ' × ' || fmt(l_c), m.quantity * l_c);
        l_dir := l_dir + m.quantity * l_c;
      END LOOP;
    ELSIF p_type = 'AUT_SERVICE' THEN
      FOR m IN (SELECT m.item_id, m.quantity, i.name_ar FROM aut_service_part m JOIN inv_item i ON i.id = m.item_id
                 WHERE m.service_id = p_id AND m.company_id = company AND m.is_optional = 'N' ORDER BY i.name_ar) LOOP
        l_c := item_cost(m.item_id, 'AVERAGE');
        row_('قطعة الخدمة', m.name_ar, num(m.quantity) || ' × ' || fmt(l_c), m.quantity * l_c);
        l_dir := l_dir + m.quantity * l_c;
      END LOOP;
    END IF;
    FOR e IN (SELECT e.element_type, e.description, e.item_id, e.quantity, e.minutes, e.hourly_rate, e.amount, e.pct, i.name_ar
                FROM sal_cost_element e LEFT JOIN inv_item i ON i.id = e.item_id
               WHERE e.target_type = p_type AND e.target_id = p_id AND e.company_id = company ORDER BY e.sort_order, e.id) LOOP
      IF e.element_type = 'MATERIAL' AND e.item_id IS NOT NULL THEN
        l_c := item_cost(e.item_id, 'AVERAGE');
        row_('مادة', NVL(e.description, e.name_ar), num(NVL(e.quantity, 1)) || ' × ' || fmt(l_c), NVL(e.quantity, 1) * l_c);
        l_dir := l_dir + NVL(e.quantity, 1) * l_c;
      ELSIF e.element_type = 'LABOR' THEN
        row_('عمالة', e.description, num(e.minutes) || ' دقيقة × ' || fmt(e.hourly_rate) || ' للساعة', NVL(e.minutes, 0) / 60 * NVL(e.hourly_rate, 0));
        l_dir := l_dir + NVL(e.minutes, 0) / 60 * NVL(e.hourly_rate, 0);
      ELSIF e.element_type = 'OVERHEAD_PCT' THEN
        l_pct := l_pct + NVL(e.pct, 0);
      ELSE
        row_(CASE e.element_type WHEN 'OVERHEAD_AMOUNT' THEN 'أعباء ثابتة' ELSE 'أخرى' END, e.description, '', e.amount);
        l_dir := l_dir + NVL(e.amount, 0);
      END IF;
    END LOOP;
    IF l_pct > 0 THEN
      row_('أعباء نسبية', 'نسبة من التكلفة المباشرة', pct(l_pct) || ' × ' || fmt(l_dir), l_dir * l_pct / 100);
    END IF;
    RETURN l || '</tbody><tfoot><tr><th colspan="3">تكلفة الوحدة</th><th class="nn-num">' || fmt(l_dir * (1 + l_pct / 100))
             || '</th></tr></tfoot></table>';
  END cost_html;

  FUNCTION save_cost_element(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id  NUMBER := jn(l_o, 'id');
    l_tt  VARCHAR2(30) := js(l_o, 'targetType');
    l_tid NUMBER := jn(l_o, 'targetId');
    l_et  VARCHAR2(30) := js(l_o, 'type');
    l_it  NUMBER := jn(l_o, 'itemId');
    l_q   NUMBER := jn(l_o, 'qty');
    l_mn  NUMBER := jn(l_o, 'minutes');
    l_hr  NUMBER := jn(l_o, 'rate');
    l_am  NUMBER := jn(l_o, 'amount');
    l_pc  NUMBER := jn(l_o, 'pct');
    l_ds  VARCHAR2(200) := SUBSTR(js(l_o, 'desc'), 1, 200);
    l_so  NUMBER := jn(l_o, 'sort');
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'SAL_COST_ELEMENT.CREATE' ELSE 'SAL_COST_ELEMENT.UPDATE' END);
    NOONA_CORE_PKG.assert(l_tt IN ('HIS_SERVICE', 'AUT_SERVICE', 'ITEM'), 'NOONA-PRC-002', 'اختر الخدمة أو الصنف', 'Choose the service or item');
    check_target(l_tt, l_tid);
    NOONA_CORE_PKG.assert(l_et IN ('MATERIAL', 'LABOR', 'OVERHEAD_AMOUNT', 'OVERHEAD_PCT', 'OTHER'), 'NOONA-PRC-003',
      'اختر نوع عنصر التكلفة', 'Choose the cost element type');
    IF l_et = 'MATERIAL' THEN
      NOONA_CORE_PKG.assert(l_it IS NOT NULL AND NVL(l_q, 0) > 0, 'NOONA-PRC-004', 'المادة تحتاج صنفاً وكمية أكبر من صفر',
        'Material needs an item and a positive quantity');
    ELSIF l_et = 'LABOR' THEN
      NOONA_CORE_PKG.assert(NVL(l_mn, 0) > 0 AND NVL(l_hr, 0) >= 0, 'NOONA-PRC-005', 'العمالة تحتاج عدد الدقائق وتكلفة الساعة',
        'Labor needs minutes and an hourly rate');
    ELSIF l_et = 'OVERHEAD_PCT' THEN
      NOONA_CORE_PKG.assert(NVL(l_pc, 0) > 0 AND l_pc <= 500, 'NOONA-PRC-006', 'نسبة الأعباء بين 0 و 500%', 'Overhead percent 0-500');
    ELSE
      NOONA_CORE_PKG.assert(NVL(l_am, -1) >= 0, 'NOONA-PRC-007', 'أدخل مبلغ العنصر', 'Enter the element amount');
    END IF;
    IF l_id IS NULL THEN
      INSERT INTO sal_cost_element (company_id, target_type, target_id, element_type, description, item_id, quantity, minutes,
                                    hourly_rate, amount, pct, sort_order)
      VALUES (company, l_tt, l_tid, l_et, l_ds, CASE WHEN l_et = 'MATERIAL' THEN l_it END,
              CASE WHEN l_et = 'MATERIAL' THEN l_q END, CASE WHEN l_et = 'LABOR' THEN l_mn END, CASE WHEN l_et = 'LABOR' THEN l_hr END,
              CASE WHEN l_et IN ('OVERHEAD_AMOUNT', 'OTHER') THEN l_am END, CASE WHEN l_et = 'OVERHEAD_PCT' THEN l_pc END, l_so)
      RETURNING id INTO l_id;
    ELSE
      UPDATE sal_cost_element SET element_type = l_et, description = l_ds,
             item_id = CASE WHEN l_et = 'MATERIAL' THEN l_it END, quantity = CASE WHEN l_et = 'MATERIAL' THEN l_q END,
             minutes = CASE WHEN l_et = 'LABOR' THEN l_mn END, hourly_rate = CASE WHEN l_et = 'LABOR' THEN l_hr END,
             amount = CASE WHEN l_et IN ('OVERHEAD_AMOUNT', 'OTHER') THEN l_am END, pct = CASE WHEN l_et = 'OVERHEAD_PCT' THEN l_pc END
       WHERE id = l_id AND company_id = company AND target_type = l_tt AND target_id = l_tid;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PRC-008', 'عنصر التكلفة غير موجود', 'Cost element not found');
    END IF;
    RETURN l_id;
  END save_cost_element;

  PROCEDURE delete_cost_element(p_id IN NUMBER) IS
  BEGIN
    guard('SAL_COST_ELEMENT.DELETE');
    DELETE FROM sal_cost_element WHERE id = p_id AND company_id = company;
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PRC-008', 'عنصر التكلفة غير موجود', 'Cost element not found');
  END delete_cost_element;

  -- ================================================================ سعر البيع من التكلفة
  FUNCTION round_price(p_price IN NUMBER, p_rounding IN VARCHAR2) RETURN NUMBER DETERMINISTIC IS
    FUNCTION up(p NUMBER, s NUMBER) RETURN NUMBER IS BEGIN RETURN CEIL(ROUND(p / s, 6)) * s; END up;
  BEGIN
    IF p_price IS NULL THEN RETURN NULL; END IF;
    RETURN CASE p_rounding
      WHEN 'R005' THEN up(p_price, 0.05) WHEN 'R025' THEN up(p_price, 0.25) WHEN 'R050' THEN up(p_price, 0.5)
      WHEN 'R1' THEN up(p_price, 1) WHEN 'R5' THEN up(p_price, 5) WHEN 'R10' THEN up(p_price, 10)
      -- .99: أقرب سعر ينتهي بـ .99 لا يقل عن السعر المحسوب (12.30 ← 12.99، 13.00 ← 13.99)
      WHEN 'END99' THEN FLOOR(p_price) + 0.99
      ELSE ROUND(p_price, 2) END;
  END round_price;

  FUNCTION price_from_cost(p_cost IN NUMBER, p_method IN VARCHAR2, p_value IN NUMBER, p_rounding IN VARCHAR2 DEFAULT 'NONE')
    RETURN NUMBER DETERMINISTIC IS
    l NUMBER;
  BEGIN
    IF p_cost IS NULL OR p_value IS NULL THEN RETURN NULL; END IF;
    l := CASE p_method
           WHEN 'MARKUP_PCT' THEN p_cost * (1 + p_value / 100)               -- نسبة فوق التكلفة: 100 × 25% = 125
           WHEN 'MARGIN_PCT' THEN p_cost / (1 - LEAST(p_value, 99.99) / 100)  -- هامش من سعر البيع: 100 / (1 - 20%) = 125
           WHEN 'FIXED_AMOUNT' THEN p_cost + p_value                         -- مبلغ ثابت فوق التكلفة
           WHEN 'MULTIPLIER' THEN p_cost * p_value                           -- معامل: التكلفة × 1.5
         END;
    RETURN round_price(l, NVL(p_rounding, 'NONE'));
  END price_from_cost;

  FUNCTION current_price(p_type IN VARCHAR2, p_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    IF p_type = 'ITEM' THEN
      SELECT MAX(sale_price) INTO l FROM inv_item_company WHERE item_id = p_id AND company_id = company;
    ELSIF p_type = 'HIS_SERVICE' THEN
      SELECT MAX(price) INTO l FROM his_service WHERE id = p_id AND company_id = company;
    ELSIF p_type = 'AUT_SERVICE' THEN
      SELECT MAX(price) INTO l FROM aut_service WHERE id = p_id AND company_id = company;
    END IF;
    RETURN l;
  END current_price;

  -- السعر المحسوب صافٍ من الضريبة؛ الصنف المسعر شاملاً الضريبة يضاف عليه نسبة ضريبة البيع
  FUNCTION gross_up(p_type VARCHAR2, p_id NUMBER, p_price NUMBER, p_rounding VARCHAR2) RETURN NUMBER IS
    l_inc VARCHAR2(1);
    l_tax NUMBER;
  BEGIN
    IF p_type <> 'ITEM' OR p_price IS NULL THEN RETURN p_price; END IF;
    SELECT MAX(prices_include_tax), MAX(sales_tax_code_id) INTO l_inc, l_tax FROM inv_item_company WHERE item_id = p_id AND company_id = company;
    IF l_inc = 'Y' AND l_tax IS NOT NULL THEN
      RETURN round_price(p_price * (1 + NVL(NOONA_INV_PKG.tax_rate(l_tax), 0) / 100), NVL(p_rounding, 'NONE'));
    END IF;
    RETURN p_price;
  END gross_up;

  -- السياسة المطابقة: الأخص أولاً (الصنف/الخدمة، ثم الفئة/النوع، ثم الكل)، ثم الأولوية، ثم الأحدث
  FUNCTION policy_for(p_type IN VARCHAR2, p_id IN NUMBER) RETURN NUMBER IS
    l_cat  NUMBER;
    l_stp  VARCHAR2(30);
    l_id   NUMBER;
  BEGIN
    IF p_type = 'ITEM' THEN
      SELECT MAX(category_id) INTO l_cat FROM inv_item WHERE id = p_id;
    ELSIF p_type = 'HIS_SERVICE' THEN
      SELECT MAX(service_type) INTO l_stp FROM his_service WHERE id = p_id AND company_id = company;
    ELSIF p_type = 'AUT_SERVICE' THEN
      SELECT MAX(category_id) INTO l_cat FROM aut_service WHERE id = p_id AND company_id = company;
    END IF;
    SELECT MAX(id) KEEP (DENSE_RANK FIRST ORDER BY rnk, priority_no, id DESC) INTO l_id
      FROM (SELECT p.id, p.priority_no,
                   CASE
                     WHEN p.target_type = p_type AND p.target_id = p_id THEN 1
                     WHEN p.target_type = 'ITEM_CATEGORY' AND p_type = 'ITEM' AND p.target_id IN (
                            SELECT c.id FROM inv_item_category c START WITH c.id = l_cat CONNECT BY PRIOR c.parent_category_id = c.id) THEN 2
                     WHEN p.target_type = 'HIS_SERVICE_TYPE' AND p_type = 'HIS_SERVICE' AND p.target_code = l_stp THEN 2
                     WHEN p.target_type = 'AUT_CATEGORY' AND p_type = 'AUT_SERVICE' AND p.target_id = l_cat THEN 2
                     WHEN p.target_type = DECODE(p_type, 'ITEM', 'ALL_ITEMS', 'HIS_SERVICE', 'ALL_HIS', 'AUT_SERVICE', 'ALL_AUT') THEN 3
                   END rnk
              FROM sal_pricing_policy p
             WHERE p.company_id = company AND p.status_code = 'ACTIVE'
               AND TRUNC(SYSDATE) BETWEEN p.effective_from AND NVL(p.effective_to, TRUNC(SYSDATE)))
     WHERE rnk IS NOT NULL;
    RETURN l_id;
  END policy_for;

  FUNCTION policy_text(p_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(1000);
  BEGIN
    FOR p IN (SELECT * FROM sal_pricing_policy WHERE id = p_id AND company_id = company) LOOP
      l := CASE p.method
             WHEN 'MARKUP_PCT' THEN 'التكلفة + ' || pct(p.method_value)
             WHEN 'MARGIN_PCT' THEN 'هامش ' || pct(p.method_value) || ' من سعر البيع'
             WHEN 'FIXED_AMOUNT' THEN 'التكلفة + ' || fmt(p.method_value)
             WHEN 'MULTIPLIER' THEN 'التكلفة × ' || num(p.method_value) END
        || ' على ' || CASE p.cost_basis WHEN 'AVERAGE' THEN 'متوسط التكلفة' WHEN 'LAST_PURCHASE' THEN 'آخر سعر شراء'
                                        WHEN 'STANDARD' THEN 'التكلفة المعيارية' ELSE 'بطاقة التكلفة' END
        || CASE WHEN p.min_margin_pct IS NOT NULL THEN '، أدنى هامش ' || pct(p.min_margin_pct) END
        || CASE p.rounding WHEN 'NONE' THEN NULL WHEN 'END99' THEN '، ينتهي بـ .99'
             ELSE '، تقريب لأعلى ' || CASE p.rounding WHEN 'R005' THEN '0.05' WHEN 'R025' THEN '0.25' WHEN 'R050' THEN '0.50'
                                                       WHEN 'R1' THEN '1' WHEN 'R5' THEN '5' ELSE '10' END END;
    END LOOP;
    RETURN l;
  END policy_text;

  -- سعر مقترح وأدنى سعر لهدف واحد حسب سياسته
  PROCEDURE suggest(p_type VARCHAR2, p_id NUMBER, o_policy OUT NUMBER, o_cost OUT NUMBER, o_price OUT NUMBER, o_min OUT NUMBER) IS
  BEGIN
    o_policy := policy_for(p_type, p_id);
    o_cost := NULL; o_price := NULL; o_min := NULL;
    FOR p IN (SELECT * FROM sal_pricing_policy WHERE id = o_policy) LOOP
      o_cost := cost_of(p_type, p_id, CASE WHEN p_type <> 'ITEM' AND p.cost_basis <> 'COST_SHEET' THEN 'COST_SHEET' ELSE p.cost_basis END);
      IF NVL(o_cost, 0) > 0 THEN
        o_price := gross_up(p_type, p_id, price_from_cost(o_cost, p.method, p.method_value, p.rounding), p.rounding);
        IF p.min_margin_pct IS NOT NULL THEN
          o_min := gross_up(p_type, p_id, price_from_cost(o_cost, 'MARKUP_PCT', p.min_margin_pct, 'NONE'), 'NONE');
        END IF;
      END IF;
    END LOOP;
  END suggest;

  FUNCTION margin_of(p_cost NUMBER, p_price NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN CASE WHEN NVL(p_price, 0) > 0 AND p_cost IS NOT NULL THEN ROUND((p_price - p_cost) / p_price * 100, 2) END;
  END margin_of;

  FUNCTION suggest_json(p_type IN VARCHAR2, p_id IN NUMBER) RETURN CLOB IS
    l_pol NUMBER; l_c NUMBER; l_p NUMBER; l_m NUMBER; l_cur NUMBER;
  BEGIN
    guard('SAL_PRICING_POLICY.VIEW');
    check_target(p_type, p_id);
    suggest(p_type, p_id, l_pol, l_c, l_p, l_m);
    IF l_c IS NULL THEN l_c := cost_of(p_type, p_id); END IF;
    l_cur := current_price(p_type, p_id);
    RETURN '{"cost":' || num(l_c) || ',"policyId":' || num(l_pol) || ',"policy":' || jt(policy_text(l_pol))
        || ',"price":' || num(l_p) || ',"minPrice":' || num(l_m) || ',"current":' || num(l_cur)
        || ',"margin":' || num(margin_of(l_c, l_cur)) || ',"newMargin":' || num(margin_of(l_c, l_p)) || '}';
  END suggest_json;

  FUNCTION save_policy(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id  NUMBER := jn(l_o, 'id');
    l_tt  VARCHAR2(30) := js(l_o, 'targetType');
    l_tid NUMBER := jn(l_o, 'targetId');
    l_tc  VARCHAR2(50) := js(l_o, 'targetCode');
    l_mt  VARCHAR2(30) := NVL(js(l_o, 'method'), 'MARKUP_PCT');
    l_v   NUMBER := jn(l_o, 'value');
    l_mm  NUMBER := jn(l_o, 'minMargin');
    l_code VARCHAR2(50) := UPPER(js(l_o, 'code'));
    l_nm   VARCHAR2(200) := js(l_o, 'name');
    l_bs   VARCHAR2(30) := NVL(js(l_o, 'basis'), 'AVERAGE');
    l_rd   VARCHAR2(30) := NVL(js(l_o, 'rounding'), 'NONE');
    l_pr   NUMBER := NVL(jn(l_o, 'priority'), 100);
    l_fr   DATE := jd(l_o, 'from');
    l_to   DATE := jd(l_o, 'to');
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'SAL_PRICING_POLICY.CREATE' ELSE 'SAL_PRICING_POLICY.UPDATE' END);
    NOONA_CORE_PKG.assert(l_tt IN ('ITEM', 'ITEM_CATEGORY', 'ALL_ITEMS', 'HIS_SERVICE', 'HIS_SERVICE_TYPE', 'ALL_HIS', 'AUT_SERVICE',
      'AUT_CATEGORY', 'ALL_AUT'), 'NOONA-PRC-010', 'اختر ما تنطبق عليه السياسة', 'Choose the policy target');
    NOONA_CORE_PKG.assert(l_tt LIKE 'ALL%' OR l_tid IS NOT NULL OR (l_tt = 'HIS_SERVICE_TYPE' AND l_tc IS NOT NULL), 'NOONA-PRC-011',
      'اختر الصنف أو الفئة أو الخدمة أو النوع', 'Choose the item, category, service or type');
    IF l_tt IN ('ITEM', 'HIS_SERVICE', 'AUT_SERVICE') THEN check_target(l_tt, l_tid); END IF;
    NOONA_CORE_PKG.assert(l_mt IN ('MARKUP_PCT', 'MARGIN_PCT', 'FIXED_AMOUNT', 'MULTIPLIER'), 'NOONA-PRC-012', 'طريقة التسعير غير معروفة', 'Unknown method');
    NOONA_CORE_PKG.assert(l_v IS NOT NULL AND l_v >= 0, 'NOONA-PRC-013', 'أدخل قيمة الطريقة (النسبة أو المبلغ أو المعامل)', 'Enter the method value');
    NOONA_CORE_PKG.assert(l_mt <> 'MARGIN_PCT' OR l_v < 100, 'NOONA-PRC-014', 'هامش الربح من سعر البيع يجب أن يقل عن 100%', 'Margin must be below 100%');
    NOONA_CORE_PKG.assert(l_mt <> 'MULTIPLIER' OR l_v >= 1, 'NOONA-PRC-015', 'المعامل لا يقل عن 1 (وإلا يباع بأقل من التكلفة)', 'Multiplier must be at least 1');
    NOONA_CORE_PKG.assert(l_mm IS NULL OR l_mm BETWEEN 0 AND 1000, 'NOONA-PRC-016', 'أدنى هامش بين 0 و 1000%', 'Minimum margin 0-1000');
    NOONA_CORE_PKG.assert(l_code IS NOT NULL AND js(l_o, 'name') IS NOT NULL, 'NOONA-PRC-017', 'الرمز والاسم مطلوبان', 'Code and name are required');
    IF l_id IS NULL THEN
      INSERT INTO sal_pricing_policy (company_id, code, name_ar, target_type, target_id, target_code, cost_basis, method, method_value,
                                      min_margin_pct, rounding, priority_no, effective_from, effective_to)
      VALUES (company, l_code, l_nm, l_tt, CASE WHEN l_tt NOT LIKE 'ALL%' AND l_tt <> 'HIS_SERVICE_TYPE' THEN l_tid END,
              CASE WHEN l_tt = 'HIS_SERVICE_TYPE' THEN l_tc END, l_bs, l_mt, l_v, l_mm, l_rd, l_pr, NVL(l_fr, TRUNC(SYSDATE)), l_to)
      RETURNING id INTO l_id;
    ELSE
      UPDATE sal_pricing_policy SET name_ar = l_nm, target_type = l_tt,
             target_id = CASE WHEN l_tt NOT LIKE 'ALL%' AND l_tt <> 'HIS_SERVICE_TYPE' THEN l_tid END,
             target_code = CASE WHEN l_tt = 'HIS_SERVICE_TYPE' THEN l_tc END, cost_basis = l_bs,
             method = l_mt, method_value = l_v, min_margin_pct = l_mm, rounding = l_rd,
             priority_no = l_pr, effective_from = NVL(l_fr, effective_from), effective_to = l_to
       WHERE id = l_id AND company_id = company;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PRC-018', 'السياسة غير موجودة', 'Policy not found');
    END IF;
    RETURN l_id;
  END save_policy;

  PROCEDURE set_policy_status(p_id IN NUMBER, p_status IN VARCHAR2) IS
  BEGIN
    guard('SAL_PRICING_POLICY.UPDATE');
    NOONA_CORE_PKG.assert(p_status IN ('ACTIVE', 'INACTIVE'), 'NOONA-PRC-019', 'حالة غير صحيحة', 'Invalid status');
    UPDATE sal_pricing_policy SET status_code = p_status WHERE id = p_id AND company_id = company;
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PRC-018', 'السياسة غير موجودة', 'Policy not found');
  END set_policy_status;

  -- ================================================================ إعادة التسعير
  FUNCTION new_run(p_scope IN VARCHAR2, p_only_changed IN VARCHAR2 DEFAULT 'Y') RETURN NUMBER IS
    l_run NUMBER;
    l_n   PLS_INTEGER := 0;
    TYPE t_t IS TABLE OF VARCHAR2(30) INDEX BY PLS_INTEGER;
    TYPE t_i IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    l_tt  t_t;
    l_id  t_i;
    l_pol NUMBER; l_c NUMBER; l_p NUMBER; l_m NUMBER; l_cur NUMBER; l_mg NUMBER;
  BEGIN
    guard('SAL_PRICE_RUN.CREATE');
    NOONA_CORE_PKG.assert(p_scope IN ('ITEMS', 'HIS', 'AUT', 'ALL'), 'NOONA-PRC-020', 'اختر نطاق إعادة التسعير', 'Choose the scope');
    NOONA_INV_PKG.ensure_sequence('SAL_PRICE_RUN', 'PRC-');
    INSERT INTO sal_price_run (company_id, doc_no, scope_type, only_changed)
    VALUES (company, NOONA_REFERENCE_PKG.next_doc_no('SAL_PRICE_RUN', company), p_scope, NVL(p_only_changed, 'Y'))
    RETURNING id INTO l_run;
    IF p_scope IN ('ITEMS', 'ALL') THEN
      FOR r IN (SELECT c.item_id FROM inv_item_company c JOIN inv_item i ON i.id = c.item_id
                 WHERE c.company_id = company AND i.status_code = 'ACTIVE' AND NVL(i.is_sellable, 'Y') = 'Y') LOOP
        l_tt(l_tt.COUNT + 1) := 'ITEM'; l_id(l_id.COUNT + 1) := r.item_id;
      END LOOP;
    END IF;
    IF p_scope IN ('HIS', 'ALL') THEN
      FOR r IN (SELECT id FROM his_service WHERE company_id = company AND status_code = 'ACTIVE') LOOP
        l_tt(l_tt.COUNT + 1) := 'HIS_SERVICE'; l_id(l_id.COUNT + 1) := r.id;
      END LOOP;
    END IF;
    IF p_scope IN ('AUT', 'ALL') THEN
      FOR r IN (SELECT id FROM aut_service WHERE company_id = company AND is_active = 'Y') LOOP
        l_tt(l_tt.COUNT + 1) := 'AUT_SERVICE'; l_id(l_id.COUNT + 1) := r.id;
      END LOOP;
    END IF;
    FOR i IN 1 .. l_tt.COUNT LOOP
      suggest(l_tt(i), l_id(i), l_pol, l_c, l_p, l_m);
      l_cur := current_price(l_tt(i), l_id(i));
      IF l_p IS NOT NULL AND (NVL(p_only_changed, 'Y') = 'N' OR l_cur IS NULL OR l_p <> l_cur) THEN
        l_mg := margin_of(l_c, l_p);
        INSERT INTO sal_price_run_line (company_id, run_id, target_type, target_id, policy_id, cost_amount, old_price, new_price,
                                        new_min_price, margin_pct)
        VALUES (company, l_run, l_tt(i), l_id(i), l_pol, l_c, l_cur, l_p, l_m, l_mg);
        l_n := l_n + 1;
      END IF;
    END LOOP;
    UPDATE sal_price_run SET lines_count = l_n WHERE id = l_run;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'SAL_PRICE_RUN', l_run, 'CREATE', 'SUCCESS', NULL, '{"lines":' || l_n || '}');
    RETURN l_run;
  END new_run;

  PROCEDURE set_run_line(p_line_id IN NUMBER, p_selected IN VARCHAR2, p_price IN NUMBER DEFAULT NULL) IS
  BEGIN
    guard('SAL_PRICE_RUN.UPDATE');
    NOONA_CORE_PKG.assert(p_price IS NULL OR p_price >= 0, 'NOONA-PRC-021', 'السعر لا يكون سالباً', 'Price cannot be negative');
    UPDATE sal_price_run_line l SET is_selected = NVL(p_selected, l.is_selected), new_price = NVL(p_price, l.new_price),
           margin_pct = CASE WHEN NVL(NVL(p_price, l.new_price), 0) > 0 AND l.cost_amount IS NOT NULL
                             THEN ROUND((NVL(p_price, l.new_price) - l.cost_amount) / NVL(p_price, l.new_price) * 100, 2) END
     WHERE id = p_line_id AND company_id = company
       AND run_id IN (SELECT id FROM sal_price_run WHERE status_code = 'DRAFT' AND company_id = company);
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PRC-022', 'السطر غير موجود أو التشغيل مطبق مسبقاً', 'Line not found or run already applied');
  END set_run_line;

  PROCEDURE write_price(p_type VARCHAR2, p_id NUMBER, p_price NUMBER, p_min NUMBER, p_cost NUMBER, p_src VARCHAR2, p_run NUMBER) IS
    l_old NUMBER := current_price(p_type, p_id);
  BEGIN
    IF p_type = 'ITEM' THEN
      UPDATE inv_item_company SET sale_price = p_price, min_sale_price = CASE WHEN p_min IS NOT NULL THEN LEAST(p_min, p_price) ELSE min_sale_price END
       WHERE item_id = p_id AND company_id = company;
    ELSIF p_type = 'HIS_SERVICE' THEN
      UPDATE his_service SET price = p_price WHERE id = p_id AND company_id = company;
    ELSIF p_type = 'AUT_SERVICE' THEN
      UPDATE aut_service SET price = p_price WHERE id = p_id AND company_id = company;
    END IF;
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PRC-001', 'الصنف أو الخدمة غير موجود في الشركة الحالية', 'Item or service not found');
    IF NVL(l_old, -1) <> NVL(p_price, -1) THEN
      INSERT INTO sal_price_history (company_id, target_type, target_id, old_price, new_price, cost_amount, source_code, run_id)
      VALUES (company, p_type, p_id, l_old, p_price, p_cost, p_src, p_run);
    END IF;
  END write_price;

  FUNCTION apply_run(p_run_id IN NUMBER) RETURN NUMBER IS
    l_st VARCHAR2(30);
    l_n  PLS_INTEGER := 0;
  BEGIN
    guard('SAL_PRICE_RUN.UPDATE');
    BEGIN
      SELECT status_code INTO l_st FROM sal_price_run WHERE id = p_run_id AND company_id = company FOR UPDATE;
    EXCEPTION WHEN NO_DATA_FOUND THEN l_st := NULL;
    END;
    NOONA_CORE_PKG.assert(l_st = 'DRAFT', 'NOONA-PRC-023', 'التشغيل غير موجود أو مطبق أو ملغى', 'Run not found or not draft');
    FOR l IN (SELECT * FROM sal_price_run_line WHERE run_id = p_run_id AND is_selected = 'Y' AND new_price IS NOT NULL) LOOP
      IF l.target_type = 'ITEM' THEN guard('INV_ITEM.UPDATE');
      ELSIF l.target_type = 'HIS_SERVICE' THEN guard('HIS_SERVICE.UPDATE');
      ELSE guard('AUT_SERVICE.UPDATE');
      END IF;
      write_price(l.target_type, l.target_id, l.new_price, l.new_min_price, l.cost_amount, 'RUN', p_run_id);
      l_n := l_n + 1;
    END LOOP;
    UPDATE sal_price_run SET status_code = 'APPLIED', applied_count = l_n, applied_by = NOONA_CTX_PKG.current_user_name, applied_at = SYSTIMESTAMP
     WHERE id = p_run_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'SAL_PRICE_RUN', p_run_id, 'APPLY', 'SUCCESS', NULL, '{"applied":' || l_n || '}');
    RETURN l_n;
  END apply_run;

  PROCEDURE cancel_run(p_run_id IN NUMBER) IS
  BEGIN
    guard('SAL_PRICE_RUN.UPDATE');
    UPDATE sal_price_run SET status_code = 'CANCELLED' WHERE id = p_run_id AND company_id = company AND status_code = 'DRAFT';
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PRC-023', 'التشغيل غير موجود أو مطبق أو ملغى', 'Run not found or not draft');
  END cancel_run;

  PROCEDURE set_price(p_type IN VARCHAR2, p_id IN NUMBER, p_price IN NUMBER, p_min_price IN NUMBER DEFAULT NULL) IS
  BEGIN
    guard(CASE p_type WHEN 'ITEM' THEN 'INV_ITEM.UPDATE' WHEN 'HIS_SERVICE' THEN 'HIS_SERVICE.UPDATE' ELSE 'AUT_SERVICE.UPDATE' END);
    check_target(p_type, p_id);
    NOONA_CORE_PKG.assert(p_price IS NOT NULL AND p_price >= 0, 'NOONA-PRC-021', 'السعر لا يكون سالباً', 'Price cannot be negative');
    NOONA_CORE_PKG.assert(p_min_price IS NULL OR p_min_price <= p_price, 'NOONA-PRC-024', 'أدنى سعر لا يتجاوز سعر البيع',
      'Minimum price cannot exceed the price');
    write_price(p_type, p_id, p_price, p_min_price, cost_of(p_type, p_id), 'MANUAL', NULL);
  END set_price;

  FUNCTION margin_html(p_scope IN VARCHAR2 DEFAULT 'ALL') RETURN CLOB IS
    l     CLOB;
    l_pol NUMBER; l_c NUMBER; l_p NUMBER; l_m NUMBER; l_cur NUMBER; l_mg NUMBER; l_min NUMBER;
    l_n   PLS_INTEGER := 0;
    l_low PLS_INTEGER := 0;
    PROCEDURE one(p_type VARCHAR2, p_id NUMBER, p_kind VARCHAR2) IS
    BEGIN
      suggest(p_type, p_id, l_pol, l_c, l_p, l_m);
      IF l_c IS NULL THEN l_c := cost_of(p_type, p_id); END IF;
      l_cur := current_price(p_type, p_id);
      l_mg := margin_of(l_c, l_cur);
      l_min := NULL;
      FOR p IN (SELECT min_margin_pct FROM sal_pricing_policy WHERE id = l_pol) LOOP l_min := p.min_margin_pct; END LOOP;
      l_n := l_n + 1;
      IF l_min IS NOT NULL AND l_c > 0 AND NVL(l_cur, 0) < l_c * (1 + l_min / 100) THEN l_low := l_low + 1; END IF;
      l := l || '<tr' || CASE WHEN NVL(l_cur, 0) < l_c THEN ' class="nn-bad"' END || '><td>' || p_kind || '</td><td>'
             || esc(target_name(p_type, p_id)) || '</td><td class="nn-num">' || fmt(l_c) || '</td><td class="nn-num">' || fmt(l_cur)
             || '</td><td class="nn-num">' || pct(l_mg) || '</td><td>' || esc(NVL(policy_text(l_pol), '—')) || '</td><td class="nn-num">'
             || CASE WHEN l_p IS NULL THEN '—' ELSE fmt(l_p) END || '</td></tr>';
    END one;
  BEGIN
    guard('SAL_PRICING_POLICY.VIEW');
    l := '<table class="nn-rpt"><thead><tr><th>النوع</th><th>الصنف / الخدمة</th><th>التكلفة</th><th>سعر البيع</th><th>الهامش</th>'
      || '<th>السياسة</th><th>السعر المقترح</th></tr></thead><tbody>';
    IF p_scope IN ('ITEMS', 'ALL') THEN
      FOR r IN (SELECT c.item_id FROM inv_item_company c JOIN inv_item i ON i.id = c.item_id
                 WHERE c.company_id = company AND i.status_code = 'ACTIVE' AND NVL(i.is_sellable, 'Y') = 'Y' ORDER BY i.item_no) LOOP
        one('ITEM', r.item_id, 'صنف');
      END LOOP;
    END IF;
    IF p_scope IN ('HIS', 'ALL') THEN
      FOR r IN (SELECT id FROM his_service WHERE company_id = company AND status_code = 'ACTIVE' ORDER BY code) LOOP
        one('HIS_SERVICE', r.id, 'خدمة طبية');
      END LOOP;
    END IF;
    IF p_scope IN ('AUT', 'ALL') THEN
      FOR r IN (SELECT id FROM aut_service WHERE company_id = company AND is_active = 'Y' ORDER BY code) LOOP
        one('AUT_SERVICE', r.id, 'خدمة سيارات');
      END LOOP;
    END IF;
    RETURN '<p class="nn-hint">' || l_n || ' صنف وخدمة؛ ' || l_low || ' تحت أدنى هامش سياستها. الأحمر: سعر البيع أقل من التكلفة.</p>'
        || l || '</tbody></table>';
  END margin_html;

  -- ================================================================ العروض
  FUNCTION promotion_text(p_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(2000);
  BEGIN
    FOR p IN (SELECT * FROM sal_promotion WHERE id = p_id AND company_id = company) LOOP
      l := CASE p.promo_type
             WHEN 'PCT_OFF' THEN 'خصم ' || pct(p.promo_value)
             WHEN 'AMOUNT_OFF' THEN 'خصم ' || fmt(p.promo_value) || ' للوحدة'
             WHEN 'FIXED_PRICE' THEN 'سعر خاص ' || fmt(p.promo_value)
             WHEN 'BUY_X_GET_Y' THEN 'اشتر ' || num(p.buy_qty) || ' واحصل على ' || num(p.get_qty) || ' مجاناً'
             WHEN 'SPEND_PCT' THEN 'خصم ' || pct(p.promo_value) || ' على الفاتورة'
             WHEN 'SPEND_AMOUNT' THEN 'خصم ' || fmt(p.promo_value) || ' على الفاتورة' END
        || CASE WHEN p.min_amount IS NOT NULL THEN ' عند الشراء بـ ' || fmt(p.min_amount) || ' فأكثر' END
        || CASE WHEN p.min_qty IS NOT NULL THEN ' (من ' || num(p.min_qty) || ' وحدات)' END
        || CASE WHEN p.max_discount IS NOT NULL THEN '، أقصى خصم ' || fmt(p.max_discount) END
        || CASE WHEN p.coupon_code IS NOT NULL THEN '، بالكوبون ' || p.coupon_code END
        || CASE WHEN p.hour_from IS NOT NULL THEN '، من الساعة ' || p.hour_from || ' إلى ' || NVL(p.hour_to, 24) END
        || '، من ' || TO_CHAR(p.effective_from, 'YYYY-MM-DD') || CASE WHEN p.effective_to IS NOT NULL THEN ' إلى ' || TO_CHAR(p.effective_to, 'YYYY-MM-DD') END;
    END LOOP;
    RETURN l;
  END promotion_text;

  FUNCTION save_promotion(p_doc IN CLOB, p_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := p_id;
    l_tp   VARCHAR2(30) := js(l_o, 'type');
    l_v    NUMBER := NVL(jn(l_o, 'value'), 0);
    l_b    NUMBER := jn(l_o, 'buyQty');
    l_g    NUMBER := jn(l_o, 'getQty');
    l_code VARCHAR2(50) := UPPER(js(l_o, 'code'));
    l_days VARCHAR2(20) := REPLACE(js(l_o, 'days'), ' ', '');
    l_ch   VARCHAR2(200) := UPPER(REPLACE(js(l_o, 'channels'), ' ', ''));
    l_from DATE := NVL(jd(l_o, 'from'), TRUNC(SYSDATE));
    l_to   DATE := jd(l_o, 'to');
    l_hf   NUMBER := jn(l_o, 'hourFrom');
    l_ht   NUMBER := jn(l_o, 'hourTo');
    l_tg   JSON_ARRAY_T;
    l_t    JSON_OBJECT_T;
    l_tt   VARCHAR2(30);
    l_n    PLS_INTEGER := 0;
    l_nm   VARCHAR2(200) := js(l_o, 'name');
    l_mq   NUMBER := jn(l_o, 'minQty');
    l_ma   NUMBER := jn(l_o, 'minAmount');
    l_mx   NUMBER := jn(l_o, 'maxDiscount');
    l_br   NUMBER := jn(l_o, 'branchId');
    l_cp   VARCHAR2(50) := UPPER(js(l_o, 'coupon'));
    l_pr   NUMBER := NVL(jn(l_o, 'priority'), 100);
    l_sk   VARCHAR2(1) := NVL(js(l_o, 'stackable'), 'N');
    l_st   VARCHAR2(30) := NVL(js(l_o, 'status'), 'ACTIVE');
    l_tid  NUMBER;
    l_tc   VARCHAR2(50);
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'SAL_PROMOTION.CREATE' ELSE 'SAL_PROMOTION.UPDATE' END);
    NOONA_CORE_PKG.assert(l_code IS NOT NULL AND js(l_o, 'name') IS NOT NULL, 'NOONA-PRC-030', 'رمز العرض واسمه مطلوبان', 'Code and name are required');
    NOONA_CORE_PKG.assert(l_tp IN ('PCT_OFF', 'AMOUNT_OFF', 'FIXED_PRICE', 'BUY_X_GET_Y', 'SPEND_PCT', 'SPEND_AMOUNT'), 'NOONA-PRC-031',
      'اختر نوع العرض', 'Choose the promotion type');
    NOONA_CORE_PKG.assert(l_v >= 0 AND (l_tp NOT IN ('PCT_OFF', 'SPEND_PCT') OR l_v BETWEEN 0.01 AND 100), 'NOONA-PRC-032',
      'نسبة الخصم بين 0.01 و 100%', 'Discount percent 0.01-100');
    NOONA_CORE_PKG.assert(l_tp NOT IN ('AMOUNT_OFF', 'SPEND_AMOUNT') OR l_v > 0, 'NOONA-PRC-033', 'أدخل مبلغ الخصم', 'Enter the discount amount');
    NOONA_CORE_PKG.assert(l_tp <> 'BUY_X_GET_Y' OR (NVL(l_b, 0) > 0 AND NVL(l_g, 0) > 0), 'NOONA-PRC-034',
      'عرض «اشتر واحصل» يحتاج كمية الشراء وكمية المجاني', 'Buy X get Y needs both quantities');
    NOONA_CORE_PKG.assert(l_tp NOT IN ('SPEND_PCT', 'SPEND_AMOUNT') OR NVL(jn(l_o, 'minAmount'), 0) > 0, 'NOONA-PRC-035',
      'عرض قيمة الفاتورة يحتاج أدنى قيمة شراء', 'Spend promotion needs a minimum amount');
    NOONA_CORE_PKG.assert(l_to IS NULL OR l_to >= l_from, 'NOONA-PRC-036', 'تاريخ النهاية قبل البداية', 'End date before start date');
    NOONA_CORE_PKG.assert(l_days IS NULL OR REGEXP_LIKE(l_days, '^[1-7](,[1-7])*$'), 'NOONA-PRC-037',
      'أيام الأسبوع أرقام من 1 (الأحد) إلى 7 مفصولة بفواصل', 'Days must be 1-7 separated by commas');
    NOONA_CORE_PKG.assert((l_hf IS NULL AND l_ht IS NULL) OR (l_hf BETWEEN 0 AND 23 AND l_ht BETWEEN 1 AND 24 AND l_ht > l_hf), 'NOONA-PRC-038',
      'ساعات العرض: من 0 إلى 23 والنهاية بعد البداية', 'Hours must be 0-23 and end after start');
    NOONA_CORE_PKG.assert(l_ch IS NULL OR REGEXP_LIKE(l_ch, '^(POS|SALES|HIS|AUT|RST)(,(POS|SALES|HIS|AUT|RST))*$'), 'NOONA-PRC-039',
      'القنوات: POS, SALES, HIS, AUT, RST', 'Channels must be POS, SALES, HIS, AUT, RST');
    IF l_id IS NULL THEN
      INSERT INTO sal_promotion (company_id, code, name_ar, promo_type, promo_value, buy_qty, get_qty, min_qty, min_amount, max_discount,
                                 channels, branch_id, days_of_week, hour_from, hour_to, coupon_code, priority_no, stackable,
                                 effective_from, effective_to, status_code)
      VALUES (company, l_code, l_nm, l_tp, l_v, CASE WHEN l_tp = 'BUY_X_GET_Y' THEN l_b END, CASE WHEN l_tp = 'BUY_X_GET_Y' THEN l_g END,
              l_mq, l_ma, l_mx, l_ch, l_br, l_days, l_hf, l_ht, l_cp, l_pr, l_sk, l_from, l_to, l_st)
      RETURNING id INTO l_id;
    ELSE
      UPDATE sal_promotion SET name_ar = l_nm, promo_type = l_tp, promo_value = l_v,
             buy_qty = CASE WHEN l_tp = 'BUY_X_GET_Y' THEN l_b END, get_qty = CASE WHEN l_tp = 'BUY_X_GET_Y' THEN l_g END,
             min_qty = l_mq, min_amount = l_ma, max_discount = l_mx, channels = l_ch,
             branch_id = l_br, days_of_week = l_days, hour_from = l_hf, hour_to = l_ht, coupon_code = l_cp,
             priority_no = l_pr, stackable = l_sk, effective_from = l_from, effective_to = l_to
       WHERE id = l_id AND company_id = company;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PRC-040', 'العرض غير موجود', 'Promotion not found');
    END IF;
    IF l_o.has('targets') THEN
      DELETE FROM sal_promotion_target WHERE promotion_id = l_id AND company_id = company;
      l_tg := l_o.get_array('targets');
      FOR i IN 0 .. l_tg.get_size - 1 LOOP
        l_t := TREAT(l_tg.get(i) AS JSON_OBJECT_T);
        l_tt := js(l_t, 'type');
        NOONA_CORE_PKG.assert(l_tt IN ('ITEM', 'ITEM_CATEGORY', 'ALL_ITEMS', 'HIS_SERVICE', 'HIS_SERVICE_TYPE', 'ALL_HIS', 'AUT_SERVICE',
          'AUT_CATEGORY', 'ALL_AUT'), 'NOONA-PRC-041', 'نوع هدف العرض غير معروف', 'Unknown promotion target');
        l_tid := jn(l_t, 'id');
        l_tc := js(l_t, 'code');
        IF l_tt IN ('ITEM', 'HIS_SERVICE', 'AUT_SERVICE') THEN check_target(l_tt, l_tid); END IF;
        INSERT INTO sal_promotion_target (company_id, promotion_id, target_type, target_id, target_code)
        VALUES (company, l_id, l_tt, CASE WHEN l_tt NOT LIKE 'ALL%' AND l_tt <> 'HIS_SERVICE_TYPE' THEN l_tid END,
                CASE WHEN l_tt = 'HIS_SERVICE_TYPE' THEN l_tc END);
        l_n := l_n + 1;
      END LOOP;
    END IF;
    SELECT COUNT(*) INTO l_n FROM sal_promotion_target WHERE promotion_id = l_id;
    NOONA_CORE_PKG.assert(l_tp IN ('SPEND_PCT', 'SPEND_AMOUNT') OR l_n > 0, 'NOONA-PRC-042',
      'حدد الأصناف أو الخدمات أو الفئات التي يشملها العرض', 'Choose what the promotion applies to');
    RETURN l_id;
  END save_promotion;

  PROCEDURE set_promotion_status(p_id IN NUMBER, p_status IN VARCHAR2) IS
  BEGIN
    guard('SAL_PROMOTION.UPDATE');
    NOONA_CORE_PKG.assert(p_status IN ('ACTIVE', 'PAUSED', 'CANCELLED'), 'NOONA-PRC-043', 'حالة غير صحيحة', 'Invalid status');
    UPDATE sal_promotion SET status_code = p_status WHERE id = p_id AND company_id = company AND status_code NOT IN ('CANCELLED', 'EXPIRED');
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PRC-040', 'العرض غير موجود أو منتهٍ', 'Promotion not found or ended');
  END set_promotion_status;

  FUNCTION target_label(p_type IN VARCHAR2, p_id IN NUMBER, p_code IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
  BEGIN
    RETURN type_label(p_type, p_code) || CASE WHEN p_id IS NOT NULL THEN ': ' || target_name(p_type, p_id) END;
  END target_label;

  PROCEDURE split_target(p_target VARCHAR2, o_type OUT VARCHAR2, o_id OUT NUMBER, o_code OUT VARCHAR2) IS
    l_rest VARCHAR2(100);
  BEGIN
    o_type := UPPER(REGEXP_SUBSTR(p_target, '^[A-Za-z_]+'));      -- النوع-المعرف أو النوع:المعرف
    l_rest := SUBSTR(p_target, LENGTH(o_type) + 2);
    o_id := NULL; o_code := NULL;
    IF o_type = 'HIS_SERVICE_TYPE' THEN o_code := l_rest;
    ELSIF l_rest IS NOT NULL THEN o_id := TO_NUMBER(l_rest);
    END IF;
  EXCEPTION WHEN VALUE_ERROR THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRC-041', 'نوع هدف العرض غير معروف', 'Unknown target');
  END split_target;

  PROCEDURE add_promotion_target(p_promo IN NUMBER, p_target IN VARCHAR2) IS
    l_tt VARCHAR2(30); l_id NUMBER; l_cd VARCHAR2(50); l_n NUMBER;
  BEGIN
    guard('SAL_PROMOTION.UPDATE');
    NOONA_CORE_PKG.assert(p_promo IS NOT NULL AND p_target IS NOT NULL, 'NOONA-PRC-044', 'اختر العرض والصنف أو الخدمة', 'Choose the promotion and target');
    SELECT COUNT(*) INTO l_n FROM sal_promotion WHERE id = p_promo AND company_id = company;
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-PRC-040', 'العرض غير موجود', 'Promotion not found');
    split_target(p_target, l_tt, l_id, l_cd);
    NOONA_CORE_PKG.assert(l_tt IN ('ITEM', 'ITEM_CATEGORY', 'ALL_ITEMS', 'HIS_SERVICE', 'HIS_SERVICE_TYPE', 'ALL_HIS', 'AUT_SERVICE',
      'AUT_CATEGORY', 'ALL_AUT'), 'NOONA-PRC-041', 'نوع هدف العرض غير معروف', 'Unknown promotion target');
    IF l_tt IN ('ITEM', 'HIS_SERVICE', 'AUT_SERVICE') THEN check_target(l_tt, l_id); END IF;
    SELECT COUNT(*) INTO l_n FROM sal_promotion_target
     WHERE promotion_id = p_promo AND target_type = l_tt AND NVL(target_id, -1) = NVL(l_id, -1) AND NVL(target_code, '-') = NVL(l_cd, '-');
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PRC-045', 'مضاف للعرض مسبقاً', 'Already in the promotion');
    INSERT INTO sal_promotion_target (company_id, promotion_id, target_type, target_id, target_code) VALUES (company, p_promo, l_tt, l_id, l_cd);
  END add_promotion_target;

  PROCEDURE remove_promotion_target(p_target_id IN NUMBER) IS
  BEGIN
    guard('SAL_PROMOTION.UPDATE');
    DELETE FROM sal_promotion_target WHERE id = p_target_id AND company_id = company;
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PRC-046', 'السطر غير موجود', 'Target not found');
  END remove_promotion_target;

  -- هل العرض ساري الآن للقناة والفرع والكوبون؟ (الأحد = 1)
  FUNCTION promo_live(p sal_promotion%ROWTYPE, p_channel VARCHAR2, p_coupon VARCHAR2, p_at DATE, p_branch NUMBER) RETURN BOOLEAN IS
    l_day VARCHAR2(1) := TO_CHAR(MOD(TRUNC(p_at) - TRUNC(p_at, 'IW') + 1, 7) + 1);
    l_hr  NUMBER := TO_NUMBER(TO_CHAR(p_at, 'HH24'));
  BEGIN
    RETURN p.status_code = 'ACTIVE' AND TRUNC(p_at) BETWEEN p.effective_from AND NVL(p.effective_to, TRUNC(p_at))
       AND (p.channels IS NULL OR INSTR(',' || p.channels || ',', ',' || p_channel || ',') > 0)
       AND (p.branch_id IS NULL OR p.branch_id = p_branch OR p_branch IS NULL)
       AND (p.days_of_week IS NULL OR INSTR(',' || p.days_of_week || ',', ',' || l_day || ',') > 0)
       AND (p.hour_from IS NULL OR (l_hr >= p.hour_from AND l_hr < NVL(p.hour_to, 24)))
       AND (p.coupon_code IS NULL OR p.coupon_code = UPPER(TRIM(p_coupon)));
  END promo_live;

  FUNCTION promo_matches(p_promo NUMBER, p_type VARCHAR2, p_id NUMBER, p_cat NUMBER, p_stp VARCHAR2) RETURN BOOLEAN IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM sal_promotion_target t
     WHERE t.promotion_id = p_promo
       AND ((t.target_type = p_type AND t.target_id = p_id)
         OR (t.target_type = 'ITEM_CATEGORY' AND p_type = 'ITEM' AND t.target_id IN (
               SELECT c.id FROM inv_item_category c START WITH c.id = p_cat CONNECT BY PRIOR c.parent_category_id = c.id))
         OR (t.target_type = 'HIS_SERVICE_TYPE' AND p_type = 'HIS_SERVICE' AND t.target_code = p_stp)
         OR (t.target_type = 'AUT_CATEGORY' AND p_type = 'AUT_SERVICE' AND t.target_id = p_cat)
         OR t.target_type = DECODE(p_type, 'ITEM', 'ALL_ITEMS', 'HIS_SERVICE', 'ALL_HIS', 'AUT_SERVICE', 'ALL_AUT'));
    RETURN l > 0;
  END promo_matches;

  -- خصم العرض لإجمالي السطر
  FUNCTION promo_amount(p sal_promotion%ROWTYPE, p_qty NUMBER, p_unit NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    IF p.min_qty IS NOT NULL AND p_qty < p.min_qty THEN RETURN 0; END IF;
    l := CASE p.promo_type
           WHEN 'PCT_OFF' THEN p_qty * p_unit * p.promo_value / 100
           WHEN 'AMOUNT_OFF' THEN p_qty * LEAST(p.promo_value, p_unit)
           WHEN 'FIXED_PRICE' THEN p_qty * GREATEST(p_unit - p.promo_value, 0)
           -- اشتر X واحصل على Y: كل (X + Y) وحدة منها Y مجاناً
           WHEN 'BUY_X_GET_Y' THEN FLOOR(p_qty / (p.buy_qty + p.get_qty)) * p.get_qty * p_unit
           ELSE 0 END;
    IF p.max_discount IS NOT NULL THEN l := LEAST(l, p.max_discount); END IF;
    RETURN ROUND(GREATEST(LEAST(l, p_qty * p_unit), 0), 2);
  END promo_amount;

  -- أفضل عرض غير قابل للجمع، أو مجموع القابلة للجمع إن كان أكبر
  PROCEDURE best_line(p_type VARCHAR2, p_id NUMBER, p_qty NUMBER, p_unit NUMBER, p_channel VARCHAR2, p_coupon VARCHAR2, p_at DATE,
                      p_branch NUMBER, o_promo OUT NUMBER, o_disc OUT NUMBER, o_name OUT VARCHAR2) IS
    l_cat NUMBER;
    l_stp VARCHAR2(30);
    l_d   NUMBER;
    l_sd  NUMBER := 0;
    l_sp  NUMBER;
    l_sn  VARCHAR2(1000);
  BEGIN
    o_promo := NULL; o_disc := 0; o_name := NULL;
    IF NVL(p_qty, 0) <= 0 OR NVL(p_unit, 0) <= 0 THEN RETURN; END IF;
    IF p_type = 'ITEM' THEN SELECT MAX(category_id) INTO l_cat FROM inv_item WHERE id = p_id;
    ELSIF p_type = 'HIS_SERVICE' THEN SELECT MAX(service_type) INTO l_stp FROM his_service WHERE id = p_id;
    ELSIF p_type = 'AUT_SERVICE' THEN SELECT MAX(category_id) INTO l_cat FROM aut_service WHERE id = p_id;
    END IF;
    FOR p IN (SELECT * FROM sal_promotion WHERE company_id = company AND status_code = 'ACTIVE'
                AND promo_type IN ('PCT_OFF', 'AMOUNT_OFF', 'FIXED_PRICE', 'BUY_X_GET_Y') ORDER BY priority_no, id) LOOP
      IF promo_live(p, p_channel, p_coupon, p_at, p_branch) AND promo_matches(p.id, p_type, p_id, l_cat, l_stp) THEN
        l_d := promo_amount(p, p_qty, p_unit);
        IF l_d > 0 THEN
          IF p.stackable = 'Y' THEN
            l_sd := l_sd + l_d; l_sp := NVL(l_sp, p.id); l_sn := l_sn || CASE WHEN l_sn IS NOT NULL THEN ' + ' END || p.name_ar;
          ELSIF l_d > o_disc THEN
            o_disc := l_d; o_promo := p.id; o_name := p.name_ar;
          END IF;
        END IF;
      END IF;
    END LOOP;
    l_sd := LEAST(l_sd, p_qty * p_unit);
    IF l_sd > o_disc THEN o_disc := l_sd; o_promo := l_sp; o_name := l_sn; END IF;
  END best_line;

  FUNCTION line_promo(p_type IN VARCHAR2, p_id IN NUMBER, p_qty IN NUMBER, p_unit_price IN NUMBER, p_channel IN VARCHAR2,
                      p_coupon IN VARCHAR2 DEFAULT NULL, p_at IN DATE DEFAULT NULL, p_branch IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_p NUMBER; l_d NUMBER; l_n VARCHAR2(1000); l_free NUMBER;
  BEGIN
    best_line(p_type, p_id, p_qty, p_unit_price, UPPER(p_channel), p_coupon, NVL(p_at, SYSDATE), p_branch, l_p, l_d, l_n);
    IF l_p IS NULL THEN RETURN '{}'; END IF;
    l_free := CASE WHEN p_unit_price > 0 THEN ROUND(l_d / p_unit_price, 3) END;
    RETURN '{"promoId":' || l_p || ',"name":' || jt(l_n) || ',"text":' || jt(promotion_text(l_p)) || ',"discount":' || num(l_d)
        || ',"freeQty":' || num(l_free) || ',"net":' || num(ROUND(p_qty * p_unit_price - l_d, 2)) || '}';
  END line_promo;

  FUNCTION line_discount(p_type IN VARCHAR2, p_id IN NUMBER, p_qty IN NUMBER, p_unit_price IN NUMBER, p_channel IN VARCHAR2,
                         p_coupon IN VARCHAR2 DEFAULT NULL, p_at IN DATE DEFAULT NULL, p_branch IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_p NUMBER; l_d NUMBER; l_n VARCHAR2(1000);
  BEGIN
    best_line(p_type, p_id, p_qty, p_unit_price, UPPER(p_channel), p_coupon, NVL(p_at, SYSDATE), p_branch, l_p, l_d, l_n);
    RETURN NVL(l_d, 0);
  END line_discount;

  FUNCTION doc_promo(p_channel IN VARCHAR2, p_total IN NUMBER, p_coupon IN VARCHAR2 DEFAULT NULL, p_at IN DATE DEFAULT NULL,
                     p_branch IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_best NUMBER := 0;
    l_id   NUMBER;
    l_nm   VARCHAR2(400);
    l_d    NUMBER;
  BEGIN
    FOR p IN (SELECT * FROM sal_promotion WHERE company_id = company AND status_code = 'ACTIVE'
                AND promo_type IN ('SPEND_PCT', 'SPEND_AMOUNT') AND NVL(p_total, 0) >= NVL(min_amount, 0) ORDER BY priority_no, id) LOOP
      IF promo_live(p, UPPER(p_channel), p_coupon, NVL(p_at, SYSDATE), p_branch) THEN
        l_d := CASE p.promo_type WHEN 'SPEND_PCT' THEN p_total * p.promo_value / 100 ELSE p.promo_value END;
        IF p.max_discount IS NOT NULL THEN l_d := LEAST(l_d, p.max_discount); END IF;
        l_d := ROUND(LEAST(l_d, p_total), 2);
        IF l_d > l_best THEN l_best := l_d; l_id := p.id; l_nm := p.name_ar; END IF;
      END IF;
    END LOOP;
    IF l_id IS NULL THEN RETURN '{}'; END IF;
    RETURN '{"promoId":' || l_id || ',"name":' || jt(l_nm) || ',"text":' || jt(promotion_text(l_id)) || ',"discount":' || num(l_best) || '}';
  END doc_promo;

  FUNCTION price_line(p_type IN VARCHAR2, p_id IN NUMBER, p_qty IN NUMBER, p_channel IN VARCHAR2,
                      p_coupon IN VARCHAR2 DEFAULT NULL, p_branch IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_price NUMBER := current_price(p_type, p_id);
    l_p NUMBER; l_d NUMBER; l_n VARCHAR2(1000);
  BEGIN
    best_line(p_type, p_id, NVL(p_qty, 1), l_price, UPPER(p_channel), p_coupon, SYSDATE, p_branch, l_p, l_d, l_n);
    RETURN '{"price":' || num(l_price) || ',"promoId":' || num(l_p) || ',"promo":' || jt(l_n) || ',"discount":' || num(NVL(l_d, 0))
        || ',"net":' || num(ROUND(NVL(p_qty, 1) * NVL(l_price, 0) - NVL(l_d, 0), 2)) || '}';
  END price_line;

  FUNCTION quote_cart(p_doc IN CLOB, p_channel IN VARCHAR2) RETURN CLOB IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_ls   JSON_ARRAY_T := CASE WHEN l_o.has('lines') THEN l_o.get_array('lines') ELSE JSON_ARRAY_T() END;
    l_l    JSON_OBJECT_T;
    l_cp   VARCHAR2(50) := js(l_o, 'coupon');
    l_br   NUMBER := jn(l_o, 'branch');
    l_out  CLOB := '[';
    l_p    NUMBER; l_d NUMBER; l_n VARCHAR2(1000);
    l_q    NUMBER; l_u NUMBER;
    l_tot  NUMBER := 0;
    l_ld   NUMBER := 0;
    l_doc  CLOB;
    l_dd   NUMBER := 0;
  BEGIN
    FOR i IN 0 .. l_ls.get_size - 1 LOOP
      l_l := TREAT(l_ls.get(i) AS JSON_OBJECT_T);
      l_q := NVL(jn(l_l, 'q'), 0); l_u := NVL(jn(l_l, 'p'), 0);
      l_d := 0; l_n := NULL; l_p := NULL;
      IF NVL(js(l_l, 'man'), 'N') = 'N' THEN
        best_line(NVL(js(l_l, 't'), 'ITEM'), jn(l_l, 'id'), l_q, l_u, UPPER(p_channel), l_cp, SYSDATE, l_br, l_p, l_d, l_n);
      ELSE
        l_d := NVL(jn(l_l, 'disc'), 0);
      END IF;
      l_tot := l_tot + l_q * l_u - NVL(l_d, 0);
      l_ld := l_ld + CASE WHEN NVL(js(l_l, 'man'), 'N') = 'N' THEN NVL(l_d, 0) ELSE 0 END;
      l_out := l_out || CASE WHEN i > 0 THEN ',' END || '{"k":' || NVL(num(jn(l_l, 'k')), TO_CHAR(i)) || ',"disc":' || num(NVL(l_d, 0))
            || ',"promoId":' || num(l_p) || ',"promo":' || jt(l_n) || '}';
    END LOOP;
    l_doc := doc_promo(p_channel, l_tot, l_cp, SYSDATE, l_br);
    IF l_doc <> '{}' THEN l_dd := JSON_OBJECT_T.parse(l_doc).get_number('discount'); END IF;
    RETURN '{"lines":' || l_out || '],"doc":' || l_doc || ',"lineDisc":' || num(l_ld) || ',"docDisc":' || num(l_dd)
        || ',"total":' || num(l_tot - l_dd) || '}';
  END quote_cart;

  FUNCTION active_promotions_json(p_channel IN VARCHAR2) RETURN CLOB IS
    l CLOB := '[';
    l_first BOOLEAN := TRUE;
  BEGIN
    FOR p IN (SELECT * FROM sal_promotion WHERE company_id = company AND status_code = 'ACTIVE' ORDER BY priority_no, id) LOOP
      IF promo_live(p, UPPER(p_channel), p.coupon_code, SYSDATE, NULL) THEN
        l := l || CASE WHEN NOT l_first THEN ',' END || '{"id":' || p.id || ',"name":' || jt(p.name_ar) || ',"text":'
               || jt(promotion_text(p.id)) || ',"coupon":' || jt(p.coupon_code) || '}';
        l_first := FALSE;
      END IF;
    END LOOP;
    RETURN l || ']';
  END active_promotions_json;

  -- ================================================================ الباقات
  FUNCTION save_bundle(p_doc IN CLOB, p_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := p_id;
    l_mt   VARCHAR2(30) := NVL(js(l_o, 'method'), 'FIXED_PRICE');
    l_v    NUMBER := jn(l_o, 'value');
    l_code VARCHAR2(50) := UPPER(js(l_o, 'code'));
    l_ch   VARCHAR2(200) := UPPER(REPLACE(js(l_o, 'channels'), ' ', ''));
    l_ls   JSON_ARRAY_T;
    l_l    JSON_OBJECT_T;
    l_tt   VARCHAR2(30);
    l_n    NUMBER;
    l_list NUMBER := 0;
    l_nm   VARCHAR2(200) := js(l_o, 'name');
    l_ds   VARCHAR2(4000) := js(l_o, 'desc');
    l_inc  VARCHAR2(1) := NVL(js(l_o, 'incl'), 'N');
    l_fr   DATE := jd(l_o, 'from');
    l_to   DATE := jd(l_o, 'to');
    l_st   VARCHAR2(30) := NVL(js(l_o, 'status'), 'ACTIVE');
    l_tid  NUMBER;
    l_q    NUMBER;
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'SAL_BUNDLE.CREATE' ELSE 'SAL_BUNDLE.UPDATE' END);
    NOONA_CORE_PKG.assert(l_code IS NOT NULL AND js(l_o, 'name') IS NOT NULL, 'NOONA-PRC-050', 'رمز الباقة واسمها مطلوبان', 'Code and name are required');
    NOONA_CORE_PKG.assert(l_mt IN ('FIXED_PRICE', 'PCT_OFF', 'AMOUNT_OFF'), 'NOONA-PRC-051', 'اختر طريقة سعر الباقة', 'Choose the bundle pricing method');
    NOONA_CORE_PKG.assert(l_v IS NOT NULL AND l_v >= 0 AND (l_mt <> 'PCT_OFF' OR l_v <= 100), 'NOONA-PRC-052',
      'أدخل سعر الباقة أو نسبة الخصم (حتى 100%) أو مبلغه', 'Enter the bundle price, percent or amount');
    NOONA_CORE_PKG.assert(l_ch IS NULL OR REGEXP_LIKE(l_ch, '^(POS|SALES|HIS|AUT|RST)(,(POS|SALES|HIS|AUT|RST))*$'), 'NOONA-PRC-039',
      'القنوات: POS, SALES, HIS, AUT, RST', 'Channels must be POS, SALES, HIS, AUT, RST');
    IF l_id IS NULL THEN
      INSERT INTO sal_bundle (company_id, code, name_ar, description, channels, pricing_method, pricing_value, price_includes_tax,
                              effective_from, effective_to, status_code)
      VALUES (company, l_code, l_nm, l_ds, l_ch, l_mt, l_v, l_inc, NVL(l_fr, TRUNC(SYSDATE)), l_to, l_st)
      RETURNING id INTO l_id;
    ELSE
      UPDATE sal_bundle SET name_ar = l_nm, description = l_ds, channels = l_ch, pricing_method = l_mt,
             pricing_value = l_v, price_includes_tax = l_inc, effective_from = NVL(l_fr, effective_from), effective_to = l_to
       WHERE id = l_id AND company_id = company;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PRC-053', 'الباقة غير موجودة', 'Bundle not found');
    END IF;
    IF l_o.has('lines') THEN
      DELETE FROM sal_bundle_line WHERE bundle_id = l_id AND company_id = company;
      l_ls := l_o.get_array('lines');
      FOR i IN 0 .. l_ls.get_size - 1 LOOP
        l_l := TREAT(l_ls.get(i) AS JSON_OBJECT_T);
        l_tt := js(l_l, 'type');
        NOONA_CORE_PKG.assert(l_tt IN ('ITEM', 'HIS_SERVICE', 'AUT_SERVICE'), 'NOONA-PRC-054', 'مكون الباقة صنف أو خدمة', 'Component must be an item or service');
        l_tid := jn(l_l, 'id');
        l_q := NVL(jn(l_l, 'qty'), 1);
        check_target(l_tt, l_tid);
        NOONA_CORE_PKG.assert(l_q > 0, 'NOONA-PRC-055', 'كمية المكون أكبر من صفر', 'Quantity must be positive');
        INSERT INTO sal_bundle_line (company_id, bundle_id, target_type, target_id, quantity, sort_order)
        VALUES (company, l_id, l_tt, l_tid, l_q, i + 1);
      END LOOP;
    END IF;
    SELECT COUNT(*) INTO l_n FROM sal_bundle_line WHERE bundle_id = l_id;
    NOONA_CORE_PKG.assert(l_n >= 2, 'NOONA-PRC-056', 'الباقة تضم مكونين على الأقل', 'A bundle needs at least two components');
    FOR c IN (SELECT target_type, target_id, quantity FROM sal_bundle_line WHERE bundle_id = l_id) LOOP
      l_list := l_list + c.quantity * NVL(current_price(c.target_type, c.target_id), 0);
    END LOOP;
    NOONA_CORE_PKG.assert(l_mt <> 'FIXED_PRICE' OR l_v <= l_list, 'NOONA-PRC-057',
      'سعر الباقة (' || fmt(l_v) || ') أعلى من مجموع أسعار مكوناتها (' || fmt(l_list) || ')', 'Bundle price exceeds components total');
    RETURN l_id;
  END save_bundle;

  PROCEDURE set_bundle_status(p_id IN NUMBER, p_status IN VARCHAR2) IS
  BEGIN
    guard('SAL_BUNDLE.UPDATE');
    NOONA_CORE_PKG.assert(p_status IN ('ACTIVE', 'INACTIVE'), 'NOONA-PRC-058', 'حالة غير صحيحة', 'Invalid status');
    UPDATE sal_bundle SET status_code = p_status WHERE id = p_id AND company_id = company;
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-PRC-053', 'الباقة غير موجودة', 'Bundle not found');
  END set_bundle_status;

  PROCEDURE add_bundle_line(p_bundle IN NUMBER, p_target IN VARCHAR2, p_qty IN NUMBER DEFAULT 1) IS
    l_tt VARCHAR2(30); l_id NUMBER; l_cd VARCHAR2(50); l_n NUMBER; l_so NUMBER;
  BEGIN
    guard('SAL_BUNDLE.UPDATE');
    NOONA_CORE_PKG.assert(p_bundle IS NOT NULL AND p_target IS NOT NULL, 'NOONA-PRC-059', 'اختر الباقة والمكون', 'Choose the bundle and component');
    SELECT COUNT(*) INTO l_n FROM sal_bundle WHERE id = p_bundle AND company_id = company;
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-PRC-053', 'الباقة غير موجودة', 'Bundle not found');
    split_target(p_target, l_tt, l_id, l_cd);
    NOONA_CORE_PKG.assert(l_tt IN ('ITEM', 'HIS_SERVICE', 'AUT_SERVICE'), 'NOONA-PRC-054', 'مكون الباقة صنف أو خدمة', 'Component must be an item or service');
    check_target(l_tt, l_id);
    NOONA_CORE_PKG.assert(NVL(p_qty, 1) > 0, 'NOONA-PRC-055', 'كمية المكون أكبر من صفر', 'Quantity must be positive');
    SELECT COUNT(*), NVL(MAX(sort_order), 0) + 1 INTO l_n, l_so FROM sal_bundle_line WHERE bundle_id = p_bundle AND target_type = l_tt AND target_id = l_id;
    IF l_n > 0 THEN
      UPDATE sal_bundle_line SET quantity = quantity + NVL(p_qty, 1) WHERE bundle_id = p_bundle AND target_type = l_tt AND target_id = l_id;
    ELSE
      SELECT NVL(MAX(sort_order), 0) + 1 INTO l_so FROM sal_bundle_line WHERE bundle_id = p_bundle;
      INSERT INTO sal_bundle_line (company_id, bundle_id, target_type, target_id, quantity, sort_order)
      VALUES (company, p_bundle, l_tt, l_id, NVL(p_qty, 1), l_so);
    END IF;
  END add_bundle_line;

  PROCEDURE remove_bundle_line(p_line_id IN NUMBER) IS
    l_b NUMBER; l_n NUMBER;
  BEGIN
    guard('SAL_BUNDLE.UPDATE');
    SELECT MAX(bundle_id) INTO l_b FROM sal_bundle_line WHERE id = p_line_id AND company_id = company;
    NOONA_CORE_PKG.assert(l_b IS NOT NULL, 'NOONA-PRC-046', 'السطر غير موجود', 'Line not found');
    SELECT COUNT(*) INTO l_n FROM sal_bundle_line WHERE bundle_id = l_b;
    NOONA_CORE_PKG.assert(l_n > 2, 'NOONA-PRC-056', 'الباقة تضم مكونين على الأقل', 'A bundle needs at least two components');
    DELETE FROM sal_bundle_line WHERE id = p_line_id;
  END remove_bundle_line;

  FUNCTION bundle_text(p_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    FOR b IN (SELECT pricing_method, pricing_value FROM sal_bundle WHERE id = p_id AND company_id = company) LOOP
      l := CASE b.pricing_method WHEN 'FIXED_PRICE' THEN 'سعر ثابت ' || fmt(b.pricing_value)
                                 WHEN 'PCT_OFF' THEN 'خصم ' || pct(b.pricing_value) || ' من مجموع المكونات'
                                 ELSE 'خصم ' || fmt(b.pricing_value) || ' من مجموع المكونات' END;
    END LOOP;
    RETURN l;
  END bundle_text;

  -- سعر الباقة ومجموع أسعار مكوناتها
  PROCEDURE bundle_totals(p_id NUMBER, o_list OUT NUMBER, o_price OUT NUMBER) IS
  BEGIN
    o_list := 0; o_price := NULL;
    FOR c IN (SELECT l.target_type, l.target_id, l.quantity FROM sal_bundle_line l WHERE l.bundle_id = p_id AND l.company_id = company) LOOP
      o_list := o_list + c.quantity * NVL(current_price(c.target_type, c.target_id), 0);
    END LOOP;
    FOR b IN (SELECT pricing_method, pricing_value FROM sal_bundle WHERE id = p_id AND company_id = company) LOOP
      o_price := ROUND(CASE b.pricing_method WHEN 'FIXED_PRICE' THEN b.pricing_value
                                             WHEN 'PCT_OFF' THEN o_list * (1 - b.pricing_value / 100)
                                             ELSE GREATEST(o_list - b.pricing_value, 0) END, 2);
    END LOOP;
  END bundle_totals;

  FUNCTION bundle_price(p_id IN NUMBER) RETURN NUMBER IS
    l_list NUMBER; l_price NUMBER;
  BEGIN
    bundle_totals(p_id, l_list, l_price);
    RETURN l_price;
  END bundle_price;

  -- توزيع سعر الباقة على المكونات بنسبة أسعارها الأصلية؛ فرق التقريب على آخر مكون
  FUNCTION bundle_json(p_id IN NUMBER) RETURN CLOB IS
    l      CLOB;
    l_list NUMBER;
    l_price NUMBER;
    l_done NUMBER := 0;
    l_net  NUMBER;
    l_unit NUMBER;
    l_k    PLS_INTEGER := 0;
    l_cnt  PLS_INTEGER;
  BEGIN
    bundle_totals(p_id, l_list, l_price);
    NOONA_CORE_PKG.assert(l_price IS NOT NULL, 'NOONA-PRC-053', 'الباقة غير موجودة', 'Bundle not found');
    SELECT COUNT(*) INTO l_cnt FROM sal_bundle_line WHERE bundle_id = p_id;
    FOR b IN (SELECT * FROM sal_bundle WHERE id = p_id) LOOP
      l := '{"id":' || b.id || ',"code":' || jt(b.code) || ',"name":' || jt(b.name_ar) || ',"incl":"' || b.price_includes_tax
        || '","listTotal":' || num(l_list) || ',"price":' || num(l_price) || ',"saving":' || num(l_list - l_price) || ',"lines":[';
    END LOOP;
    FOR c IN (SELECT target_type, target_id, quantity FROM sal_bundle_line WHERE bundle_id = p_id ORDER BY sort_order, id) LOOP
      l_k := l_k + 1;
      l_unit := NVL(current_price(c.target_type, c.target_id), 0);
      l_net := CASE WHEN l_k = l_cnt THEN l_price - l_done
                    WHEN l_list > 0 THEN ROUND(l_price * c.quantity * l_unit / l_list, 2)
                    ELSE ROUND(l_price / l_cnt, 2) END;
      l_done := l_done + l_net;
      l := l || CASE WHEN l_k > 1 THEN ',' END || '{"type":"' || c.target_type || '","id":' || c.target_id || ',"name":'
             || jt(target_name(c.target_type, c.target_id)) || ',"qty":' || num(c.quantity) || ',"unitList":' || num(l_unit)
             || ',"unitNet":' || num(ROUND(l_net / c.quantity, 4)) || ',"lineNet":' || num(l_net) || '}';
    END LOOP;
    RETURN l || ']}';
  END bundle_json;

  FUNCTION bundles_json(p_channel IN VARCHAR2) RETURN CLOB IS
    l CLOB := '[';
    l_first BOOLEAN := TRUE;
    l_list NUMBER; l_price NUMBER;
  BEGIN
    FOR b IN (SELECT id, code, name_ar FROM sal_bundle
               WHERE company_id = company AND status_code = 'ACTIVE' AND TRUNC(SYSDATE) BETWEEN effective_from AND NVL(effective_to, TRUNC(SYSDATE))
                 AND (channels IS NULL OR INSTR(',' || channels || ',', ',' || UPPER(p_channel) || ',') > 0) ORDER BY name_ar) LOOP
      bundle_totals(b.id, l_list, l_price);
      l := l || CASE WHEN NOT l_first THEN ',' END || '{"id":' || b.id || ',"code":' || jt(b.code) || ',"name":' || jt(b.name_ar)
             || ',"listTotal":' || num(l_list) || ',"price":' || num(l_price) || '}';
      l_first := FALSE;
    END LOOP;
    RETURN l || ']';
  END bundles_json;

  FUNCTION bundle_html(p_id IN NUMBER) RETURN CLOB IS
    l      CLOB;
    l_o    JSON_OBJECT_T;
    l_ls   JSON_ARRAY_T;
    l_l    JSON_OBJECT_T;
  BEGIN
    guard('SAL_BUNDLE.VIEW');
    l_o := JSON_OBJECT_T.parse(bundle_json(p_id));
    l_ls := l_o.get_array('lines');
    l := '<table class="nn-rpt"><thead><tr><th>المكون</th><th>الكمية</th><th>السعر الأصلي</th><th>سعره داخل الباقة</th></tr></thead><tbody>';
    FOR i IN 0 .. l_ls.get_size - 1 LOOP
      l_l := TREAT(l_ls.get(i) AS JSON_OBJECT_T);
      l := l || '<tr><td>' || esc(l_l.get_string('name')) || '</td><td class="nn-num">' || num(l_l.get_number('qty'))
             || '</td><td class="nn-num">' || fmt(l_l.get_number('qty') * l_l.get_number('unitList')) || '</td><td class="nn-num">'
             || fmt(l_l.get_number('lineNet')) || '</td></tr>';
    END LOOP;
    RETURN l || '</tbody><tfoot><tr><th colspan="2">المجموع / سعر الباقة</th><th class="nn-num">' || fmt(l_o.get_number('listTotal'))
             || '</th><th class="nn-num">' || fmt(l_o.get_number('price')) || '</th></tr><tr><th colspan="3">التوفير للعميل</th><th class="nn-num">'
             || fmt(l_o.get_number('saving')) || '</th></tr></tfoot></table>';
  END bundle_html;
END NOONA_PRC_PKG;
/
SHOW ERRORS PACKAGE BODY NOONA_PRC_PKG
