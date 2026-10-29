-- =============================================================================
-- NOONA PLUS ERP | NOONA_RES_PKG - التطوير العقاري وبيع الوحدات
--   * قوائم الأسعار (سعر الوحدة والحد الأدنى دون موافقة) وخطط السداد (دفعة أولى، أقساط دورية، دفعة عند التسليم)
--   * الحجز بعربون (قيد العربون، الصلاحية، الإلغاء برد العربون أو مصادرة جزء منه)
--   * عقد البيع من الحجز أو مباشرة: جدول الأقساط من الخطة، الضريبة حسب نوع الوحدة (السكنية معفاة والتجارية خاضعة)
--   * فوترة الأقساط عند استحقاقها بفواتير مبيعات عادية (ذمم، تحصيل، سجل ضريبي، فوترة إلكترونية) على حساب الدفعات المقدمة
--   * التسليم: الاعتراف بالإيراد وتكلفة الوحدة (من رسملة تكاليف مشروع التطوير)، الإفراغ ونقل الملكية، الفسخ بالمصادرة والرد
--   * عمولات الوسطاء: الاستحقاق عند التوقيع، الأهلية بنسبة التحصيل، الاعتماد والسداد
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_RES_PKG AUTHID DEFINER AS
  FUNCTION company RETURN NUMBER;
  -- حسابات بيع الوحدات (العربون 2151، الدفعات المقدمة 2150، الإيراد 4140، المصادرة 4141، الوحدات المعدة للبيع 1150،
  -- تكلفة المبيعات 5160، العمولات 5161 و2152)؛ يعيد عدد المنشأ
  FUNCTION setup_accounts RETURN NUMBER;
  FUNCTION status_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION badge(p_code IN VARCHAR2) RETURN VARCHAR2;

  -- ---------------------------------------------------------- الأسعار وخطط السداد
  -- {"id","code","name","property","from":"YYYY-MM-DD","lines":[{"unit","price","min"}]} ؛ القائمة مسودة حتى تفعيلها
  FUNCTION save_price_list(p_doc IN CLOB) RETURN NUMBER;
  -- تفعيل القائمة: تنتهي القائمة الفعالة السابقة للعقار ويحدث سعر الوحدات
  PROCEDURE activate_price_list(p_list_id IN NUMBER);
  FUNCTION unit_price(p_unit_id IN NUMBER) RETURN NUMBER;
  FUNCTION unit_min_price(p_unit_id IN NUMBER) RETURN NUMBER;
  -- {"id","code","name","property","down":10,"count":12,"freq":"MONTHLY|QUARTERLY|SEMI_ANNUAL|ANNUAL","handover":20}
  FUNCTION save_plan(p_doc IN CLOB) RETURN NUMBER;

  -- ---------------------------------------------------------- الحجز
  -- {"unit","buyer":partyId | "buyerName","phone","tax","broker":partyId,"price","discount","deposit","place","days":7,"notes"}
  FUNCTION reserve(p_doc IN CLOB) RETURN NUMBER;
  -- الإلغاء: يرد العربون ناقصاً المصادر (p_forfeit) من نفس مكان الاستلام
  PROCEDURE cancel_reservation(p_reservation_id IN NUMBER, p_reason IN VARCHAR2, p_forfeit IN NUMBER DEFAULT 0);
  -- الحجوزات المنتهية: تتحرر الوحدة ويبقى العربون حتى رده أو مصادرته؛ يعيد العدد
  FUNCTION expire_reservations RETURN NUMBER;

  -- ---------------------------------------------------------- العقد
  -- {"reservation" | "unit","buyer"/"buyerName"..., "plan","price","discount","date","handover","method":"POINT_IN_TIME|OVER_TIME",
  --  "registration","broker","commission":2.5,"eligible":20,"coBuyers":[...]}
  FUNCTION create_contract(p_doc IN CLOB) RETURN NUMBER;
  -- التوقيع: الوحدة مباعة، فوترة المستحق، تطبيق العربون، قيد عمولة الوسيط
  PROCEDURE sign_contract(p_contract_id IN NUMBER, p_date IN DATE DEFAULT NULL, p_registration IN VARCHAR2 DEFAULT NULL);
  -- فوترة الأقساط المستحقة حتى تاريخ (لعقد أو لكل العقود): يعيد عدد الفواتير
  FUNCTION bill_installments(p_contract_id IN NUMBER DEFAULT NULL, p_as_of IN DATE DEFAULT NULL) RETURN NUMBER;
  -- تحديث حالة الأقساط من الذمم (مدفوع، جزئي، متأخر)
  PROCEDURE refresh_installments(p_contract_id IN NUMBER DEFAULT NULL);
  FUNCTION collected(p_contract_id IN NUMBER) RETURN NUMBER;
  FUNCTION billed(p_contract_id IN NUMBER) RETURN NUMBER;
  -- الفسخ قبل التسليم: إلغاء الأقساط غير المفوترة، مصادرة جزء من المحصل، رد الباقي، تحرير الوحدة، عكس العمولة غير المسددة
  PROCEDURE terminate_contract(p_contract_id IN NUMBER, p_reason IN VARCHAR2, p_forfeit IN NUMBER, p_place IN VARCHAR2 DEFAULT NULL);
  FUNCTION contract_status(p_contract_id IN NUMBER) RETURN VARCHAR2;

  -- ---------------------------------------------------------- التسليم والإفراغ
  FUNCTION schedule_handover(p_contract_id IN NUMBER, p_date IN DATE) RETURN NUMBER;
  -- ملاحظات المعاينة [{"item","status":"OPEN|FIXED"}]
  PROCEDURE save_snags(p_handover_id IN NUMBER, p_snags IN CLOB);
  -- التسليم: الاعتراف بالإيراد المفوتر وتكلفة الوحدة، حالة الوحدة مسلمة
  PROCEDURE complete_handover(p_handover_id IN NUMBER, p_date IN DATE, p_keys IN NUMBER DEFAULT NULL, p_notes IN VARCHAR2 DEFAULT NULL);
  -- {"ref","date","fees","deed","financed":"Y"} يشترط سداد كامل الثمن ما لم يكن بتمويل
  FUNCTION transfer_title(p_contract_id IN NUMBER, p_doc IN CLOB) RETURN NUMBER;

  -- ---------------------------------------------------------- العمولات والتكاليف
  PROCEDURE approve_commission(p_commission_id IN NUMBER);
  PROCEDURE pay_commission(p_commission_id IN NUMBER, p_place IN VARCHAR2, p_date IN DATE DEFAULT NULL);
  -- رسملة تكاليف مشروع التطوير غير المرسملة على الوحدات غير المعترف بها؛ يعيد رقم التوزيع
  FUNCTION capitalize_costs(p_property_id IN NUMBER, p_basis IN VARCHAR2 DEFAULT 'AREA') RETURN NUMBER;
  FUNCTION unit_cost(p_unit_id IN NUMBER) RETURN NUMBER;

  -- ---------------------------------------------------------- الشاشات
  FUNCTION summary_html RETURN CLOB;
  FUNCTION availability_html(p_property_id IN NUMBER, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION reservations_html(p_status IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION contracts_html(p_status IN VARCHAR2 DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION contract_html(p_contract_id IN NUMBER) RETURN CLOB;
  FUNCTION installments_html(p_contract_id IN NUMBER) RETURN CLOB;
  -- الأقساط المستحقة والمتأخرة في فترة (تقرير التحصيل)
  FUNCTION collections_html(p_from IN DATE, p_to IN DATE) RETURN CLOB;
  FUNCTION commissions_html(p_status IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION handovers_html RETURN CLOB;
  FUNCTION sales_report_html(p_from IN DATE, p_to IN DATE) RETURN CLOB;
  FUNCTION plans_html RETURN CLOB;
  FUNCTION price_lists_html RETURN CLOB;
  FUNCTION allocations_html(p_property_id IN NUMBER DEFAULT NULL) RETURN CLOB;
END NOONA_RES_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_RES_PKG AS

  c_res   CONSTANT VARCHAR2(30) := 'RE_RESERVATION';
  c_ctr   CONSTANT VARCHAR2(30) := 'RE_SALE_CONTRACT';
  c_ho    CONSTANT VARCHAR2(30) := 'RE_HANDOVER';
  c_com   CONSTANT VARCHAR2(30) := 'RE_BROKER_COMMISSION';
  c_alloc CONSTANT VARCHAR2(30) := 'RE_COST_ALLOCATION';
  c_jt    CONSTANT VARCHAR2(30) := 'REAL_ESTATE';

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(TO_CHAR(NVL(p, 0), 'FM999,999,999,990.00', 'NLS_NUMERIC_CHARACTERS=''.,'''));
  END fmt;
  FUNCTION pct(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN RTRIM(RTRIM(TO_CHAR(NVL(p, 0), 'FM990.99', 'NLS_NUMERIC_CHARACTERS=''.,'''), '0'), '.') || '%';
  END pct;
  FUNCTION ds(p DATE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD'); END ds;

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
    RETURN TO_DATE(js(p_o, p_k), 'YYYY-MM-DD');
  END jd;

  PROCEDURE add_line(p_lines IN OUT NOCOPY NOONA_GL_PKG.t_lines, p_acc NUMBER, p_dr NUMBER, p_cr NUMBER, p_party NUMBER, p_desc VARCHAR2) IS
  BEGIN
    IF NVL(p_dr, 0) = 0 AND NVL(p_cr, 0) = 0 THEN RETURN; END IF;
    p_lines.EXTEND;
    p_lines(p_lines.COUNT).account_id := p_acc;
    p_lines(p_lines.COUNT).debit := ROUND(NVL(p_dr, 0), 2);
    p_lines(p_lines.COUNT).credit := ROUND(NVL(p_cr, 0), 2);
    p_lines(p_lines.COUNT).party_id := p_party;
    p_lines(p_lines.COUNT).description := SUBSTR(p_desc, 1, 1000);
  END add_line;

  FUNCTION ensure_account(p_code VARCHAR2, p_name VARCHAR2, p_parent VARCHAR2, p_type VARCHAR2) RETURN NUMBER IS
    l NUMBER := NOONA_INV_PKG.acc_id(p_code);
  BEGIN
    IF l IS NULL THEN
      l := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, p_code, p_name, p_parent, p_type, 'Y', NULL);
    END IF;
    RETURN l;
  END ensure_account;

  FUNCTION acc(p_kind VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN CASE p_kind
      WHEN 'DEPOSIT' THEN ensure_account('2151', 'عربون حجز الوحدات العقارية', '21', 'LIABILITY')
      WHEN 'ADVANCE' THEN ensure_account('2150', 'دفعات مقدمة من مشتري الوحدات', '21', 'LIABILITY')
      WHEN 'COMM_PAY' THEN ensure_account('2152', 'عمولات الوسطاء المستحقة', '21', 'LIABILITY')
      WHEN 'REVENUE' THEN ensure_account('4140', 'إيرادات بيع الوحدات العقارية', '4', 'REVENUE')
      WHEN 'FORFEIT' THEN ensure_account('4141', 'إيرادات مصادرة العربون وغرامات الفسخ', '4', 'REVENUE')
      WHEN 'UNITS' THEN ensure_account('1150', 'وحدات عقارية معدة للبيع', '11', 'ASSET')
      WHEN 'COGS' THEN ensure_account('5160', 'تكلفة الوحدات العقارية المباعة', '51', 'EXPENSE')
      WHEN 'COMM_EXP' THEN ensure_account('5161', 'عمولات وسطاء بيع الوحدات', '51', 'EXPENSE')
      WHEN 'DEV_COST' THEN ensure_account('5150', 'تكاليف المشروعات', '51', 'EXPENSE')
      WHEN 'AR' THEN ensure_account('1103', 'العملاء', '11', 'ASSET') END;
  END acc;

  FUNCTION setup_accounts RETURN NUMBER IS
    l_n NUMBER := 0;
    l_x NUMBER;
  BEGIN
    guard('RE_SALE_CONTRACT.CREATE');
    FOR k IN (SELECT column_value c FROM TABLE(sys.odcivarchar2list('DEPOSIT', 'ADVANCE', 'COMM_PAY', 'REVENUE', 'FORFEIT', 'UNITS', 'COGS', 'COMM_EXP'))) LOOP
      l_x := NOONA_INV_PKG.acc_id(CASE k.c WHEN 'DEPOSIT' THEN '2151' WHEN 'ADVANCE' THEN '2150' WHEN 'COMM_PAY' THEN '2152' WHEN 'REVENUE' THEN '4140'
                                           WHEN 'FORFEIT' THEN '4141' WHEN 'UNITS' THEN '1150' WHEN 'COGS' THEN '5160' ELSE '5161' END);
      IF l_x IS NULL THEN
        l_x := acc(k.c);
        l_n := l_n + 1;
      END IF;
    END LOOP;
    RETURN l_n;
  END setup_accounts;

  FUNCTION next_no(p_type VARCHAR2, p_prefix VARCHAR2, p_entity VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT company, p_type, NULL, p_prefix, 1, 5, 'N', 'NEVER', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = p_type);
    RETURN NOONA_REFERENCE_PKG.next_doc_no(p_type, company, NULL, TRUNC(SYSDATE), p_entity, NULL);
  END next_no;

  FUNCTION post(p_class VARCHAR2, p_entity VARCHAR2, p_id NUMBER, p_date DATE, p_desc VARCHAR2, p_lines NOONA_GL_PKG.t_lines, p_ref VARCHAR2) RETURN NUMBER IS
    l_j  NUMBER;
    l_ev NUMBER;
  BEGIN
    l_j := NOONA_ACE_PKG.post_source(p_class, c_jt, p_entity, p_id, p_date, p_desc, NOONA_GL_PKG.ledger_currency, 1, p_lines, p_ref, NULL, c_jt);
    SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
    RETURN l_ev;
  END post;

  FUNCTION status_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'DRAFT' THEN 'مسودة' WHEN 'ACTIVE' THEN 'ساري' WHEN 'CONVERTED' THEN 'تحول لعقد' WHEN 'EXPIRED' THEN 'منتهي'
      WHEN 'CANCELLED' THEN 'ملغى' WHEN 'REFUNDED' THEN 'مسترد' WHEN 'APPROVED' THEN 'معتمد' WHEN 'SIGNED' THEN 'موقع'
      WHEN 'REGISTERED' THEN 'موثق' WHEN 'UNDER_CONSTRUCTION' THEN 'تحت الإنشاء' WHEN 'READY_FOR_HANDOVER' THEN 'جاهز للتسليم'
      WHEN 'HANDED_OVER' THEN 'مسلم' WHEN 'TITLE_TRANSFERRED' THEN 'تم الإفراغ' WHEN 'TERMINATED' THEN 'مفسوخ'
      WHEN 'SCHEDULED' THEN 'مجدول' WHEN 'DUE' THEN 'مستحق' WHEN 'INVOICED' THEN 'مفوتر' WHEN 'PARTIALLY_PAID' THEN 'مسدد جزئياً'
      WHEN 'PAID' THEN 'مسدد' WHEN 'OVERDUE' THEN 'متأخر' WHEN 'WAIVED' THEN 'معفى' WHEN 'ACCRUED' THEN 'مستحق (غير مؤهل)'
      WHEN 'ELIGIBLE' THEN 'مؤهل للصرف' WHEN 'REVERSED' THEN 'معكوس' WHEN 'INSPECTION' THEN 'معاينة' WHEN 'SNAGS_OPEN' THEN 'ملاحظات مفتوحة'
      WHEN 'ACCEPTED' THEN 'مقبول' WHEN 'PENDING' THEN 'قيد الإجراء' WHEN 'COMPLETED' THEN 'مكتمل' WHEN 'POSTED' THEN 'مرحل'
      WHEN 'RETIRED' THEN 'منتهية' ELSE p_code END;
  END status_label;

  FUNCTION badge(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<span class="nn-badge ' || CASE WHEN p_code IN ('PAID', 'SIGNED', 'REGISTERED', 'HANDED_OVER', 'TITLE_TRANSFERRED', 'CONVERTED', 'COMPLETED', 'ACTIVE', 'POSTED')
                                            THEN 'is-success'
                                            WHEN p_code IN ('OVERDUE', 'TERMINATED', 'CANCELLED', 'EXPIRED', 'REVERSED') THEN 'is-danger'
                                            WHEN p_code IN ('INVOICED', 'ELIGIBLE', 'APPROVED', 'PARTIALLY_PAID') THEN 'is-info'
                                            WHEN p_code IN ('WAIVED', 'RETIRED') THEN 'is-muted' ELSE 'is-warning' END || '">'
        || esc(status_label(p_code)) || '</span>';
  END badge;

  -- الوحدات التجارية تخضع للضريبة الأساسية، والسكنية معفاة (تخضع لضريبة التصرفات العقارية خارج الفاتورة)
  FUNCTION tax_code_for(p_unit_id NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(unit_type) INTO l FROM re_unit WHERE id = p_unit_id;
    RETURN CASE WHEN l IN ('OFFICE', 'SHOP', 'SHOWROOM', 'WAREHOUSE', 'STORAGE', 'PARKING') THEN 'VAT15' ELSE 'VATEX' END;
  END tax_code_for;

  FUNCTION lock_unit(p_unit_id NUMBER) RETURN re_unit%ROWTYPE IS
    l re_unit%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM re_unit WHERE id = p_unit_id AND company_id = company FOR UPDATE;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-RES-001', 'الوحدة غير موجودة', 'Unit not found');
  END lock_unit;

  -- المشتري: طرف قائم أو جديد (الاسم والجوال والرقم الضريبي)
  FUNCTION buyer_party(p_o JSON_OBJECT_T) RETURN NUMBER IS
    l_party NUMBER := jn(p_o, 'buyer');
    l_acc   NUMBER;
  BEGIN
    IF l_party IS NULL AND js(p_o, 'buyerName') IS NOT NULL THEN
      l_acc := NOONA_SAL_PKG.save_customer(JSON_OBJECT('name' VALUE js(p_o, 'buyerName'), 'phone' VALUE js(p_o, 'phone'), 'tax' VALUE js(p_o, 'tax'),
                                                       'person' VALUE NVL(js(p_o, 'person'), 'Y'), 'term' VALUE 'NET0'));
      l_party := NOONA_SAL_PKG.customer_party(l_acc);
    END IF;
    NOONA_CORE_PKG.assert(l_party IS NOT NULL, 'NOONA-RES-002', 'اختر المشتري أو أدخل اسمه', 'Buyer is required');
    RETURN l_party;
  END buyer_party;

  -- ================================================================ الأسعار
  FUNCTION unit_price(p_unit_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(l.base_price) INTO l FROM re_price_list_line l JOIN re_price_list p ON p.id = l.price_list_id
     WHERE l.unit_id = p_unit_id AND p.status_code = 'ACTIVE';
    IF l IS NULL THEN
      SELECT MAX(list_price) INTO l FROM re_unit WHERE id = p_unit_id;
    END IF;
    RETURN l;
  END unit_price;

  FUNCTION unit_min_price(p_unit_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(l.min_price) INTO l FROM re_price_list_line l JOIN re_price_list p ON p.id = l.price_list_id
     WHERE l.unit_id = p_unit_id AND p.status_code = 'ACTIVE';
    RETURN l;
  END unit_min_price;

  FUNCTION save_price_list(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := jn(l_o, 'id');
    l_prop NUMBER := jn(l_o, 'property');
    l_name VARCHAR2(200) := js(l_o, 'name');
    l_code VARCHAR2(50) := js(l_o, 'code');
    l_from DATE := NVL(jd(l_o, 'from'), TRUNC(SYSDATE));
    l_phase VARCHAR2(50) := js(l_o, 'phase');
    l_st   VARCHAR2(30);
    l_n    NUMBER := 0;
    l_area NUMBER;
  BEGIN
    guard('RE_PRICE_LIST.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_prop IS NOT NULL AND l_name IS NOT NULL, 'NOONA-RES-010', 'اختر العقار واسم القائمة', 'Property and name are required');
    IF l_id IS NULL THEN
      SELECT COUNT(*) + 1 INTO l_n FROM re_price_list WHERE company_id = company AND property_id = l_prop;
      INSERT INTO re_price_list (company_id, code, name_ar, currency_code, property_id, phase_code, status_code, effective_from)
      VALUES (company, NVL(l_code, 'PL-' || l_prop || '-' || l_n), l_name, NOONA_GL_PKG.ledger_currency, l_prop, l_phase, 'DRAFT', l_from)
      RETURNING id INTO l_id;
    ELSE
      SELECT status_code INTO l_st FROM re_price_list WHERE id = l_id AND company_id = company FOR UPDATE;
      NOONA_CORE_PKG.assert(l_st = 'DRAFT', 'NOONA-RES-011', 'القائمة مفعلة؛ أنشئ قائمة جديدة للأسعار الجديدة', 'Only draft lists can be edited');
      UPDATE re_price_list SET name_ar = l_name, effective_from = l_from WHERE id = l_id;
      DELETE FROM re_price_list_line WHERE price_list_id = l_id;
    END IF;
    l_n := 0;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (unit NUMBER PATH '$.unit', price NUMBER PATH '$.price', mn NUMBER PATH '$.min'))) LOOP
      CONTINUE WHEN r.unit IS NULL OR NVL(r.price, 0) <= 0;
      SELECT NVL(net_area_sqm, gross_area_sqm) INTO l_area FROM re_unit WHERE id = r.unit AND property_id = l_prop;
      NOONA_CORE_PKG.assert(r.mn IS NULL OR r.mn <= r.price, 'NOONA-RES-012', 'الحد الأدنى أكبر من السعر', 'Minimum above price');
      INSERT INTO re_price_list_line (company_id, price_list_id, unit_id, base_price, price_per_sqm, min_price)
      VALUES (company, l_id, r.unit, r.price, CASE WHEN l_area > 0 THEN ROUND(r.price / l_area, 2) END, r.mn);
      l_n := l_n + 1;
    END LOOP;
    NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-RES-013', 'أضف سعر وحدة واحدة على الأقل', 'Add at least one unit price');
    RETURN l_id;
  END save_price_list;

  PROCEDURE activate_price_list(p_list_id IN NUMBER) IS
    l re_price_list%ROWTYPE;
  BEGIN
    guard('RE_PRICE_LIST.APPROVE');
    SELECT * INTO l FROM re_price_list WHERE id = p_list_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l.status_code IN ('DRAFT', 'APPROVED'), 'NOONA-RES-014', 'القائمة مفعلة أو منتهية', 'List is not a draft');
    UPDATE re_price_list SET status_code = 'RETIRED', effective_to = TRUNC(SYSDATE) - 1
     WHERE company_id = company AND property_id = l.property_id AND status_code = 'ACTIVE' AND id <> p_list_id;
    UPDATE re_price_list SET status_code = 'ACTIVE' WHERE id = p_list_id;
    UPDATE re_unit u SET list_price = (SELECT base_price FROM re_price_list_line x WHERE x.price_list_id = p_list_id AND x.unit_id = u.id)
     WHERE u.id IN (SELECT unit_id FROM re_price_list_line WHERE price_list_id = p_list_id);
  END activate_price_list;

  FUNCTION save_plan(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := jn(l_o, 'id');
    l_down NUMBER := NVL(jn(l_o, 'down'), 0);
    l_ho   NUMBER := NVL(jn(l_o, 'handover'), 0);
    l_cnt  NUMBER := NVL(jn(l_o, 'count'), 0);
    l_freq VARCHAR2(30) := NVL(js(l_o, 'freq'), 'MONTHLY');
    l_step NUMBER;
    l_rest NUMBER;
    l_each NUMBER;
    l_no   PLS_INTEGER := 0;
    l_code VARCHAR2(50) := js(l_o, 'code');
    l_name VARCHAR2(200) := js(l_o, 'name');
    l_prop NUMBER := jn(l_o, 'property');
  BEGIN
    guard('RE_PAYMENT_PLAN.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(js(l_o, 'name') IS NOT NULL, 'NOONA-RES-015', 'اسم الخطة مطلوب', 'Plan name is required');
    NOONA_CORE_PKG.assert(l_down >= 0 AND l_ho >= 0 AND l_down + l_ho <= 100 AND l_cnt >= 0, 'NOONA-RES-016',
                          'الدفعة الأولى ودفعة التسليم لا تتجاوزان 100%', 'Down and handover payments exceed 100%');
    l_rest := 100 - l_down - l_ho;
    NOONA_CORE_PKG.assert(l_rest = 0 OR l_cnt > 0, 'NOONA-RES-017', 'حدد عدد الأقساط للنسبة المتبقية (' || pct(l_rest) || ')',
                          'Installment count is required for the remaining share');
    l_step := CASE l_freq WHEN 'QUARTERLY' THEN 3 WHEN 'SEMI_ANNUAL' THEN 6 WHEN 'ANNUAL' THEN 12 ELSE 1 END;
    IF l_id IS NULL THEN
      INSERT INTO re_payment_plan (company_id, code, name_ar, property_id, down_payment_pct, installments_count, frequency, is_active)
      VALUES (company, NVL(l_code, 'PP-' || TO_CHAR(SYSTIMESTAMP, 'YYMMDDHH24MISSFF2')), l_name, l_prop, l_down, l_cnt, l_freq, 'Y')
      RETURNING id INTO l_id;
    ELSE
      UPDATE re_payment_plan SET name_ar = l_name, property_id = l_prop, down_payment_pct = l_down, installments_count = l_cnt,
                                 frequency = l_freq
       WHERE id = l_id AND company_id = company;
      DELETE FROM re_payment_plan_line WHERE payment_plan_id = l_id;
    END IF;
    IF l_down > 0 THEN
      l_no := l_no + 1;
      INSERT INTO re_payment_plan_line (company_id, payment_plan_id, line_no, due_pct, due_trigger, offset_months, sort_order)
      VALUES (company, l_id, l_no, l_down, 'ON_SIGNING', 0, l_no);
    END IF;
    IF l_cnt > 0 AND l_rest > 0 THEN
      l_each := TRUNC(l_rest / l_cnt, 4);
      FOR i IN 1 .. l_cnt LOOP
        l_no := l_no + 1;
        INSERT INTO re_payment_plan_line (company_id, payment_plan_id, line_no, due_pct, due_trigger, offset_months, sort_order)
        VALUES (company, l_id, l_no, CASE WHEN i = l_cnt THEN l_rest - l_each * (l_cnt - 1) ELSE l_each END, 'MONTHS_AFTER_SIGNING', i * l_step, l_no);
      END LOOP;
    END IF;
    IF l_ho > 0 THEN
      l_no := l_no + 1;
      INSERT INTO re_payment_plan_line (company_id, payment_plan_id, line_no, due_pct, due_trigger, offset_months, sort_order)
      VALUES (company, l_id, l_no, l_ho, 'ON_HANDOVER', 0, l_no);
    END IF;
    RETURN l_id;
  END save_plan;

  -- ================================================================ الحجز
  FUNCTION reserve(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_unit  re_unit%ROWTYPE := lock_unit(jn(l_o, 'unit'));
    l_party NUMBER;
    l_price NUMBER := NVL(jn(l_o, 'price'), unit_price(l_unit.id));
    l_disc  NUMBER := NVL(jn(l_o, 'discount'), 0);
    l_dep   NUMBER := NVL(jn(l_o, 'deposit'), 0);
    l_place VARCHAR2(30) := js(l_o, 'place');
    l_min   NUMBER := unit_min_price(l_unit.id);
    l_n     NUMBER;
    l_id    NUMBER;
    l_no    VARCHAR2(50);
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_ev    NUMBER;
    l_x     NUMBER;
    l_bname VARCHAR2(400);
    l_brk   NUMBER := jn(l_o, 'broker');
    l_days  NUMBER := NVL(jn(l_o, 'days'), 7);
    l_notes VARCHAR2(1000) := js(l_o, 'notes');
  BEGIN
    guard('RE_RESERVATION.CREATE');
    NOONA_CORE_PKG.assert(l_unit.status_code = 'AVAILABLE', 'NOONA-RES-020', 'الوحدة ' || l_unit.code || ' غير متاحة (' || NOONA_RE_PKG.unit_status_label(l_unit.status_code) || ')',
                          'Unit is not available');
    NOONA_CORE_PKG.assert(l_unit.usage_type IN ('SALE', 'MIXED'), 'NOONA-RES-021', 'الوحدة ليست معروضة للبيع', 'Unit is not for sale');
    SELECT COUNT(*) INTO l_n FROM re_reservation WHERE unit_id = l_unit.id AND status_code = 'ACTIVE';
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-RES-022', 'للوحدة حجز ساري', 'Unit already has an active reservation');
    NOONA_CORE_PKG.assert(NVL(l_price, 0) > 0, 'NOONA-RES-023', 'لا يوجد سعر للوحدة؛ فعّل قائمة أسعار أو أدخل السعر', 'Unit price is required');
    NOONA_CORE_PKG.assert(l_disc >= 0 AND l_disc < l_price AND l_dep >= 0, 'NOONA-RES-024', 'الخصم والعربون غير صحيحين', 'Invalid discount or deposit');
    IF l_min IS NOT NULL AND l_price - l_disc < l_min THEN
      NOONA_CORE_PKG.assert(NOONA_SECURITY_PKG.has_permission('RE_RESERVATION.APPROVE', company) = 'Y', 'NOONA-RES-025',
                            'السعر بعد الخصم (' || fmt(l_price - l_disc) || ') أقل من الحد الأدنى (' || fmt(l_min) || '): يحتاج صلاحية اعتماد الخصم',
                            'Discount below the minimum price needs approval');
    END IF;
    NOONA_CORE_PKG.assert(l_dep = 0 OR l_place IS NOT NULL, 'NOONA-RES-026', 'اختر الصندوق أو البنك لاستلام العربون', 'Choose where the deposit is received');
    l_party := buyer_party(l_o);
    SELECT display_name_ar INTO l_bname FROM pty_party WHERE id = l_party;
    l_no := next_no('RE_RESERVATION', 'RSV-', c_res);
    INSERT INTO re_reservation (company_id, doc_no, doc_date, currency_code, exchange_rate, unit_id, buyer_party_id, broker_party_id, quoted_price,
                                discount_amount, deposit_amount, expires_at, deposit_place, notes, status_code)
    VALUES (company, l_no, TRUNC(SYSDATE), NOONA_GL_PKG.ledger_currency, 1, l_unit.id, l_party, l_brk, l_price, l_disc, l_dep,
            SYSTIMESTAMP + NUMTODSINTERVAL(l_days, 'DAY'), CASE WHEN l_dep > 0 THEN l_place END, l_notes, 'ACTIVE')
    RETURNING id INTO l_id;
    IF l_dep > 0 THEN
      add_line(l_lines, NOONA_CSH_PKG.place_account(l_place), l_dep, 0, NULL, 'عربون حجز ' || l_no || ' - ' || l_bname);
      add_line(l_lines, acc('DEPOSIT'), 0, l_dep, l_party, 'عربون حجز الوحدة ' || NOONA_RE_PKG.unit_label(l_unit.id) || ' - ' || l_no);
      l_ev := post('RE_RESERVATION_DEPOSIT', c_res, l_id, TRUNC(SYSDATE), 'عربون حجز ' || l_no, l_lines, l_no);
      l_x := NOONA_CSH_PKG.record_settlement('RECEIPT', l_place, TRUNC(SYSDATE), l_dep, l_party, l_bname, c_res, l_id, l_no, 'عربون حجز وحدة', l_ev);
      UPDATE re_reservation SET deposit_event_id = l_ev WHERE id = l_id;
    END IF;
    UPDATE re_unit SET status_code = 'RESERVED' WHERE id = l_unit.id;
    RETURN l_id;
  END reserve;

  PROCEDURE cancel_reservation(p_reservation_id IN NUMBER, p_reason IN VARCHAR2, p_forfeit IN NUMBER DEFAULT 0) IS
    r       re_reservation%ROWTYPE;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
    l_ev    NUMBER;
    l_x     NUMBER;
    l_f     NUMBER := ROUND(NVL(p_forfeit, 0), 2);
    l_bname VARCHAR2(400);
  BEGIN
    guard('RE_RESERVATION.UPDATE');
    SELECT * INTO r FROM re_reservation WHERE id = p_reservation_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(r.status_code IN ('ACTIVE', 'EXPIRED'), 'NOONA-RES-027', 'الحجز ' || status_label(r.status_code), 'Reservation is closed');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-RES-028', 'اكتب سبب الإلغاء', 'Reason is required');
    NOONA_CORE_PKG.assert(l_f BETWEEN 0 AND r.deposit_amount, 'NOONA-RES-029', 'المبلغ المصادر بين صفر وقيمة العربون', 'Forfeit must be within the deposit');
    SELECT display_name_ar INTO l_bname FROM pty_party WHERE id = r.buyer_party_id;
    IF r.deposit_amount > 0 THEN
      -- عكس العربون كاملاً (يرد كامل المبلغ من نفس المكان) ثم إثبات الجزء المصادر إيراداً محتفظاً به في الصندوق
      l_j := NOONA_ACE_PKG.reverse_source(c_res, r.id, TRUNC(SYSDATE), 'إلغاء الحجز: ' || p_reason);
      IF l_f > 0 THEN
        add_line(l_lines, NOONA_CSH_PKG.place_account(r.deposit_place), l_f, 0, NULL, 'الجزء المصادر من عربون ' || r.doc_no);
        add_line(l_lines, acc('FORFEIT'), 0, l_f, r.buyer_party_id, 'مصادرة عربون حجز ملغى ' || r.doc_no || ' - ' || p_reason);
        l_ev := post('RE_RESERVATION_FORFEIT', c_res, r.id, TRUNC(SYSDATE), 'مصادرة عربون ' || r.doc_no, l_lines, r.doc_no);
        l_x := NOONA_CSH_PKG.record_settlement('RECEIPT', r.deposit_place, TRUNC(SYSDATE), l_f, r.buyer_party_id, l_bname,
                                               c_res, r.id, r.doc_no || '-F', 'الجزء المصادر من عربون حجز ملغى', l_ev);
      END IF;
    END IF;
    UPDATE re_reservation SET status_code = CASE WHEN r.deposit_amount - l_f > 0 THEN 'REFUNDED' ELSE 'CANCELLED' END,
                              refund_amount = r.deposit_amount - l_f, notes = SUBSTR(TRIM(notes || ' | إلغاء: ' || p_reason), 1, 1000)
     WHERE id = r.id;
    UPDATE re_unit SET status_code = 'AVAILABLE' WHERE id = r.unit_id AND status_code = 'RESERVED';
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-RES-030', 'الحجز غير موجود', 'Reservation not found');
  END cancel_reservation;

  FUNCTION expire_reservations RETURN NUMBER IS
    l_n NUMBER := 0;
  BEGIN
    guard('RE_RESERVATION.UPDATE');
    FOR r IN (SELECT id, unit_id FROM re_reservation WHERE company_id = company AND status_code = 'ACTIVE' AND expires_at < SYSTIMESTAMP FOR UPDATE) LOOP
      UPDATE re_reservation SET status_code = 'EXPIRED' WHERE id = r.id;
      UPDATE re_unit SET status_code = 'AVAILABLE' WHERE id = r.unit_id AND status_code = 'RESERVED';
      l_n := l_n + 1;
    END LOOP;
    RETURN l_n;
  END expire_reservations;

  -- ================================================================ العقد
  FUNCTION get_contract(p_id NUMBER, p_lock BOOLEAN DEFAULT FALSE) RETURN re_sale_contract%ROWTYPE IS
    l re_sale_contract%ROWTYPE;
  BEGIN
    IF p_lock THEN
      SELECT * INTO l FROM re_sale_contract WHERE id = p_id AND company_id = company FOR UPDATE;
    ELSE
      SELECT * INTO l FROM re_sale_contract WHERE id = p_id AND company_id = company;
    END IF;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-RES-040', 'عقد البيع غير موجود', 'Sale contract not found');
  END get_contract;

  FUNCTION contract_status(p_contract_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM re_sale_contract WHERE id = p_contract_id AND company_id = company;
    RETURN l;
  END contract_status;

  FUNCTION create_contract(p_doc IN CLOB) RETURN NUMBER IS
    l_o      JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_rsv    re_reservation%ROWTYPE;
    l_unit   re_unit%ROWTYPE;
    l_party  NUMBER;
    l_broker NUMBER;
    l_price  NUMBER;
    l_disc   NUMBER;
    l_net    NUMBER;
    l_tc     VARCHAR2(30);
    l_rate   NUMBER;
    l_tax    NUMBER;
    l_plan   NUMBER := jn(l_o, 'plan');
    l_date   DATE := NVL(jd(l_o, 'date'), TRUNC(SYSDATE));
    l_ho     DATE := jd(l_o, 'handover');
    l_id     NUMBER;
    l_no     VARCHAR2(50);
    l_cust   NUMBER;
    l_n      PLS_INTEGER := 0;
    l_k      PLS_INTEGER := 0;
    l_sum    NUMBER := 0;
    l_stax   NUMBER := 0;
    l_amt    NUMBER;
    l_t      NUMBER;
    l_cnt    NUMBER;
    l_due    DATE;
    l_comm   NUMBER := NVL(jn(l_o, 'commission'), 0);
    l_min    NUMBER;
    l_method VARCHAR2(30) := NVL(js(l_o, 'method'), 'POINT_IN_TIME');
    l_reg    VARCHAR2(100);
    l_co_b   CLOB;
    l_rid    NUMBER;
    l_elig   NUMBER := NVL(jn(l_o, 'eligible'), 0);
    l_rule   VARCHAR2(500);
  BEGIN
    guard('RE_SALE_CONTRACT.CREATE');
    IF jn(l_o, 'reservation') IS NOT NULL THEN
      l_rid := jn(l_o, 'reservation');
      SELECT * INTO l_rsv FROM re_reservation WHERE id = l_rid AND company_id = company FOR UPDATE;
      NOONA_CORE_PKG.assert(l_rsv.status_code = 'ACTIVE', 'NOONA-RES-041', 'الحجز ليس سارياً (' || status_label(l_rsv.status_code) || ')',
                            'Reservation is not active');
      l_unit := lock_unit(l_rsv.unit_id);
      l_party := l_rsv.buyer_party_id;
      l_broker := NVL(jn(l_o, 'broker'), l_rsv.broker_party_id);
      l_price := NVL(jn(l_o, 'price'), l_rsv.quoted_price);
      l_disc := NVL(jn(l_o, 'discount'), l_rsv.discount_amount);
    ELSE
      l_unit := lock_unit(jn(l_o, 'unit'));
      NOONA_CORE_PKG.assert(l_unit.status_code = 'AVAILABLE', 'NOONA-RES-020', 'الوحدة ' || l_unit.code || ' غير متاحة', 'Unit is not available');
      l_party := buyer_party(l_o);
      l_broker := jn(l_o, 'broker');
      l_price := NVL(jn(l_o, 'price'), unit_price(l_unit.id));
      l_disc := NVL(jn(l_o, 'discount'), 0);
      l_min := unit_min_price(l_unit.id);
      IF l_min IS NOT NULL AND l_price - l_disc < l_min THEN
        NOONA_CORE_PKG.assert(NOONA_SECURITY_PKG.has_permission('RE_SALE_CONTRACT.APPROVE', company) = 'Y', 'NOONA-RES-025',
                              'السعر بعد الخصم أقل من الحد الأدنى: يحتاج صلاحية اعتماد', 'Discount below the minimum price needs approval');
      END IF;
    END IF;
    NOONA_CORE_PKG.assert(NVL(l_price, 0) > 0 AND l_disc >= 0 AND l_disc < l_price, 'NOONA-RES-042', 'سعر البيع والخصم غير صحيحين', 'Invalid price or discount');
    NOONA_CORE_PKG.assert(l_method IN ('POINT_IN_TIME', 'OVER_TIME'), 'NOONA-RES-043', 'طريقة الاعتراف غير صحيحة', 'Invalid revenue method');
    NOONA_CORE_PKG.assert(l_comm BETWEEN 0 AND 20 AND (l_comm = 0 OR l_broker IS NOT NULL), 'NOONA-RES-044', 'اختر الوسيط لنسبة العمولة (حتى 20%)',
                          'A broker is required for a commission');
    l_net := l_price - l_disc;
    l_tc := tax_code_for(l_unit.id);
    l_rate := NOONA_INV_PKG.tax_rate(NOONA_INV_PKG.tax_id(l_tc), l_date);
    l_tax := ROUND(l_net * NVL(l_rate, 0) / 100, 2);
    l_cust := NOONA_SAL_PKG.party_account(l_party);
    l_reg := js(l_o, 'registration');
    IF l_o.has('coBuyers') THEN l_co_b := l_o.get('coBuyers').to_clob; END IF;
    l_no := next_no('RE_SALE_CONTRACT', 'SC-', c_ctr);
    INSERT INTO re_sale_contract (company_id, doc_no, doc_date, currency_code, exchange_rate, unit_id, reservation_id, buyer_party_id, co_buyers,
                                  customer_account_id, payment_plan_id, sale_price, discount_amount, tax_amount, total_amount, registration_no,
                                  expected_handover, revenue_method, revenue_recognized, status_code)
    VALUES (company, l_no, l_date, NOONA_GL_PKG.ledger_currency, 1, l_unit.id, l_rsv.id, l_party,
            l_co_b, l_cust, l_plan, l_price, l_disc, l_tax, l_net + l_tax, l_reg, l_ho, l_method, CASE WHEN l_method = 'OVER_TIME' THEN 'Y' ELSE 'N' END, 'DRAFT')
    RETURNING id INTO l_id;
    -- جدول الأقساط من الخطة (أو دفعة واحدة عند التوقيع)
    SELECT COUNT(*) INTO l_cnt FROM re_payment_plan_line WHERE payment_plan_id = l_plan;
    IF l_cnt = 0 THEN
      INSERT INTO re_sale_installment (company_id, contract_id, installment_no, due_date, amount, tax_amount, label, status_code)
      VALUES (company, l_id, 1, l_date, l_net, l_tax, 'كامل الثمن عند التوقيع', 'SCHEDULED');
    ELSE
      FOR p IN (SELECT * FROM re_payment_plan_line WHERE payment_plan_id = l_plan ORDER BY line_no) LOOP
        l_n := l_n + 1;
        IF l_n = l_cnt THEN
          l_amt := l_net - l_sum; l_t := l_tax - l_stax;
        ELSE
          l_amt := ROUND(l_net * p.due_pct / 100, 2); l_t := ROUND(l_tax * p.due_pct / 100, 2);
        END IF;
        l_sum := l_sum + l_amt; l_stax := l_stax + l_t;
        IF p.due_trigger = 'MONTHS_AFTER_SIGNING' THEN l_k := l_k + 1; END IF;
        l_due := CASE p.due_trigger WHEN 'ON_SIGNING' THEN l_date WHEN 'MONTHS_AFTER_SIGNING' THEN ADD_MONTHS(l_date, NVL(p.offset_months, 0))
                                    WHEN 'ON_HANDOVER' THEN NVL(l_ho, ADD_MONTHS(l_date, 24)) WHEN 'POST_HANDOVER' THEN ADD_MONTHS(NVL(l_ho, ADD_MONTHS(l_date, 24)), NVL(p.offset_months, 0))
                                    ELSE ADD_MONTHS(l_date, NVL(p.offset_months, 0)) END;
        INSERT INTO re_sale_installment (company_id, contract_id, installment_no, due_date, amount, tax_amount, label, milestone_id, status_code)
        VALUES (company, l_id, l_n, l_due, l_amt, l_t,
                CASE p.due_trigger WHEN 'ON_SIGNING' THEN 'الدفعة الأولى' WHEN 'ON_HANDOVER' THEN 'دفعة التسليم' WHEN 'POST_HANDOVER' THEN 'دفعة بعد التسليم'
                                   WHEN 'CONSTRUCTION_MILESTONE' THEN 'دفعة إنجاز' ELSE 'قسط ' || l_k END,
                p.milestone_id, 'SCHEDULED');
      END LOOP;
    END IF;
    IF l_broker IS NOT NULL AND l_comm > 0 THEN
      l_rule := 'تستحق عند تحصيل ' || pct(l_elig) || ' من الثمن';
      INSERT INTO re_broker_commission (company_id, contract_id, broker_party_id, commission_pct, commission_amount, eligibility_rule, eligible_pct, status_code)
      VALUES (company, l_id, l_broker, l_comm, ROUND(l_net * l_comm / 100, 2),
              l_rule, l_elig, 'ACCRUED');
    END IF;
    IF l_rsv.id IS NOT NULL THEN
      UPDATE re_reservation SET status_code = 'CONVERTED' WHERE id = l_rsv.id;
    END IF;
    UPDATE re_unit SET status_code = 'RESERVED' WHERE id = l_unit.id;
    RETURN l_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-RES-030', 'الحجز غير موجود', 'Reservation not found');
  END create_contract;

  FUNCTION billed(p_contract_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(amount + tax_amount), 0) INTO l FROM re_sale_installment
     WHERE contract_id = p_contract_id AND sales_invoice_id IS NOT NULL AND status_code <> 'CANCELLED';
    RETURN l;
  END billed;

  -- المحصل = المفوتر ناقصاً المفتوح في الذمم (يشمل العربون المطبق)
  FUNCTION collected(p_contract_id IN NUMBER) RETURN NUMBER IS
    l_open NUMBER;
  BEGIN
    SELECT NVL(SUM(o.open_amount), 0) INTO l_open FROM re_sale_installment i JOIN ar_open_item o ON o.source_entity_type = 'SAL_INVOICE'
       AND o.source_entity_id = i.sales_invoice_id
     WHERE i.contract_id = p_contract_id AND i.status_code <> 'CANCELLED';
    RETURN billed(p_contract_id) - l_open;
  END collected;

  PROCEDURE refresh_installments(p_contract_id IN NUMBER DEFAULT NULL) IS
    l_open NUMBER;
  BEGIN
    FOR i IN (SELECT i.id, i.sales_invoice_id, i.amount + i.tax_amount total, i.due_date, i.status_code FROM re_sale_installment i
                JOIN re_sale_contract c ON c.id = i.contract_id
               WHERE c.company_id = company AND (p_contract_id IS NULL OR c.id = p_contract_id)
                 AND i.status_code NOT IN ('PAID', 'CANCELLED', 'WAIVED') AND i.sales_invoice_id IS NOT NULL) LOOP
      SELECT NVL(SUM(open_amount), 0) INTO l_open FROM ar_open_item WHERE source_entity_type = 'SAL_INVOICE' AND source_entity_id = i.sales_invoice_id;
      UPDATE re_sale_installment
         SET paid_amount = i.total - l_open,
             status_code = CASE WHEN l_open <= 0 THEN 'PAID' WHEN l_open < i.total THEN 'PARTIALLY_PAID'
                                WHEN i.due_date < TRUNC(SYSDATE) THEN 'OVERDUE' ELSE 'INVOICED' END
       WHERE id = i.id;
    END LOOP;
    -- عمولات بلغت نسبة التحصيل المطلوبة
    FOR m IN (SELECT b.id, b.contract_id, b.eligible_pct, c.total_amount FROM re_broker_commission b JOIN re_sale_contract c ON c.id = b.contract_id
               WHERE c.company_id = company AND (p_contract_id IS NULL OR c.id = p_contract_id) AND b.status_code = 'ACCRUED'
                 AND c.status_code NOT IN ('DRAFT', 'CANCELLED', 'TERMINATED')) LOOP
      IF collected(m.contract_id) >= m.total_amount * NVL(m.eligible_pct, 0) / 100 THEN
        UPDATE re_broker_commission SET status_code = 'ELIGIBLE' WHERE id = m.id;
      END IF;
    END LOOP;
  END refresh_installments;

  FUNCTION bill_one(p_inst_id NUMBER) RETURN NUMBER IS
    i     re_sale_installment%ROWTYPE;
    c     re_sale_contract%ROWTYPE;
    l_inv NUMBER;
    l_oi  NUMBER;
  BEGIN
    SELECT * INTO i FROM re_sale_installment WHERE id = p_inst_id FOR UPDATE;
    c := get_contract(i.contract_id);
    l_inv := NOONA_SAL_PKG.save_invoice(JSON_OBJECT('cust' VALUE c.customer_account_id, 'date' VALUE ds(LEAST(i.due_date, TRUNC(SYSDATE))), 'mode' VALUE 'CREDIT',
               'action' VALUE 'POST',
               'lines' VALUE JSON_ARRAY(JSON_OBJECT('d' VALUE i.label || ' - عقد ' || c.doc_no || ' - ' || NOONA_RE_PKG.unit_label(c.unit_id),
                                                    'q' VALUE 1, 'p' VALUE i.amount, 'inc' VALUE 'N', 'tc' VALUE tax_code_for(c.unit_id),
                                                    'acc' VALUE CASE WHEN c.revenue_recognized = 'Y' THEN '4140' ELSE '2150' END))));
    SELECT MIN(id) INTO l_oi FROM ar_open_item WHERE source_entity_type = 'SAL_INVOICE' AND source_entity_id = l_inv;
    UPDATE re_sale_installment SET sales_invoice_id = l_inv, ar_open_item_id = l_oi, status_code = 'INVOICED' WHERE id = i.id;
    RETURN l_inv;
  END bill_one;

  FUNCTION bill_installments(p_contract_id IN NUMBER DEFAULT NULL, p_as_of IN DATE DEFAULT NULL) RETURN NUMBER IS
    l_n   NUMBER := 0;
    l_inv NUMBER;
    l_as  DATE := LEAST(NVL(p_as_of, TRUNC(SYSDATE)), TRUNC(SYSDATE));
    l_x   NUMBER;
  BEGIN
    guard('RE_SALE_CONTRACT.UPDATE');
    l_x := acc('ADVANCE') + acc('REVENUE');
    FOR i IN (SELECT i.id FROM re_sale_installment i JOIN re_sale_contract c ON c.id = i.contract_id
               WHERE c.company_id = company AND (p_contract_id IS NULL OR c.id = p_contract_id)
                 AND c.status_code IN ('SIGNED', 'REGISTERED', 'UNDER_CONSTRUCTION', 'READY_FOR_HANDOVER', 'HANDED_OVER', 'TITLE_TRANSFERRED')
                 AND i.status_code = 'SCHEDULED' AND i.due_date <= l_as
               ORDER BY c.id, i.installment_no) LOOP
      l_inv := bill_one(i.id);
      l_n := l_n + 1;
    END LOOP;
    RETURN l_n;
  END bill_installments;

  PROCEDURE sign_contract(p_contract_id IN NUMBER, p_date IN DATE DEFAULT NULL, p_registration IN VARCHAR2 DEFAULT NULL) IS
    c       re_sale_contract%ROWTYPE := get_contract(p_contract_id, TRUE);
    l_date  DATE := NVL(p_date, c.doc_date);
    l_dep   NUMBER := 0;
    l_left  NUMBER;
    l_x     NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_ev    NUMBER;
    l_bname VARCHAR2(400);
    l_ar    NUMBER;
  BEGIN
    guard('RE_SALE_CONTRACT.APPROVE');
    NOONA_CORE_PKG.assert(c.status_code IN ('DRAFT', 'APPROVED'), 'NOONA-RES-045', 'العقد ' || status_label(c.status_code), 'Contract already signed');
    NOONA_CORE_PKG.assert(l_date <= TRUNC(SYSDATE), 'NOONA-RES-046', 'تاريخ التوقيع لا يكون مستقبلياً', 'Signing date cannot be in the future');
    UPDATE re_sale_contract SET status_code = CASE WHEN NVL(p_registration, registration_no) IS NOT NULL THEN 'REGISTERED' ELSE 'SIGNED' END,
                                signed_date = l_date, registration_no = NVL(p_registration, registration_no)
     WHERE id = c.id;
    UPDATE re_unit SET status_code = 'SOLD' WHERE id = c.unit_id;
    -- فوترة ما استحق حتى التوقيع (الدفعة الأولى)
    l_x := bill_installments(c.id, GREATEST(l_date, TRUNC(SYSDATE)));
    -- تطبيق عربون الحجز على أول الفواتير
    IF c.reservation_id IS NOT NULL THEN
      SELECT deposit_amount INTO l_dep FROM re_reservation WHERE id = c.reservation_id;
    END IF;
    IF l_dep > 0 THEN
      SELECT display_name_ar INTO l_bname FROM pty_party WHERE id = c.buyer_party_id;
      SELECT MAX(receivable_account_id) INTO l_ar FROM ar_customer_account WHERE id = c.customer_account_id;
      IF l_ar IS NULL THEN l_ar := acc('AR'); END IF;
      l_left := l_dep;
      FOR i IN (SELECT sales_invoice_id FROM re_sale_installment WHERE contract_id = c.id AND sales_invoice_id IS NOT NULL ORDER BY installment_no) LOOP
        EXIT WHEN l_left <= 0;
        l_left := NOONA_SAL_PKG.settle_open('SAL_INVOICE', i.sales_invoice_id, l_left);
      END LOOP;
      NOONA_CORE_PKG.assert(l_left = 0, 'NOONA-RES-047', 'العربون (' || fmt(l_dep) || ') أكبر من الدفعة الأولى المفوترة؛ عدل خطة السداد',
                            'Deposit exceeds the first billed installment');
      add_line(l_lines, acc('DEPOSIT'), l_dep, 0, c.buyer_party_id, 'تطبيق عربون الحجز على العقد ' || c.doc_no);
      add_line(l_lines, l_ar, 0, l_dep, c.buyer_party_id, 'عربون محصل مسبقاً - ' || l_bname);
      l_ev := post('RE_DEPOSIT_APPLIED', 'RE_DEPOSIT_APPLIED', c.id, l_date, 'تطبيق العربون على العقد ' || c.doc_no, l_lines, c.doc_no);
      l_lines := NOONA_GL_PKG.t_lines();
    END IF;
    -- استحقاق عمولة الوسيط
    FOR m IN (SELECT * FROM re_broker_commission WHERE contract_id = c.id AND status_code = 'ACCRUED' AND accrual_event_id IS NULL) LOOP
      l_lines := NOONA_GL_PKG.t_lines();
      add_line(l_lines, acc('COMM_EXP'), m.commission_amount, 0, NULL, 'عمولة بيع الوحدة ' || NOONA_RE_PKG.unit_label(c.unit_id) || ' - ' || c.doc_no);
      add_line(l_lines, acc('COMM_PAY'), 0, m.commission_amount, m.broker_party_id, 'عمولة وسيط مستحقة - عقد ' || c.doc_no);
      l_ev := post('RE_COMMISSION_ACCRUED', c_com, m.id, l_date, 'عمولة وسيط - ' || c.doc_no, l_lines, c.doc_no);
      UPDATE re_broker_commission SET accrual_event_id = l_ev WHERE id = m.id;
    END LOOP;
    refresh_installments(c.id);
    NOONA_AUDIT_PKG.log_event('POSTING', c_ctr, c.id, 'SIGN', 'SUCCESS');
    NOONA_API_PKG.publish('RE_SALE_CONTRACT.SIGNED', c_ctr, c.id);
  END sign_contract;

  PROCEDURE terminate_contract(p_contract_id IN NUMBER, p_reason IN VARCHAR2, p_forfeit IN NUMBER, p_place IN VARCHAR2 DEFAULT NULL) IS
    c       re_sale_contract%ROWTYPE := get_contract(p_contract_id, TRUE);
    l_paid  NUMBER := 0;
    l_net   NUMBER;
    l_f     NUMBER := ROUND(NVL(p_forfeit, 0), 2);
    l_ref   NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_ev    NUMBER;
    l_x     NUMBER;
    l_j     NUMBER;
    l_open  NUMBER;
    l_bname VARCHAR2(400);
    l_line  NUMBER;
  BEGIN
    guard('RE_SALE_CONTRACT.APPROVE');
    NOONA_CORE_PKG.assert(c.status_code IN ('DRAFT', 'APPROVED', 'SIGNED', 'REGISTERED', 'UNDER_CONSTRUCTION', 'READY_FOR_HANDOVER'), 'NOONA-RES-048',
                          'يفسخ العقد قبل التسليم فقط', 'Only a contract not handed over can be terminated');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-RES-028', 'اكتب سبب الفسخ', 'Reason is required');
    refresh_installments(c.id);
    SELECT display_name_ar INTO l_bname FROM pty_party WHERE id = c.buyer_party_id;
    -- الفواتير غير المسددة إطلاقاً تلغى بإشعار دائن؛ المسددة جزئياً تمنع الفسخ حتى تسوى
    FOR i IN (SELECT * FROM re_sale_installment WHERE contract_id = c.id AND sales_invoice_id IS NOT NULL AND status_code <> 'CANCELLED') LOOP
      SELECT NVL(SUM(open_amount), 0) INTO l_open FROM ar_open_item WHERE source_entity_type = 'SAL_INVOICE' AND source_entity_id = i.sales_invoice_id;
      NOONA_CORE_PKG.assert(l_open = 0 OR l_open = i.amount + i.tax_amount, 'NOONA-RES-049',
                            'القسط ' || i.installment_no || ' مسدد جزئياً؛ أكمل تحصيله أو سوه قبل الفسخ', 'Partially paid installment must be settled first');
      IF l_open > 0 THEN
        SELECT MIN(id) INTO l_line FROM sal_invoice_line WHERE invoice_id = i.sales_invoice_id;
        l_x := NOONA_SAL_PKG.post_return(JSON_OBJECT('inv' VALUE i.sales_invoice_id, 'reason' VALUE 'فسخ العقد ' || c.doc_no || ': ' || p_reason,
                                                     'lines' VALUE JSON_ARRAY(JSON_OBJECT('l' VALUE l_line, 'q' VALUE 1))));
        UPDATE re_sale_installment SET status_code = 'CANCELLED' WHERE id = i.id;
      ELSE
        l_paid := l_paid + i.amount;
      END IF;
    END LOOP;
    UPDATE re_sale_installment SET status_code = 'CANCELLED' WHERE contract_id = c.id AND status_code = 'SCHEDULED';
    -- المحصل (صافي الضريبة) في الدفعات المقدمة: يصادر جزء ويرد الباقي
    l_net := l_paid;
    NOONA_CORE_PKG.assert(l_f BETWEEN 0 AND l_net, 'NOONA-RES-050', 'المصادر بين صفر والمحصل (' || fmt(l_net) || ')', 'Forfeit must be within the amount collected');
    l_ref := l_net - l_f;
    NOONA_CORE_PKG.assert(l_ref = 0 OR p_place IS NOT NULL, 'NOONA-RES-051', 'اختر الصندوق أو البنك لرد المبلغ', 'Choose where the refund is paid from');
    IF l_net > 0 THEN
      add_line(l_lines, CASE WHEN c.revenue_recognized = 'Y' THEN acc('REVENUE') ELSE acc('ADVANCE') END, l_net, 0, c.buyer_party_id, 'فسخ العقد ' || c.doc_no);
      add_line(l_lines, acc('FORFEIT'), 0, l_f, c.buyer_party_id, 'مصادرة عند فسخ العقد ' || c.doc_no);
      IF l_ref > 0 THEN
        add_line(l_lines, NOONA_CSH_PKG.place_account(p_place), 0, l_ref, NULL, 'رد للمشتري بعد فسخ العقد ' || c.doc_no || ' - ' || l_bname);
      END IF;
      l_ev := post('RE_CONTRACT_TERMINATED', 'RE_CONTRACT_TERMINATION', c.id, TRUNC(SYSDATE), 'فسخ عقد بيع ' || c.doc_no, l_lines, c.doc_no);
      IF l_ref > 0 THEN
        l_x := NOONA_CSH_PKG.record_settlement('PAYMENT', p_place, TRUNC(SYSDATE), l_ref, c.buyer_party_id, l_bname, 'RE_CONTRACT_TERMINATION', c.id,
                                               c.doc_no || '-T', 'رد بعد فسخ عقد بيع وحدة', l_ev);
      END IF;
    END IF;
    -- العمولة غير المسددة تعكس
    FOR m IN (SELECT * FROM re_broker_commission WHERE contract_id = c.id AND status_code IN ('ACCRUED', 'ELIGIBLE', 'APPROVED')) LOOP
      IF m.accrual_event_id IS NOT NULL THEN
        l_j := NOONA_ACE_PKG.reverse_source(c_com, m.id, TRUNC(SYSDATE), 'فسخ العقد');
      END IF;
      UPDATE re_broker_commission SET status_code = 'REVERSED' WHERE id = m.id;
    END LOOP;
    UPDATE re_sale_contract SET status_code = 'TERMINATED', cancel_reason = p_reason, forfeited_amount = l_f, refunded_amount = l_ref,
                                termination_event_id = l_ev
     WHERE id = c.id;
    UPDATE re_unit SET status_code = 'AVAILABLE' WHERE id = c.unit_id;
    NOONA_AUDIT_PKG.log_event('POSTING', c_ctr, c.id, 'TERMINATE', 'SUCCESS', p_new_values => JSON_OBJECT('forfeit' VALUE l_f, 'refund' VALUE l_ref));
  END terminate_contract;

  -- ================================================================ التسليم والإفراغ
  FUNCTION schedule_handover(p_contract_id IN NUMBER, p_date IN DATE) RETURN NUMBER IS
    c    re_sale_contract%ROWTYPE := get_contract(p_contract_id);
    l_id NUMBER;
    l_no VARCHAR2(50);
  BEGIN
    guard('RE_HANDOVER.CREATE');
    NOONA_CORE_PKG.assert(c.status_code IN ('SIGNED', 'REGISTERED', 'UNDER_CONSTRUCTION', 'READY_FOR_HANDOVER'), 'NOONA-RES-060',
                          'يجدول التسليم لعقد موقع لم يسلم', 'Contract must be signed and not handed over');
    SELECT MIN(id) INTO l_id FROM re_handover WHERE contract_id = c.id AND status_code <> 'HANDED_OVER';
    IF l_id IS NULL THEN
      l_no := next_no('RE_HANDOVER', 'HO-', c_ho);
      INSERT INTO re_handover (company_id, doc_no, doc_date, contract_id, unit_id, scheduled_date, status_code)
      VALUES (company, l_no, TRUNC(SYSDATE), c.id, c.unit_id, p_date, 'SCHEDULED')
      RETURNING id INTO l_id;
    ELSE
      UPDATE re_handover SET scheduled_date = p_date WHERE id = l_id;
    END IF;
    UPDATE re_sale_contract SET status_code = 'READY_FOR_HANDOVER' WHERE id = c.id;
    RETURN l_id;
  END schedule_handover;

  PROCEDURE save_snags(p_handover_id IN NUMBER, p_snags IN CLOB) IS
    l_open NUMBER;
  BEGIN
    guard('RE_HANDOVER.UPDATE');
    SELECT COUNT(*) INTO l_open FROM JSON_TABLE(p_snags, '$[*]' COLUMNS (st VARCHAR2(30) PATH '$.status')) WHERE NVL(st, 'OPEN') = 'OPEN';
    UPDATE re_handover SET snag_list = p_snags, status_code = CASE WHEN l_open > 0 THEN 'SNAGS_OPEN' ELSE 'ACCEPTED' END
     WHERE id = p_handover_id AND company_id = company AND status_code <> 'HANDED_OVER';
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-RES-061', 'محضر التسليم غير موجود أو مكتمل', 'Handover not found or completed');
  END save_snags;

  FUNCTION unit_cost(p_unit_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(j.cost), 0) INTO l FROM re_cost_allocation a,
           JSON_TABLE(a.details, '$[*]' COLUMNS (unit NUMBER PATH '$.unit', cost NUMBER PATH '$.cost')) j
     WHERE a.company_id = company AND a.status_code = 'POSTED' AND j.unit = p_unit_id;
    RETURN l;
  END unit_cost;

  PROCEDURE complete_handover(p_handover_id IN NUMBER, p_date IN DATE, p_keys IN NUMBER DEFAULT NULL, p_notes IN VARCHAR2 DEFAULT NULL) IS
    h       re_handover%ROWTYPE;
    c       re_sale_contract%ROWTYPE;
    l_rev   NUMBER;
    l_cost  NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_ev    NUMBER;
    l_date  DATE := NVL(p_date, TRUNC(SYSDATE));
  BEGIN
    guard('RE_HANDOVER.UPDATE');
    SELECT * INTO h FROM re_handover WHERE id = p_handover_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(h.status_code IN ('SCHEDULED', 'INSPECTION', 'ACCEPTED'), 'NOONA-RES-062',
                          CASE WHEN h.status_code = 'SNAGS_OPEN' THEN 'توجد ملاحظات معاينة مفتوحة؛ أغلقها أولاً' ELSE 'التسليم مكتمل' END,
                          'Handover cannot be completed');
    c := get_contract(h.contract_id, TRUE);
    NOONA_CORE_PKG.assert(l_date <= TRUNC(SYSDATE), 'NOONA-RES-063', 'تاريخ التسليم لا يكون مستقبلياً', 'Handover date cannot be in the future');
    -- الاعتراف بالإيراد عند التسليم: المفوتر سابقاً على الدفعات المقدمة ينقل للإيراد، والأقساط اللاحقة تفوتر على الإيراد مباشرة
    IF c.revenue_recognized = 'N' THEN
      SELECT NVL(SUM(amount), 0) INTO l_rev FROM re_sale_installment WHERE contract_id = c.id AND sales_invoice_id IS NOT NULL AND status_code <> 'CANCELLED';
      add_line(l_lines, acc('ADVANCE'), l_rev, 0, c.buyer_party_id, 'الاعتراف بإيراد بيع الوحدة عند التسليم - ' || c.doc_no);
      add_line(l_lines, acc('REVENUE'), 0, l_rev, c.buyer_party_id, 'إيراد بيع الوحدة ' || NOONA_RE_PKG.unit_label(c.unit_id) || ' - ' || c.doc_no);
    END IF;
    l_cost := unit_cost(c.unit_id);
    IF l_cost > 0 THEN
      add_line(l_lines, acc('COGS'), l_cost, 0, NULL, 'تكلفة الوحدة المباعة ' || NOONA_RE_PKG.unit_label(c.unit_id));
      add_line(l_lines, acc('UNITS'), 0, l_cost, NULL, 'تكلفة الوحدة المباعة ' || NOONA_RE_PKG.unit_label(c.unit_id));
    END IF;
    IF l_lines.COUNT >= 2 THEN
      l_ev := post('RE_REVENUE_RECOGNIZED', c_ho, h.id, l_date, 'تسليم الوحدة ' || NOONA_RE_PKG.unit_label(c.unit_id) || ' - ' || c.doc_no, l_lines, h.doc_no);
    END IF;
    UPDATE re_handover SET status_code = 'HANDED_OVER', handover_date = l_date, keys_count = p_keys, notes = p_notes WHERE id = h.id;
    UPDATE re_sale_contract SET status_code = 'HANDED_OVER', revenue_recognized = 'Y', unit_cost = l_cost, revenue_event_id = NVL(l_ev, revenue_event_id)
     WHERE id = c.id;
    -- دفعات التسليم تستحق بتاريخ التسليم
    UPDATE re_sale_installment SET due_date = l_date WHERE contract_id = c.id AND status_code = 'SCHEDULED' AND label = 'دفعة التسليم';
    UPDATE re_unit SET status_code = 'HANDED_OVER' WHERE id = c.unit_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-RES-061', 'محضر التسليم غير موجود', 'Handover not found');
  END complete_handover;

  FUNCTION transfer_title(p_contract_id IN NUMBER, p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    c     re_sale_contract%ROWTYPE := get_contract(p_contract_id, TRUE);
    l_id  NUMBER;
    l_dt  DATE := NVL(jd(l_o, 'date'), TRUNC(SYSDATE));
    l_col NUMBER;
    l_ref  VARCHAR2(100) := js(l_o, 'ref');
    l_fees NUMBER := jn(l_o, 'fees');
    l_deed VARCHAR2(100) := js(l_o, 'deed');
  BEGIN
    guard('RE_TITLE_TRANSFER.CREATE');
    NOONA_CORE_PKG.assert(c.status_code IN ('SIGNED', 'REGISTERED', 'READY_FOR_HANDOVER', 'HANDED_OVER'), 'NOONA-RES-064',
                          'الإفراغ لعقد موقع لم يفسخ', 'Contract must be signed');
    NOONA_CORE_PKG.assert(js(l_o, 'deed') IS NOT NULL, 'NOONA-RES-065', 'أدخل رقم الصك الجديد', 'New deed number is required');
    refresh_installments(c.id);
    l_col := collected(c.id);
    NOONA_CORE_PKG.assert(NVL(js(l_o, 'financed'), 'N') = 'Y' OR l_col >= c.total_amount, 'NOONA-RES-066',
                          'لم يسدد كامل الثمن (المحصل ' || fmt(l_col) || ' من ' || fmt(c.total_amount) || ')؛ الإفراغ قبل السداد بتمويل بنكي فقط',
                          'Full price must be collected unless financed');
    INSERT INTO re_title_transfer (company_id, contract_id, authority_ref, transfer_date, fees_amount, new_deed_no, status_code)
    VALUES (company, c.id, l_ref, l_dt, l_fees, l_deed, 'COMPLETED')
    RETURNING id INTO l_id;
    UPDATE re_unit_ownership SET effective_to = l_dt - 1 WHERE unit_id = c.unit_id AND effective_to IS NULL;
    INSERT INTO re_unit_ownership (company_id, unit_id, owner_party_id, ownership_pct, source_contract_id, effective_from)
    VALUES (company, c.unit_id, c.buyer_party_id, 100, c.id, l_dt);
    UPDATE re_unit SET owner_party_id = c.buyer_party_id, title_deed_no = l_deed WHERE id = c.unit_id;
    UPDATE re_sale_contract SET status_code = CASE WHEN status_code = 'HANDED_OVER' THEN 'TITLE_TRANSFERRED' ELSE status_code END WHERE id = c.id;
    RETURN l_id;
  END transfer_title;

  -- ================================================================ العمولات
  PROCEDURE approve_commission(p_commission_id IN NUMBER) IS
    l re_broker_commission%ROWTYPE;
  BEGIN
    guard('RE_BROKER_COMMISSION.APPROVE');
    SELECT * INTO l FROM re_broker_commission WHERE id = p_commission_id AND company_id = company FOR UPDATE;
    refresh_installments(l.contract_id);
    SELECT * INTO l FROM re_broker_commission WHERE id = p_commission_id;
    NOONA_CORE_PKG.assert(l.status_code = 'ELIGIBLE', 'NOONA-RES-070',
                          CASE WHEN l.status_code = 'ACCRUED' THEN 'العمولة لم تستحق بعد: ' || l.eligibility_rule ELSE 'العمولة ' || status_label(l.status_code) END,
                          'Commission is not eligible');
    UPDATE re_broker_commission SET status_code = 'APPROVED' WHERE id = l.id;
  END approve_commission;

  PROCEDURE pay_commission(p_commission_id IN NUMBER, p_place IN VARCHAR2, p_date IN DATE DEFAULT NULL) IS
    l       re_broker_commission%ROWTYPE;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_ev    NUMBER;
    l_x     NUMBER;
    l_name  VARCHAR2(400);
    l_date  DATE := NVL(p_date, TRUNC(SYSDATE));
    l_no    VARCHAR2(50);
  BEGIN
    guard('RE_BROKER_COMMISSION.APPROVE');
    SELECT * INTO l FROM re_broker_commission WHERE id = p_commission_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l.status_code = 'APPROVED', 'NOONA-RES-071', 'اعتمد العمولة قبل سدادها', 'Approve the commission first');
    NOONA_CORE_PKG.assert(p_place IS NOT NULL, 'NOONA-RES-072', 'اختر الصندوق أو البنك', 'Choose the cash box or bank');
    SELECT display_name_ar INTO l_name FROM pty_party WHERE id = l.broker_party_id;
    SELECT doc_no INTO l_no FROM re_sale_contract WHERE id = l.contract_id;
    add_line(l_lines, acc('COMM_PAY'), l.commission_amount, 0, l.broker_party_id, 'سداد عمولة ' || l_name || ' - عقد ' || l_no);
    add_line(l_lines, NOONA_CSH_PKG.place_account(p_place), 0, l.commission_amount, NULL, 'سداد عمولة وسيط - ' || l_name);
    l_ev := post('RE_COMMISSION_PAID', 'RE_COMMISSION_PAYMENT', l.id, l_date, 'سداد عمولة وسيط - ' || l_no, l_lines, l_no);
    l_x := NOONA_CSH_PKG.record_settlement('PAYMENT', p_place, l_date, l.commission_amount, l.broker_party_id, l_name, 'RE_COMMISSION_PAYMENT', l.id,
                                           'COM-' || l.id, 'عمولة وسيط بيع وحدة', l_ev);
    UPDATE re_broker_commission SET status_code = 'PAID', payment_event_id = l_ev, paid_date = l_date WHERE id = l.id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-RES-073', 'العمولة غير موجودة', 'Commission not found');
  END pay_commission;

  -- ================================================================ رسملة التكاليف
  FUNCTION capitalize_costs(p_property_id IN NUMBER, p_basis IN VARCHAR2 DEFAULT 'AREA') RETURN NUMBER IS
    l_prj   NUMBER;
    l_total NUMBER;
    l_done  NUMBER;
    l_amt   NUMBER;
    l_base  NUMBER;
    l_basis VARCHAR2(30) := NVL(p_basis, 'AREA');
    l_arr   JSON_ARRAY_T := JSON_ARRAY_T();
    l_o     JSON_OBJECT_T;
    l_share NUMBER;
    l_sum   NUMBER := 0;
    l_n     PLS_INTEGER := 0;
    l_cnt   PLS_INTEGER;
    l_id    NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_ev    NUMBER;
    l_per   NUMBER := NOONA_GL_PKG.period_for(TRUNC(SYSDATE));
    l_pname VARCHAR2(400) := NOONA_RE_PKG.property_name(p_property_id);
    l_det   CLOB;
  BEGIN
    guard('RE_COST_ALLOCATION.POST');
    SELECT MAX(project_id) INTO l_prj FROM re_property WHERE id = p_property_id AND company_id = company;
    NOONA_CORE_PKG.assert(l_prj IS NOT NULL, 'NOONA-RES-080', 'العقار غير مرتبط بمشروع تطوير', 'Property is not linked to a development project');
    NOONA_CORE_PKG.assert(l_basis IN ('AREA', 'SALE_VALUE', 'UNIT_COUNT'), 'NOONA-RES-081', 'أساس التوزيع غير صحيح', 'Invalid basis');
    NOONA_CORE_PKG.assert(l_per IS NOT NULL, 'NOONA-RES-082', 'لا توجد فترة محاسبية مفتوحة لتاريخ اليوم', 'No open period');
    l_total := NOONA_PRJ_PKG.actual_cost(l_prj);
    SELECT NVL(SUM(total_cost), 0) INTO l_done FROM re_cost_allocation WHERE property_id = p_property_id AND status_code = 'POSTED';
    l_amt := ROUND(l_total - l_done, 2);
    NOONA_CORE_PKG.assert(l_amt > 0, 'NOONA-RES-083', 'لا توجد تكاليف تطوير جديدة غير مرسملة (المرسمل ' || fmt(l_done) || ')', 'Nothing to capitalize');
    -- الوحدات التي لم يعترف بإيرادها بعد
    SELECT NVL(SUM(CASE l_basis WHEN 'AREA' THEN NVL(NVL(u.net_area_sqm, u.gross_area_sqm), 0) WHEN 'SALE_VALUE' THEN NVL(u.list_price, 0) ELSE 1 END), 0), COUNT(*)
      INTO l_base, l_cnt
      FROM re_unit u WHERE u.property_id = p_property_id
       AND NOT EXISTS (SELECT 1 FROM re_sale_contract c WHERE c.unit_id = u.id AND c.revenue_recognized = 'Y' AND c.status_code <> 'TERMINATED');
    NOONA_CORE_PKG.assert(l_base > 0, 'NOONA-RES-084', 'لا توجد وحدات غير مسلمة بقيمة لأساس التوزيع', 'No units to allocate to');
    FOR u IN (SELECT u.id, CASE l_basis WHEN 'AREA' THEN NVL(NVL(u.net_area_sqm, u.gross_area_sqm), 0) WHEN 'SALE_VALUE' THEN NVL(u.list_price, 0) ELSE 1 END b
                FROM re_unit u WHERE u.property_id = p_property_id
                 AND NOT EXISTS (SELECT 1 FROM re_sale_contract c WHERE c.unit_id = u.id AND c.revenue_recognized = 'Y' AND c.status_code <> 'TERMINATED')
               ORDER BY u.id) LOOP
      l_n := l_n + 1;
      l_share := CASE WHEN l_n = l_cnt THEN l_amt - l_sum ELSE ROUND(l_amt * u.b / l_base, 2) END;
      l_sum := l_sum + l_share;
      l_o := JSON_OBJECT_T();
      l_o.put('unit', u.id); l_o.put('cost', l_share);
      l_arr.append(l_o);
    END LOOP;
    l_det := l_arr.to_clob;
    INSERT INTO re_cost_allocation (company_id, property_id, period_id, allocation_basis, total_cost, details, status_code)
    VALUES (company, p_property_id, l_per, l_basis, l_amt, l_det, 'CALCULATED')
    RETURNING id INTO l_id;
    add_line(l_lines, acc('UNITS'), l_amt, 0, NULL, 'رسملة تكاليف تطوير ' || l_pname || ' على الوحدات');
    add_line(l_lines, acc('DEV_COST'), 0, l_amt, NULL, 'نقل تكاليف مشروع التطوير إلى الوحدات المعدة للبيع - ' || l_pname);
    l_ev := post('RE_COST_CAPITALIZED', c_alloc, l_id, TRUNC(SYSDATE), 'رسملة تكاليف التطوير - ' || l_pname, l_lines, NULL);
    UPDATE re_cost_allocation SET status_code = 'POSTED', accounting_event_id = l_ev, posted_at = SYSTIMESTAMP, posted_by = NOONA_CTX_PKG.current_user_name
     WHERE id = l_id;
    RETURN l_id;
  END capitalize_costs;

  -- ================================================================ الشاشات
  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_cls VARCHAR2 DEFAULT 'is-info') RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_cls || '"><span class="nn-kpi-icon fa ' || p_icon || '" aria-hidden="true"></span><div><div class="nn-kpi-value">'
        || p_value || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION summary_html RETURN CLOB IS
    l_av NUMBER; l_rs NUMBER; l_sold NUMBER; l_val NUMBER; l_col NUMBER := 0; l_od NUMBER; l_due NUMBER; l_co NUMBER := company;
  BEGIN
    guard('RE_SALE_CONTRACT.VIEW');
    refresh_installments;
    SELECT COUNT(CASE WHEN status_code = 'AVAILABLE' THEN 1 END), COUNT(CASE WHEN status_code = 'RESERVED' THEN 1 END),
           COUNT(CASE WHEN status_code IN ('SOLD', 'HANDED_OVER') THEN 1 END)
      INTO l_av, l_rs, l_sold FROM re_unit WHERE company_id = l_co AND usage_type IN ('SALE', 'MIXED');
    SELECT NVL(SUM(total_amount), 0) INTO l_val FROM re_sale_contract
     WHERE company_id = l_co AND status_code NOT IN ('DRAFT', 'CANCELLED', 'TERMINATED') AND signed_date >= TRUNC(SYSDATE, 'YYYY');
    FOR c IN (SELECT id FROM re_sale_contract WHERE company_id = l_co AND status_code NOT IN ('DRAFT', 'CANCELLED', 'TERMINATED')) LOOP
      l_col := l_col + collected(c.id);
    END LOOP;
    SELECT NVL(SUM(i.amount + i.tax_amount - i.paid_amount), 0) INTO l_od FROM re_sale_installment i JOIN re_sale_contract c ON c.id = i.contract_id
     WHERE c.company_id = l_co AND i.status_code IN ('OVERDUE', 'PARTIALLY_PAID') AND i.due_date < TRUNC(SYSDATE);
    SELECT NVL(SUM(i.amount + i.tax_amount), 0) INTO l_due FROM re_sale_installment i JOIN re_sale_contract c ON c.id = i.contract_id
     WHERE c.company_id = l_co AND i.status_code IN ('SCHEDULED', 'INVOICED') AND i.due_date BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE) + 30
       AND c.status_code NOT IN ('DRAFT', 'CANCELLED', 'TERMINATED');
    RETURN '<div class="nn-kpis">' || kpi('وحدات متاحة للبيع', l_av, 'fa-home', 'is-success') || kpi('محجوزة', l_rs, 'fa-bookmark', 'is-warning')
        || kpi('مباعة', l_sold, 'fa-key', 'is-info') || kpi('مبيعات هذا العام', fmt(l_val), 'fa-line-chart', 'is-info')
        || kpi('المحصل من العقود', fmt(l_col), 'fa-money', 'is-success')
        || kpi('أقساط متأخرة', fmt(l_od), 'fa-exclamation-triangle', CASE WHEN l_od > 0 THEN 'is-danger' ELSE 'is-muted' END)
        || kpi('تستحق خلال 30 يوماً', fmt(l_due), 'fa-calendar', 'is-warning') || '</div>';
  END summary_html;

  FUNCTION availability_html(p_property_id IN NUMBER, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('RE_SALE_CONTRACT.VIEW');
    l_h := '<div class="nn-res-grid">';
    FOR u IN (SELECT u.id, u.code, u.unit_type, u.status_code, NVL(u.net_area_sqm, u.gross_area_sqm) area, u.bedrooms, b.name_ar bname,
                     NOONA_RES_PKG.unit_price(u.id) price
                FROM re_unit u LEFT JOIN re_building b ON b.id = u.building_id
               WHERE u.property_id = p_property_id AND u.company_id = company AND u.usage_type IN ('SALE', 'MIXED')
               ORDER BY b.code, u.code) LOOP
      l_n := l_n + 1;
      l_h := l_h || (CASE WHEN p_link IS NOT NULL AND u.status_code = 'AVAILABLE' THEN '<a' ELSE '<div' END || ' class="nn-res-unit is-' || LOWER(u.status_code) || '"'
          || CASE WHEN p_link IS NOT NULL AND u.status_code = 'AVAILABLE' THEN ' href="' || REPLACE(p_link, '#ID#', u.id) || '"' END
          || ' title="' || esc(NOONA_RE_PKG.unit_status_label(u.status_code)) || '"><b>' || esc(u.code) || '</b><small>'
          || esc(NOONA_RE_PKG.unit_type_label(u.unit_type)) || CASE WHEN u.bedrooms > 0 THEN ' · ' || u.bedrooms || ' غرف' END
          || CASE WHEN u.area > 0 THEN ' · ' || ROUND(u.area) || ' م²' END || '</small><span>' || CASE WHEN u.price > 0 THEN fmt(u.price) END || '</span>'
          || '<em>' || esc(NOONA_RE_PKG.unit_status_label(u.status_code)) || '</em>'
          || CASE WHEN p_link IS NOT NULL AND u.status_code = 'AVAILABLE' THEN '</a>' ELSE '</div>' END);
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد وحدات للبيع في هذا العقار (استخدام الوحدة: للبيع أو متعدد)</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</div>');
  END availability_html;

  FUNCTION reservations_html(p_status IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('RE_RESERVATION.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>الحجز</th><th>التاريخ</th><th>الوحدة</th><th>المشتري</th><th class="n">السعر</th><th class="n">الخصم</th>'
        || '<th class="n">العربون</th><th>ينتهي</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT r.*, p.display_name_ar bname FROM re_reservation r JOIN pty_party p ON p.id = r.buyer_party_id
               WHERE r.company_id = company AND (p_status IS NULL OR r.status_code = p_status) ORDER BY r.id DESC FETCH FIRST 300 ROWS ONLY) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr data-res="' || r.id || '"><td><b>' || esc(r.doc_no) || '</b></td><td>' || ds(r.doc_date) || '</td><td>' || esc(NOONA_RE_PKG.unit_label(r.unit_id))
          || '</td><td>' || esc(r.bname) || '</td><td class="n">' || fmt(r.quoted_price) || '</td><td class="n">' || fmt(r.discount_amount) || '</td><td class="n">'
          || fmt(r.deposit_amount) || '</td><td' || CASE WHEN r.status_code = 'ACTIVE' AND r.expires_at < SYSTIMESTAMP + 1 THEN ' class="is-over"' END || '>'
          || TO_CHAR(r.expires_at, 'YYYY-MM-DD') || '</td><td>' || badge(r.status_code) || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد حجوزات</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody></table>');
  END reservations_html;

  FUNCTION contracts_html(p_status IN VARCHAR2 DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
    l_c NUMBER;
  BEGIN
    guard('RE_SALE_CONTRACT.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>العقد</th><th>التاريخ</th><th>الوحدة</th><th>المشتري</th><th class="n">الإجمالي</th><th class="n">المحصل</th>'
        || '<th>نسبة التحصيل</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT c.*, p.display_name_ar bname FROM re_sale_contract c JOIN pty_party p ON p.id = c.buyer_party_id
               WHERE c.company_id = company AND (p_status IS NULL OR c.status_code = p_status
                     OR (p_status = 'OPEN' AND c.status_code NOT IN ('TITLE_TRANSFERRED', 'TERMINATED', 'CANCELLED')))
               ORDER BY c.id DESC FETCH FIRST 300 ROWS ONLY) LOOP
      l_n := l_n + 1;
      l_c := collected(r.id);
      l_h := l_h || ('<tr><td>' || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', r.id) || '"><b>' || esc(r.doc_no) || '</b></a>'
                                       ELSE '<b>' || esc(r.doc_no) || '</b>' END
          || '</td><td>' || ds(r.doc_date) || '</td><td>' || esc(NOONA_RE_PKG.unit_label(r.unit_id)) || '</td><td>' || esc(r.bname) || '</td><td class="n">'
          || fmt(r.total_amount) || '</td><td class="n">' || fmt(l_c) || '</td><td><div class="nn-prj-bar"><span style="width:'
          || LEAST(100, ROUND(l_c * 100 / NULLIF(r.total_amount, 0))) || '%"></span></div> ' || pct(l_c * 100 / NULLIF(r.total_amount, 0)) || '</td><td>'
          || badge(r.status_code) || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد عقود بيع</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody></table>');
  END contracts_html;

  FUNCTION installments_html(p_contract_id IN NUMBER) RETURN CLOB IS
    l_h  CLOB;
    t_a  NUMBER := 0; t_t NUMBER := 0; t_p NUMBER := 0;
    l_no VARCHAR2(50);
  BEGIN
    guard('RE_SALE_CONTRACT.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>#</th><th>البيان</th><th>الاستحقاق</th><th class="n">المبلغ</th><th class="n">الضريبة</th>'
        || '<th class="n">الإجمالي</th><th class="n">المحصل</th><th>الفاتورة</th><th>الحالة</th></tr></thead><tbody>';
    FOR i IN (SELECT * FROM re_sale_installment WHERE contract_id = p_contract_id ORDER BY installment_no) LOOP
      l_no := NULL;
      IF i.sales_invoice_id IS NOT NULL THEN
        SELECT doc_no INTO l_no FROM sal_invoice WHERE id = i.sales_invoice_id;
      END IF;
      IF i.status_code <> 'CANCELLED' THEN
        t_a := t_a + i.amount; t_t := t_t + i.tax_amount; t_p := t_p + i.paid_amount;
      END IF;
      l_h := l_h || ('<tr' || CASE WHEN i.status_code = 'CANCELLED' THEN ' class="is-void"' END || '><td>' || i.installment_no || '</td><td>' || esc(i.label)
          || '</td><td' || CASE WHEN i.status_code = 'OVERDUE' THEN ' class="is-over"' END || '>' || ds(i.due_date) || '</td><td class="n">' || fmt(i.amount)
          || '</td><td class="n">' || fmt(i.tax_amount) || '</td><td class="n">' || fmt(i.amount + i.tax_amount) || '</td><td class="n">' || fmt(i.paid_amount)
          || '</td><td>' || esc(l_no) || '</td><td>' || badge(i.status_code) || '</td></tr>');
    END LOOP;
    RETURN l_h || ('</tbody><tfoot><tr><td colspan="3">الإجمالي</td><td class="n">' || fmt(t_a) || '</td><td class="n">' || fmt(t_t) || '</td><td class="n">'
        || fmt(t_a + t_t) || '</td><td class="n">' || fmt(t_p) || '</td><td colspan="2">المتبقي ' || fmt(t_a + t_t - t_p) || '</td></tr></tfoot></table>');
  END installments_html;

  FUNCTION contract_html(p_contract_id IN NUMBER) RETURN CLOB IS
    c     re_sale_contract%ROWTYPE := get_contract(p_contract_id);
    l_h   CLOB;
    l_b   VARCHAR2(400);
    l_ph  VARCHAR2(100);
    l_col NUMBER;
    l_pl  VARCHAR2(200);
    l_rs  VARCHAR2(50);
  BEGIN
    guard('RE_SALE_CONTRACT.VIEW');
    refresh_installments(c.id);
    l_col := collected(c.id);
    SELECT p.display_name_ar, (SELECT MAX(mobile) FROM ref_contact x WHERE x.party_id = p.id)
      INTO l_b, l_ph FROM pty_party p WHERE p.id = c.buyer_party_id;
    SELECT MAX(name_ar) INTO l_pl FROM re_payment_plan WHERE id = c.payment_plan_id;
    SELECT MAX(doc_no) INTO l_rs FROM re_reservation WHERE id = c.reservation_id;
    l_h := '<div class="nn-prj-chips"><span>العقد ' || esc(c.doc_no) || '</span><span>' || esc(NOONA_RE_PKG.unit_label(c.unit_id)) || '</span>'
        || badge(c.status_code) || CASE WHEN c.registration_no IS NOT NULL THEN '<span>التوثيق ' || esc(c.registration_no) || '</span>' END
        || CASE WHEN c.revenue_recognized = 'Y' THEN '<span class="nn-badge is-success">تم الاعتراف بالإيراد</span>' END || '</div>'
        || '<table class="nn-prj-cert-info"><tr><th>المشتري</th><td>' || esc(l_b) || CASE WHEN l_ph IS NOT NULL THEN ' · <span dir="ltr">' || esc(l_ph) || '</span>' END
        || '</td><th>تاريخ التوقيع</th><td>' || ds(c.signed_date) || '</td></tr>'
        || '<tr><th>سعر البيع</th><td>' || fmt(c.sale_price) || '</td><th>الخصم</th><td>' || fmt(c.discount_amount) || '</td></tr>'
        || '<tr><th>الضريبة</th><td>' || fmt(c.tax_amount) || '</td><th>الإجمالي</th><td><b>' || fmt(c.total_amount) || '</b></td></tr>'
        || '<tr><th>خطة السداد</th><td>' || esc(NVL(l_pl, 'دفعة واحدة')) || '</td><th>الحجز</th><td>' || esc(l_rs) || '</td></tr>'
        || '<tr><th>المحصل</th><td>' || fmt(l_col) || ' (' || pct(l_col * 100 / NULLIF(c.total_amount, 0)) || ')</td><th>المتبقي</th><td>'
        || fmt(c.total_amount - l_col) || '</td></tr>'
        || '<tr><th>التسليم المتوقع</th><td>' || ds(c.expected_handover) || '</td><th>الاعتراف بالإيراد</th><td>'
        || CASE c.revenue_method WHEN 'OVER_TIME' THEN 'على مدى الإنشاء (مع كل قسط)' ELSE 'عند التسليم' END || '</td></tr>'
        || CASE WHEN c.status_code = 'TERMINATED' THEN '<tr><th>الفسخ</th><td colspan="3">' || esc(c.cancel_reason) || ' · مصادر ' || fmt(c.forfeited_amount)
                || ' · مردود ' || fmt(c.refunded_amount) || '</td></tr>' END
        || '</table><h4 class="nn-prj-h">جدول الأقساط</h4>' || installments_html(c.id);
    FOR m IN (SELECT b.*, p.display_name_ar bname FROM re_broker_commission b JOIN pty_party p ON p.id = b.broker_party_id WHERE b.contract_id = c.id) LOOP
      l_h := l_h || ('<h4 class="nn-prj-h">عمولة الوسيط</h4><p>' || esc(m.bname) || ' · ' || pct(m.commission_pct) || ' = ' || fmt(m.commission_amount) || ' · '
          || esc(m.eligibility_rule) || ' ' || badge(m.status_code) || '</p>');
    END LOOP;
    FOR h IN (SELECT * FROM re_handover WHERE contract_id = c.id ORDER BY id) LOOP
      l_h := l_h || ('<h4 class="nn-prj-h">التسليم ' || esc(h.doc_no) || '</h4><p>الموعد ' || ds(h.scheduled_date)
          || CASE WHEN h.handover_date IS NOT NULL THEN ' · سلمت ' || ds(h.handover_date) END
          || CASE WHEN h.keys_count IS NOT NULL THEN ' · المفاتيح ' || h.keys_count END || ' ' || badge(h.status_code) || '</p>');
      IF h.snag_list IS NOT NULL THEN
        l_h := l_h || ('<ul class="nn-res-snags">');
        FOR s IN (SELECT item, NVL(st, 'OPEN') st FROM JSON_TABLE(h.snag_list, '$[*]' COLUMNS (item VARCHAR2(500) PATH '$.item', st VARCHAR2(30) PATH '$.status'))) LOOP
          l_h := l_h || ('<li class="is-' || LOWER(s.st) || '">' || esc(s.item) || CASE WHEN s.st = 'FIXED' THEN ' ✓' END || '</li>');
        END LOOP;
        l_h := l_h || ('</ul>');
      END IF;
    END LOOP;
    FOR t IN (SELECT * FROM re_title_transfer WHERE contract_id = c.id) LOOP
      l_h := l_h || ('<h4 class="nn-prj-h">الإفراغ</h4><p>صك ' || esc(t.new_deed_no) || ' · ' || ds(t.transfer_date) || ' · مرجع ' || esc(t.authority_ref)
          || CASE WHEN t.fees_amount > 0 THEN ' · الرسوم ' || fmt(t.fees_amount) END || ' ' || badge(t.status_code) || '</p>');
    END LOOP;
    RETURN l_h;
  END contract_html;

  FUNCTION collections_html(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
    t   NUMBER := 0; t_p NUMBER := 0;
  BEGIN
    guard('RE_SALE_CONTRACT.VIEW');
    refresh_installments;
    l_h := '<table class="nn-prj-t"><thead><tr><th>الاستحقاق</th><th>العقد</th><th>الوحدة</th><th>المشتري</th><th>البيان</th><th class="n">المبلغ</th>'
        || '<th class="n">المحصل</th><th class="n">المتبقي</th><th>التأخير</th><th>الحالة</th></tr></thead><tbody>';
    FOR i IN (SELECT i.*, c.doc_no, c.unit_id, p.display_name_ar bname FROM re_sale_installment i JOIN re_sale_contract c ON c.id = i.contract_id
                JOIN pty_party p ON p.id = c.buyer_party_id
               WHERE c.company_id = company AND c.status_code NOT IN ('DRAFT', 'CANCELLED', 'TERMINATED')
                 AND i.status_code NOT IN ('PAID', 'CANCELLED', 'WAIVED') AND i.due_date <= p_to
                 AND (i.due_date >= p_from OR i.status_code IN ('OVERDUE', 'PARTIALLY_PAID'))
               ORDER BY i.due_date, c.doc_no) LOOP
      l_n := l_n + 1;
      t := t + i.amount + i.tax_amount; t_p := t_p + i.paid_amount;
      l_h := l_h || ('<tr><td>' || ds(i.due_date) || '</td><td>' || esc(i.doc_no) || '</td><td>' || esc(NOONA_RE_PKG.unit_label(i.unit_id)) || '</td><td>'
          || esc(i.bname) || '</td><td>' || esc(i.label) || '</td><td class="n">' || fmt(i.amount + i.tax_amount) || '</td><td class="n">' || fmt(i.paid_amount)
          || '</td><td class="n">' || fmt(i.amount + i.tax_amount - i.paid_amount) || '</td><td' || CASE WHEN i.due_date < TRUNC(SYSDATE) THEN ' class="is-over"' END
          || '>' || CASE WHEN i.due_date < TRUNC(SYSDATE) THEN (TRUNC(SYSDATE) - i.due_date) || ' يوم' END || '</td><td>' || badge(i.status_code) || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد أقساط مستحقة في الفترة</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody><tfoot><tr><td colspan="5">الإجمالي (' || l_n || ')</td><td class="n">' || fmt(t) || '</td><td class="n">' || fmt(t_p)
                    || '</td><td class="n">' || fmt(t - t_p) || '</td><td colspan="2"></td></tr></tfoot></table>');
  END collections_html;

  FUNCTION commissions_html(p_status IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('RE_BROKER_COMMISSION.VIEW');
    refresh_installments;
    l_h := '<table class="nn-prj-t"><thead><tr><th>الوسيط</th><th>العقد</th><th>الوحدة</th><th class="n">النسبة</th><th class="n">العمولة</th><th>الشرط</th>'
        || '<th>السداد</th><th>الحالة</th></tr></thead><tbody>';
    FOR m IN (SELECT b.*, p.display_name_ar bname, c.doc_no, c.unit_id FROM re_broker_commission b JOIN pty_party p ON p.id = b.broker_party_id
                JOIN re_sale_contract c ON c.id = b.contract_id
               WHERE b.company_id = company AND (p_status IS NULL OR b.status_code = p_status) ORDER BY b.id DESC) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr data-com="' || m.id || '"><td>' || esc(m.bname) || '</td><td>' || esc(m.doc_no) || '</td><td>' || esc(NOONA_RE_PKG.unit_label(m.unit_id))
          || '</td><td class="n">' || pct(m.commission_pct) || '</td><td class="n">' || fmt(m.commission_amount) || '</td><td>' || esc(m.eligibility_rule)
          || '</td><td>' || ds(m.paid_date) || '</td><td>' || badge(m.status_code) || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد عمولات</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody></table>');
  END commissions_html;

  FUNCTION handovers_html RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
    l_open NUMBER;
  BEGIN
    guard('RE_HANDOVER.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>المحضر</th><th>الوحدة</th><th>العقد</th><th>المشتري</th><th>الموعد</th><th>التسليم</th>'
        || '<th>ملاحظات مفتوحة</th><th>الحالة</th></tr></thead><tbody>';
    FOR h IN (SELECT h.*, c.doc_no cno, p.display_name_ar bname FROM re_handover h JOIN re_sale_contract c ON c.id = h.contract_id
                JOIN pty_party p ON p.id = c.buyer_party_id
               WHERE h.company_id = company ORDER BY CASE WHEN h.status_code = 'HANDED_OVER' THEN 1 ELSE 0 END, h.scheduled_date) LOOP
      l_n := l_n + 1;
      l_open := 0;
      IF h.snag_list IS NOT NULL THEN
        SELECT COUNT(*) INTO l_open FROM JSON_TABLE(h.snag_list, '$[*]' COLUMNS (st VARCHAR2(30) PATH '$.status')) WHERE NVL(st, 'OPEN') = 'OPEN';
      END IF;
      l_h := l_h || ('<tr data-ho="' || h.id || '"><td><b>' || esc(h.doc_no) || '</b></td><td>' || esc(NOONA_RE_PKG.unit_label(h.unit_id)) || '</td><td>'
          || esc(h.cno) || '</td><td>' || esc(h.bname) || '</td><td>' || ds(h.scheduled_date) || '</td><td>' || ds(h.handover_date) || '</td><td>'
          || CASE WHEN l_open > 0 THEN '<span class="nn-badge is-warning">' || l_open || '</span>' END || '</td><td>' || badge(h.status_code) || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد مواعيد تسليم</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody></table>');
  END handovers_html;

  FUNCTION sales_report_html(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
    t_v NUMBER := 0; t_c NUMBER := 0;
    l_c NUMBER;
  BEGIN
    guard('RE_SALE_CONTRACT.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>العقار</th><th class="n">الوحدات المباعة</th><th class="n">المساحة</th><th class="n">قيمة المبيعات</th>'
        || '<th class="n">متوسط سعر المتر</th><th class="n">الخصومات</th><th class="n">المحصل</th></tr></thead><tbody>';
    FOR r IN (SELECT u.property_id, COUNT(*) n, SUM(NVL(u.net_area_sqm, u.gross_area_sqm)) area, SUM(c.sale_price - c.discount_amount) val,
                     SUM(c.discount_amount) disc, LISTAGG(c.id, ',') WITHIN GROUP (ORDER BY c.id) ids
                FROM re_sale_contract c JOIN re_unit u ON u.id = c.unit_id
               WHERE c.company_id = company AND c.status_code NOT IN ('DRAFT', 'CANCELLED', 'TERMINATED') AND NVL(c.signed_date, c.doc_date) BETWEEN p_from AND p_to
               GROUP BY u.property_id) LOOP
      l_n := l_n + 1;
      l_c := 0;
      FOR x IN (SELECT TO_NUMBER(REGEXP_SUBSTR(r.ids, '[^,]+', 1, LEVEL)) id FROM dual CONNECT BY LEVEL <= REGEXP_COUNT(r.ids, ',') + 1) LOOP
        l_c := l_c + collected(x.id);
      END LOOP;
      t_v := t_v + r.val; t_c := t_c + l_c;
      l_h := l_h || ('<tr><td>' || esc(NOONA_RE_PKG.property_name(r.property_id)) || '</td><td class="n">' || r.n || '</td><td class="n">' || fmt(r.area)
          || '</td><td class="n">' || fmt(r.val) || '</td><td class="n">' || CASE WHEN r.area > 0 THEN fmt(r.val / r.area) END || '</td><td class="n">' || fmt(r.disc)
          || '</td><td class="n">' || fmt(l_c) || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد مبيعات في الفترة</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody><tfoot><tr><td colspan="3">الإجمالي</td><td class="n">' || fmt(t_v) || '</td><td></td><td></td><td class="n">' || fmt(t_c)
                    || '</td></tr></tfoot></table>');
  END sales_report_html;

  FUNCTION plans_html RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
    l_l VARCHAR2(4000);
  BEGIN
    guard('RE_PAYMENT_PLAN.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>الخطة</th><th>العقار</th><th class="n">الدفعة الأولى</th><th class="n">الأقساط</th><th>التكرار</th><th>التوزيع</th></tr></thead><tbody>';
    FOR p IN (SELECT * FROM re_payment_plan WHERE company_id = company AND is_active = 'Y' ORDER BY code) LOOP
      l_n := l_n + 1;
      SELECT LISTAGG(RTRIM(RTRIM(TO_CHAR(due_pct, 'FM990.99'), '0'), '.') || '%', ' · ') WITHIN GROUP (ORDER BY line_no) INTO l_l
        FROM re_payment_plan_line WHERE payment_plan_id = p.id AND line_no <= 8;
      l_h := l_h || ('<tr><td><b>' || esc(p.name_ar) || '</b></td><td>' || esc(NVL(NOONA_RE_PKG.property_name(p.property_id), 'كل العقارات')) || '</td><td class="n">'
          || pct(p.down_payment_pct) || '</td><td class="n">' || p.installments_count || '</td><td>'
          || CASE p.frequency WHEN 'MONTHLY' THEN 'شهري' WHEN 'QUARTERLY' THEN 'ربع سنوي' WHEN 'SEMI_ANNUAL' THEN 'نصف سنوي' WHEN 'ANNUAL' THEN 'سنوي' ELSE p.frequency END
          || '</td><td><small>' || esc(l_l) || '</small></td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد خطط سداد</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody></table>');
  END plans_html;

  FUNCTION price_lists_html RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('RE_PRICE_LIST.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>القائمة</th><th>العقار</th><th>من</th><th class="n">الوحدات</th><th class="n">متوسط السعر</th><th class="n">متوسط سعر المتر</th>'
        || '<th>الحالة</th></tr></thead><tbody>';
    FOR p IN (SELECT p.*, (SELECT COUNT(*) FROM re_price_list_line l WHERE l.price_list_id = p.id) n,
                     (SELECT AVG(base_price) FROM re_price_list_line l WHERE l.price_list_id = p.id) av,
                     (SELECT AVG(price_per_sqm) FROM re_price_list_line l WHERE l.price_list_id = p.id) sq
                FROM re_price_list p WHERE p.company_id = company ORDER BY p.id DESC) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr data-pl="' || p.id || '"><td><b>' || esc(p.name_ar) || '</b></td><td>' || esc(NOONA_RE_PKG.property_name(p.property_id)) || '</td><td>'
          || ds(p.effective_from) || '</td><td class="n">' || p.n || '</td><td class="n">' || fmt(p.av) || '</td><td class="n">' || fmt(p.sq) || '</td><td>'
          || badge(p.status_code) || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد قوائم أسعار</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody></table>');
  END price_lists_html;

  FUNCTION allocations_html(p_property_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('RE_COST_ALLOCATION.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>التاريخ</th><th>العقار</th><th>الأساس</th><th class="n">المبلغ المرسمل</th><th class="n">الوحدات</th><th>الحالة</th></tr></thead><tbody>';
    FOR a IN (SELECT a.*, (SELECT COUNT(*) FROM JSON_TABLE(a.details, '$[*]' COLUMNS (u NUMBER PATH '$.unit'))) n FROM re_cost_allocation a
               WHERE a.company_id = company AND (p_property_id IS NULL OR a.property_id = p_property_id) ORDER BY a.id DESC) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr><td>' || TO_CHAR(a.posted_at, 'YYYY-MM-DD') || '</td><td>' || esc(NOONA_RE_PKG.property_name(a.property_id)) || '</td><td>'
          || CASE a.allocation_basis WHEN 'AREA' THEN 'المساحة' WHEN 'SALE_VALUE' THEN 'سعر البيع' ELSE 'عدد الوحدات' END || '</td><td class="n">' || fmt(a.total_cost)
          || '</td><td class="n">' || a.n || '</td><td>' || badge(a.status_code) || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لم ترسمل تكاليف تطوير بعد</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody></table>');
  END allocations_html;
END NOONA_RES_PKG;
/
SHOW ERRORS PACKAGE BODY NOONA_RES_PKG
