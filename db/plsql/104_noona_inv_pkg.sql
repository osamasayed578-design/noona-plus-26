-- =============================================================================
-- NOONA PLUS ERP | المخزون والأصناف وسلسلة الإمداد: NOONA_INV_PKG
--   الأصناف (رقم وكود وباركود متعدد)، ملفات الأصناف: عام / قطع غيار سيارات (رقم OEM والتوافق والبدائل) /
--   أدوية (المادة الفعالة والوصفة والدفعات والصلاحية) / خامات ومنتجات مصنعة (قائمة المواد والإنتاج).
--   الحركات لا تعدل بعد الترحيل؛ التكلفة بالمتوسط المرجح لكل شركة، والصرف من الدفعات بالأقدم انتهاءً (FEFO).
--   الربط المحاسبي: حسابات الصنف ← حسابات الفئة ← الافتراضي، ومراكز التكلفة من الصنف أو المستودع.
-- =============================================================================

CREATE OR REPLACE PACKAGE NOONA_INV_PKG AUTHID DEFINER AS

  FUNCTION company RETURN NUMBER;
  -- تجهيز المخزون للشركة: الحسابات الإضافية، الفئات الافتراضية لكل ملف، المستودع الرئيسي، ترقيم المستندات، حسابات الضريبة
  FUNCTION quick_setup RETURN NUMBER;
  FUNCTION is_ready RETURN VARCHAR2;
  -- ترقيم مستند للشركة الحالية إن لم يكن معرفاً
  PROCEDURE ensure_sequence(p_type IN VARCHAR2, p_prefix IN VARCHAR2);
  FUNCTION default_warehouse RETURN NUMBER;
  FUNCTION create_warehouse(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_type IN VARCHAR2 DEFAULT 'MAIN',
                            p_cost_center_id IN NUMBER DEFAULT NULL, p_allow_negative IN VARCHAR2 DEFAULT 'N') RETURN NUMBER;
  -- فئة أصناف بحساباتها (رموز حسابات؛ الفارغ = الافتراضي)
  FUNCTION create_category(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_profile IN VARCHAR2 DEFAULT 'GENERAL',
                           p_parent_code IN VARCHAR2 DEFAULT NULL, p_inventory_acc IN VARCHAR2 DEFAULT NULL,
                           p_cogs_acc IN VARCHAR2 DEFAULT NULL, p_revenue_acc IN VARCHAR2 DEFAULT NULL,
                           p_expense_acc IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

  -- ---------------------------------------------------------- الأصناف
  -- الصنف كاملاً من JSON واحد:
  -- {"id","no","code","name","nameEn","type","cat","uom","profile","tracking":"NONE|LOT","expiry":"Y","shelf",
  --  "brand","mfr","mpn","generic","strength","form","rx":"Y","reg","price","minPrice","incl":"Y","tax":"VAT15",
  --  "ptax":"VAT15","cc","wh","min","max","reorder","status":"ACTIVE",
  --  "barcodes":["628..."],"fitment":[{"make","model","from","to","engine"}],"alternates":[{"no","type"}]}
  FUNCTION save_item(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION item_json(p_item_id IN NUMBER) RETURN CLOB;
  -- بحث سريع: الباركود، رقم الصنف، الكود، رقم OEM، الاسم، المادة الفعالة، العلامة
  FUNCTION find_items(p_term IN VARCHAR2, p_warehouse_id IN NUMBER DEFAULT NULL, p_limit IN NUMBER DEFAULT 20,
                      p_purpose IN VARCHAR2 DEFAULT 'SALE') RETURN CLOB;
  FUNCTION item_by_barcode(p_barcode IN VARCHAR2) RETURN NUMBER;
  FUNCTION item_label(p_item_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION is_stocked(p_item_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION on_hand(p_item_id IN NUMBER, p_warehouse_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
  FUNCTION avg_cost(p_item_id IN NUMBER) RETURN NUMBER;
  -- حساب الصنف: INVENTORY / COGS / REVENUE / EXPENSE (الصنف ← الفئة ← الافتراضي)
  FUNCTION account_for(p_item_id IN NUMBER, p_kind IN VARCHAR2) RETURN NUMBER;
  FUNCTION acc_id(p_code IN VARCHAR2) RETURN NUMBER;
  FUNCTION item_cost_center(p_item_id IN NUMBER, p_warehouse_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
  -- الضريبة
  FUNCTION tax_id(p_code IN VARCHAR2) RETURN NUMBER;
  FUNCTION tax_rate(p_tax_code_id IN NUMBER, p_date IN DATE DEFAULT NULL) RETURN NUMBER;
  FUNCTION item_tax_code(p_item_id IN NUMBER, p_purpose IN VARCHAR2 DEFAULT 'SALE') RETURN NUMBER;
  -- حساب الضريبة على المدخلات (1107) أو المخرجات (2104) للشركة
  FUNCTION tax_account(p_tax_code_id IN NUMBER, p_purpose IN VARCHAR2) RETURN NUMBER;

  -- ---------------------------------------------------------- الحركات (للمشتريات والمبيعات ونقاط البيع)
  TYPE t_move IS RECORD (item_id NUMBER, qty NUMBER, unit_cost NUMBER, lot_no VARCHAR2(100), expiry DATE, lot_id NUMBER,
                         line_ref VARCHAR2(100), total_cost NUMBER);
  TYPE t_moves IS TABLE OF t_move;
  -- حركة مرحلة فوراً؛ تعيد رقمها وتملأ total_cost لكل سطر (تكلفة الصرف بالمتوسط المرجح)
  FUNCTION move(p_type_code IN VARCHAR2, p_warehouse_id IN NUMBER, p_date IN DATE, p_source_type IN VARCHAR2,
                p_source_id IN NUMBER, p_lines IN OUT NOCOPY t_moves, p_reference IN VARCHAR2 DEFAULT NULL) RETURN NUMBER
    ACCESSIBLE BY (PACKAGE NOONA_PUR_PKG, PACKAGE NOONA_SAL_PKG, PACKAGE NOONA_POS_PKG);

  -- ---------------------------------------------------------- مستندات المخزون المباشرة
  -- الأنواع: OPENING رصيد افتتاحي، ADJ_IN تسوية بالزيادة، ADJ_OUT عجز، SCRAP إتلاف، CONSUMPTION صرف لمركز تكلفة،
  --          TRANSFER_OUT تحويل بين مستودعين
  -- {"id","type","date","wh","toWh","cc","reason","desc","action":"SAVE|POST","lines":[{"i":12,"q":5,"c":10.5,"lot":"B1","exp":"2027-01-31"}]}
  FUNCTION save_stock_doc(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION stock_doc_json(p_txn_id IN NUMBER, p_type IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  PROCEDURE post_stock_doc(p_txn_id IN NUMBER);
  PROCEDURE cancel_stock_doc(p_txn_id IN NUMBER);
  FUNCTION txn_type_label(p_code IN VARCHAR2) RETURN VARCHAR2;

  -- ---------------------------------------------------------- التصنيع
  -- قائمة المواد الافتراضية للمنتج: [{"i":compId,"q":2,"s":5}] (الكمية لكل p_base_qty من المنتج، s = نسبة الهالك)
  FUNCTION save_bom(p_item_id IN NUMBER, p_lines IN CLOB, p_base_qty IN NUMBER DEFAULT 1) RETURN NUMBER;
  FUNCTION bom_json(p_item_id IN NUMBER) RETURN CLOB;
  -- إنتاج: صرف المكونات بالمتوسط واستلام المنتج بتكلفتها؛ يعيد حركة الاستلام
  FUNCTION produce(p_item_id IN NUMBER, p_qty IN NUMBER, p_warehouse_id IN NUMBER, p_date IN DATE,
                   p_description IN VARCHAR2 DEFAULT NULL, p_lot_no IN VARCHAR2 DEFAULT NULL, p_expiry IN DATE DEFAULT NULL) RETURN NUMBER;

  -- ---------------------------------------------------------- التقارير (HTML)
  FUNCTION inv_summary RETURN CLOB;
  FUNCTION stock_balance(p_warehouse_id IN NUMBER DEFAULT NULL, p_category_id IN NUMBER DEFAULT NULL,
                         p_show_zero IN VARCHAR2 DEFAULT 'N', p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION item_card(p_item_id IN NUMBER, p_from IN DATE, p_to IN DATE, p_warehouse_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  FUNCTION expiry_report(p_days IN NUMBER DEFAULT 90, p_warehouse_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  FUNCTION reorder_report RETURN CLOB;
  FUNCTION fitment_search(p_make IN VARCHAR2, p_model IN VARCHAR2 DEFAULT NULL, p_year IN NUMBER DEFAULT NULL,
                          p_warehouse_id IN NUMBER DEFAULT NULL) RETURN CLOB;
END NOONA_INV_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_INV_PKG AS

  c_entity CONSTANT VARCHAR2(30) := 'INV_TRANSACTION';

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;

  FUNCTION company RETURN NUMBER IS
  BEGIN
    RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  END company;

  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL OR p = 0 THEN '' ELSE TO_CHAR(p, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.,''') END;
  END fmt;

  FUNCTION fqty(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN RTRIM(TO_CHAR(NVL(p, 0), 'FM999G999G999G990D999', 'NLS_NUMERIC_CHARACTERS=''.,'''), '.');
  END fqty;

  FUNCTION fnum(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(p, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
  END fnum;

  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  FUNCTION jt(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_CORE_PKG.json_text(p); END;

  -- ================================================================ الحسابات والضريبة
  FUNCTION acc_id(p_code IN VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM gl_account WHERE coa_id = NOONA_GL_PKG.primary_coa AND account_code = p_code;
    RETURN l;
  END acc_id;

  FUNCTION ensure_account(p_code VARCHAR2, p_name VARCHAR2, p_parent VARCHAR2, p_type VARCHAR2) RETURN NUMBER IS
    l NUMBER := acc_id(p_code);
  BEGIN
    IF l IS NULL THEN
      l := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, p_code, p_name, p_parent, p_type);
    END IF;
    RETURN l;
  END ensure_account;

  FUNCTION tax_id(p_code IN VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY tenant_id NULLS LAST) INTO l
      FROM loc_tax_code WHERE code = p_code AND status_code = 'ACTIVE';
    RETURN l;
  END tax_id;

  FUNCTION tax_rate(p_tax_code_id IN NUMBER, p_date IN DATE DEFAULT NULL) RETURN NUMBER IS
    l   NUMBER;
    l_d DATE;
  BEGIN
    IF p_tax_code_id IS NULL THEN RETURN 0; END IF;
    l_d := TRUNC(NVL(p_date, SYSDATE));
    SELECT MAX(rate_pct) KEEP (DENSE_RANK LAST ORDER BY version_no) INTO l
      FROM loc_tax_rate WHERE tax_code_id = p_tax_code_id AND effective_from <= l_d AND (effective_to IS NULL OR effective_to >= l_d);
    RETURN NVL(l, 0);
  END tax_rate;

  FUNCTION tax_account(p_tax_code_id IN NUMBER, p_purpose IN VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(CASE WHEN p_purpose = 'PURCHASE' THEN recoverable_account_id ELSE payable_account_id END) INTO l
      FROM loc_tax_account WHERE company_id = company AND tax_code_id = p_tax_code_id
       AND TRUNC(SYSDATE) BETWEEN effective_from AND NVL(effective_to, DATE '9999-12-31');
    RETURN NVL(l, acc_id(CASE WHEN p_purpose = 'PURCHASE' THEN '1107' ELSE '2104' END));
  END tax_account;

  FUNCTION item_tax_code(p_item_id IN NUMBER, p_purpose IN VARCHAR2 DEFAULT 'SALE') RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(CASE WHEN p_purpose = 'PURCHASE' THEN NVL(c.purchase_tax_code_id, c.sales_tax_code_id) ELSE c.sales_tax_code_id END)
      INTO l FROM inv_item_company c WHERE c.item_id = p_item_id AND c.company_id = company;
    IF l IS NULL THEN
      SELECT MAX(g.default_tax_code_id) INTO l FROM inv_item i JOIN inv_item_category g ON g.id = i.category_id WHERE i.id = p_item_id;
    END IF;
    RETURN NVL(l, tax_id('VAT15'));
  END item_tax_code;

  FUNCTION account_for(p_item_id IN NUMBER, p_kind IN VARCHAR2) RETURN NUMBER IS
    l_i NUMBER; l_c NUMBER;
  BEGIN
    SELECT MAX(DECODE(p_kind, 'INVENTORY', c.inventory_account_id, 'COGS', c.cogs_account_id, 'REVENUE', c.revenue_account_id,
                      'EXPENSE', c.expense_account_id)),
           MAX(DECODE(p_kind, 'INVENTORY', g.inventory_account_id, 'COGS', g.cogs_account_id, 'REVENUE', g.revenue_account_id,
                      'EXPENSE', g.expense_account_id))
      INTO l_i, l_c
      FROM inv_item i JOIN inv_item_category g ON g.id = i.category_id
      LEFT JOIN inv_item_company c ON c.item_id = i.id AND c.company_id = company
     WHERE i.id = p_item_id;
    RETURN COALESCE(l_i, l_c, acc_id(CASE p_kind WHEN 'INVENTORY' THEN '1105' WHEN 'COGS' THEN '5101' WHEN 'REVENUE' THEN '4101' ELSE '5299' END));
  END account_for;

  FUNCTION item_cost_center(p_item_id IN NUMBER, p_warehouse_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(default_cost_center_id) INTO l FROM inv_item_company WHERE item_id = p_item_id AND company_id = company;
    IF l IS NULL AND p_warehouse_id IS NOT NULL THEN
      SELECT MAX(cost_center_id) INTO l FROM inv_warehouse WHERE id = p_warehouse_id;
    END IF;
    RETURN l;
  END item_cost_center;

  -- ================================================================ التجهيز
  PROCEDURE ensure_sequence(p_type IN VARCHAR2, p_prefix IN VARCHAR2) IS
  BEGIN
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT company, p_type, NULL, p_prefix, 1, 6, 'N', 'NEVER', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = p_type);
  END ensure_sequence;

  FUNCTION default_warehouse RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY DECODE(warehouse_type, 'MAIN', 0, 1), id) INTO l
      FROM inv_warehouse WHERE company_id = company AND status_code = 'ACTIVE';
    RETURN l;
  END default_warehouse;

  FUNCTION create_warehouse(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_type IN VARCHAR2 DEFAULT 'MAIN',
                            p_cost_center_id IN NUMBER DEFAULT NULL, p_allow_negative IN VARCHAR2 DEFAULT 'N') RETURN NUMBER IS
    l NUMBER;
  BEGIN
    guard('INV_WAREHOUSE.CREATE');
    NOONA_CORE_PKG.assert(TRIM(p_code) IS NOT NULL AND TRIM(p_name_ar) IS NOT NULL, 'NOONA-INV-001', 'رمز المستودع واسمه إلزاميان',
                          'Warehouse code and name are required');
    INSERT INTO inv_warehouse (company_id, branch_id, code, name_ar, warehouse_type, allow_negative, cost_center_id, status_code)
    VALUES (company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), UPPER(TRIM(p_code)), p_name_ar, NVL(p_type, 'MAIN'),
            NVL(p_allow_negative, 'N'), p_cost_center_id, 'ACTIVE')
    RETURNING id INTO l;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'INV_WAREHOUSE', l, 'CREATE', 'SUCCESS');
    RETURN l;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-INV-002', 'رمز المستودع مستخدم', 'Warehouse code already exists');
  END create_warehouse;

  FUNCTION create_category(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_profile IN VARCHAR2 DEFAULT 'GENERAL',
                           p_parent_code IN VARCHAR2 DEFAULT NULL, p_inventory_acc IN VARCHAR2 DEFAULT NULL,
                           p_cogs_acc IN VARCHAR2 DEFAULT NULL, p_revenue_acc IN VARCHAR2 DEFAULT NULL,
                           p_expense_acc IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l      NUMBER;
    l_par  NUMBER;
    l_a1 NUMBER; l_a2 NUMBER; l_a3 NUMBER; l_a4 NUMBER; l_tx NUMBER;
    FUNCTION acc(p VARCHAR2) RETURN NUMBER IS
      a NUMBER;
    BEGIN
      IF p IS NULL THEN RETURN NULL; END IF;
      a := acc_id(p);
      NOONA_CORE_PKG.assert(a IS NOT NULL, 'NOONA-INV-004', 'الحساب غير موجود: ' || p, 'Account not found');
      RETURN a;
    END acc;
  BEGIN
    guard('INV_ITEM_CATEGORY.CREATE');
    IF p_parent_code IS NOT NULL THEN
      SELECT MIN(id) INTO l_par FROM inv_item_category WHERE code = UPPER(p_parent_code);
    END IF;
    l_a1 := acc(p_inventory_acc); l_a2 := acc(p_cogs_acc); l_a3 := acc(p_revenue_acc); l_a4 := acc(p_expense_acc);
    l_tx := tax_id('VAT15');
    INSERT INTO inv_item_category (code, name_ar, parent_category_id, default_costing_method, default_tax_code_id, product_profile,
                                   inventory_account_id, cogs_account_id, revenue_account_id, expense_account_id, is_active)
    VALUES (UPPER(TRIM(p_code)), p_name_ar, l_par, 'WEIGHTED_AVERAGE', l_tx, NVL(p_profile, 'GENERAL'), l_a1, l_a2, l_a3, l_a4, 'Y')
    RETURNING id INTO l;
    RETURN l;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-INV-003', 'رمز الفئة مستخدم', 'Category code already exists');
  END create_category;

  FUNCTION quick_setup RETURN NUMBER IS
    l_n   NUMBER := 0;
    l_id  NUMBER;
    l_cc  NUMBER;
  BEGIN
    guard('INV_WAREHOUSE.CREATE');
    IF NOONA_GL_PKG.primary_ledger IS NULL THEN
      l_n := NOONA_GL_PKG.quick_setup;
    END IF;
    -- حسابات المخزون الإضافية
    l_id := ensure_account('3105', 'الأرصدة الافتتاحية', '3', 'EQUITY');
    l_id := ensure_account('4203', 'فروقات زيادة المخزون', '4', 'REVENUE');
    l_id := ensure_account('5213', 'عجز وتلف المخزون', '52', 'EXPENSE');
    l_id := ensure_account('5102', 'تكلفة الخدمات والمشتريات غير المخزنية', '51', 'EXPENSE');
    -- الفئات الافتراضية لكل ملف أصناف
    FOR r IN (SELECT 'GEN' c, 'بضائع عامة' n, 'GENERAL' p, NULL e FROM dual
              UNION ALL SELECT 'AUTO', 'قطع غيار السيارات', 'AUTO_PART', NULL FROM dual
              UNION ALL SELECT 'PHARMA', 'الأدوية والمستحضرات', 'PHARMA', NULL FROM dual
              UNION ALL SELECT 'RAW', 'الخامات ومواد الإنتاج', 'RAW_MATERIAL', NULL FROM dual
              UNION ALL SELECT 'FG', 'المنتجات التامة', 'GENERAL', NULL FROM dual
              UNION ALL SELECT 'SRV', 'الخدمات والمصروفات', 'GENERAL', '5102' FROM dual) LOOP
      SELECT COUNT(*) INTO l_id FROM inv_item_category WHERE code = r.c;
      IF l_id = 0 THEN
        l_id := create_category(r.c, r.n, r.p, NULL, '1105', '5101', '4101', NVL(r.e, '5102'));
        l_n := l_n + 1;
      END IF;
    END LOOP;
    -- المستودع الرئيسي
    IF default_warehouse IS NULL THEN
      SELECT MIN(id) INTO l_cc FROM gl_cost_center WHERE company_id = company AND code = 'CC-500';
      l_id := create_warehouse('WH-01', 'المستودع الرئيسي', 'MAIN', l_cc);
      l_n := l_n + 1;
    END IF;
    -- طرق السداد (نقدي، مدى، بطاقات، محافظ رقمية، تحويل، شيك، آجل) وشروط الدفع
    FOR r IN (SELECT 'CASH' c, 'نقدي' n, 'Cash' e, 'CASH' t, 'N' rq, 10 o, 'fa-money' i FROM dual
              UNION ALL SELECT 'MADA', 'مدى', 'mada', 'CARD', 'Y', 20, 'fa-credit-card' FROM dual
              UNION ALL SELECT 'CARD', 'فيزا / ماستركارد', 'Visa / Mastercard', 'CARD', 'Y', 30, 'fa-cc-visa' FROM dual
              UNION ALL SELECT 'APPLE_PAY', 'Apple Pay', 'Apple Pay', 'WALLET', 'Y', 40, 'fa-apple' FROM dual
              UNION ALL SELECT 'STC_PAY', 'STC Pay', 'STC Pay', 'WALLET', 'Y', 50, 'fa-mobile' FROM dual
              UNION ALL SELECT 'BANK_APP', 'تطبيق بنكي / تحويل فوري', 'Bank app / instant transfer', 'BANK_TRANSFER', 'Y', 60, 'fa-university' FROM dual
              UNION ALL SELECT 'CHEQUE', 'شيك', 'Cheque', 'CHEQUE', 'Y', 70, 'fa-file-text-o' FROM dual
              UNION ALL SELECT 'CREDIT', 'آجل (على الحساب)', 'On account', 'CREDIT', 'N', 80, 'fa-clock-o' FROM dual) LOOP
      INSERT INTO ref_payment_method (code, name_ar, name_en, method_type, requires_reference, sort_order, icon_class, is_active)
      SELECT r.c, r.n, r.e, r.t, r.rq, r.o, r.i, 'Y' FROM dual WHERE NOT EXISTS (SELECT 1 FROM ref_payment_method WHERE code = r.c);
      l_n := l_n + SQL%ROWCOUNT;
    END LOOP;
    FOR r IN (SELECT 'NET0' c, 'نقداً / فوري' n, 0 d FROM dual UNION ALL SELECT 'NET15', '15 يوماً', 15 FROM dual
              UNION ALL SELECT 'NET30', '30 يوماً', 30 FROM dual UNION ALL SELECT 'NET60', '60 يوماً', 60 FROM dual
              UNION ALL SELECT 'NET90', '90 يوماً', 90 FROM dual) LOOP
      INSERT INTO ref_payment_term (code, name_ar, base_date_rule, due_days, is_installment, is_active)
      SELECT r.c, r.n, 'DOC_DATE', r.d, 'N', 'Y' FROM dual WHERE NOT EXISTS (SELECT 1 FROM ref_payment_term WHERE code = r.c);
      l_n := l_n + SQL%ROWCOUNT;
    END LOOP;
    -- ترقيم المستندات
    ensure_sequence('INV_ITEM', 'ITM-');
    ensure_sequence('INV_TRANSACTION', 'IT-');
    -- حسابات ضريبة القيمة المضافة للشركة
    FOR t IN (SELECT id FROM loc_tax_code WHERE tenant_id IS NULL AND code IN ('VAT15', 'VAT0', 'VATEX', 'VATOS')) LOOP
      INSERT INTO loc_tax_account (company_id, tax_code_id, payable_account_id, recoverable_account_id, effective_from)
      SELECT company, t.id, acc_id('2104'), acc_id('1107'), DATE '2000-01-01' FROM dual
       WHERE NOT EXISTS (SELECT 1 FROM loc_tax_account WHERE company_id = company AND tax_code_id = t.id);
      l_n := l_n + SQL%ROWCOUNT;
    END LOOP;
    RETURN l_n;
  END quick_setup;

  FUNCTION is_ready RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN default_warehouse IS NOT NULL AND acc_id('5213') IS NOT NULL THEN 'Y' ELSE 'N' END;
  END is_ready;

  -- ================================================================ الأصناف
  FUNCTION is_stocked(p_item_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT item_type INTO l FROM inv_item WHERE id = p_item_id;
    RETURN CASE WHEN l IN ('SERVICE', 'NON_STOCK') THEN 'N' ELSE 'Y' END;
  END is_stocked;

  FUNCTION item_label(p_item_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT item_no || ' - ' || name_ar INTO l FROM inv_item WHERE id = p_item_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
  END item_label;

  FUNCTION item_by_barcode(p_barcode IN VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(item_id) INTO l FROM inv_item_barcode WHERE barcode = TRIM(p_barcode) AND is_active = 'Y';
    IF l IS NULL THEN
      SELECT MIN(id) INTO l FROM inv_item WHERE (item_no = TRIM(p_barcode) OR item_code = TRIM(p_barcode)) AND status_code = 'ACTIVE';
    END IF;
    RETURN l;
  END item_by_barcode;

  FUNCTION on_hand(p_item_id IN NUMBER, p_warehouse_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(on_hand_qty), 0) INTO l FROM inv_onhand
     WHERE item_id = p_item_id AND company_id = company AND (p_warehouse_id IS NULL OR warehouse_id = p_warehouse_id);
    RETURN l;
  END on_hand;

  FUNCTION avg_cost(p_item_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(average_cost) INTO l FROM inv_item_cost WHERE item_id = p_item_id AND company_id = company AND warehouse_id IS NULL;
    IF NVL(l, 0) = 0 THEN
      SELECT MAX(NVL(last_purchase_price, standard_cost)) INTO l FROM inv_item_company WHERE item_id = p_item_id AND company_id = company;
    END IF;
    RETURN NVL(l, 0);
  END avg_cost;

  FUNCTION save_item(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id    NUMBER := l_o.get_number('id');
    l_no    VARCHAR2(50) := TRIM(l_o.get_string('no'));
    l_cat   NUMBER := l_o.get_number('cat');
    l_uom   NUMBER := l_o.get_number('uom');
    l_type  VARCHAR2(30) := NVL(l_o.get_string('type'), 'STOCK');
    l_prof  VARCHAR2(30);
    l_trk   VARCHAR2(30);
    l_arr   JSON_ARRAY_T;
    l_e     JSON_OBJECT_T;
    l_alt   NUMBER;
    l_n     NUMBER;
    l_bar   VARCHAR2(100);
    l_f1    VARCHAR2(200); l_f2 VARCHAR2(200); l_f3 VARCHAR2(200); l_y1 NUMBER; l_y2 NUMBER;
    s_name    VARCHAR2(4000) := l_o.get_string('name');
    s_profile VARCHAR2(4000) := l_o.get_string('profile');
    s_tracking VARCHAR2(4000) := l_o.get_string('tracking');
    s_nameEn  VARCHAR2(4000) := l_o.get_string('nameEn');
    s_desc    VARCHAR2(4000) := l_o.get_string('desc');
    s_expiry  VARCHAR2(4000) := l_o.get_string('expiry');
    n_shelf   NUMBER := l_o.get_number('shelf');
    s_sell    VARCHAR2(4000) := l_o.get_string('sell');
    s_buy     VARCHAR2(4000) := l_o.get_string('buy');
    s_code    VARCHAR2(4000) := l_o.get_string('code');
    s_brand   VARCHAR2(4000) := l_o.get_string('brand');
    s_mfr     VARCHAR2(4000) := l_o.get_string('mfr');
    s_mpn     VARCHAR2(4000) := l_o.get_string('mpn');
    s_generic VARCHAR2(4000) := l_o.get_string('generic');
    s_strength VARCHAR2(4000) := l_o.get_string('strength');
    s_form    VARCHAR2(4000) := l_o.get_string('form');
    s_rx      VARCHAR2(4000) := l_o.get_string('rx');
    s_reg     VARCHAR2(4000) := l_o.get_string('reg');
    s_status  VARCHAR2(4000) := l_o.get_string('status');
    n_price   NUMBER := l_o.get_number('price');
    n_minPrice NUMBER := l_o.get_number('minPrice');
    s_incl    VARCHAR2(4000) := l_o.get_string('incl');
    s_tax     VARCHAR2(4000) := l_o.get_string('tax');
    s_ptax    VARCHAR2(4000) := l_o.get_string('ptax');
    n_cc      NUMBER := l_o.get_number('cc');
    n_wh      NUMBER := l_o.get_number('wh');
    n_min     NUMBER := l_o.get_number('min');
    n_max     NUMBER := l_o.get_number('max');
    n_reorder NUMBER := l_o.get_number('reorder');
    n_cost    NUMBER := l_o.get_number('cost');
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'INV_ITEM.CREATE' ELSE 'INV_ITEM.UPDATE' END);
    NOONA_CORE_PKG.assert(TRIM(s_name) IS NOT NULL, 'NOONA-INV-010', 'اسم الصنف إلزامي', 'Item name is required');
    IF l_cat IS NULL THEN
      SELECT MIN(id) INTO l_cat FROM inv_item_category WHERE code = 'GEN';
    END IF;
    NOONA_CORE_PKG.assert(l_cat IS NOT NULL, 'NOONA-INV-011', 'اختر فئة الصنف (أو نفذ تجهيز المخزون)', 'Item category is required');
    SELECT product_profile INTO l_prof FROM inv_item_category WHERE id = l_cat;
    l_prof := NVL(s_profile, l_prof);
    IF l_uom IS NULL THEN
      SELECT MIN(id) INTO l_uom FROM inv_uom WHERE code = 'PCS';
    END IF;
    -- الأدوية: الدفعات والصلاحية إلزامية
    l_trk := CASE WHEN l_prof = 'PHARMA' THEN 'LOT' ELSE NVL(s_tracking, 'NONE') END;
    IF l_no IS NULL AND l_id IS NULL THEN
      l_no := NOONA_REFERENCE_PKG.next_doc_no('INV_ITEM', company, NULL, TRUNC(SYSDATE), 'INV_ITEM', NULL);
    END IF;
    IF l_id IS NULL THEN
      INSERT INTO inv_item (name_ar, name_en, description, item_no, item_type, category_id, base_uom_id, tracking_mode, track_expiry,
                            shelf_life_days, is_sellable, is_purchasable, is_manufactured, allow_negative, item_code, product_profile,
                            brand, manufacturer, manufacturer_part_no, generic_name, strength, dosage_form, requires_prescription,
                            regulatory_reg_no, status_code)
      VALUES (TRIM(s_name), s_nameEn, s_desc, l_no, l_type, l_cat, l_uom, l_trk,
              CASE WHEN l_prof = 'PHARMA' THEN 'Y' ELSE NVL(s_expiry, 'N') END, n_shelf,
              NVL(s_sell, 'Y'), NVL(s_buy, 'Y'),
              CASE WHEN l_type IN ('FINISHED_GOOD', 'SEMI_FINISHED') THEN 'Y' ELSE 'N' END, 'N',
              TRIM(s_code), l_prof, s_brand, s_mfr, TRIM(s_mpn),
              s_generic, s_strength, s_form, NVL(s_rx, 'N'),
              s_reg, NVL(s_status, 'ACTIVE'))
      RETURNING id INTO l_id;
    ELSE
      UPDATE inv_item
         SET name_ar = TRIM(s_name), name_en = s_nameEn, description = s_desc,
             item_no = NVL(l_no, item_no), item_type = l_type, category_id = l_cat, tracking_mode = l_trk,
             track_expiry = CASE WHEN l_prof = 'PHARMA' THEN 'Y' ELSE NVL(s_expiry, 'N') END,
             shelf_life_days = n_shelf, is_sellable = NVL(s_sell, 'Y'),
             is_purchasable = NVL(s_buy, 'Y'),
             is_manufactured = CASE WHEN l_type IN ('FINISHED_GOOD', 'SEMI_FINISHED') THEN 'Y' ELSE 'N' END,
             item_code = TRIM(s_code), product_profile = l_prof, brand = s_brand,
             manufacturer = s_mfr, manufacturer_part_no = TRIM(s_mpn),
             generic_name = s_generic, strength = s_strength, dosage_form = s_form,
             requires_prescription = NVL(s_rx, 'N'), regulatory_reg_no = s_reg,
             status_code = NVL(s_status, status_code)
       WHERE id = l_id;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-INV-012', 'الصنف غير موجود', 'Item not found');
      -- وحدة الصنف لا تتغير بعد وجود حركات
      SELECT COUNT(*) INTO l_n FROM inv_transaction_line WHERE item_id = l_id AND ROWNUM = 1;
      IF l_n = 0 THEN UPDATE inv_item SET base_uom_id = l_uom WHERE id = l_id; END IF;
    END IF;
    -- إعدادات الشركة: الأسعار والضريبة والمركز والمستودع والحدود
    MERGE INTO inv_item_company c
    USING (SELECT l_id item_id FROM dual) x ON (c.company_id = company AND c.item_id = x.item_id)
     WHEN MATCHED THEN UPDATE SET sale_price = n_price, min_sale_price = n_minPrice,
                                  prices_include_tax = NVL(s_incl, 'N'),
                                  sales_tax_code_id = tax_id(NVL(s_tax, 'VAT15')),
                                  purchase_tax_code_id = tax_id(NVL(s_ptax, NVL(s_tax, 'VAT15'))),
                                  default_cost_center_id = n_cc, default_warehouse_id = n_wh,
                                  min_qty = n_min, max_qty = n_max,
                                  reorder_qty = n_reorder, standard_cost = NVL(n_cost, standard_cost)
     WHEN NOT MATCHED THEN INSERT (company_id, item_id, costing_method, sale_price, min_sale_price, prices_include_tax, sales_tax_code_id,
                                   purchase_tax_code_id, default_cost_center_id, default_warehouse_id, min_qty, max_qty, reorder_qty,
                                   standard_cost, is_active)
          VALUES (company, l_id, 'WEIGHTED_AVERAGE', n_price, n_minPrice, NVL(s_incl, 'N'),
                  tax_id(NVL(s_tax, 'VAT15')),
                  tax_id(NVL(s_ptax, NVL(s_tax, 'VAT15'))),
                  n_cc, n_wh, n_min, n_max, n_reorder,
                  n_cost, 'Y');
    -- الباركود (استبدال القائمة)
    IF l_o.has('barcodes') THEN
      DELETE FROM inv_item_barcode WHERE item_id = l_id;
      l_arr := l_o.get_array('barcodes');
      FOR i IN 0 .. NVL(l_arr.get_size, 0) - 1 LOOP
        l_bar := TRIM(l_arr.get_string(i));
        CONTINUE WHEN l_bar IS NULL;
        BEGIN
          INSERT INTO inv_item_barcode (item_id, barcode, uom_id, barcode_type, is_active)
          VALUES (l_id, l_bar, l_uom, CASE WHEN REGEXP_LIKE(l_bar, '^[0-9]{13}$') THEN 'EAN13' WHEN REGEXP_LIKE(l_bar, '^[0-9]{8}$') THEN 'EAN8'
                                          WHEN REGEXP_LIKE(l_bar, '^[0-9]{12}$') THEN 'UPC' ELSE 'CODE128' END, 'Y');
        EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
          NOONA_CORE_PKG.raise_error('NOONA-INV-013', 'الباركود ' || l_bar || ' مستخدم لصنف آخر', 'Barcode already used');
        END;
      END LOOP;
    END IF;
    -- توافق قطع الغيار
    IF l_o.has('fitment') THEN
      DELETE FROM inv_item_fitment WHERE item_id = l_id;
      l_arr := l_o.get_array('fitment');
      FOR i IN 0 .. NVL(l_arr.get_size, 0) - 1 LOOP
        l_e := TREAT(l_arr.get(i) AS JSON_OBJECT_T);
        l_f1 := TRIM(l_e.get_string('make')); l_f2 := TRIM(l_e.get_string('model'));
        l_y1 := l_e.get_number('from'); l_y2 := l_e.get_number('to'); l_f3 := l_e.get_string('engine');
        CONTINUE WHEN l_f1 IS NULL;
        INSERT INTO inv_item_fitment (item_id, vehicle_make, vehicle_model, year_from, year_to, engine)
        VALUES (l_id, l_f1, l_f2, l_y1, l_y2, l_f3);
      END LOOP;
    END IF;
    -- البدائل (برقم الصنف أو الكود أو رقم OEM)
    IF l_o.has('alternates') THEN
      DELETE FROM inv_item_alternate WHERE item_id = l_id;
      l_arr := l_o.get_array('alternates');
      FOR i IN 0 .. NVL(l_arr.get_size, 0) - 1 LOOP
        l_e := TREAT(l_arr.get(i) AS JSON_OBJECT_T);
        l_f1 := TRIM(l_e.get_string('no')); l_f2 := NVL(l_e.get_string('type'), 'SUBSTITUTE');
        SELECT MIN(id) INTO l_alt FROM inv_item WHERE item_no = l_f1 OR item_code = l_f1 OR manufacturer_part_no = l_f1;
        NOONA_CORE_PKG.assert(l_alt IS NOT NULL, 'NOONA-INV-014', 'الصنف البديل غير موجود: ' || l_e.get_string('no'), 'Alternate not found');
        CONTINUE WHEN l_alt = l_id;
        INSERT INTO inv_item_alternate (item_id, alt_item_id, alt_type)
        VALUES (l_id, l_alt, l_f2);
      END LOOP;
    END IF;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'INV_ITEM', l_id, 'SAVE', 'SUCCESS');
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-INV-015', 'رقم الصنف أو الكود مستخدم لصنف آخر', 'Item number or code already used');
  END save_item;

  FUNCTION item_json(p_item_id IN NUMBER) RETURN CLOB IS
    l_out CLOB;
  BEGIN
    IF p_item_id IS NULL THEN
      RETURN '{"id":null,"type":"STOCK","tracking":"NONE","tax":"VAT15","status":"ACTIVE","barcodes":[],"fitment":[],"alternates":[]}';
    END IF;
    SELECT JSON_OBJECT('id' VALUE i.id, 'no' VALUE i.item_no, 'code' VALUE i.item_code, 'name' VALUE i.name_ar, 'nameEn' VALUE i.name_en,
             'type' VALUE i.item_type, 'cat' VALUE i.category_id, 'uom' VALUE i.base_uom_id, 'profile' VALUE i.product_profile,
             'tracking' VALUE i.tracking_mode, 'expiry' VALUE i.track_expiry, 'shelf' VALUE i.shelf_life_days, 'brand' VALUE i.brand,
             'mfr' VALUE i.manufacturer, 'mpn' VALUE i.manufacturer_part_no, 'generic' VALUE i.generic_name, 'strength' VALUE i.strength,
             'form' VALUE i.dosage_form, 'rx' VALUE i.requires_prescription, 'reg' VALUE i.regulatory_reg_no, 'status' VALUE i.status_code,
             'price' VALUE c.sale_price, 'minPrice' VALUE c.min_sale_price, 'incl' VALUE c.prices_include_tax,
             'tax' VALUE (SELECT code FROM loc_tax_code WHERE id = c.sales_tax_code_id),
             'ptax' VALUE (SELECT code FROM loc_tax_code WHERE id = c.purchase_tax_code_id),
             'cc' VALUE c.default_cost_center_id, 'wh' VALUE c.default_warehouse_id, 'min' VALUE c.min_qty, 'max' VALUE c.max_qty,
             'reorder' VALUE c.reorder_qty, 'cost' VALUE c.standard_cost, 'onhand' VALUE on_hand(i.id), 'avg' VALUE avg_cost(i.id),
             'barcodes' VALUE (SELECT JSON_ARRAYAGG(barcode ORDER BY id RETURNING CLOB) FROM inv_item_barcode WHERE item_id = i.id) FORMAT JSON,
             'fitment' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('make' VALUE vehicle_make, 'model' VALUE vehicle_model, 'from' VALUE year_from,
                                                   'to' VALUE year_to, 'engine' VALUE engine) ORDER BY id RETURNING CLOB)
                                FROM inv_item_fitment WHERE item_id = i.id) FORMAT JSON,
             'alternates' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('no' VALUE x.item_no, 'name' VALUE x.name_ar, 'type' VALUE a.alt_type)
                                                      ORDER BY a.id RETURNING CLOB)
                                   FROM inv_item_alternate a JOIN inv_item x ON x.id = a.alt_item_id WHERE a.item_id = i.id) FORMAT JSON
             RETURNING CLOB)
      INTO l_out
      FROM inv_item i LEFT JOIN inv_item_company c ON c.item_id = i.id AND c.company_id = company
     WHERE i.id = p_item_id;
    RETURN REPLACE(REPLACE(REPLACE(l_out, '"barcodes":null', '"barcodes":[]'), '"fitment":null', '"fitment":[]'),
                   '"alternates":null', '"alternates":[]');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-INV-012', 'الصنف غير موجود', 'Item not found');
  END item_json;

  FUNCTION find_items(p_term IN VARCHAR2, p_warehouse_id IN NUMBER DEFAULT NULL, p_limit IN NUMBER DEFAULT 20,
                      p_purpose IN VARCHAR2 DEFAULT 'SALE') RETURN CLOB IS
    l_t    VARCHAR2(200) := TRIM(p_term);
    l_lk   VARCHAR2(210) := '%' || UPPER(TRIM(p_term)) || '%';
    l_vat  NUMBER := tax_id('VAT15');
    l_co   NUMBER := company;
    l_d    DATE := TRUNC(SYSDATE);
    l_lim  NUMBER := NVL(p_limit, 20);
    l_out  CLOB;
  BEGIN
    -- مطابقة تامة أولاً (الباركود/الرقم/الكود/OEM) ثم البحث الجزئي بالاسم والمادة الفعالة والعلامة
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE x.id, 'no' VALUE x.item_no, 'code' VALUE x.item_code, 'n' VALUE x.name_ar,
             'b' VALUE x.barcode, 'p' VALUE x.sale_price, 'inc' VALUE x.incl,
             't' VALUE NVL((SELECT MAX(r.rate_pct) KEEP (DENSE_RANK LAST ORDER BY r.version_no) FROM loc_tax_rate r
                             WHERE r.tax_code_id = x.tax_id AND r.effective_from <= l_d AND (r.effective_to IS NULL OR r.effective_to >= l_d)), 0),
             'tc' VALUE (SELECT c.code FROM loc_tax_code c WHERE c.id = x.tax_id), 'u' VALUE x.uom, 'q' VALUE x.qty, 'c' VALUE x.cost,
             'trk' VALUE x.tracking_mode, 'rx' VALUE x.requires_prescription, 'mpn' VALUE x.manufacturer_part_no,
             'g' VALUE x.generic_name, 'st' VALUE x.stocked)
           ORDER BY x.rnk, x.name_ar RETURNING CLOB)
      INTO l_out
      FROM (SELECT * FROM (SELECT i.id, i.item_no, i.item_code, i.name_ar, i.tracking_mode, i.requires_prescription, i.manufacturer_part_no, i.generic_name,
                   (SELECT MIN(b.barcode) FROM inv_item_barcode b WHERE b.item_id = i.id) barcode,
                   c.sale_price, NVL(c.prices_include_tax, 'N') incl,
                   COALESCE(CASE WHEN p_purpose = 'PURCHASE' THEN c.purchase_tax_code_id END, c.sales_tax_code_id, l_vat) tax_id,
                   u.code uom, CASE WHEN i.item_type IN ('SERVICE', 'NON_STOCK') THEN 'N' ELSE 'Y' END stocked,
                   (SELECT NVL(SUM(o.on_hand_qty), 0) FROM inv_onhand o WHERE o.item_id = i.id AND o.company_id = l_co
                       AND (p_warehouse_id IS NULL OR o.warehouse_id = p_warehouse_id)) qty,
                   CASE WHEN p_purpose = 'PURCHASE' THEN c.last_purchase_price END cost,
                   CASE WHEN i.item_no = l_t OR i.item_code = l_t OR UPPER(i.manufacturer_part_no) = UPPER(l_t)
                          OR EXISTS (SELECT 1 FROM inv_item_barcode b WHERE b.item_id = i.id AND b.barcode = l_t) THEN 0 ELSE 1 END rnk
              FROM inv_item i JOIN inv_uom u ON u.id = i.base_uom_id
              LEFT JOIN inv_item_company c ON c.item_id = i.id AND c.company_id = l_co
             WHERE i.status_code = 'ACTIVE'
               AND (p_purpose <> 'SALE' OR i.is_sellable = 'Y') AND (p_purpose <> 'PURCHASE' OR i.is_purchasable = 'Y')
               AND (l_t IS NULL
                    OR EXISTS (SELECT 1 FROM inv_item_barcode b WHERE b.item_id = i.id AND b.barcode = l_t)
                    OR i.item_no = l_t OR i.item_code = l_t
                    OR UPPER(i.name_ar) LIKE l_lk OR UPPER(i.name_en) LIKE l_lk OR UPPER(i.manufacturer_part_no) LIKE l_lk
                    OR UPPER(i.generic_name) LIKE l_lk OR UPPER(i.brand) LIKE l_lk OR UPPER(i.item_code) LIKE l_lk
                    OR UPPER(i.item_no) LIKE l_lk)
             ORDER BY rnk, i.name_ar) WHERE ROWNUM <= l_lim) x;
    RETURN NVL(l_out, '[]');
  END find_items;

  -- ================================================================ ترحيل الحركات
  FUNCTION txn_type(p_code VARCHAR2) RETURN inv_txn_type%ROWTYPE IS
    l inv_txn_type%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM (SELECT * FROM inv_txn_type WHERE code = p_code AND is_active = 'Y' ORDER BY tenant_id NULLS LAST)
     WHERE ROWNUM = 1;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-INV-020', 'نوع حركة المخزون غير معرف: ' || p_code, 'Unknown inventory transaction type');
  END txn_type;

  FUNCTION txn_type_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(200);
  BEGIN
    SELECT MAX(name_ar) KEEP (DENSE_RANK FIRST ORDER BY tenant_id NULLS LAST) INTO l FROM inv_txn_type WHERE code = p_code;
    RETURN NVL(l, p_code);
  END txn_type_label;

  FUNCTION lot_for(p_item_id NUMBER, p_lot_no VARCHAR2, p_expiry DATE) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    IF TRIM(p_lot_no) IS NULL THEN RETURN NULL; END IF;
    SELECT MIN(id) INTO l FROM inv_lot WHERE item_id = p_item_id AND lot_no = TRIM(p_lot_no);
    IF l IS NULL THEN
      INSERT INTO inv_lot (item_id, lot_no, expiry_date, quality_status, status_code)
      VALUES (p_item_id, TRIM(p_lot_no), p_expiry, 'ACCEPTED', 'ACTIVE')
      RETURNING id INTO l;
    ELSIF p_expiry IS NOT NULL THEN
      UPDATE inv_lot SET expiry_date = NVL(expiry_date, p_expiry) WHERE id = l;
    END IF;
    RETURN l;
  END lot_for;

  PROCEDURE add_onhand(p_item NUMBER, p_wh NUMBER, p_lot NUMBER, p_qty NUMBER, p_line NUMBER) IS
  BEGIN
    MERGE INTO inv_onhand o
    USING (SELECT p_item item_id, p_wh warehouse_id, p_lot lot_id FROM dual) x
       ON (o.company_id = company AND o.item_id = x.item_id AND o.warehouse_id = x.warehouse_id AND NVL(o.lot_id, 0) = NVL(x.lot_id, 0)
           AND o.location_id IS NULL AND o.serial_id IS NULL AND o.stock_status = 'AVAILABLE')
     WHEN MATCHED THEN UPDATE SET o.on_hand_qty = o.on_hand_qty + p_qty, o.last_txn_line_id = p_line
     WHEN NOT MATCHED THEN INSERT (company_id, item_id, warehouse_id, lot_id, stock_status, on_hand_qty, reserved_qty, last_txn_line_id)
          VALUES (company, p_item, p_wh, p_lot, 'AVAILABLE', p_qty, 0, p_line);
  END add_onhand;

  -- يطبق سطراً واحداً على الأرصدة والتكلفة؛ يعيد تكلفة السطر الإجمالية (موجبة)
  FUNCTION apply_line(p_txn NUMBER, p_no IN OUT PLS_INTEGER, p_sign NUMBER, p_wh NUMBER, p_class VARCHAR2,
                      p_m IN OUT NOCOPY t_move, p_for_sale BOOLEAN) RETURN NUMBER IS
    l_item    inv_item%ROWTYPE;
    l_cost    inv_item_cost%ROWTYPE;
    l_uc      NUMBER;
    l_total   NUMBER := 0;
    l_left    NUMBER;
    l_take    NUMBER;
    l_line    NUMBER;
    l_neg     VARCHAR2(1);
    l_avail   NUMBER;
    l_cur     VARCHAR2(3) := NOONA_GL_PKG.ledger_currency;
    l_fs      VARCHAR2(1) := CASE WHEN p_for_sale THEN 'Y' ELSE 'N' END;
    PROCEDURE ins(p_lot NUMBER, p_q NUMBER, p_unit NUMBER) IS
    BEGIN
      p_no := p_no + 1;
      INSERT INTO inv_transaction_line (company_id, transaction_id, line_no, item_id, lot_id, quantity, uom_id, base_quantity, unit_cost,
                                        total_cost, stock_status, ownership_type, source_line_ref)
      VALUES (company, p_txn, p_no, p_m.item_id, p_lot, p_q, l_item.base_uom_id, p_sign * p_q, p_unit,
              ROUND(p_q * p_unit, 2), 'AVAILABLE', 'OWNED', p_m.line_ref)
      RETURNING id INTO l_line;
      add_onhand(p_m.item_id, p_wh, p_lot, p_sign * p_q, l_line);
    END ins;
  BEGIN
    SELECT * INTO l_item FROM inv_item WHERE id = p_m.item_id;
    NOONA_CORE_PKG.assert(p_m.qty > 0, 'NOONA-INV-021', 'الكمية يجب أن تكون موجبة (' || l_item.name_ar || ')', 'Quantity must be positive');
    -- تكلفة الصنف على مستوى الشركة (قفل يمنع الصرف المتزامن من نفس الرصيد)
    BEGIN
      SELECT * INTO l_cost FROM inv_item_cost WHERE company_id = company AND item_id = p_m.item_id AND warehouse_id IS NULL FOR UPDATE;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      INSERT INTO inv_item_cost (company_id, item_id, warehouse_id, currency_code, on_hand_qty, total_value, average_cost)
      VALUES (company, p_m.item_id, NULL, l_cur, 0, 0, 0)
      RETURNING id, company_id, item_id, warehouse_id, currency_code, on_hand_qty, total_value, average_cost
           INTO l_cost.id, l_cost.company_id, l_cost.item_id, l_cost.warehouse_id, l_cost.currency_code, l_cost.on_hand_qty,
                l_cost.total_value, l_cost.average_cost;
    END;
    IF p_sign > 0 THEN
      -- الوارد: الدفعة إلزامية للأصناف المتتبعة، والتكلفة من المستند (أو المتوسط الحالي للمرتجعات والتحويلات)
      IF l_item.tracking_mode IN ('LOT', 'LOT_AND_SERIAL') THEN
        p_m.lot_id := NVL(p_m.lot_id, lot_for(p_m.item_id, p_m.lot_no, p_m.expiry));
        NOONA_CORE_PKG.assert(p_m.lot_id IS NOT NULL, 'NOONA-INV-022', 'رقم الدفعة إلزامي للصنف ' || l_item.item_no || ' - ' || l_item.name_ar,
                              'Lot number is required for this item');
        IF l_item.track_expiry = 'Y' THEN
          SELECT COUNT(*) INTO l_avail FROM inv_lot WHERE id = p_m.lot_id AND expiry_date IS NOT NULL;
          NOONA_CORE_PKG.assert(l_avail = 1, 'NOONA-INV-023', 'تاريخ انتهاء الدفعة إلزامي للصنف ' || l_item.name_ar,
                                'Expiry date is required for this item');
        END IF;
      END IF;
      l_uc := NVL(p_m.unit_cost, CASE WHEN l_cost.average_cost > 0 THEN l_cost.average_cost ELSE avg_cost(p_m.item_id) END);
      ins(p_m.lot_id, p_m.qty, l_uc);
      l_total := ROUND(p_m.qty * l_uc, 2);
      UPDATE inv_item_cost
         SET on_hand_qty = on_hand_qty + p_m.qty, total_value = total_value + l_total,
             average_cost = CASE WHEN on_hand_qty + p_m.qty > 0 THEN ROUND((total_value + l_total) / (on_hand_qty + p_m.qty), 6)
                                 ELSE average_cost END
       WHERE id = l_cost.id;
    ELSE
      -- الصادر: بالمتوسط المرجح، ومن الدفعات بالأقدم انتهاءً (لا تباع دفعة منتهية)
      l_uc := CASE WHEN l_cost.average_cost > 0 THEN l_cost.average_cost ELSE avg_cost(p_m.item_id) END;
      SELECT CASE WHEN l_item.allow_negative = 'Y' OR w.allow_negative = 'Y' THEN 'Y' ELSE 'N' END INTO l_neg
        FROM inv_warehouse w WHERE w.id = p_wh;
      IF l_item.tracking_mode IN ('LOT', 'LOT_AND_SERIAL') THEN
        l_left := p_m.qty;
        FOR o IN (SELECT o.id, o.lot_id, o.on_hand_qty, l.expiry_date
                    FROM inv_onhand o JOIN inv_lot l ON l.id = o.lot_id
                   WHERE o.company_id = company AND o.item_id = p_m.item_id AND o.warehouse_id = p_wh AND o.on_hand_qty > 0
                     AND (p_m.lot_id IS NULL OR o.lot_id = p_m.lot_id)
                     AND (l_fs = 'N' OR l.expiry_date IS NULL OR l.expiry_date >= TRUNC(SYSDATE))
                   ORDER BY l.expiry_date NULLS LAST, o.lot_id
                   FOR UPDATE OF o.on_hand_qty) LOOP
          EXIT WHEN l_left <= 0;
          l_take := LEAST(l_left, o.on_hand_qty);
          ins(o.lot_id, l_take, l_uc);
          IF p_m.lot_id IS NULL THEN p_m.lot_id := o.lot_id; END IF;
          l_left := l_left - l_take;
        END LOOP;
        NOONA_CORE_PKG.assert(l_left <= 0, 'NOONA-INV-024',
          'الرصيد المتاح من دفعات سارية لا يكفي للصنف ' || l_item.item_no || ' - ' || l_item.name_ar || ' (المطلوب ' || fqty(p_m.qty)
          || '، الناقص ' || fqty(l_left) || ')', 'Not enough valid lot quantity');
      ELSE
        SELECT NVL(SUM(on_hand_qty), 0) INTO l_avail FROM inv_onhand
         WHERE company_id = company AND item_id = p_m.item_id AND warehouse_id = p_wh;
        NOONA_CORE_PKG.assert(l_neg = 'Y' OR l_avail >= p_m.qty, 'NOONA-INV-025',
          'الرصيد لا يكفي للصنف ' || l_item.item_no || ' - ' || l_item.name_ar || ': المتاح ' || fqty(l_avail) || ' والمطلوب ' || fqty(p_m.qty),
          'Insufficient stock');
        ins(NULL, p_m.qty, l_uc);
      END IF;
      l_total := ROUND(p_m.qty * l_uc, 2);
      UPDATE inv_item_cost
         SET on_hand_qty = on_hand_qty - p_m.qty,
             total_value = CASE WHEN on_hand_qty - p_m.qty <= 0 THEN 0 ELSE total_value - l_total END
       WHERE id = l_cost.id;
    END IF;
    p_m.unit_cost := l_uc;
    p_m.total_cost := l_total;
    RETURN l_total;
  END apply_line;

  FUNCTION new_txn(p_type inv_txn_type%ROWTYPE, p_wh NUMBER, p_to_wh NUMBER, p_date DATE, p_src_type VARCHAR2, p_src_id NUMBER,
                   p_reason VARCHAR2, p_status VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    INSERT INTO inv_transaction (company_id, branch_id, doc_no, doc_date, source_entity_type, source_entity_id, txn_type_id, warehouse_id,
                                 to_warehouse_id, accounting_date, reason_code, status_code)
    VALUES (company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), 'DRAFT-' || RAWTOHEX(SYS_GUID()), TRUNC(p_date), p_src_type, p_src_id,
            p_type.id, p_wh, p_to_wh, TRUNC(p_date), SUBSTR(p_reason, 1, 30), p_status)
    RETURNING id INTO l;
    UPDATE inv_transaction SET doc_no = 'مسودة-' || l WHERE id = l;
    RETURN l;
  END new_txn;

  PROCEDURE number_txn(p_txn NUMBER, p_date DATE) IS
  BEGIN
    UPDATE inv_transaction
       SET doc_no = NOONA_REFERENCE_PKG.next_doc_no('INV_TRANSACTION', company, branch_id, p_date, c_entity, p_txn),
           status_code = 'POSTED', posted_at = SYSTIMESTAMP, posted_by = NOONA_CTX_PKG.current_user_name
     WHERE id = p_txn;
  END number_txn;

  FUNCTION move(p_type_code IN VARCHAR2, p_warehouse_id IN NUMBER, p_date IN DATE, p_source_type IN VARCHAR2,
                p_source_id IN NUMBER, p_lines IN OUT NOCOPY t_moves, p_reference IN VARCHAR2 DEFAULT NULL) RETURN NUMBER
    ACCESSIBLE BY (PACKAGE NOONA_PUR_PKG, PACKAGE NOONA_SAL_PKG, PACKAGE NOONA_POS_PKG) IS
    l_t   inv_txn_type%ROWTYPE := txn_type(p_type_code);
    l_id  NUMBER;
    l_no  PLS_INTEGER := 0;
    l_x   NUMBER;
    l_n   PLS_INTEGER := 0;
  BEGIN
    NOONA_CORE_PKG.assert(p_warehouse_id IS NOT NULL, 'NOONA-INV-026', 'المستودع إلزامي لحركة المخزون', 'Warehouse is required');
    FOR i IN 1 .. p_lines.COUNT LOOP
      IF is_stocked(p_lines(i).item_id) = 'Y' THEN l_n := l_n + 1; END IF;
    END LOOP;
    IF l_n = 0 THEN RETURN NULL; END IF;                         -- لا أصناف مخزنية (خدمات فقط)
    l_id := new_txn(l_t, p_warehouse_id, NULL, p_date, p_source_type, p_source_id, p_reference, 'POSTED');
    FOR i IN 1 .. p_lines.COUNT LOOP
      IF is_stocked(p_lines(i).item_id) = 'Y' THEN
        l_x := apply_line(l_id, l_no, l_t.qty_sign, p_warehouse_id, l_t.txn_class, p_lines(i), p_type_code IN ('SALES_ISSUE', 'POS_ISSUE'));
      ELSE
        p_lines(i).total_cost := 0;
      END IF;
    END LOOP;
    number_txn(l_id, p_date);
    RETURN l_id;
  END move;

  -- ================================================================ مستندات المخزون المباشرة
  FUNCTION save_stock_doc(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := l_o.get_number('id');
    l_type VARCHAR2(30) := NVL(l_o.get_string('type'), 'ADJ_IN');
    l_t    inv_txn_type%ROWTYPE;
    l_date DATE := NVL(TO_DATE(l_o.get_string('date'), 'YYYY-MM-DD'), TRUNC(SYSDATE));
    l_wh   NUMBER := NVL(l_o.get_number('wh'), default_warehouse);
    l_to   NUMBER := l_o.get_number('toWh');
    l_cc   NUMBER := l_o.get_number('cc');
    l_ln   JSON_ARRAY_T := l_o.get_array('lines');
    l_e    JSON_OBJECT_T;
    l_no   PLS_INTEGER := 0;
    l_item inv_item%ROWTYPE;
    l_st   VARCHAR2(30);
    l_lot  NUMBER;
    l_li   NUMBER; l_lq NUMBER; l_lc NUMBER; l_ll VARCHAR2(100); l_lx DATE;
    s_reason  VARCHAR2(4000) := l_o.get_string('reason');
    s_action  VARCHAR2(4000) := l_o.get_string('action');
  BEGIN
    guard(CASE WHEN l_id IS NULL THEN 'INV_TRANSACTION.CREATE' ELSE 'INV_TRANSACTION.UPDATE' END);
    NOONA_CORE_PKG.assert(l_type IN ('OPENING', 'ADJ_IN', 'ADJ_OUT', 'SCRAP', 'CONSUMPTION', 'TRANSFER_OUT'), 'NOONA-INV-030',
                          'نوع مستند المخزون غير صالح', 'Invalid stock document type');
    l_t := txn_type(l_type);
    NOONA_CORE_PKG.assert(l_wh IS NOT NULL, 'NOONA-INV-026', 'المستودع إلزامي (نفذ تجهيز المخزون)', 'Warehouse is required');
    NOONA_CORE_PKG.assert(l_type <> 'TRANSFER_OUT' OR (l_to IS NOT NULL AND l_to <> l_wh), 'NOONA-INV-031',
                          'حدد مستودعاً مستلماً مختلفاً للتحويل', 'Choose a different destination warehouse');
    NOONA_CORE_PKG.assert(l_t.default_reason_required = 'N' OR TRIM(s_reason) IS NOT NULL, 'NOONA-INV-032',
                          'سبب التسوية إلزامي', 'Reason is required');
    IF l_id IS NULL THEN
      l_id := new_txn(l_t, l_wh, l_to, l_date, NULL, NULL, s_reason, 'DRAFT');
    ELSE
      SELECT status_code INTO l_st FROM inv_transaction WHERE id = l_id AND company_id = company FOR UPDATE;
      NOONA_CORE_PKG.assert(l_st = 'DRAFT', 'NOONA-INV-033', 'لا يعدل مستند مخزون بعد ترحيله', 'Only draft documents can be edited');
      UPDATE inv_transaction SET txn_type_id = l_t.id, warehouse_id = l_wh, to_warehouse_id = l_to, doc_date = l_date,
                                 accounting_date = l_date, reason_code = SUBSTR(s_reason, 1, 30)
       WHERE id = l_id;
      DELETE FROM inv_transaction_line WHERE transaction_id = l_id;
    END IF;
    -- مركز التكلفة والبيان في مرجع المصدر (للصرف لمركز تكلفة)
    UPDATE inv_transaction SET source_entity_type = CASE WHEN l_cc IS NOT NULL THEN 'GL_COST_CENTER' END, source_entity_id = l_cc,
                               idempotency_key = NULL
     WHERE id = l_id;
    NOONA_CORE_PKG.assert(l_type <> 'CONSUMPTION' OR l_cc IS NOT NULL, 'NOONA-INV-034', 'حدد مركز التكلفة المستفيد من الصرف',
                          'Cost center is required');
    FOR i IN 0 .. NVL(l_ln.get_size, 0) - 1 LOOP
      l_e := TREAT(l_ln.get(i) AS JSON_OBJECT_T);
      l_li := l_e.get_number('i'); l_lq := l_e.get_number('q'); l_lc := l_e.get_number('c');
      l_ll := TRIM(l_e.get_string('lot')); l_lx := TO_DATE(l_e.get_string('exp'), 'YYYY-MM-DD');
      CONTINUE WHEN l_li IS NULL;
      SELECT * INTO l_item FROM inv_item WHERE id = l_li;
      NOONA_CORE_PKG.assert(NVL(l_lq, 0) > 0, 'NOONA-INV-021', 'الكمية يجب أن تكون موجبة (' || l_item.name_ar || ')',
                            'Quantity must be positive');
      NOONA_CORE_PKG.assert(l_item.item_type NOT IN ('SERVICE', 'NON_STOCK'), 'NOONA-INV-035',
                            'الصنف ' || l_item.name_ar || ' خدمة وليس مخزنياً', 'Not a stock item');
      IF l_t.qty_sign > 0 THEN
        l_lot := lot_for(l_item.id, l_ll, l_lx);
      ELSE
        SELECT MIN(id) INTO l_lot FROM inv_lot WHERE item_id = l_item.id AND lot_no = l_ll;
      END IF;
      l_no := l_no + 1;
      INSERT INTO inv_transaction_line (company_id, transaction_id, line_no, item_id, lot_id, quantity, uom_id, base_quantity, unit_cost,
                                        total_cost, stock_status, ownership_type)
      VALUES (company, l_id, l_no, l_item.id, l_lot, l_lq, l_item.base_uom_id, l_t.qty_sign * l_lq,
              l_lc, ROUND(l_lq * NVL(l_lc, 0), 2), 'AVAILABLE', 'OWNED');
    END LOOP;
    NOONA_CORE_PKG.assert(l_no > 0 OR s_action = 'SAVE', 'NOONA-INV-036', 'أضف صنفاً واحداً على الأقل',
                          'Add at least one line');
    IF s_action = 'POST' THEN
      post_stock_doc(l_id);
    END IF;
    RETURN l_id;
  END save_stock_doc;

  FUNCTION stock_doc_json(p_txn_id IN NUMBER, p_type IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_out CLOB;
  BEGIN
    IF p_txn_id IS NULL THEN
      RETURN '{"id":null,"status":"DRAFT","type":' || jt(NVL(p_type, 'ADJ_IN')) || ',"date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD')
          || '","wh":' || NVL(TO_CHAR(default_warehouse), 'null') || ',"lines":[]}';
    END IF;
    SELECT JSON_OBJECT('id' VALUE t.id, 'no' VALUE t.doc_no, 'status' VALUE t.status_code, 'type' VALUE y.code, 'typeName' VALUE y.name_ar,
             'date' VALUE TO_CHAR(t.doc_date, 'YYYY-MM-DD'), 'wh' VALUE t.warehouse_id, 'toWh' VALUE t.to_warehouse_id,
             'cc' VALUE CASE WHEN t.source_entity_type = 'GL_COST_CENTER' THEN t.source_entity_id END, 'reason' VALUE t.reason_code,
             'lines' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('i' VALUE l.item_id, 'n' VALUE i.item_no || ' - ' || i.name_ar,
                                    'q' VALUE l.quantity, 'c' VALUE l.unit_cost, 'v' VALUE l.total_cost, 'lot' VALUE lt.lot_no,
                                    'exp' VALUE TO_CHAR(lt.expiry_date, 'YYYY-MM-DD')) ORDER BY l.line_no RETURNING CLOB)
                              FROM inv_transaction_line l JOIN inv_item i ON i.id = l.item_id LEFT JOIN inv_lot lt ON lt.id = l.lot_id
                             WHERE l.transaction_id = t.id) FORMAT JSON
             RETURNING CLOB)
      INTO l_out
      FROM inv_transaction t JOIN inv_txn_type y ON y.id = t.txn_type_id
     WHERE t.id = p_txn_id AND t.company_id = company;
    RETURN REPLACE(l_out, '"lines":null', '"lines":[]');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-INV-037', 'مستند المخزون غير موجود', 'Stock document not found');
  END stock_doc_json;

  -- قيد مستند المخزون: سطور مجمعة حسب الحساب ومركز التكلفة
  PROCEDURE post_gl(p_txn NUMBER, p_type VARCHAR2, p_date DATE, p_cc NUMBER, p_desc VARCHAR2, p_jtype VARCHAR2 DEFAULT 'INVENTORY',
                    p_class VARCHAR2 DEFAULT 'INV_TXN_POSTED') IS
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_no    VARCHAR2(100);
    l_j     NUMBER;
    l_wh    NUMBER;
    l_ctr   NUMBER;
    PROCEDURE add(p_acc NUMBER, p_dr NUMBER, p_cr NUMBER, p_ccid NUMBER, p_txt VARCHAR2) IS
    BEGIN
      IF NVL(p_dr, 0) = 0 AND NVL(p_cr, 0) = 0 THEN RETURN; END IF;
      l_lines.EXTEND;
      l_lines(l_lines.COUNT).account_id := p_acc;
      l_lines(l_lines.COUNT).debit := NVL(p_dr, 0);
      l_lines(l_lines.COUNT).credit := NVL(p_cr, 0);
      l_lines(l_lines.COUNT).cost_center_id := p_ccid;
      l_lines(l_lines.COUNT).description := p_txt;
    END add;
  BEGIN
    SELECT doc_no, warehouse_id INTO l_no, l_wh FROM inv_transaction WHERE id = p_txn;
    l_ctr := CASE p_type WHEN 'OPENING' THEN acc_id('3105') WHEN 'ADJ_IN' THEN acc_id('4203') ELSE acc_id('5213') END;
    -- الحسابات المقابلة لكل صنف: المخزون، والمصروف لمركز التكلفة في الصرف
    FOR r IN (SELECT account_for(l.item_id, 'INVENTORY') inv_acc,
                     CASE WHEN p_type = 'CONSUMPTION' THEN account_for(l.item_id, 'EXPENSE') END exp_acc,
                     SUM(ABS(l.total_cost)) amt
                FROM inv_transaction_line l WHERE l.transaction_id = p_txn
               GROUP BY account_for(l.item_id, 'INVENTORY'), CASE WHEN p_type = 'CONSUMPTION' THEN account_for(l.item_id, 'EXPENSE') END
              HAVING SUM(ABS(l.total_cost)) > 0) LOOP
      IF p_type IN ('OPENING', 'ADJ_IN') THEN
        add(r.inv_acc, r.amt, 0, NULL, p_desc);
        add(l_ctr, 0, r.amt, CASE WHEN NOONA_GL_PKG.cc_rule(l_ctr) = 'REQUIRED' THEN NVL(p_cc, item_cost_center(NULL, l_wh)) END, p_desc);
      ELSIF p_type = 'CONSUMPTION' THEN
        add(r.exp_acc, r.amt, 0, p_cc, p_desc);
        add(r.inv_acc, 0, r.amt, NULL, p_desc);
      ELSE
        add(l_ctr, r.amt, 0, CASE WHEN NOONA_GL_PKG.cc_rule(l_ctr) <> 'FORBIDDEN' THEN NVL(p_cc, item_cost_center(NULL, l_wh)) END, p_desc);
        add(r.inv_acc, 0, r.amt, NULL, p_desc);
      END IF;
    END LOOP;
    IF l_lines.COUNT >= 2 THEN
      l_j := NOONA_ACE_PKG.post_source(p_class, 'INVENTORY', c_entity, p_txn, p_date, txn_type_label(p_type) || ' ' || l_no || ': ' || p_desc,
                                       NOONA_GL_PKG.ledger_currency, 1, l_lines, l_no, NULL, p_jtype);
      UPDATE inv_transaction SET accounting_event_id = (SELECT accounting_event_id FROM gl_journal WHERE id = l_j) WHERE id = p_txn;
    END IF;
  END post_gl;

  PROCEDURE post_stock_doc(p_txn_id IN NUMBER) IS
    l_t     inv_transaction%ROWTYPE;
    l_y     inv_txn_type%ROWTYPE;
    l_moves t_moves := t_moves();
    l_no    PLS_INTEGER := 0;
    l_x     NUMBER;
    l_in    NUMBER;
    l_in_y  inv_txn_type%ROWTYPE;
    l_n     PLS_INTEGER := 0;
  BEGIN
    guard('INV_TRANSACTION.POST');
    SELECT * INTO l_t FROM inv_transaction WHERE id = p_txn_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_t.status_code = 'DRAFT', 'NOONA-INV-033', 'المستند مرحل أو ملغى', 'Document is not a draft');
    SELECT * INTO l_y FROM inv_txn_type WHERE id = l_t.txn_type_id;
    FOR r IN (SELECT * FROM inv_transaction_line WHERE transaction_id = p_txn_id ORDER BY line_no) LOOP
      l_moves.EXTEND;
      l_moves(l_moves.COUNT).item_id := r.item_id;
      l_moves(l_moves.COUNT).qty := r.quantity;
      l_moves(l_moves.COUNT).unit_cost := CASE WHEN l_y.qty_sign > 0 THEN r.unit_cost END;
      l_moves(l_moves.COUNT).lot_id := r.lot_id;
    END LOOP;
    NOONA_CORE_PKG.assert(l_moves.COUNT > 0, 'NOONA-INV-036', 'أضف صنفاً واحداً على الأقل', 'Add at least one line');
    IF l_y.qty_sign > 0 AND l_y.code IN ('OPENING', 'ADJ_IN') THEN
      FOR i IN 1 .. l_moves.COUNT LOOP
        NOONA_CORE_PKG.assert(NVL(l_moves(i).unit_cost, 0) > 0 OR avg_cost(l_moves(i).item_id) > 0, 'NOONA-INV-038',
          'أدخل تكلفة الوحدة للصنف ' || item_label(l_moves(i).item_id) || ' (لا توجد تكلفة سابقة)', 'Unit cost is required');
      END LOOP;
    END IF;
    DELETE FROM inv_transaction_line WHERE transaction_id = p_txn_id;
    FOR i IN 1 .. l_moves.COUNT LOOP
      l_x := apply_line(p_txn_id, l_no, l_y.qty_sign, l_t.warehouse_id, l_y.txn_class, l_moves(i), FALSE);
    END LOOP;
    number_txn(p_txn_id, l_t.doc_date);
    -- التحويل: حركة وارد للمستودع المستلم بنفس التكلفة
    IF l_y.code = 'TRANSFER_OUT' THEN
      l_in_y := txn_type('TRANSFER_IN');
      l_in := new_txn(l_in_y, l_t.to_warehouse_id, l_t.warehouse_id, l_t.doc_date, c_entity, p_txn_id, l_t.reason_code, 'POSTED');
      l_no := 0;
      FOR r IN (SELECT item_id, lot_id, SUM(quantity) q, MAX(unit_cost) c FROM inv_transaction_line WHERE transaction_id = p_txn_id
                 GROUP BY item_id, lot_id) LOOP
        l_moves := t_moves();
        l_moves.EXTEND;
        l_moves(1).item_id := r.item_id; l_moves(1).qty := r.q; l_moves(1).unit_cost := r.c; l_moves(1).lot_id := r.lot_id;
        l_x := apply_line(l_in, l_no, 1, l_t.to_warehouse_id, 'TRANSFER_IN', l_moves(1), FALSE);
        l_n := l_n + 1;
      END LOOP;
      number_txn(l_in, l_t.doc_date);
    ELSE
      post_gl(p_txn_id, l_y.code, l_t.doc_date, CASE WHEN l_t.source_entity_type = 'GL_COST_CENTER' THEN l_t.source_entity_id END,
              NVL(l_t.reason_code, l_y.name_ar));
    END IF;
    NOONA_AUDIT_PKG.log_event('POSTING', c_entity, p_txn_id, 'POST', 'SUCCESS');
  END post_stock_doc;

  PROCEDURE cancel_stock_doc(p_txn_id IN NUMBER) IS
  BEGIN
    guard('INV_TRANSACTION.CANCEL');
    UPDATE inv_transaction SET status_code = 'CANCELLED' WHERE id = p_txn_id AND company_id = company AND status_code = 'DRAFT';
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-INV-033', 'يلغى المستند المسودة فقط', 'Only drafts can be cancelled');
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_entity, p_txn_id, 'CANCEL', 'SUCCESS');
  END cancel_stock_doc;

  -- ================================================================ التصنيع
  FUNCTION save_bom(p_item_id IN NUMBER, p_lines IN CLOB, p_base_qty IN NUMBER DEFAULT 1) RETURN NUMBER IS
    l_item inv_item%ROWTYPE;
    l_bom  NUMBER;
    l_ver  NUMBER;
    l_no   PLS_INTEGER := 0;
    l_used NUMBER;
  BEGIN
    guard('MFG_BOM.CREATE');
    SELECT * INTO l_item FROM inv_item WHERE id = p_item_id;
    -- التحقق قبل أي تعديل
    FOR r IN (SELECT * FROM JSON_TABLE(p_lines, '$[*]' COLUMNS (i NUMBER PATH '$.i', q NUMBER PATH '$.q'))) LOOP
      CONTINUE WHEN r.i IS NULL;
      NOONA_CORE_PKG.assert(r.i <> p_item_id, 'NOONA-INV-040', 'المنتج لا يكون مكوناً لنفسه', 'An item cannot be its own component');
      NOONA_CORE_PKG.assert(NVL(r.q, 0) > 0, 'NOONA-INV-041', 'كمية المكون يجب أن تكون موجبة', 'Component quantity must be positive');
      l_no := l_no + 1;
    END LOOP;
    NOONA_CORE_PKG.assert(l_no > 0, 'NOONA-INV-042', 'أضف مكوناً واحداً على الأقل', 'Add at least one component');
    l_no := 0;
    SELECT MAX(id), MAX(version_no) INTO l_bom, l_ver FROM mfg_bom
     WHERE company_id = company AND item_id = p_item_id AND is_default = 'Y' AND status_code <> 'OBSOLETE';
    -- القائمة المستخدمة في إنتاج سابق لا تعدل: تنشأ نسخة جديدة
    IF l_bom IS NOT NULL THEN
      SELECT COUNT(*) INTO l_used FROM inv_transaction WHERE source_entity_type = 'MFG_BOM' AND source_entity_id = l_bom AND ROWNUM = 1;
      IF l_used > 0 THEN
        UPDATE mfg_bom SET status_code = 'OBSOLETE', is_default = 'N', effective_to = TRUNC(SYSDATE) WHERE id = l_bom;
        l_bom := NULL;
      ELSE
        DELETE FROM mfg_bom_line WHERE bom_id = l_bom;
        UPDATE mfg_bom SET base_quantity = NVL(p_base_qty, 1) WHERE id = l_bom;
      END IF;
    END IF;
    IF l_bom IS NULL THEN
      INSERT INTO mfg_bom (company_id, code, name_ar, item_id, version_no, bom_type, base_quantity, uom_id, is_default, status_code)
      VALUES (company, l_item.item_no, 'قائمة مواد ' || l_item.name_ar, p_item_id, NVL(l_ver, 0) + 1, 'PRODUCTION', NVL(p_base_qty, 1),
              l_item.base_uom_id, 'Y', 'PUBLISHED')
      RETURNING id INTO l_bom;
    END IF;
    FOR r IN (SELECT * FROM JSON_TABLE(p_lines, '$[*]' COLUMNS (i NUMBER PATH '$.i', q NUMBER PATH '$.q', s NUMBER PATH '$.s'))) LOOP
      CONTINUE WHEN r.i IS NULL;
      NOONA_CORE_PKG.assert(r.i <> p_item_id, 'NOONA-INV-040', 'المنتج لا يكون مكوناً لنفسه', 'An item cannot be its own component');
      NOONA_CORE_PKG.assert(NVL(r.q, 0) > 0, 'NOONA-INV-041', 'كمية المكون يجب أن تكون موجبة', 'Component quantity must be positive');
      l_no := l_no + 1;
      INSERT INTO mfg_bom_line (company_id, bom_id, line_no, component_item_id, quantity, uom_id, scrap_pct, sort_order)
      SELECT company, l_bom, l_no, r.i, r.q, base_uom_id, NVL(r.s, 0), l_no FROM inv_item WHERE id = r.i;
    END LOOP;
    NOONA_CORE_PKG.assert(l_no > 0, 'NOONA-INV-042', 'أضف مكوناً واحداً على الأقل', 'Add at least one component');
    UPDATE inv_item SET is_manufactured = 'Y' WHERE id = p_item_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'MFG_BOM', l_bom, 'SAVE', 'SUCCESS');
    RETURN l_bom;
  END save_bom;

  FUNCTION bom_json(p_item_id IN NUMBER) RETURN CLOB IS
    l_out CLOB;
  BEGIN
    SELECT JSON_OBJECT('bom' VALUE b.id, 'version' VALUE b.version_no, 'base' VALUE b.base_quantity,
             'lines' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('i' VALUE l.component_item_id, 'n' VALUE i.item_no || ' - ' || i.name_ar,
                                    'q' VALUE l.quantity, 's' VALUE l.scrap_pct, 'c' VALUE avg_cost(l.component_item_id),
                                    'oh' VALUE on_hand(l.component_item_id)) ORDER BY l.line_no RETURNING CLOB)
                              FROM mfg_bom_line l JOIN inv_item i ON i.id = l.component_item_id WHERE l.bom_id = b.id) FORMAT JSON
             RETURNING CLOB)
      INTO l_out
      FROM mfg_bom b WHERE b.company_id = company AND b.item_id = p_item_id AND b.is_default = 'Y' AND ROWNUM = 1;
    RETURN l_out;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '{"bom":null,"lines":[]}';
  END bom_json;

  FUNCTION produce(p_item_id IN NUMBER, p_qty IN NUMBER, p_warehouse_id IN NUMBER, p_date IN DATE,
                   p_description IN VARCHAR2 DEFAULT NULL, p_lot_no IN VARCHAR2 DEFAULT NULL, p_expiry IN DATE DEFAULT NULL) RETURN NUMBER IS
    l_bom   mfg_bom%ROWTYPE;
    l_wh    NUMBER := NVL(p_warehouse_id, default_warehouse);
    l_iss   NUMBER;
    l_rec   NUMBER;
    l_no    PLS_INTEGER := 0;
    l_m     t_move;
    l_x     NUMBER;
    l_total NUMBER := 0;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
    l_fg    NUMBER := account_for(p_item_id, 'INVENTORY');
    l_dn    VARCHAR2(100);
  BEGIN
    guard('INV_TRANSACTION.POST');
    NOONA_CORE_PKG.assert(NVL(p_qty, 0) > 0, 'NOONA-INV-021', 'كمية الإنتاج يجب أن تكون موجبة', 'Quantity must be positive');
    BEGIN
      SELECT * INTO l_bom FROM mfg_bom WHERE company_id = company AND item_id = p_item_id AND is_default = 'Y' AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-INV-043', 'لا توجد قائمة مواد للمنتج؛ عرّف مكوناته أولاً', 'No bill of materials');
    END;
    -- صرف المكونات
    l_iss := new_txn(txn_type('MFG_ISSUE'), l_wh, NULL, p_date, 'MFG_BOM', l_bom.id, SUBSTR(p_description, 1, 30), 'POSTED');
    FOR r IN (SELECT component_item_id, quantity, scrap_pct FROM mfg_bom_line WHERE bom_id = l_bom.id ORDER BY line_no) LOOP
      l_m := NULL;
      l_m.item_id := r.component_item_id;
      l_m.qty := ROUND(r.quantity * p_qty / l_bom.base_quantity * (1 + NVL(r.scrap_pct, 0) / 100), 6);
      l_x := apply_line(l_iss, l_no, -1, l_wh, 'MFG_ISSUE', l_m, FALSE);
      l_total := l_total + l_x;
      -- قيد: دائن مخزون الخامات لكل مكون
      l_lines.EXTEND;
      l_lines(l_lines.COUNT).account_id := account_for(r.component_item_id, 'INVENTORY');
      l_lines(l_lines.COUNT).debit := 0;
      l_lines(l_lines.COUNT).credit := l_x;
      l_lines(l_lines.COUNT).description := 'صرف ' || item_label(r.component_item_id);
      l_lines(l_lines.COUNT).item_id := r.component_item_id;
    END LOOP;
    number_txn(l_iss, p_date);
    -- استلام المنتج التام بتكلفة المكونات
    l_rec := new_txn(txn_type('MFG_RECEIPT'), l_wh, NULL, p_date, c_entity, l_iss, SUBSTR(p_description, 1, 30), 'POSTED');
    l_no := 0;
    l_m := NULL;
    l_m.item_id := p_item_id; l_m.qty := p_qty; l_m.unit_cost := ROUND(l_total / p_qty, 6); l_m.lot_no := p_lot_no; l_m.expiry := p_expiry;
    l_x := apply_line(l_rec, l_no, 1, l_wh, 'MFG_RECEIPT', l_m, FALSE);
    number_txn(l_rec, p_date);
    -- القيد (يتجاهل الأسطر الصفرية؛ إن كان المخزون نفس الحساب يتقابل)
    l_lines.EXTEND;
    l_lines(l_lines.COUNT).account_id := l_fg;
    l_lines(l_lines.COUNT).debit := l_total;
    l_lines(l_lines.COUNT).credit := 0;
    l_lines(l_lines.COUNT).description := 'إنتاج ' || fqty(p_qty) || ' ' || item_label(p_item_id);
    l_lines(l_lines.COUNT).item_id := p_item_id;
    IF l_total > 0 THEN
      DECLARE
        l_clean NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
      BEGIN
        FOR i IN 1 .. l_lines.COUNT LOOP
          IF NVL(l_lines(i).debit, 0) > 0 OR NVL(l_lines(i).credit, 0) > 0 THEN
            l_clean.EXTEND; l_clean(l_clean.COUNT) := l_lines(i);
          END IF;
        END LOOP;
        SELECT doc_no INTO l_dn FROM inv_transaction WHERE id = l_rec;
        l_j := NOONA_ACE_PKG.post_source('MFG_PRODUCTION_POSTED', 'MANUFACTURING', c_entity, l_rec, p_date,
                                         'إنتاج ' || item_label(p_item_id) || ' ' || l_dn || NVL2(p_description, ': ' || p_description, ''),
                                         NOONA_GL_PKG.ledger_currency, 1, l_clean, l_dn, NULL, 'MANUFACTURING');
      END;
    END IF;
    NOONA_AUDIT_PKG.log_event('POSTING', c_entity, l_rec, 'PRODUCE', 'SUCCESS',
      p_new_values => '{"qty":' || fnum(p_qty) || ',"cost":' || fnum(l_total) || '}');
    RETURN l_rec;
  END produce;

  -- ================================================================ التقارير
  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_class VARCHAR2 DEFAULT '') RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_class || '"><span class="nn-kpi-icon fa ' || p_icon || '" aria-hidden="true"></span><div>'
        || '<div class="nn-kpi-value">' || p_value || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION inv_summary RETURN CLOB IS
    l_items NUMBER; l_val NUMBER; l_low NUMBER; l_exp NUMBER; l_soon NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_items FROM inv_item WHERE status_code = 'ACTIVE';
    SELECT NVL(SUM(total_value), 0) INTO l_val FROM inv_item_cost WHERE company_id = company AND warehouse_id IS NULL;
    SELECT COUNT(*) INTO l_low FROM inv_item_company c
     WHERE c.company_id = company AND c.min_qty IS NOT NULL
       AND (SELECT NVL(SUM(on_hand_qty), 0) FROM inv_onhand o WHERE o.item_id = c.item_id AND o.company_id = company) < c.min_qty;
    SELECT COUNT(DISTINCT o.lot_id) INTO l_exp FROM inv_onhand o JOIN inv_lot l ON l.id = o.lot_id
     WHERE o.company_id = company AND o.on_hand_qty > 0 AND l.expiry_date < TRUNC(SYSDATE);
    SELECT COUNT(DISTINCT o.lot_id) INTO l_soon FROM inv_onhand o JOIN inv_lot l ON l.id = o.lot_id
     WHERE o.company_id = company AND o.on_hand_qty > 0 AND l.expiry_date BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE) + 90;
    RETURN '<div class="nn-kpis">' || kpi('الأصناف النشطة', l_items, 'fa-cubes')
        || kpi('قيمة المخزون', fmt(l_val), 'fa-money')
        || kpi('تحت حد الطلب', l_low, 'fa-exclamation-triangle', CASE WHEN l_low > 0 THEN 'is-warning' END)
        || kpi('دفعات منتهية بالمخزون', l_exp, 'fa-ban', CASE WHEN l_exp > 0 THEN 'is-danger' END)
        || kpi('تنتهي خلال 90 يوماً', l_soon, 'fa-clock-o', CASE WHEN l_soon > 0 THEN 'is-warning' END) || '</div>';
  END inv_summary;

  FUNCTION stock_balance(p_warehouse_id IN NUMBER DEFAULT NULL, p_category_id IN NUMBER DEFAULT NULL,
                         p_show_zero IN VARCHAR2 DEFAULT 'N', p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_html CLOB;
    l_tot  NUMBER := 0;
    l_n    PLS_INTEGER := 0;
    l_wh   VARCHAR2(200);
  BEGIN
    guard('INV_ONHAND.VIEW');
    SELECT MAX(name_ar) INTO l_wh FROM inv_warehouse WHERE id = p_warehouse_id;
    l_html := NOONA_BRAND_PKG.report_header('أرصدة المخزون' || CASE WHEN l_wh IS NOT NULL THEN ' - ' || l_wh END)
           || '<table class="nn-rpt"><thead><tr><th>رقم الصنف</th><th>الكود</th><th>الصنف</th><th>الفئة</th><th>الكمية</th><th>الوحدة</th>'
           || '<th>متوسط التكلفة</th><th>القيمة</th><th>الحد الأدنى</th></tr></thead><tbody>';
    FOR r IN (SELECT i.id, i.item_no, i.item_code, i.name_ar, g.name_ar cat, u.name_ar uom, NVL(q.qty, 0) qty, avg_cost(i.id) ac, c.min_qty
                FROM inv_item i JOIN inv_item_category g ON g.id = i.category_id JOIN inv_uom u ON u.id = i.base_uom_id
                LEFT JOIN inv_item_company c ON c.item_id = i.id AND c.company_id = company
                LEFT JOIN (SELECT item_id, SUM(on_hand_qty) qty FROM inv_onhand
                            WHERE company_id = company AND (p_warehouse_id IS NULL OR warehouse_id = p_warehouse_id) GROUP BY item_id) q
                       ON q.item_id = i.id
               WHERE i.item_type NOT IN ('SERVICE', 'NON_STOCK') AND (p_category_id IS NULL OR i.category_id = p_category_id)
                 AND (p_show_zero = 'Y' OR NVL(q.qty, 0) <> 0)
               ORDER BY g.name_ar, i.item_no) LOOP
      l_n := l_n + 1;
      l_tot := l_tot + ROUND(r.qty * r.ac, 2);
      l_html := l_html || '<tr' || CASE WHEN r.min_qty IS NOT NULL AND r.qty < r.min_qty THEN ' class="nn-rpt-warn"' END || '><td class="nn-num-code">'
             || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', r.id) || '">' || esc(r.item_no) || '</a>' ELSE esc(r.item_no) END
             || '</td><td>' || esc(r.item_code) || '</td><td class="nn-rpt-text">' || esc(r.name_ar) || '</td><td>' || esc(r.cat)
             || '</td><td>' || fqty(r.qty) || '</td><td>' || esc(r.uom) || '</td><td>' || fmt(r.ac) || '</td><td>' || fmt(r.qty * r.ac)
             || '</td><td>' || CASE WHEN r.min_qty IS NOT NULL THEN fqty(r.min_qty) END || '</td></tr>';
    END LOOP;
    IF l_n = 0 THEN
      l_html := l_html || '<tr><td colspan="9" class="nn-rpt-text">لا توجد أرصدة</td></tr>';
    END IF;
    RETURN l_html || '</tbody><tfoot><tr><td colspan="7">إجمالي قيمة المخزون (' || l_n || ' صنف)</td><td>' || fmt(l_tot)
        || '</td><td></td></tr></tfoot></table>'
        || NOONA_GL_PKG.report_footer('الكمية من الحركات المرحلة؛ القيمة بالمتوسط المرجح للشركة');
  END stock_balance;

  FUNCTION item_card(p_item_id IN NUMBER, p_from IN DATE, p_to IN DATE, p_warehouse_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_html CLOB;
    l_bal  NUMBER;
    l_in   NUMBER := 0; l_out NUMBER := 0;
  BEGIN
    guard('INV_TRANSACTION.VIEW');
    IF p_item_id IS NULL THEN RETURN '<div class="nn-empty">اختر صنفاً</div>'; END IF;
    SELECT NVL(SUM(l.base_quantity), 0) INTO l_bal
      FROM inv_transaction_line l JOIN inv_transaction t ON t.id = l.transaction_id
     WHERE l.item_id = p_item_id AND t.company_id = company AND t.status_code = 'POSTED' AND t.doc_date < p_from
       AND (p_warehouse_id IS NULL OR t.warehouse_id = p_warehouse_id);
    l_html := NOONA_BRAND_PKG.report_header('بطاقة صنف: ' || item_label(p_item_id) || ' من ' || TO_CHAR(p_from, 'YYYY-MM-DD')
                                            || ' إلى ' || TO_CHAR(p_to, 'YYYY-MM-DD'))
           || '<table class="nn-rpt"><thead><tr><th>التاريخ</th><th>المستند</th><th>الحركة</th><th>المستودع</th><th>الدفعة</th>'
           || '<th>وارد</th><th>صادر</th><th>الرصيد</th><th>تكلفة الوحدة</th></tr></thead><tbody>'
           || '<tr class="nn-rpt-head2"><td colspan="7">الرصيد الافتتاحي</td><td>' || fqty(l_bal) || '</td><td></td></tr>';
    FOR r IN (SELECT t.doc_date, t.doc_no, y.name_ar typ, w.name_ar wh, lt.lot_no, lt.expiry_date, l.base_quantity q, l.unit_cost
                FROM inv_transaction_line l JOIN inv_transaction t ON t.id = l.transaction_id JOIN inv_txn_type y ON y.id = t.txn_type_id
                JOIN inv_warehouse w ON w.id = t.warehouse_id LEFT JOIN inv_lot lt ON lt.id = l.lot_id
               WHERE l.item_id = p_item_id AND t.company_id = company AND t.status_code = 'POSTED' AND t.doc_date BETWEEN p_from AND p_to
                 AND (p_warehouse_id IS NULL OR t.warehouse_id = p_warehouse_id)
               ORDER BY t.doc_date, t.id, l.line_no) LOOP
      l_bal := l_bal + r.q;
      IF r.q > 0 THEN l_in := l_in + r.q; ELSE l_out := l_out - r.q; END IF;
      l_html := l_html || '<tr><td>' || TO_CHAR(r.doc_date, 'YYYY-MM-DD') || '</td><td>' || esc(r.doc_no) || '</td><td class="nn-rpt-text">'
             || esc(r.typ) || '</td><td>' || esc(r.wh) || '</td><td>' || esc(r.lot_no)
             || CASE WHEN r.expiry_date IS NOT NULL THEN ' (' || TO_CHAR(r.expiry_date, 'YYYY-MM-DD') || ')' END || '</td><td>'
             || CASE WHEN r.q > 0 THEN fqty(r.q) END || '</td><td>' || CASE WHEN r.q < 0 THEN fqty(-r.q) END || '</td><td>' || fqty(l_bal)
             || '</td><td>' || fmt(r.unit_cost) || '</td></tr>';
    END LOOP;
    RETURN l_html || '</tbody><tfoot><tr><td colspan="5">الإجمالي</td><td>' || fqty(l_in) || '</td><td>' || fqty(l_out) || '</td><td>'
        || fqty(l_bal) || '</td><td></td></tr></tfoot></table>' || NOONA_GL_PKG.report_footer('الحركات المرحلة فقط');
  END item_card;

  FUNCTION expiry_report(p_days IN NUMBER DEFAULT 90, p_warehouse_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_html CLOB;
    l_n    PLS_INTEGER := 0;
  BEGIN
    guard('INV_ONHAND.VIEW');
    l_html := NOONA_BRAND_PKG.report_header('الدفعات المنتهية والقريبة الانتهاء (خلال ' || NVL(p_days, 90) || ' يوماً)')
           || '<table class="nn-rpt"><thead><tr><th>الصنف</th><th>المادة الفعالة</th><th>الدفعة</th><th>تاريخ الانتهاء</th><th>المتبقي (يوم)</th>'
           || '<th>المستودع</th><th>الكمية</th><th>القيمة</th></tr></thead><tbody>';
    FOR r IN (SELECT i.item_no || ' - ' || i.name_ar item, i.generic_name, l.lot_no, l.expiry_date, w.name_ar wh, o.on_hand_qty q,
                     o.on_hand_qty * avg_cost(i.id) v, l.expiry_date - TRUNC(SYSDATE) days
                FROM inv_onhand o JOIN inv_lot l ON l.id = o.lot_id JOIN inv_item i ON i.id = o.item_id JOIN inv_warehouse w ON w.id = o.warehouse_id
               WHERE o.company_id = company AND o.on_hand_qty > 0 AND l.expiry_date <= TRUNC(SYSDATE) + NVL(p_days, 90)
                 AND (p_warehouse_id IS NULL OR o.warehouse_id = p_warehouse_id)
               ORDER BY l.expiry_date, i.item_no) LOOP
      l_n := l_n + 1;
      l_html := l_html || '<tr' || CASE WHEN r.days < 0 THEN ' class="nn-rpt-bad"' WHEN r.days <= 30 THEN ' class="nn-rpt-warn"' END
             || '><td class="nn-rpt-text">' || esc(r.item) || '</td><td>' || esc(r.generic_name) || '</td><td>' || esc(r.lot_no) || '</td><td>'
             || TO_CHAR(r.expiry_date, 'YYYY-MM-DD') || '</td><td>' || CASE WHEN r.days < 0 THEN 'منتهية' ELSE TO_CHAR(r.days) END
             || '</td><td>' || esc(r.wh) || '</td><td>' || fqty(r.q) || '</td><td>' || fmt(r.v) || '</td></tr>';
    END LOOP;
    IF l_n = 0 THEN
      l_html := l_html || '<tr><td colspan="8" class="nn-rpt-text">لا توجد دفعات منتهية أو قريبة الانتهاء</td></tr>';
    END IF;
    RETURN l_html || '</tbody></table>' || NOONA_GL_PKG.report_footer('الدفعات التي لها رصيد فقط؛ الدفعة المنتهية لا تباع');
  END expiry_report;

  FUNCTION reorder_report RETURN CLOB IS
    l_html CLOB;
    l_n    PLS_INTEGER := 0;
  BEGIN
    guard('INV_ONHAND.VIEW');
    l_html := NOONA_BRAND_PKG.report_header('الأصناف تحت حد إعادة الطلب')
           || '<table class="nn-rpt"><thead><tr><th>الصنف</th><th>الرصيد</th><th>الحد الأدنى</th><th>الحد الأعلى</th>'
           || '<th>الكمية المقترحة للطلب</th><th>آخر سعر شراء</th><th>القيمة التقديرية</th></tr></thead><tbody>';
    FOR r IN (SELECT i.item_no || ' - ' || i.name_ar item, q.qty, c.min_qty, c.max_qty, c.reorder_qty, c.last_purchase_price,
                     GREATEST(NVL(c.reorder_qty, 0), NVL(c.max_qty, c.min_qty) - q.qty) sugg
                FROM inv_item_company c JOIN inv_item i ON i.id = c.item_id
                CROSS APPLY (SELECT NVL(SUM(on_hand_qty), 0) qty FROM inv_onhand o WHERE o.item_id = c.item_id AND o.company_id = company) q
               WHERE c.company_id = company AND c.min_qty IS NOT NULL AND q.qty < c.min_qty AND i.status_code = 'ACTIVE'
               ORDER BY i.item_no) LOOP
      l_n := l_n + 1;
      l_html := l_html || '<tr><td class="nn-rpt-text">' || esc(r.item) || '</td><td>' || fqty(r.qty) || '</td><td>' || fqty(r.min_qty)
             || '</td><td>' || CASE WHEN r.max_qty IS NOT NULL THEN fqty(r.max_qty) END || '</td><td><b>' || fqty(r.sugg) || '</b></td><td>'
             || fmt(r.last_purchase_price) || '</td><td>' || fmt(r.sugg * r.last_purchase_price) || '</td></tr>';
    END LOOP;
    IF l_n = 0 THEN
      l_html := l_html || '<tr><td colspan="7" class="nn-rpt-text">لا توجد أصناف تحت حد الطلب</td></tr>';
    END IF;
    RETURN l_html || '</tbody></table>' || NOONA_GL_PKG.report_footer('الكمية المقترحة: حتى الحد الأعلى أو كمية إعادة الطلب أيهما أكبر');
  END reorder_report;

  FUNCTION fitment_search(p_make IN VARCHAR2, p_model IN VARCHAR2 DEFAULT NULL, p_year IN NUMBER DEFAULT NULL,
                          p_warehouse_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_html CLOB;
    l_n    PLS_INTEGER := 0;
  BEGIN
    guard('INV_ITEM.VIEW');
    IF TRIM(p_make) IS NULL THEN RETURN '<div class="nn-empty">أدخل الشركة المصنعة للمركبة</div>'; END IF;
    l_html := NOONA_BRAND_PKG.report_header('قطع الغيار المتوافقة: ' || p_make || NVL2(p_model, ' ' || p_model, '') || NVL2(p_year, ' ' || p_year, ''))
           || '<table class="nn-rpt"><thead><tr><th>رقم الصنف</th><th>القطعة</th><th>رقم OEM</th><th>العلامة</th><th>التوافق</th>'
           || '<th>الرصيد</th><th>سعر البيع</th><th>البدائل</th></tr></thead><tbody>';
    FOR r IN (SELECT i.id, i.item_no, i.name_ar, i.manufacturer_part_no, i.brand,
                     f.vehicle_make || ' ' || f.vehicle_model || ' ' || f.year_from || NVL2(f.year_to, '-' || f.year_to, '') || ' ' || f.engine fit,
                     on_hand(i.id, p_warehouse_id) qty, c.sale_price,
                     (SELECT LISTAGG(x.item_no, '، ') WITHIN GROUP (ORDER BY x.item_no) FROM inv_item_alternate a JOIN inv_item x ON x.id = a.alt_item_id
                       WHERE a.item_id = i.id) alts
                FROM inv_item_fitment f JOIN inv_item i ON i.id = f.item_id
                LEFT JOIN inv_item_company c ON c.item_id = i.id AND c.company_id = company
               WHERE UPPER(f.vehicle_make) LIKE '%' || UPPER(TRIM(p_make)) || '%'
                 AND (p_model IS NULL OR UPPER(f.vehicle_model) LIKE '%' || UPPER(TRIM(p_model)) || '%')
                 AND (p_year IS NULL OR p_year BETWEEN NVL(f.year_from, 0) AND NVL(f.year_to, 9999))
                 AND i.status_code = 'ACTIVE'
               ORDER BY i.name_ar) LOOP
      l_n := l_n + 1;
      l_html := l_html || '<tr><td class="nn-num-code">' || esc(r.item_no) || '</td><td class="nn-rpt-text">' || esc(r.name_ar) || '</td><td>'
             || esc(r.manufacturer_part_no) || '</td><td>' || esc(r.brand) || '</td><td>' || esc(r.fit) || '</td><td>' || fqty(r.qty)
             || '</td><td>' || fmt(r.sale_price) || '</td><td>' || esc(r.alts) || '</td></tr>';
    END LOOP;
    IF l_n = 0 THEN
      l_html := l_html || '<tr><td colspan="8" class="nn-rpt-text">لا توجد قطع مسجل توافقها مع هذه المركبة</td></tr>';
    END IF;
    RETURN l_html || '</tbody></table>' || NOONA_GL_PKG.report_footer;
  END fitment_search;

END NOONA_INV_PKG;
/
