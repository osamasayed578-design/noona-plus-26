-- =============================================================================
-- NOONA PLUS ERP | المطاعم والكافتريا: NOONA_RST_PKG (فوق محرك نقاط البيع NOONA_POS_PKG)
--   الصالات والطاولات، الطلب المفتوح على الطاولة أو سفري أو توصيل أو على حساب عميل، إرسال دفعات للمطبخ وشاشة المطبخ،
--   النقل والدمج والتقسيم، طباعة الحساب، المحاسبة بالطاولة كاملة أو بالطلب: نقدي/شبكة/محافظ/مختلط أو آجل على العميل،
--   كل حساب يتحول إلى إيصال نقطة بيع (الوردية والدرج والضريبة والقيد عند إقفال الوردية كما في نقاط البيع)،
--   العملاء الآجلون وأرصدتهم والتحصيل منهم (سند تحصيل المبيعات)، ولوحة مبيعات المطعم.
-- =============================================================================

CREATE OR REPLACE PACKAGE NOONA_RST_PKG AUTHID DEFINER AS

  FUNCTION company RETURN NUMBER;
  -- تجهيز نقاط البيع إن لزم + صالة رئيسية بعشر طاولات + فئة «قائمة الطعام» + ترقيم الطلبات
  FUNCTION quick_setup RETURN NUMBER;
  FUNCTION is_ready RETURN VARCHAR2;
  FUNCTION default_terminal RETURN NUMBER;
  FUNCTION save_area(p_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_terminal_id IN NUMBER, p_sort IN NUMBER DEFAULT 0,
                     p_status IN VARCHAR2 DEFAULT 'ACTIVE') RETURN NUMBER;
  -- طاولات متتالية في الصالة: البادئة + الرقم (T1، T2...)؛ يعيد عدد المضاف
  FUNCTION add_tables(p_area_id IN NUMBER, p_count IN NUMBER, p_prefix IN VARCHAR2 DEFAULT 'T', p_seats IN NUMBER DEFAULT 4) RETURN NUMBER;
  FUNCTION save_table(p_id IN NUMBER, p_area_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_seats IN NUMBER,
                      p_shape IN VARCHAR2 DEFAULT 'SQUARE', p_status IN VARCHAR2 DEFAULT 'ACTIVE') RETURN NUMBER;
  -- قائمة الطعام: فئة فرعية تحت «قائمة الطعام» وصنف خدمي بسعر شامل الضريبة
  FUNCTION menu_category(p_code IN VARCHAR2, p_name_ar IN VARCHAR2) RETURN NUMBER;
  FUNCTION save_menu_item(p_id IN NUMBER, p_name_ar IN VARCHAR2, p_category_id IN NUMBER, p_price IN NUMBER,
                          p_status IN VARCHAR2 DEFAULT 'ACTIVE') RETURN NUMBER;

  -- ---------------------------------------------------------- التشغيل
  -- المحطة والوردية وطرق السداد والفئات والأصناف بأسعارها الشاملة والصالات
  FUNCTION boot_json(p_terminal_id IN NUMBER) RETURN CLOB;
  -- الطاولات بحالتها (FREE / OPEN / BILLED) والطلبات المفتوحة غير المرتبطة بطاولة
  FUNCTION floor_json(p_terminal_id IN NUMBER) RETURN CLOB;
  -- {"type":"DINE_IN|TAKEAWAY|DELIVERY","terminal","table","guests","waiter","cust","name","phone","addr","notes"}
  FUNCTION open_order(p_doc IN CLOB) RETURN NUMBER;
  -- {"id","guests","waiter","cust","name","phone","addr","notes","disc"}
  PROCEDURE update_order(p_doc IN CLOB);
  FUNCTION order_json(p_order_id IN NUMBER) RETURN CLOB;
  -- [{"i":item,"q":1,"n":"بدون بصل"}]
  PROCEDURE add_items(p_order_id IN NUMBER, p_lines IN CLOB);
  -- تعديل كمية سطر لم يرسل للمطبخ (0 = حذف)
  PROCEDURE set_qty(p_line_id IN NUMBER, p_qty IN NUMBER);
  PROCEDURE void_line(p_line_id IN NUMBER, p_reason IN VARCHAR2);
  -- يرسل الأسطر الجديدة كدفعة للمطبخ؛ يعيد رقم الدفعة (0 إن لا جديد)
  FUNCTION send_kitchen(p_order_id IN NUMBER) RETURN NUMBER;
  PROCEDURE move_table(p_order_id IN NUMBER, p_table_id IN NUMBER);
  PROCEDURE merge_orders(p_from_id IN NUMBER, p_into_id IN NUMBER);
  -- [{"l":line,"q":1}] ينقل الكميات إلى طلب جديد على نفس الطاولة؛ يعيد رقمه
  FUNCTION split_order(p_order_id IN NUMBER, p_lines IN CLOB) RETURN NUMBER;
  PROCEDURE cancel_order(p_order_id IN NUMBER, p_reason IN VARCHAR2);
  -- الحساب (فاتورة مبدئية) لطلب أو لكل الطلبات المفتوحة على طاولة؛ يحول الحالة إلى «طبع الحساب»
  FUNCTION bill_html(p_order_id IN NUMBER DEFAULT NULL, p_table_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  -- {"key":"uuid","orders":[1,2] | "table":5,"cust":acc,"disc":10,"pays":[{"m":"CASH","a":50},{"m":"CREDIT","a":20}]}
  -- يعيد نتيجة إيصال نقطة البيع {"ok","id","no","total","tax","paid","change","qr"}
  FUNCTION settle(p_doc IN CLOB) RETURN CLOB;
  FUNCTION orders_total(p_orders IN VARCHAR2) RETURN NUMBER;

  -- ---------------------------------------------------------- المطبخ
  FUNCTION kitchen_json(p_terminal_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  PROCEDURE kitchen_ready(p_order_id IN NUMBER, p_round IN NUMBER);
  PROCEDURE kitchen_served(p_order_id IN NUMBER);

  -- ---------------------------------------------------------- العملاء الآجلون والتحصيل
  FUNCTION credit_customers_json(p_term IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION quick_customer(p_name IN VARCHAR2, p_phone IN VARCHAR2, p_limit IN NUMBER DEFAULT NULL) RETURN NUMBER;
  -- {"cust","amount","place":"BOX:1","method":"CASH","ref","notes"}
  FUNCTION collect(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION credit_html(p_term IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION default_place RETURN VARCHAR2;

  -- ---------------------------------------------------------- اللوحات
  FUNCTION type_label(p_type IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION today_html RETURN CLOB;
  FUNCTION dashboard_html(p_from IN DATE, p_to IN DATE, p_terminal_id IN NUMBER DEFAULT NULL) RETURN CLOB;
END NOONA_RST_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_RST_PKG AS

  c_ord CONSTANT VARCHAR2(30) := 'RST_ORDER';

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;
  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END;
  FUNCTION fmt0(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(NVL(p, 0), 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.,''');
  END fmt0;
  FUNCTION fqty(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN RTRIM(RTRIM(TO_CHAR(NVL(p, 0), 'FM999G999G990D999', 'NLS_NUMERIC_CHARACTERS=''.,'''), '0'), '.');
  END fqty;
  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  FUNCTION type_label(p_type IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_type WHEN 'DINE_IN' THEN 'صالة' WHEN 'TAKEAWAY' THEN 'سفري' WHEN 'DELIVERY' THEN 'توصيل' ELSE p_type END;
  END type_label;

  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_status WHEN 'OPEN' THEN 'مفتوح' WHEN 'BILLED' THEN 'طبع الحساب' WHEN 'PAID' THEN 'مدفوع' WHEN 'CHARGED' THEN 'آجل على العميل'
                         WHEN 'CANCELLED' THEN 'ملغى' ELSE p_status END;
  END status_label;

  -- ================================================================ التجهيز
  FUNCTION default_terminal RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(terminal_id) INTO l FROM rst_area WHERE company_id = company AND status_code = 'ACTIVE' AND terminal_id IS NOT NULL;
    IF l IS NULL THEN
      SELECT MIN(id) INTO l FROM pos_terminal WHERE company_id = company AND status_code = 'ACTIVE';
    END IF;
    RETURN l;
  END default_terminal;

  FUNCTION is_ready RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM rst_area WHERE company_id = company;
    RETURN CASE WHEN l > 0 AND NOONA_POS_PKG.is_ready = 'Y' THEN 'Y' ELSE 'N' END;
  END is_ready;

  FUNCTION save_area(p_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_terminal_id IN NUMBER, p_sort IN NUMBER DEFAULT 0,
                     p_status IN VARCHAR2 DEFAULT 'ACTIVE') RETURN NUMBER IS
    l NUMBER := p_id;
  BEGIN
    guard('RST_AREA.' || CASE WHEN p_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(TRIM(p_code) IS NOT NULL AND TRIM(p_name_ar) IS NOT NULL, 'NOONA-RST-001', 'رمز واسم الصالة إلزاميان',
                          'Area code and name are required');
    IF l IS NULL THEN
      INSERT INTO rst_area (company_id, code, name_ar, terminal_id, sort_order, status_code)
      VALUES (company, UPPER(TRIM(p_code)), TRIM(p_name_ar), NVL(p_terminal_id, default_terminal), NVL(p_sort, 0), NVL(p_status, 'ACTIVE'))
      RETURNING id INTO l;
    ELSE
      UPDATE rst_area SET code = UPPER(TRIM(p_code)), name_ar = TRIM(p_name_ar), terminal_id = NVL(p_terminal_id, terminal_id),
                          sort_order = NVL(p_sort, 0), status_code = NVL(p_status, status_code)
       WHERE id = l AND company_id = company;
    END IF;
    RETURN l;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-RST-002', 'رمز الصالة مستخدم', 'Area code already exists');
  END save_area;

  FUNCTION save_table(p_id IN NUMBER, p_area_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_seats IN NUMBER,
                      p_shape IN VARCHAR2 DEFAULT 'SQUARE', p_status IN VARCHAR2 DEFAULT 'ACTIVE') RETURN NUMBER IS
    l NUMBER := p_id;
    l_n NUMBER;
  BEGIN
    guard('RST_TABLE.' || CASE WHEN p_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(p_area_id IS NOT NULL AND TRIM(p_code) IS NOT NULL, 'NOONA-RST-003', 'الصالة ورقم الطاولة إلزاميان',
                          'Area and table code are required');
    SELECT COUNT(*) INTO l_n FROM rst_table WHERE company_id = company AND code = UPPER(TRIM(p_code)) AND id <> NVL(p_id, -1);
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-RST-004', 'رقم الطاولة مستخدم: ' || UPPER(TRIM(p_code)), 'Table code already exists');
    IF l IS NULL THEN
      INSERT INTO rst_table (company_id, area_id, code, name_ar, seats, shape, sort_order, status_code)
      VALUES (company, p_area_id, UPPER(TRIM(p_code)), NVL(TRIM(p_name_ar), 'طاولة ' || UPPER(TRIM(p_code))), NVL(p_seats, 4),
              NVL(p_shape, 'SQUARE'), NVL(TO_NUMBER(REGEXP_SUBSTR(p_code, '[0-9]+')), 0), NVL(p_status, 'ACTIVE'))
      RETURNING id INTO l;
    ELSE
      UPDATE rst_table SET area_id = p_area_id, code = UPPER(TRIM(p_code)), name_ar = NVL(TRIM(p_name_ar), name_ar), seats = NVL(p_seats, seats),
                           shape = NVL(p_shape, shape), status_code = NVL(p_status, status_code)
       WHERE id = l AND company_id = company;
    END IF;
    RETURN l;
  END save_table;

  FUNCTION add_tables(p_area_id IN NUMBER, p_count IN NUMBER, p_prefix IN VARCHAR2 DEFAULT 'T', p_seats IN NUMBER DEFAULT 4) RETURN NUMBER IS
    l_pre VARCHAR2(10) := UPPER(NVL(TRIM(p_prefix), 'T'));
    l_max NUMBER;
    l_x   NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert(NVL(p_count, 0) BETWEEN 1 AND 200, 'NOONA-RST-005', 'عدد الطاولات بين 1 و200', 'Table count must be 1..200');
    SELECT NVL(MAX(TO_NUMBER(REGEXP_SUBSTR(code, '[0-9]+$'))), 0) INTO l_max FROM rst_table
     WHERE company_id = company AND REGEXP_LIKE(code, '^' || l_pre || '[0-9]+$');
    FOR k IN 1 .. p_count LOOP
      l_x := save_table(NULL, p_area_id, l_pre || (l_max + k), 'طاولة ' || (l_max + k), p_seats);
    END LOOP;
    RETURN p_count;
  END add_tables;

  FUNCTION menu_root RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM inv_item_category WHERE code = 'MENU';
    IF l IS NULL THEN
      l := NOONA_INV_PKG.create_category('MENU', 'قائمة الطعام', 'FOOD');
    END IF;
    RETURN l;
  END menu_root;

  FUNCTION menu_category(p_code IN VARCHAR2, p_name_ar IN VARCHAR2) RETURN NUMBER IS
    l NUMBER;
    l_r NUMBER := menu_root;
  BEGIN
    SELECT MIN(id) INTO l FROM inv_item_category WHERE code = UPPER(TRIM(p_code));
    IF l IS NULL THEN
      l := NOONA_INV_PKG.create_category(UPPER(TRIM(p_code)), TRIM(p_name_ar), 'FOOD', 'MENU');
    END IF;
    RETURN l;
  END menu_category;

  FUNCTION save_menu_item(p_id IN NUMBER, p_name_ar IN VARCHAR2, p_category_id IN NUMBER, p_price IN NUMBER,
                          p_status IN VARCHAR2 DEFAULT 'ACTIVE') RETURN NUMBER IS
    l_doc CLOB;
    l_cat NUMBER := NVL(p_category_id, menu_root);
  BEGIN
    NOONA_CORE_PKG.assert(NVL(p_price, -1) >= 0, 'NOONA-RST-006', 'أدخل سعر الصنف', 'Price is required');
    SELECT JSON_OBJECT('id' VALUE p_id, 'name' VALUE p_name_ar, 'type' VALUE 'NON_STOCK', 'cat' VALUE l_cat,
                       'price' VALUE p_price, 'incl' VALUE 'Y', 'tax' VALUE 'VAT15', 'sell' VALUE 'Y', 'buy' VALUE 'N',
                       'status' VALUE NVL(p_status, 'ACTIVE') RETURNING CLOB)
      INTO l_doc FROM dual;
    RETURN NOONA_INV_PKG.save_item(l_doc);
  END save_menu_item;

  FUNCTION quick_setup RETURN NUMBER IS
    l_n NUMBER := 0;
    l_x NUMBER;
    l_a NUMBER;
  BEGIN
    guard('RST_AREA.CREATE');
    IF NOONA_POS_PKG.is_ready = 'N' THEN
      l_n := NOONA_POS_PKG.quick_setup;
    END IF;
    NOONA_INV_PKG.ensure_sequence(c_ord, 'RO-');
    l_x := menu_root;
    SELECT COUNT(*) INTO l_x FROM rst_area WHERE company_id = company;
    IF l_x = 0 THEN
      l_a := save_area(NULL, 'HALL', 'الصالة الرئيسية', default_terminal, 10);
      l_x := add_tables(l_a, 10, 'T', 4);
      l_n := l_n + 11;
    END IF;
    RETURN l_n;
  END quick_setup;

  -- ================================================================ أدوات داخلية
  FUNCTION get_order(p_id NUMBER, p_lock BOOLEAN DEFAULT TRUE) RETURN rst_order%ROWTYPE IS
    l rst_order%ROWTYPE;
  BEGIN
    IF p_lock THEN
      SELECT * INTO l FROM rst_order WHERE id = p_id AND company_id = company FOR UPDATE;
    ELSE
      SELECT * INTO l FROM rst_order WHERE id = p_id AND company_id = company;
    END IF;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-RST-010', 'الطلب غير موجود', 'Order not found');
  END get_order;

  PROCEDURE assert_open(p_o rst_order%ROWTYPE) IS
  BEGIN
    NOONA_CORE_PKG.assert(p_o.status_code IN ('OPEN', 'BILLED'), 'NOONA-RST-011', 'الطلب ' || p_o.order_no || ' مقفل (' || status_label(p_o.status_code) || ')',
                          'Order is closed');
  END assert_open;

  -- إعادة احتساب الإجماليات (السعر شامل الضريبة، والخصم نسبة على الحساب)
  PROCEDURE recalc(p_id NUMBER) IS
    l_gross NUMBER;
    l_tax   NUMBER;
    l_pct   NUMBER;
  BEGIN
    SELECT NVL(discount_pct, 0) INTO l_pct FROM rst_order WHERE id = p_id;
    SELECT NVL(SUM(ROUND(l.line_total * (1 - l_pct / 100), 2)), 0),
           NVL(SUM(ROUND(l.line_total * (1 - l_pct / 100), 2)
                   - ROUND(ROUND(l.line_total * (1 - l_pct / 100), 2) / (1 + NOONA_INV_PKG.tax_rate(NOONA_INV_PKG.item_tax_code(l.item_id, 'SALE')) / 100), 2)), 0)
      INTO l_gross, l_tax
      FROM rst_order_line l WHERE l.order_id = p_id AND l.kitchen_status <> 'VOID';
    UPDATE rst_order SET total_amount = l_gross, tax_amount = l_tax, subtotal = l_gross - l_tax WHERE id = p_id;
  END recalc;

  -- السعر الشامل للوحدة الآن
  FUNCTION gross_price(p_item NUMBER) RETURN NUMBER IS
    l_p   NUMBER;
    l_inc VARCHAR2(1);
    l_tc  NUMBER;
    l_net NUMBER;
    l_tx  NUMBER;
  BEGIN
    NOONA_SAL_PKG.price_line(p_item, 1, l_p, 0, l_inc, l_tc, TRUNC(SYSDATE), l_net, l_tx);
    RETURN l_net + l_tx;
  END gross_price;

  -- ================================================================ التشغيل
  FUNCTION boot_json(p_terminal_id IN NUMBER) RETURN CLOB IS
    l_t     pos_terminal%ROWTYPE;
    l_items CLOB;
    l_cats  CLOB;
    l_areas CLOB;
    l_out   CLOB;
    l_co    NUMBER := company;
    l_vat   NUMBER := NOONA_INV_PKG.tax_id('VAT15');
    l_d     DATE := TRUNC(SYSDATE);
    l_shift NUMBER;
    l_root  NUMBER;
    l_menu  NUMBER;
  BEGIN
    guard('RST_ORDER.VIEW');
    SELECT * INTO l_t FROM pos_terminal WHERE id = p_terminal_id AND company_id = l_co;
    -- قائمة المطعم: أصناف «قائمة الطعام» وفئاتها الفرعية؛ وإن لم توجد بعد فكل الأصناف القابلة للبيع (عدا أدوية الوصفة)
    SELECT MIN(id) INTO l_root FROM inv_item_category WHERE code = 'MENU';
    SELECT COUNT(*) INTO l_menu FROM inv_item i JOIN inv_item_category g ON g.id = i.category_id
     WHERE (g.id = l_root OR g.parent_category_id = l_root) AND i.status_code = 'ACTIVE';
    l_shift := NOONA_POS_PKG.current_shift(p_terminal_id);
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE x.id, 'n' VALUE x.name_ar, 'c' VALUE x.category_id, 'no' VALUE x.item_no,
             'p' VALUE ROUND(CASE WHEN x.incl = 'Y' THEN x.sale_price ELSE x.sale_price * (1 + x.rate / 100) END, 2)) ORDER BY x.name_ar RETURNING CLOB)
      INTO l_items
      FROM (SELECT i.id, i.name_ar, i.category_id, i.item_no, c.sale_price, NVL(c.prices_include_tax, 'N') incl,
                   NVL((SELECT MAX(r.rate_pct) KEEP (DENSE_RANK LAST ORDER BY r.version_no) FROM loc_tax_rate r
                         WHERE r.tax_code_id = NVL(c.sales_tax_code_id, l_vat) AND r.effective_from <= l_d
                           AND (r.effective_to IS NULL OR r.effective_to >= l_d)), 0) rate
              FROM inv_item i JOIN inv_item_company c ON c.item_id = i.id AND c.company_id = l_co
              JOIN inv_item_category g ON g.id = i.category_id
             WHERE i.status_code = 'ACTIVE' AND i.is_sellable = 'Y' AND c.sale_price IS NOT NULL AND NVL(i.requires_prescription, 'N') = 'N'
               AND (l_menu = 0 OR g.id = l_root OR g.parent_category_id = l_root)) x;
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE g.id, 'n' VALUE g.name_ar) ORDER BY CASE WHEN g.parent_category_id IS NULL THEN 1 ELSE 0 END, g.name_ar
             RETURNING CLOB)
      INTO l_cats
      FROM inv_item_category g
     WHERE EXISTS (SELECT 1 FROM inv_item i JOIN inv_item_company c ON c.item_id = i.id AND c.company_id = l_co
                    WHERE i.category_id = g.id AND i.status_code = 'ACTIVE' AND i.is_sellable = 'Y' AND c.sale_price IS NOT NULL
                      AND NVL(i.requires_prescription, 'N') = 'N')
       AND (l_menu = 0 OR g.id = l_root OR g.parent_category_id = l_root);
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE id, 'n' VALUE name_ar) ORDER BY sort_order, code RETURNING CLOB)
      INTO l_areas FROM rst_area WHERE company_id = l_co AND status_code = 'ACTIVE' AND (terminal_id = p_terminal_id OR terminal_id IS NULL);
    SELECT JSON_OBJECT('terminal' VALUE JSON_OBJECT('id' VALUE l_t.id, 'code' VALUE l_t.code, 'n' VALUE l_t.name_ar),
             'shift' VALUE l_shift, 'user' VALUE NOONA_CTX_PKG.current_user_name,
             'place' VALUE 'BOX:' || l_t.cash_box_id,
             'methods' VALUE NOONA_PUR_PKG.payment_methods_json FORMAT JSON,
             'cats' VALUE NVL(l_cats, TO_CLOB('[]')) FORMAT JSON,
             'areas' VALUE NVL(l_areas, TO_CLOB('[]')) FORMAT JSON,
             'items' VALUE NVL(l_items, TO_CLOB('[]')) FORMAT JSON RETURNING CLOB)
      INTO l_out FROM dual;
    RETURN l_out;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-RST-012', 'نقطة البيع غير موجودة', 'Terminal not found');
  END boot_json;

  FUNCTION floor_json(p_terminal_id IN NUMBER) RETURN CLOB IS
    l_tables CLOB;
    l_orders CLOB;
    l_out    CLOB;
    l_co     NUMBER := company;
  BEGIN
    guard('RST_ORDER.VIEW');
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE t.id, 'code' VALUE t.code, 'n' VALUE t.name_ar, 'seats' VALUE t.seats, 'shape' VALUE t.shape,
             'area' VALUE t.area_id, 'orders' VALUE x.cnt, 'total' VALUE x.total, 'guests' VALUE x.guests, 'min' VALUE x.mins,
             'billed' VALUE x.billed, 'ready' VALUE x.ready, 'waiter' VALUE x.waiter, 'first' VALUE x.first_id,
             'state' VALUE CASE WHEN NVL(x.cnt, 0) = 0 THEN 'FREE' WHEN x.billed = x.cnt THEN 'BILLED' ELSE 'OPEN' END)
             ORDER BY a.sort_order, t.sort_order, t.code RETURNING CLOB)
      INTO l_tables
      FROM rst_table t JOIN rst_area a ON a.id = t.area_id
      LEFT JOIN (SELECT o.table_id, COUNT(*) cnt, SUM(o.total_amount) total, SUM(o.guests) guests, MIN(o.id) first_id,
                        ROUND((CAST(SYSTIMESTAMP AS DATE) - CAST(MIN(o.opened_at) AS DATE)) * 1440) mins,
                        SUM(CASE WHEN o.status_code = 'BILLED' THEN 1 ELSE 0 END) billed, MAX(o.waiter_name) waiter,
                        SUM((SELECT COUNT(*) FROM rst_order_line l WHERE l.order_id = o.id AND l.kitchen_status = 'READY')) ready
                   FROM rst_order o WHERE o.company_id = l_co AND o.status_code IN ('OPEN', 'BILLED') AND o.table_id IS NOT NULL
                  GROUP BY o.table_id) x ON x.table_id = t.id
     WHERE t.company_id = l_co AND t.status_code = 'ACTIVE' AND a.status_code = 'ACTIVE'
       AND (a.terminal_id = p_terminal_id OR a.terminal_id IS NULL);
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE o.id, 'no' VALUE o.order_no, 'type' VALUE o.order_type, 'tl' VALUE type_label(o.order_type),
             'name' VALUE NVL(o.customer_name, NOONA_SAL_PKG.customer_label(o.customer_account_id)), 'phone' VALUE o.customer_phone,
             'total' VALUE o.total_amount, 'st' VALUE o.status_code,
             'min' VALUE ROUND((CAST(SYSTIMESTAMP AS DATE) - CAST(o.opened_at AS DATE)) * 1440),
             'table' VALUE t.code) ORDER BY o.opened_at RETURNING CLOB)
      INTO l_orders
      FROM rst_order o LEFT JOIN rst_table t ON t.id = o.table_id
     WHERE o.company_id = l_co AND o.terminal_id = p_terminal_id AND o.status_code IN ('OPEN', 'BILLED');
    SELECT JSON_OBJECT('tables' VALUE NVL(l_tables, TO_CLOB('[]')) FORMAT JSON, 'orders' VALUE NVL(l_orders, TO_CLOB('[]')) FORMAT JSON,
                       'shift' VALUE NOONA_POS_PKG.current_shift(p_terminal_id) RETURNING CLOB)
      INTO l_out FROM dual;
    RETURN l_out;
  END floor_json;

  FUNCTION open_order(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_type  VARCHAR2(30) := NVL(l_o.get_string('type'), 'DINE_IN');
    l_term  NUMBER := l_o.get_number('terminal');
    l_table NUMBER := l_o.get_number('table');
    l_cust  NUMBER := l_o.get_number('cust');
    l_name  VARCHAR2(200) := TRIM(l_o.get_string('name'));
    l_phone VARCHAR2(30) := TRIM(l_o.get_string('phone'));
    l_addr  VARCHAR2(500) := TRIM(l_o.get_string('addr'));
    l_guest NUMBER := l_o.get_number('guests');
    l_wait  VARCHAR2(100) := TRIM(l_o.get_string('waiter'));
    l_notes VARCHAR2(500) := l_o.get_string('notes');
    l_br    NUMBER;
    l_no    VARCHAR2(50);
    l_id    NUMBER;
    l_area  NUMBER;
  BEGIN
    guard('RST_ORDER.CREATE');
    NOONA_CORE_PKG.assert(l_type IN ('DINE_IN', 'TAKEAWAY', 'DELIVERY'), 'NOONA-RST-013', 'نوع الطلب: صالة أو سفري أو توصيل', 'Invalid order type');
    IF l_table IS NOT NULL THEN
      SELECT MAX(t.area_id), MAX(a.terminal_id) INTO l_area, l_br FROM rst_table t JOIN rst_area a ON a.id = t.area_id
       WHERE t.id = l_table AND t.company_id = company AND t.status_code = 'ACTIVE';
      NOONA_CORE_PKG.assert(l_area IS NOT NULL, 'NOONA-RST-014', 'الطاولة غير موجودة أو موقوفة', 'Table not found');
      l_term := NVL(l_term, l_br);
      l_type := 'DINE_IN';
    END IF;
    NOONA_CORE_PKG.assert(l_type <> 'DINE_IN' OR l_table IS NOT NULL OR l_cust IS NOT NULL OR l_name IS NOT NULL, 'NOONA-RST-015',
                          'اختر الطاولة لطلب الصالة', 'Choose a table for a dine-in order');
    NOONA_CORE_PKG.assert(l_type <> 'DELIVERY' OR (l_phone IS NOT NULL OR l_cust IS NOT NULL), 'NOONA-RST-016',
                          'أدخل جوال العميل أو اختر العميل لطلب التوصيل', 'Phone or customer is required for delivery');
    l_term := NVL(l_term, default_terminal);
    SELECT MAX(branch_id), COUNT(*) INTO l_br, l_area FROM pos_terminal WHERE id = l_term AND company_id = company AND status_code = 'ACTIVE';
    NOONA_CORE_PKG.assert(l_area = 1, 'NOONA-RST-012', 'نقطة البيع غير موجودة', 'Terminal not found');
    IF l_cust IS NOT NULL AND l_name IS NULL THEN
      l_name := NOONA_SAL_PKG.customer_label(l_cust);
    END IF;
    l_no := NOONA_REFERENCE_PKG.next_doc_no(c_ord, company, l_br, TRUNC(SYSDATE), c_ord, NULL);
    INSERT INTO rst_order (company_id, branch_id, order_no, order_type, terminal_id, table_id, guests, waiter_name, customer_account_id,
                           customer_name, customer_phone, delivery_address, opened_at, kitchen_round, subtotal, tax_amount, total_amount, notes,
                           status_code)
    VALUES (company, l_br, l_no, l_type, l_term, l_table, l_guest, NVL(l_wait, NOONA_CTX_PKG.current_user_name), l_cust, l_name, l_phone,
            l_addr, SYSTIMESTAMP, 0, 0, 0, 0, l_notes, 'OPEN')
    RETURNING id INTO l_id;
    RETURN l_id;
  END open_order;

  PROCEDURE update_order(p_doc IN CLOB) IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id  NUMBER := l_o.get_number('id');
    l_r   rst_order%ROWTYPE := get_order(l_id);
    l_g   NUMBER := l_o.get_number('guests');
    l_c   NUMBER := l_o.get_number('cust');
    l_w   VARCHAR2(100) := l_o.get_string('waiter');
    l_n   VARCHAR2(200) := l_o.get_string('name');
    l_p   VARCHAR2(30) := l_o.get_string('phone');
    l_a   VARCHAR2(500) := l_o.get_string('addr');
    l_nt  VARCHAR2(500) := l_o.get_string('notes');
    l_d   NUMBER := l_o.get_number('disc');
    l_hd  VARCHAR2(1) := CASE WHEN l_o.has('disc') THEN 'Y' ELSE 'N' END;
    l_hc  VARCHAR2(1) := CASE WHEN l_o.has('cust') THEN 'Y' ELSE 'N' END;
  BEGIN
    guard('RST_ORDER.UPDATE');
    assert_open(l_r);
    NOONA_CORE_PKG.assert(NVL(l_d, 0) BETWEEN 0 AND 100, 'NOONA-RST-017', 'نسبة الخصم بين 0 و100', 'Discount must be 0..100');
    IF l_hc = 'Y' AND l_c IS NOT NULL AND l_n IS NULL THEN
      l_n := NOONA_SAL_PKG.customer_label(l_c);
    END IF;
    UPDATE rst_order SET guests = NVL(l_g, guests), waiter_name = NVL(l_w, waiter_name),
                         customer_account_id = CASE WHEN l_hc = 'Y' THEN l_c ELSE customer_account_id END,
                         customer_name = NVL(l_n, customer_name), customer_phone = NVL(l_p, customer_phone),
                         delivery_address = NVL(l_a, delivery_address), notes = NVL(l_nt, notes),
                         discount_pct = CASE WHEN l_hd = 'Y' THEN NULLIF(l_d, 0) ELSE discount_pct END
     WHERE id = l_id;
    recalc(l_id);
  END update_order;

  FUNCTION order_json(p_order_id IN NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    guard('RST_ORDER.VIEW');
    SELECT JSON_OBJECT('id' VALUE o.id, 'no' VALUE o.order_no, 'type' VALUE o.order_type, 'tl' VALUE type_label(o.order_type),
             'st' VALUE o.status_code, 'sl' VALUE status_label(o.status_code), 'table' VALUE o.table_id, 'tcode' VALUE t.code,
             'guests' VALUE o.guests, 'waiter' VALUE o.waiter_name, 'cust' VALUE o.customer_account_id,
             'name' VALUE o.customer_name, 'phone' VALUE o.customer_phone, 'addr' VALUE o.delivery_address, 'notes' VALUE o.notes,
             'disc' VALUE o.discount_pct, 'sub' VALUE o.subtotal, 'tax' VALUE o.tax_amount, 'total' VALUE o.total_amount,
             'round' VALUE o.kitchen_round, 'sale' VALUE o.pos_sale_id, 'terminal' VALUE o.terminal_id,
             'at' VALUE TO_CHAR(o.opened_at, 'HH24:MI'),
             'lines' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE l.id, 'i' VALUE l.item_id, 'n' VALUE i.name_ar, 'q' VALUE l.quantity,
                                     'p' VALUE l.unit_price, 't' VALUE l.line_total, 'nt' VALUE l.notes, 'k' VALUE l.kitchen_status,
                                     'r' VALUE l.round_no) ORDER BY l.line_no RETURNING CLOB)
                              FROM rst_order_line l JOIN inv_item i ON i.id = l.item_id WHERE l.order_id = o.id) FORMAT JSON,
             'siblings' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE s.id, 'no' VALUE s.order_no, 'total' VALUE s.total_amount)
                                      ORDER BY s.id RETURNING CLOB)
                                 FROM rst_order s WHERE s.table_id = o.table_id AND s.id <> o.id AND s.status_code IN ('OPEN', 'BILLED')) FORMAT JSON
             RETURNING CLOB)
      INTO l
      FROM rst_order o LEFT JOIN rst_table t ON t.id = o.table_id
     WHERE o.id = p_order_id AND o.company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-RST-010', 'الطلب غير موجود', 'Order not found');
  END order_json;

  PROCEDURE add_items(p_order_id IN NUMBER, p_lines IN CLOB) IS
    l_r   rst_order%ROWTYPE := get_order(p_order_id);
    l_no  NUMBER;
    l_ex  NUMBER;
    l_p   NUMBER;
    l_cnt PLS_INTEGER := 0;
  BEGIN
    SAVEPOINT rst_add;
    guard('RST_ORDER.UPDATE');
    assert_open(l_r);
    SELECT NVL(MAX(line_no), 0) INTO l_no FROM rst_order_line WHERE order_id = p_order_id;
    FOR r IN (SELECT * FROM JSON_TABLE(p_lines, '$[*]' COLUMNS (i NUMBER PATH '$.i', q NUMBER PATH '$.q', n VARCHAR2(200) PATH '$.n'))) LOOP
      CONTINUE WHEN r.i IS NULL;
      NOONA_CORE_PKG.assert(NVL(r.q, 1) > 0, 'NOONA-RST-018', 'الكمية يجب أن تكون موجبة', 'Quantity must be positive');
      -- نفس الصنف بنفس الملاحظة ولم يرسل للمطبخ: تزاد الكمية
      SELECT MIN(id) INTO l_ex FROM rst_order_line
       WHERE order_id = p_order_id AND item_id = r.i AND kitchen_status = 'NEW' AND NVL(notes, '~') = NVL(TRIM(r.n), '~');
      IF l_ex IS NOT NULL THEN
        UPDATE rst_order_line SET quantity = quantity + NVL(r.q, 1), line_total = ROUND((quantity + NVL(r.q, 1)) * unit_price, 2) WHERE id = l_ex;
      ELSE
        l_p := gross_price(r.i);
        l_no := l_no + 1;
        INSERT INTO rst_order_line (company_id, order_id, line_no, item_id, quantity, unit_price, line_total, notes, kitchen_status)
        VALUES (company, p_order_id, l_no, r.i, NVL(r.q, 1), l_p, ROUND(NVL(r.q, 1) * l_p, 2), TRIM(r.n), 'NEW');
      END IF;
      l_cnt := l_cnt + 1;
    END LOOP;
    IF l_cnt > 0 AND l_r.status_code = 'BILLED' THEN
      UPDATE rst_order SET status_code = 'OPEN', billed_at = NULL WHERE id = p_order_id;
    END IF;
    recalc(p_order_id);
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK TO rst_add;
    RAISE;
  END add_items;

  PROCEDURE set_qty(p_line_id IN NUMBER, p_qty IN NUMBER) IS
    l_oid NUMBER;
    l_k   VARCHAR2(30);
    l_r   rst_order%ROWTYPE;
  BEGIN
    guard('RST_ORDER.UPDATE');
    SELECT order_id, kitchen_status INTO l_oid, l_k FROM rst_order_line WHERE id = p_line_id AND company_id = company;
    l_r := get_order(l_oid);
    assert_open(l_r);
    NOONA_CORE_PKG.assert(l_k = 'NEW', 'NOONA-RST-019', 'الصنف أرسل للمطبخ؛ استخدم «إلغاء الصنف» مع السبب', 'Line already sent to kitchen');
    IF NVL(p_qty, 0) <= 0 THEN
      DELETE FROM rst_order_line WHERE id = p_line_id;
    ELSE
      UPDATE rst_order_line SET quantity = p_qty, line_total = ROUND(p_qty * unit_price, 2) WHERE id = p_line_id;
    END IF;
    recalc(l_oid);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-RST-020', 'السطر غير موجود', 'Line not found');
  END set_qty;

  PROCEDURE void_line(p_line_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_oid NUMBER;
    l_k   VARCHAR2(30);
    l_r   rst_order%ROWTYPE;
  BEGIN
    guard('RST_ORDER.UPDATE');
    SELECT order_id, kitchen_status INTO l_oid, l_k FROM rst_order_line WHERE id = p_line_id AND company_id = company;
    l_r := get_order(l_oid);
    assert_open(l_r);
    IF l_k = 'NEW' THEN
      DELETE FROM rst_order_line WHERE id = p_line_id;
    ELSE
      NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-RST-021', 'اذكر سبب إلغاء صنف أرسل للمطبخ', 'Reason is required');
      UPDATE rst_order_line SET kitchen_status = 'VOID', void_reason = SUBSTR(TRIM(p_reason), 1, 200) WHERE id = p_line_id;
      NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_ord, l_oid, 'VOID_LINE', 'SUCCESS', p_new_values => '{"line":' || p_line_id || '}');
    END IF;
    recalc(l_oid);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-RST-020', 'السطر غير موجود', 'Line not found');
  END void_line;

  FUNCTION send_kitchen(p_order_id IN NUMBER) RETURN NUMBER IS
    l_r rst_order%ROWTYPE := get_order(p_order_id);
    l_n NUMBER;
  BEGIN
    guard('RST_ORDER.UPDATE');
    SELECT COUNT(*) INTO l_n FROM rst_order_line WHERE order_id = p_order_id AND kitchen_status = 'NEW';
    IF l_n = 0 THEN RETURN 0; END IF;
    UPDATE rst_order SET kitchen_round = kitchen_round + 1 WHERE id = p_order_id RETURNING kitchen_round INTO l_n;
    UPDATE rst_order_line SET kitchen_status = 'SENT', round_no = l_n, sent_at = SYSTIMESTAMP
     WHERE order_id = p_order_id AND kitchen_status = 'NEW';
    RETURN l_n;
  END send_kitchen;

  PROCEDURE move_table(p_order_id IN NUMBER, p_table_id IN NUMBER) IS
    l_r rst_order%ROWTYPE := get_order(p_order_id);
    l_n NUMBER;
  BEGIN
    guard('RST_ORDER.UPDATE');
    assert_open(l_r);
    SELECT COUNT(*) INTO l_n FROM rst_table WHERE id = p_table_id AND company_id = company AND status_code = 'ACTIVE';
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-RST-014', 'الطاولة غير موجودة أو موقوفة', 'Table not found');
    UPDATE rst_order SET table_id = p_table_id, order_type = 'DINE_IN' WHERE id = p_order_id;
  END move_table;

  PROCEDURE merge_orders(p_from_id IN NUMBER, p_into_id IN NUMBER) IS
    l_f  rst_order%ROWTYPE := get_order(p_from_id);
    l_t  rst_order%ROWTYPE := get_order(p_into_id);
    l_no NUMBER;
  BEGIN
    guard('RST_ORDER.UPDATE');
    NOONA_CORE_PKG.assert(p_from_id <> p_into_id, 'NOONA-RST-022', 'اختر طلبين مختلفين للدمج', 'Choose two different orders');
    assert_open(l_f);
    assert_open(l_t);
    SELECT NVL(MAX(line_no), 0) INTO l_no FROM rst_order_line WHERE order_id = p_into_id;
    UPDATE rst_order_line SET order_id = p_into_id, line_no = l_no + line_no WHERE order_id = p_from_id;
    UPDATE rst_order SET guests = NVL(guests, 0) + NVL(l_f.guests, 0), kitchen_round = GREATEST(kitchen_round, l_f.kitchen_round),
                         status_code = 'OPEN', billed_at = NULL WHERE id = p_into_id;
    UPDATE rst_order SET status_code = 'CANCELLED', cancel_reason = 'دمج في الطلب ' || l_t.order_no, closed_at = SYSTIMESTAMP,
                         total_amount = 0, subtotal = 0, tax_amount = 0
     WHERE id = p_from_id;
    recalc(p_into_id);
  END merge_orders;

  FUNCTION split_order(p_order_id IN NUMBER, p_lines IN CLOB) RETURN NUMBER IS
    l_r   rst_order%ROWTYPE := get_order(p_order_id);
    l_new NUMBER;
    l_no  NUMBER := 0;
    l_ln  rst_order_line%ROWTYPE;
    l_cnt PLS_INTEGER := 0;
    l_doc CLOB;
  BEGIN
    SAVEPOINT rst_split;
    guard('RST_ORDER.UPDATE');
    assert_open(l_r);
    SELECT JSON_OBJECT('type' VALUE l_r.order_type, 'terminal' VALUE l_r.terminal_id, 'table' VALUE l_r.table_id,
                       'waiter' VALUE l_r.waiter_name, 'name' VALUE l_r.customer_name) INTO l_doc FROM dual;
    l_new := open_order(l_doc);
    UPDATE rst_order SET kitchen_round = l_r.kitchen_round WHERE id = l_new;
    FOR r IN (SELECT * FROM JSON_TABLE(p_lines, '$[*]' COLUMNS (l NUMBER PATH '$.l', q NUMBER PATH '$.q'))) LOOP
      CONTINUE WHEN r.l IS NULL OR NVL(r.q, 0) <= 0;
      SELECT * INTO l_ln FROM rst_order_line WHERE id = r.l AND order_id = p_order_id AND kitchen_status <> 'VOID';
      NOONA_CORE_PKG.assert(r.q <= l_ln.quantity, 'NOONA-RST-023', 'الكمية المنقولة أكبر من كمية الصنف', 'Split quantity exceeds line');
      l_no := l_no + 1;
      IF r.q = l_ln.quantity THEN
        UPDATE rst_order_line SET order_id = l_new, line_no = l_no WHERE id = r.l;
      ELSE
        UPDATE rst_order_line SET quantity = quantity - r.q, line_total = ROUND((quantity - r.q) * unit_price, 2) WHERE id = r.l;
        INSERT INTO rst_order_line (company_id, order_id, line_no, item_id, quantity, unit_price, line_total, notes, kitchen_status, round_no,
                                    sent_at, ready_at)
        VALUES (company, l_new, l_no, l_ln.item_id, r.q, l_ln.unit_price, ROUND(r.q * l_ln.unit_price, 2), l_ln.notes, l_ln.kitchen_status,
                l_ln.round_no, l_ln.sent_at, l_ln.ready_at);
      END IF;
      l_cnt := l_cnt + 1;
    END LOOP;
    NOONA_CORE_PKG.assert(l_cnt > 0, 'NOONA-RST-024', 'اختر الأصناف المراد فصلها في حساب مستقل', 'Choose lines to split');
    recalc(p_order_id);
    recalc(l_new);
    RETURN l_new;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ROLLBACK TO rst_split;
      NOONA_CORE_PKG.raise_error('NOONA-RST-020', 'السطر غير موجود في الطلب', 'Line not found');
    WHEN OTHERS THEN
      ROLLBACK TO rst_split;
      RAISE;
  END split_order;

  PROCEDURE cancel_order(p_order_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_r rst_order%ROWTYPE := get_order(p_order_id);
    l_n NUMBER;
  BEGIN
    guard('RST_ORDER.DELETE');
    assert_open(l_r);
    SELECT COUNT(*) INTO l_n FROM rst_order_line WHERE order_id = p_order_id AND kitchen_status NOT IN ('NEW', 'VOID');
    NOONA_CORE_PKG.assert(l_n = 0 OR TRIM(p_reason) IS NOT NULL, 'NOONA-RST-025', 'الطلب فيه أصناف أرسلت للمطبخ؛ اذكر سبب الإلغاء',
                          'Reason is required');
    UPDATE rst_order_line SET kitchen_status = 'VOID', void_reason = NVL(void_reason, SUBSTR(p_reason, 1, 200))
     WHERE order_id = p_order_id AND kitchen_status <> 'VOID';
    UPDATE rst_order SET status_code = 'CANCELLED', cancel_reason = SUBSTR(NVL(TRIM(p_reason), 'إلغاء قبل التحضير'), 1, 500),
                         closed_at = SYSTIMESTAMP, total_amount = 0, subtotal = 0, tax_amount = 0
     WHERE id = p_order_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_ord, p_order_id, 'CANCEL', 'SUCCESS');
  END cancel_order;

  -- قائمة معرفات الطلبات المطلوب محاسبتها
  FUNCTION ids_of(p_order_id NUMBER, p_table_id NUMBER) RETURN SYS.ODCINUMBERLIST IS
    l SYS.ODCINUMBERLIST;
  BEGIN
    IF p_table_id IS NOT NULL THEN
      SELECT id BULK COLLECT INTO l FROM rst_order
       WHERE table_id = p_table_id AND company_id = company AND status_code IN ('OPEN', 'BILLED') ORDER BY id;
    ELSE
      SELECT id BULK COLLECT INTO l FROM rst_order WHERE id = p_order_id AND company_id = company;
    END IF;
    NOONA_CORE_PKG.assert(l.COUNT > 0, 'NOONA-RST-026', 'لا توجد طلبات مفتوحة للمحاسبة', 'No open orders to bill');
    RETURN l;
  END ids_of;

  FUNCTION bill_html(p_order_id IN NUMBER DEFAULT NULL, p_table_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_ids  SYS.ODCINUMBERLIST := ids_of(p_order_id, p_table_id);
    l_h    CLOB;
    l_r    rst_order%ROWTYPE;
    l_sum  NUMBER := 0;
    l_tax  NUMBER := 0;
    l_gr   NUMBER := 0;
    l_hd   VARCHAR2(1000);
    l_tc   VARCHAR2(30);
  BEGIN
    guard('RST_ORDER.VIEW');
    l_r := get_order(l_ids(1));
    SELECT 'رقم الطلب: ' || LISTAGG(order_no, '، ') WITHIN GROUP (ORDER BY id) INTO l_hd FROM rst_order
     WHERE id IN (SELECT COLUMN_VALUE FROM TABLE(l_ids));
    SELECT MAX(code) INTO l_tc FROM rst_table WHERE id = l_r.table_id;
    l_h := '<div class="nn-receipt nn-rst-bill"><div class="nn-rc-head"><b>' || esc(NOONA_SAL_PKG.seller_name) || '</b><br>الحساب (ليس فاتورة ضريبية)<br>'
        || esc(l_hd) || CASE WHEN l_tc IS NOT NULL THEN '<br>الطاولة: ' || esc(l_tc) END || '</div>';
    l_h := l_h || '<div class="nn-rc-meta">' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI') || ' · ' || esc(type_label(l_r.order_type))
        || CASE WHEN l_r.guests IS NOT NULL THEN ' · ' || l_r.guests || ' أشخاص' END || ' · ' || esc(l_r.waiter_name) || '</div>'
        || '<table class="nn-rc-lines"><tbody>';
    FOR r IN (SELECT i.name_ar, SUM(l.quantity) q, l.unit_price, SUM(l.line_total) t
                FROM rst_order_line l JOIN inv_item i ON i.id = l.item_id
               WHERE l.order_id IN (SELECT COLUMN_VALUE FROM TABLE(l_ids)) AND l.kitchen_status <> 'VOID'
               GROUP BY i.name_ar, l.unit_price ORDER BY MIN(l.line_no)) LOOP
      l_h := l_h || '<tr><td>' || esc(r.name_ar) || '<br><small>' || fqty(r.q) || ' × ' || fmt0(r.unit_price) || '</small></td><td class="n">'
          || fmt0(r.t) || '</td></tr>';
      l_gr := l_gr + r.t;
    END LOOP;
    SELECT NVL(SUM(total_amount), 0), NVL(SUM(tax_amount), 0) INTO l_sum, l_tax FROM rst_order WHERE id IN (SELECT COLUMN_VALUE FROM TABLE(l_ids));
    l_h := l_h || '</tbody></table><table class="nn-rc-tot">'
        || CASE WHEN l_gr <> l_sum THEN '<tr><td>المجموع</td><td class="n">' || fmt0(l_gr) || '</td></tr><tr><td>الخصم</td><td class="n">'
                || fmt0(l_gr - l_sum) || '</td></tr>' END
        || '<tr><td>منها ضريبة القيمة المضافة</td><td class="n">' || fmt0(l_tax) || '</td></tr>'
        || '<tr class="nn-rc-grand"><td>المطلوب</td><td class="n">' || fmt0(l_sum) || '</td></tr></table>'
        || '<div class="nn-rc-foot">الأسعار شاملة الضريبة · تصدر الفاتورة الضريبية عند السداد</div></div>';
    UPDATE rst_order SET status_code = 'BILLED', billed_at = SYSTIMESTAMP
     WHERE id IN (SELECT COLUMN_VALUE FROM TABLE(l_ids)) AND status_code = 'OPEN';
    RETURN l_h;
  END bill_html;

  FUNCTION orders_total(p_orders IN VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(total_amount), 0) INTO l FROM rst_order
     WHERE company_id = company AND id IN (SELECT TO_NUMBER(REGEXP_SUBSTR(p_orders, '[^,]+', 1, LEVEL)) FROM dual
                                            CONNECT BY REGEXP_SUBSTR(p_orders, '[^,]+', 1, LEVEL) IS NOT NULL);
    RETURN l;
  END orders_total;

  FUNCTION settle(p_doc IN CLOB) RETURN CLOB IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_key   VARCHAR2(100) := l_o.get_string('key');
    l_table NUMBER := l_o.get_number('table');
    l_cust  NUMBER := l_o.get_number('cust');
    l_hd    BOOLEAN := l_o.has('disc');
    l_disc  NUMBER := l_o.get_number('disc');
    l_ids   SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();
    l_arr   JSON_ARRAY_T;
    l_r     rst_order%ROWTYPE;
    l_term  NUMBER;
    l_shift NUMBER;
    l_lines JSON_ARRAY_T := JSON_ARRAY_T();
    l_ln    JSON_OBJECT_T;
    l_sale  JSON_OBJECT_T := JSON_OBJECT_T();
    l_res   CLOB;
    l_rj    JSON_OBJECT_T;
    l_sid   NUMBER;
    l_cred  NUMBER := 0;
    l_tot   NUMBER;
    l_pct   NUMBER;
    l_mt    VARCHAR2(30);
    l_mc    VARCHAR2(30);
    l_ex    NUMBER;
    l_x     NUMBER;
  BEGIN
    SAVEPOINT rst_settle;
    guard('RST_ORDER.UPDATE');
    NOONA_CORE_PKG.assert(TRIM(l_key) IS NOT NULL, 'NOONA-RST-030', 'مفتاح العملية مفقود', 'Idempotency key is required');
    -- إعادة إرسال نفس العملية بعد انقطاع
    SELECT MIN(id) INTO l_ex FROM pos_sale WHERE sync_idempotency_key = l_key;
    IF l_ex IS NOT NULL THEN
      SELECT JSON_OBJECT('ok' VALUE 'true' FORMAT JSON, 'id' VALUE s.id, 'no' VALUE s.receipt_no, 'total' VALUE s.total_amount,
                         'tax' VALUE s.tax_amount, 'paid' VALUE s.paid_amount, 'change' VALUE s.change_amount RETURNING CLOB)
        INTO l_res FROM pos_sale s WHERE s.id = l_ex;
      RETURN l_res;
    END IF;
    IF l_table IS NOT NULL THEN
      l_ids := ids_of(NULL, l_table);
    ELSE
      l_arr := l_o.get_array('orders');
      NOONA_CORE_PKG.assert(l_arr IS NOT NULL AND l_arr.get_size > 0, 'NOONA-RST-026', 'لا توجد طلبات مفتوحة للمحاسبة', 'No open orders to bill');
      FOR k IN 0 .. l_arr.get_size - 1 LOOP
        l_ids.EXTEND;
        l_ids(l_ids.COUNT) := l_arr.get_number(k);
      END LOOP;
    END IF;
    FOR k IN 1 .. l_ids.COUNT LOOP
      l_r := get_order(l_ids(k));
      assert_open(l_r);
      NOONA_CORE_PKG.assert(l_term IS NULL OR l_term = l_r.terminal_id, 'NOONA-RST-031', 'الطلبات المختارة على نقاط بيع مختلفة',
                            'Orders belong to different terminals');
      l_term := l_r.terminal_id;
      l_cust := NVL(l_cust, l_r.customer_account_id);
      IF l_hd THEN
        UPDATE rst_order SET discount_pct = NULLIF(l_disc, 0) WHERE id = l_ids(k);
        recalc(l_ids(k));
      END IF;
      l_x := send_kitchen(l_ids(k));   -- ما لم يرسل بعد (طلب سفري سريع) يذهب للمطبخ مع السداد
    END LOOP;
    -- الوردية: تفتح تلقائياً للكاشير الحالي إن لم تكن مفتوحة
    l_shift := NOONA_POS_PKG.open_shift(l_term, 0);
    FOR r IN (SELECT l.item_id, l.quantity, l.unit_price, l.line_total, NVL(o.discount_pct, 0) pct
                FROM rst_order_line l JOIN rst_order o ON o.id = l.order_id
               WHERE l.order_id IN (SELECT COLUMN_VALUE FROM TABLE(l_ids)) AND l.kitchen_status <> 'VOID'
               ORDER BY l.order_id, l.line_no) LOOP
      l_ln := JSON_OBJECT_T();
      l_ln.put('i', r.item_id);
      l_ln.put('q', r.quantity);
      l_ln.put('p', r.unit_price);
      l_ln.put('inc', 'Y');
      l_ln.put('disc', r.line_total - ROUND(r.line_total * (1 - r.pct / 100), 2));
      l_lines.append(l_ln);
    END LOOP;
    NOONA_CORE_PKG.assert(l_lines.get_size > 0, 'NOONA-RST-032', 'الحساب لا يحتوي أصنافاً', 'Bill has no items');
    -- آجل: يلزم عميل مسجل
    l_arr := l_o.get_array('pays');
    IF l_arr IS NOT NULL THEN
      FOR k IN 0 .. l_arr.get_size - 1 LOOP
        l_ln := TREAT(l_arr.get(k) AS JSON_OBJECT_T);
        l_mc := l_ln.get_string('m');
        SELECT MAX(method_type) INTO l_mt FROM ref_payment_method WHERE code = l_mc;
        IF l_mt = 'CREDIT' THEN l_cred := l_cred + NVL(l_ln.get_number('a'), 0); END IF;
      END LOOP;
    END IF;
    NOONA_CORE_PKG.assert(l_cred = 0 OR (l_cust IS NOT NULL AND NOONA_SAL_PKG.is_walk_in(l_cust) = 'N'), 'NOONA-RST-033',
                          'اختر العميل الآجل (أو أضفه) قبل تسجيل المبلغ على حسابه', 'Choose a registered customer for credit');
    l_sale.put('key', l_key);
    l_sale.put('shift', l_shift);
    IF l_cust IS NOT NULL THEN l_sale.put('cust', l_cust); END IF;
    l_sale.put('lines', l_lines);
    l_sale.put('pays', NVL(l_arr, JSON_ARRAY_T()));
    l_res := NOONA_POS_PKG.sale(l_sale.to_clob);
    l_rj := JSON_OBJECT_T.parse(l_res);
    l_sid := l_rj.get_number('id');
    l_tot := l_rj.get_number('total');
    -- طلب فارغ على الطاولة (فتح ولم يضف إليه شيء) يلغى ولا يربط بالإيصال
    UPDATE rst_order o SET status_code = 'CANCELLED', cancel_reason = 'طلب فارغ أقفل مع حساب الطاولة', closed_at = SYSTIMESTAMP
     WHERE o.id IN (SELECT COLUMN_VALUE FROM TABLE(l_ids))
       AND NOT EXISTS (SELECT 1 FROM rst_order_line l WHERE l.order_id = o.id AND l.kitchen_status <> 'VOID');
    UPDATE rst_order SET pos_sale_id = l_sid, closed_at = SYSTIMESTAMP, customer_account_id = NVL(customer_account_id, l_cust),
                         settle_mode = CASE WHEN l_cred = 0 THEN 'PAID' WHEN l_cred >= l_tot THEN 'CREDIT' ELSE 'MIXED' END,
                         status_code = CASE WHEN l_cred = 0 THEN 'PAID' ELSE 'CHARGED' END
     WHERE id IN (SELECT COLUMN_VALUE FROM TABLE(l_ids)) AND status_code <> 'CANCELLED';
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_ord, l_ids(1), 'SETTLE', 'SUCCESS', p_new_values => '{"sale":' || l_sid || '}');
    RETURN l_res;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK TO rst_settle;   -- لا يبقى خصم أو إرسال للمطبخ من محاولة سداد فاشلة
    RAISE;
  END settle;

  -- ================================================================ المطبخ
  FUNCTION kitchen_json(p_terminal_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l CLOB;
  BEGIN
    guard('RST_ORDER.VIEW');
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE x.order_id, 'r' VALUE x.round_no, 'no' VALUE o.order_no, 'tl' VALUE type_label(o.order_type),
             'type' VALUE o.order_type, 'table' VALUE t.code, 'name' VALUE o.customer_name, 'waiter' VALUE o.waiter_name,
             'min' VALUE ROUND((CAST(SYSTIMESTAMP AS DATE) - CAST(x.sent AS DATE)) * 1440), 'ready' VALUE x.ready,
             'lines' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('n' VALUE i.name_ar, 'q' VALUE l.quantity, 'nt' VALUE l.notes, 'k' VALUE l.kitchen_status)
                                     ORDER BY l.line_no RETURNING CLOB)
                              FROM rst_order_line l JOIN inv_item i ON i.id = l.item_id
                             WHERE l.order_id = x.order_id AND l.round_no = x.round_no AND l.kitchen_status IN ('SENT', 'READY', 'VOID')) FORMAT JSON)
             ORDER BY x.ready, x.sent RETURNING CLOB)
      INTO l
      FROM (SELECT order_id, round_no, MIN(sent_at) sent, CASE WHEN MIN(CASE kitchen_status WHEN 'SENT' THEN 0 ELSE 1 END) = 1 THEN 'Y' ELSE 'N' END ready
              FROM rst_order_line WHERE company_id = company AND kitchen_status IN ('SENT', 'READY') AND sent_at > SYSTIMESTAMP - INTERVAL '1' DAY
             GROUP BY order_id, round_no) x
      JOIN rst_order o ON o.id = x.order_id LEFT JOIN rst_table t ON t.id = o.table_id
     WHERE (p_terminal_id IS NULL OR o.terminal_id = p_terminal_id) AND o.status_code <> 'CANCELLED';
    RETURN NVL(l, TO_CLOB('[]'));
  END kitchen_json;

  PROCEDURE kitchen_ready(p_order_id IN NUMBER, p_round IN NUMBER) IS
  BEGIN
    guard('RST_ORDER.VIEW');
    UPDATE rst_order_line SET kitchen_status = 'READY', ready_at = SYSTIMESTAMP
     WHERE order_id = p_order_id AND round_no = p_round AND kitchen_status = 'SENT' AND company_id = company;
  END kitchen_ready;

  PROCEDURE kitchen_served(p_order_id IN NUMBER) IS
  BEGIN
    guard('RST_ORDER.VIEW');
    UPDATE rst_order_line SET kitchen_status = 'SERVED', ready_at = NVL(ready_at, SYSTIMESTAMP)
     WHERE order_id = p_order_id AND kitchen_status IN ('SENT', 'READY') AND company_id = company;
  END kitchen_served;

  -- ================================================================ العملاء الآجلون والتحصيل
  FUNCTION credit_customers_json(p_term IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l CLOB;
    l_q VARCHAR2(200) := '%' || LOWER(TRIM(p_term)) || '%';
  BEGIN
    guard('RST_ORDER.VIEW');
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE x.id, 'n' VALUE x.name, 'no' VALUE x.customer_no, 'ph' VALUE x.phone,
             'bal' VALUE NOONA_SAL_PKG.customer_balance(x.id), 'lim' VALUE NOONA_SAL_PKG.credit_limit(x.id)) ORDER BY x.name RETURNING CLOB)
      INTO l
      FROM (SELECT a.id, p.display_name_ar name, c.customer_no,
                   (SELECT MAX(NVL(ct.mobile, ct.phone)) FROM ref_contact ct WHERE ct.party_id = p.id) phone
              FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id JOIN pty_party p ON p.id = c.party_id
             WHERE a.company_id = company AND c.is_walk_in = 'N' AND a.status_code = 'ACTIVE') x
     WHERE p_term IS NULL OR LOWER(x.name || ' ' || x.customer_no || ' ' || x.phone) LIKE l_q;
    RETURN NVL(l, TO_CLOB('[]'));
  END credit_customers_json;

  FUNCTION quick_customer(p_name IN VARCHAR2, p_phone IN VARCHAR2, p_limit IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_doc CLOB;
  BEGIN
    SELECT JSON_OBJECT('name' VALUE TRIM(p_name), 'phone' VALUE TRIM(p_phone), 'term' VALUE 'NET30', 'limit' VALUE p_limit, 'person' VALUE 'Y')
      INTO l_doc FROM dual;
    RETURN NOONA_SAL_PKG.save_customer(l_doc);
  END quick_customer;

  FUNCTION default_place RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT MAX(cash_box_id) INTO l FROM pos_terminal WHERE id = default_terminal;
    RETURN CASE WHEN l IS NOT NULL THEN 'BOX:' || l END;
  END default_place;

  FUNCTION collect(p_doc IN CLOB) RETURN NUMBER IS
    l_o JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_p VARCHAR2(30) := l_o.get_string('place');
    l_m VARCHAR2(30) := NVL(l_o.get_string('method'), 'CASH');
    l_b NUMBER;
  BEGIN
    IF l_p IS NULL THEN
      -- النقد إلى درج نقطة البيع، والشبكة والتحويل إلى حساب تسوية المحطة (أو أول حساب بنكي)
      IF l_m <> 'CASH' THEN
        SELECT MAX(bank_account_id) INTO l_b FROM pos_terminal WHERE id = default_terminal;
        IF l_b IS NULL THEN
          SELECT MIN(id) INTO l_b FROM csh_bank_account WHERE company_id = company AND status_code = 'ACTIVE';
        END IF;
      END IF;
      l_o.put('place', CASE WHEN l_b IS NOT NULL THEN 'BANK:' || l_b ELSE default_place END);
    END IF;
    l_o.put('method', l_m);
    RETURN NOONA_SAL_PKG.receive(l_o.to_clob);
  END collect;

  FUNCTION credit_html(p_term IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h   CLOB;
    l_tot NUMBER := 0;
    l_n   PLS_INTEGER := 0;
    l_q   VARCHAR2(200) := '%' || LOWER(TRIM(p_term)) || '%';
  BEGIN
    guard('RST_ORDER.VIEW');
    l_h := '<table class="nn-rst-cred"><thead><tr><th>العميل</th><th>الجوال</th><th class="n">مبيعات آجلة بالمطعم</th><th class="n">الرصيد المستحق</th>'
        || '<th class="n">حد الائتمان</th><th>آخر طلب</th><th></th></tr></thead><tbody>';
    FOR r IN (SELECT x.*, NOONA_SAL_PKG.customer_balance(x.id) bal, NOONA_SAL_PKG.credit_limit(x.id) lim
                FROM (SELECT a.id, p.display_name_ar name, c.customer_no,
                             (SELECT MAX(NVL(ct.mobile, ct.phone)) FROM ref_contact ct WHERE ct.party_id = p.id) phone,
                             (SELECT NVL(SUM(o.total_amount), 0) FROM rst_order o WHERE o.customer_account_id = a.id AND o.status_code = 'CHARGED') rst,
                             (SELECT MAX(o.closed_at) FROM rst_order o WHERE o.customer_account_id = a.id AND o.status_code IN ('CHARGED', 'PAID')) last_at
                        FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id JOIN pty_party p ON p.id = c.party_id
                       WHERE a.company_id = company AND c.is_walk_in = 'N') x
               WHERE (p_term IS NULL OR LOWER(x.name || ' ' || x.customer_no || ' ' || x.phone) LIKE l_q)
                 AND (x.rst > 0 OR NOONA_SAL_PKG.customer_balance(x.id) <> 0)
               ORDER BY NOONA_SAL_PKG.customer_balance(x.id) DESC) LOOP
      l_n := l_n + 1;
      l_tot := l_tot + r.bal;
      l_h := l_h || '<tr><td><b>' || esc(r.name) || '</b><br><small>' || esc(r.customer_no) || '</small></td><td>' || esc(r.phone) || '</td>'
          || '<td class="n">' || fmt0(r.rst) || '</td><td class="n"><b class="' || CASE WHEN r.bal > 0 THEN 'nn-neg' END || '">' || fmt0(r.bal)
          || '</b></td><td class="n">' || CASE WHEN r.lim IS NOT NULL THEN fmt0(r.lim) ELSE '—' END || '</td><td>'
          || TO_CHAR(r.last_at, 'YYYY-MM-DD') || '</td><td class="nn-rst-act">'
          || CASE WHEN r.bal > 0 THEN '<button type="button" class="t-Button t-Button--small t-Button--hot" data-collect="' || r.id || '" data-name="'
                  || esc(r.name) || '" data-bal="' || TO_CHAR(r.bal, 'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS=''.,''') || '">تحصيل</button> ' END
          || '<button type="button" class="t-Button t-Button--small" data-stmt="' || r.id || '">كشف حساب</button></td></tr>';
    END LOOP;
    IF l_n = 0 THEN
      l_h := l_h || '<tr><td colspan="7" class="nn-hint">لا يوجد عملاء آجلون عليهم أرصدة</td></tr>';
    END IF;
    RETURN l_h || '</tbody><tfoot><tr><td colspan="3">إجمالي المستحق على ' || l_n || ' عميل</td><td class="n"><b>' || fmt0(l_tot)
        || '</b></td><td colspan="3"></td></tr></tfoot></table>';
  END credit_html;

  -- ================================================================ اللوحات
  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_sub VARCHAR2 DEFAULT NULL, p_cls VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-rst-kpi ' || p_cls || '"><span>' || esc(p_label) || '</span><b>' || p_value || '</b>'
        || CASE WHEN p_sub IS NOT NULL THEN '<small>' || p_sub || '</small>' END || '</div>';
  END kpi;

  FUNCTION today_html RETURN CLOB IS
    l_sales NUMBER; l_n NUMBER; l_open NUMBER; l_openv NUMBER; l_busy NUMBER; l_tab NUMBER; l_cred NUMBER; l_kit NUMBER;
    l_from TIMESTAMP := CAST(TRUNC(SYSDATE) AS TIMESTAMP);
  BEGIN
    guard('RST_ORDER.VIEW');
    SELECT NVL(SUM(total_amount), 0), COUNT(*), NVL(SUM(CASE WHEN status_code = 'CHARGED' THEN total_amount END), 0)
      INTO l_sales, l_n, l_cred FROM rst_order WHERE company_id = company AND status_code IN ('PAID', 'CHARGED') AND closed_at >= l_from;
    SELECT COUNT(*), NVL(SUM(total_amount), 0), COUNT(DISTINCT table_id) INTO l_open, l_openv, l_busy
      FROM rst_order WHERE company_id = company AND status_code IN ('OPEN', 'BILLED');
    SELECT COUNT(*) INTO l_tab FROM rst_table WHERE company_id = company AND status_code = 'ACTIVE';
    SELECT COUNT(DISTINCT order_id || '-' || round_no) INTO l_kit FROM rst_order_line WHERE company_id = company AND kitchen_status = 'SENT';
    RETURN '<div class="nn-rst-kpis">'
        || kpi('مبيعات اليوم', fmt0(l_sales), l_n || ' طلب · متوسط ' || fmt0(CASE WHEN l_n > 0 THEN l_sales / l_n END), 'is-main')
        || kpi('الطاولات المشغولة', l_busy || ' / ' || l_tab, CASE WHEN l_tab > 0 THEN ROUND(l_busy * 100 / l_tab) || '% إشغال' END)
        || kpi('طلبات مفتوحة', TO_CHAR(l_open), fmt0(l_openv) || ' لم تحصل بعد')
        || kpi('في المطبخ', TO_CHAR(l_kit), 'دفعات تحت التحضير')
        || kpi('آجل اليوم', fmt0(l_cred), 'على حسابات العملاء', 'is-warn')
        || '</div>';
  END today_html;

  FUNCTION bars(p_title VARCHAR2, p_rows SYS_REFCURSOR, p_money BOOLEAN DEFAULT TRUE) RETURN CLOB IS
    TYPE t_r IS RECORD (lbl VARCHAR2(400), v NUMBER, c NUMBER);
    TYPE t_rs IS TABLE OF t_r;
    l_rs  t_rs;
    l_max NUMBER := 0;
    l_h   CLOB;
  BEGIN
    FETCH p_rows BULK COLLECT INTO l_rs;
    CLOSE p_rows;
    FOR k IN 1 .. l_rs.COUNT LOOP l_max := GREATEST(l_max, NVL(l_rs(k).v, 0)); END LOOP;
    l_h := '<section class="nn-rst-card"><h3>' || esc(p_title) || '</h3>';
    IF l_rs.COUNT = 0 THEN
      RETURN l_h || '<p class="nn-hint">لا توجد بيانات في الفترة</p></section>';
    END IF;
    FOR k IN 1 .. l_rs.COUNT LOOP
      l_h := l_h || '<div class="nn-rst-bar"><span class="l">' || esc(l_rs(k).lbl) || '</span><span class="b"><i style="width:'
          || CASE WHEN l_max > 0 THEN ROUND(NVL(l_rs(k).v, 0) * 100 / l_max) ELSE 0 END || '%"></i></span><span class="v">'
          || CASE WHEN p_money THEN fmt0(l_rs(k).v) ELSE fqty(l_rs(k).v) END
          || CASE WHEN l_rs(k).c IS NOT NULL THEN ' <small>(' || fqty(l_rs(k).c) || ')</small>' END || '</span></div>';
    END LOOP;
    RETURN l_h || '</section>';
  END bars;

  FUNCTION dashboard_html(p_from IN DATE, p_to IN DATE, p_terminal_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_f    TIMESTAMP := CAST(TRUNC(NVL(p_from, SYSDATE)) AS TIMESTAMP);
    l_t    TIMESTAMP := CAST(TRUNC(NVL(p_to, SYSDATE)) + 1 AS TIMESTAMP);
    l_co   NUMBER := company;
    l_tm   NUMBER := p_terminal_id;
    l_h    CLOB;
    l_cur  SYS_REFCURSOR;
    l_sales NUMBER; l_tax NUMBER; l_n NUMBER; l_g NUMBER; l_cred NUMBER; l_canc NUMBER; l_cv NUMBER; l_coll NUMBER; l_out NUMBER; l_disc NUMBER;
  BEGIN
    guard('RST_ORDER.VIEW');
    SELECT NVL(SUM(total_amount), 0), NVL(SUM(tax_amount), 0), COUNT(*), NVL(SUM(guests), 0),
           NVL(SUM(CASE WHEN status_code = 'CHARGED' THEN total_amount END), 0)
      INTO l_sales, l_tax, l_n, l_g, l_cred
      FROM rst_order WHERE company_id = l_co AND status_code IN ('PAID', 'CHARGED') AND closed_at >= l_f AND closed_at < l_t
       AND (l_tm IS NULL OR terminal_id = l_tm);
    SELECT COUNT(*) INTO l_canc FROM rst_order WHERE company_id = l_co AND status_code = 'CANCELLED' AND cancel_reason NOT LIKE 'دمج%'
       AND closed_at >= l_f AND closed_at < l_t AND (l_tm IS NULL OR terminal_id = l_tm);
    SELECT NVL(SUM(l.line_total), 0) INTO l_cv FROM rst_order_line l JOIN rst_order o ON o.id = l.order_id
     WHERE o.company_id = l_co AND l.kitchen_status = 'VOID' AND l.sent_at >= l_f AND l.sent_at < l_t AND (l_tm IS NULL OR o.terminal_id = l_tm);
    SELECT NVL(SUM(l.line_total), 0) - l_sales INTO l_disc FROM rst_order_line l JOIN rst_order o ON o.id = l.order_id
     WHERE o.company_id = l_co AND o.status_code IN ('PAID', 'CHARGED') AND l.kitchen_status <> 'VOID' AND o.closed_at >= l_f AND o.closed_at < l_t
       AND (l_tm IS NULL OR o.terminal_id = l_tm);
    -- التحصيل من العملاء الذين لهم حسابات آجلة بالمطعم، والمستحق عليهم الآن
    SELECT NVL(SUM(r.amount), 0) INTO l_coll FROM ar_receipt r
     WHERE r.company_id = l_co AND r.status_code = 'CONFIRMED' AND r.doc_date >= TRUNC(NVL(p_from, SYSDATE)) AND r.doc_date < TRUNC(NVL(p_to, SYSDATE)) + 1
       AND r.customer_account_id IN (SELECT customer_account_id FROM rst_order WHERE status_code = 'CHARGED');
    SELECT NVL(SUM(NOONA_SAL_PKG.customer_balance(a.id)), 0) INTO l_out
      FROM (SELECT DISTINCT customer_account_id id FROM rst_order WHERE company_id = l_co AND status_code = 'CHARGED') a;
    l_h := '<div class="nn-rst-dash"><div class="nn-rst-kpis">'
        || kpi('صافي المبيعات (شامل الضريبة)', fmt0(l_sales), 'منها ضريبة ' || fmt0(l_tax), 'is-main')
        || kpi('عدد الطلبات', TO_CHAR(l_n), 'متوسط الفاتورة ' || fmt0(CASE WHEN l_n > 0 THEN l_sales / l_n END))
        || kpi('عدد الأشخاص', TO_CHAR(l_g), 'متوسط الفرد ' || fmt0(CASE WHEN l_g > 0 THEN l_sales / l_g END))
        || kpi('مبيعات آجلة', fmt0(l_cred), 'المحصل في الفترة ' || fmt0(l_coll), 'is-warn')
        || kpi('المستحق على العملاء الآجلين', fmt0(l_out), 'الرصيد الحالي', CASE WHEN l_out > 0 THEN 'is-neg' END)
        || kpi('الخصومات والإلغاءات', fmt0(l_disc), 'خصم · ' || l_canc || ' طلب ملغى · أصناف ملغاة ' || fmt0(l_cv))
        || '</div><div class="nn-rst-grid">';
    OPEN l_cur FOR
      SELECT type_label(order_type), SUM(total_amount), COUNT(*) FROM rst_order
       WHERE company_id = l_co AND status_code IN ('PAID', 'CHARGED') AND closed_at >= l_f AND closed_at < l_t AND (l_tm IS NULL OR terminal_id = l_tm)
       GROUP BY order_type ORDER BY 2 DESC;
    l_h := l_h || bars('المبيعات حسب نوع الطلب (عدد الطلبات)', l_cur);
    OPEN l_cur FOR
      SELECT m.name_ar, SUM(p.amount) - SUM(CASE WHEN m.method_type = 'CASH' THEN s.change_amount ELSE 0 END), COUNT(DISTINCT s.id)
        FROM pos_payment p JOIN pos_sale s ON s.id = p.sale_id JOIN ref_payment_method m ON m.id = p.payment_method_id
       WHERE s.id IN (SELECT pos_sale_id FROM rst_order WHERE company_id = l_co AND status_code IN ('PAID', 'CHARGED') AND closed_at >= l_f
                         AND closed_at < l_t AND (l_tm IS NULL OR terminal_id = l_tm))
       GROUP BY m.name_ar ORDER BY 2 DESC;
    l_h := l_h || bars('طرق السداد (عدد الإيصالات)', l_cur);
    OPEN l_cur FOR
      SELECT * FROM (SELECT i.name_ar, SUM(l.line_total), SUM(l.quantity) FROM rst_order_line l JOIN rst_order o ON o.id = l.order_id JOIN inv_item i ON i.id = l.item_id
       WHERE o.company_id = l_co AND o.status_code IN ('PAID', 'CHARGED') AND l.kitchen_status <> 'VOID' AND o.closed_at >= l_f AND o.closed_at < l_t
         AND (l_tm IS NULL OR o.terminal_id = l_tm)
       GROUP BY i.name_ar ORDER BY 2 DESC) WHERE ROWNUM <= 10;
    l_h := l_h || bars('الأصناف الأكثر مبيعاً (الكمية)', l_cur);
    OPEN l_cur FOR
      SELECT g.name_ar, SUM(l.line_total), SUM(l.quantity) FROM rst_order_line l JOIN rst_order o ON o.id = l.order_id JOIN inv_item i ON i.id = l.item_id
        JOIN inv_item_category g ON g.id = i.category_id
       WHERE o.company_id = l_co AND o.status_code IN ('PAID', 'CHARGED') AND l.kitchen_status <> 'VOID' AND o.closed_at >= l_f AND o.closed_at < l_t
         AND (l_tm IS NULL OR o.terminal_id = l_tm)
       GROUP BY g.name_ar ORDER BY 2 DESC;
    l_h := l_h || bars('المبيعات حسب فئة القائمة', l_cur);
    OPEN l_cur FOR
      SELECT TO_CHAR(closed_at, 'HH24') || ':00', SUM(total_amount), COUNT(*) FROM rst_order
       WHERE company_id = l_co AND status_code IN ('PAID', 'CHARGED') AND closed_at >= l_f AND closed_at < l_t AND (l_tm IS NULL OR terminal_id = l_tm)
       GROUP BY TO_CHAR(closed_at, 'HH24') ORDER BY 1;
    l_h := l_h || bars('المبيعات حسب الساعة (ساعات الذروة)', l_cur);
    OPEN l_cur FOR
      SELECT TO_CHAR(closed_at, 'YYYY-MM-DD'), SUM(total_amount), COUNT(*) FROM rst_order
       WHERE company_id = l_co AND status_code IN ('PAID', 'CHARGED') AND closed_at >= l_f AND closed_at < l_t AND (l_tm IS NULL OR terminal_id = l_tm)
       GROUP BY TO_CHAR(closed_at, 'YYYY-MM-DD') ORDER BY 1;
    l_h := l_h || bars('المبيعات اليومية', l_cur);
    OPEN l_cur FOR
      SELECT NVL(waiter_name, '—'), SUM(total_amount), COUNT(*) FROM rst_order
       WHERE company_id = l_co AND status_code IN ('PAID', 'CHARGED') AND closed_at >= l_f AND closed_at < l_t AND (l_tm IS NULL OR terminal_id = l_tm)
       GROUP BY waiter_name ORDER BY 2 DESC;
    l_h := l_h || bars('المبيعات حسب النادل/الكاشير', l_cur);
    OPEN l_cur FOR
      SELECT * FROM (SELECT t.code || ' - ' || t.name_ar, SUM(o.total_amount), COUNT(*) FROM rst_order o JOIN rst_table t ON t.id = o.table_id
       WHERE o.company_id = l_co AND o.status_code IN ('PAID', 'CHARGED') AND o.closed_at >= l_f AND o.closed_at < l_t
         AND (l_tm IS NULL OR o.terminal_id = l_tm)
       GROUP BY t.code, t.name_ar ORDER BY 2 DESC) WHERE ROWNUM <= 10;
    l_h := l_h || bars('الطاولات الأعلى مبيعاً', l_cur);
    OPEN l_cur FOR
      SELECT * FROM (SELECT NOONA_SAL_PKG.customer_label(customer_account_id), SUM(total_amount), COUNT(*) FROM rst_order
       WHERE company_id = l_co AND status_code = 'CHARGED' AND closed_at >= l_f AND closed_at < l_t AND (l_tm IS NULL OR terminal_id = l_tm)
       GROUP BY customer_account_id ORDER BY 2 DESC) WHERE ROWNUM <= 10;
    l_h := l_h || bars('المبيعات الآجلة حسب العميل', l_cur);
    RETURN l_h || '</div></div>';
  END dashboard_html;

END NOONA_RST_PKG;
/
