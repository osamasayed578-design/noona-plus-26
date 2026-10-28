-- =============================================================================
-- NOONA PLUS ERP | NOONA_PRP_PKG - إدارة الأملاك والإيجارات
--   * اتفاقيات إدارة أملاك الغير (الأتعاب نسبة من المحصل أو ثابتة) وكشوف حسابات الملاك وتحويل صافيهم
--   * عقود الإيجار: الوحدات، البنود الإضافية (خدمات، مواقف، مرافق)، الدورية (شهري حتى سنوي أو مقدم)، الزيادة السنوية
--   * جدول الاستحقاقات يتولد عند التفعيل؛ الفوترة بفواتير مبيعات عادية (ذمم، تحصيل، ضريبة: السكني معفى والتجاري خاضع)
--     وإيراد أملاك الغير يقيد مستحقاً للمالك
--   * التأمين: الاستلام، ثم الرد ناقصاً الخصومات عند الإخلاء؛ التجديد والإنهاء والإخلاء والمعاينات؛ العدادات وفوترة الاستهلاك
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_PRP_PKG AUTHID DEFINER AS
  FUNCTION company RETURN NUMBER;
  -- حسابات الإيجارات (الإيجار 4150، الخدمات 4151، الأتعاب 4152، الخصومات 4153، استرداد مصروفات الملاك 4154،
  -- تأمينات المستأجرين 2153، مستحقات الملاك 2154)؛ يعيد عدد المنشأ
  FUNCTION setup_accounts RETURN NUMBER;
  FUNCTION status_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION charge_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION freq_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION lease_status(p_lease_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION has_deposit(p_lease_id IN NUMBER) RETURN VARCHAR2;

  -- ---------------------------------------------------------- اتفاقيات إدارة الأملاك
  -- {"id","owner":partyId | "ownerName","phone","property","feeType":"PCT_OF_COLLECTION|PCT_OF_RENT|FIXED_MONTHLY|MIXED","feePct","feeFixed",
  --  "remit":"MONTHLY|QUARTERLY","from","to"}
  FUNCTION save_agreement(p_doc IN CLOB) RETURN NUMBER;

  -- ---------------------------------------------------------- العقد
  -- {"id","type":"RESIDENTIAL|COMMERCIAL|RETAIL|INDUSTRIAL|LAND|PARKING","property","units":[ids],"tenant":partyId | "tenantName","phone","tax",
  --  "start","end","rent":annual,"freq":"MONTHLY|QUARTERLY|SEMI_ANNUAL|ANNUAL|UPFRONT","advance":"Y","deposit","escalation":5,"grace","notice",
  --  "registration","notes","charges":[{"type":"SERVICE_CHARGE","amount","freq":"MONTHLY|...|ONE_TIME"}]}
  FUNCTION save_lease(p_doc IN CLOB) RETURN NUMBER;
  -- التفعيل (التوقيع): جدول الاستحقاقات، الوحدات مؤجرة، والعقد السابق (عند التجديد) يصبح مجدداً
  PROCEDURE activate_lease(p_lease_id IN NUMBER, p_registration IN VARCHAR2 DEFAULT NULL);
  -- فوترة الاستحقاقات حتى تاريخ: فاتورة لكل عقد وتاريخ استحقاق؛ يعيد عدد الفواتير
  FUNCTION bill_rent(p_lease_id IN NUMBER DEFAULT NULL, p_as_of IN DATE DEFAULT NULL) RETURN NUMBER;
  PROCEDURE refresh_schedule(p_lease_id IN NUMBER DEFAULT NULL);
  -- استلام التأمين المحدد في العقد
  FUNCTION receive_deposit(p_lease_id IN NUMBER, p_place IN VARCHAR2, p_date IN DATE DEFAULT NULL) RETURN NUMBER;
  -- إنهاء مبكر أو إخلاء: تلغى الاستحقاقات بعد التاريخ، تتحرر الوحدات
  PROCEDURE terminate_lease(p_lease_id IN NUMBER, p_date IN DATE, p_reason IN VARCHAR2);
  -- تسوية التأمين: [{"reason","amount"}] خصومات، والباقي يرد من الصندوق أو البنك
  PROCEDURE settle_deposit(p_lease_id IN NUMBER, p_deductions IN CLOB, p_place IN VARCHAR2 DEFAULT NULL, p_date IN DATE DEFAULT NULL);
  -- تجديد: عقد جديد (مسودة) من نهاية الحالي بإيجار جديد؛ يعيد رقمه
  FUNCTION renew_lease(p_lease_id IN NUMBER, p_new_end IN DATE, p_new_rent IN NUMBER DEFAULT NULL) RETURN NUMBER;
  -- العقود المنتهية: تنتهي وتتحرر وحداتها؛ يعيد العدد
  FUNCTION expire_leases RETURN NUMBER;
  -- {"unit","lease","type":"MOVE_IN|MOVE_OUT|PERIODIC|COMPLAINT","date","items":[{"item","condition","note"}]}
  FUNCTION save_inspection(p_doc IN CLOB) RETURN NUMBER;

  -- ---------------------------------------------------------- العدادات
  -- {"id","unit","property","type":"ELECTRICITY|WATER|GAS|CHILLED_WATER","no","account","rate"}
  FUNCTION save_meter(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION add_reading(p_meter_id IN NUMBER, p_date IN DATE, p_value IN NUMBER) RETURN NUMBER;
  -- يضيف الاستهلاك غير المفوتر لجدول استحقاقات عقد الوحدة الساري؛ يعيد العدد
  FUNCTION bill_readings RETURN NUMBER;

  -- ---------------------------------------------------------- كشوف الملاك
  -- يحتسب المحصل للفترة وأتعاب الإدارة؛ p_expenses مصروفات دفعت عن المالك
  FUNCTION owner_statement(p_agreement_id IN NUMBER, p_from IN DATE, p_to IN DATE, p_expenses IN NUMBER DEFAULT 0) RETURN NUMBER;
  PROCEDURE approve_statement(p_statement_id IN NUMBER);
  PROCEDURE remit_statement(p_statement_id IN NUMBER, p_place IN VARCHAR2, p_date IN DATE DEFAULT NULL);
  FUNCTION statement_status(p_statement_id IN NUMBER) RETURN VARCHAR2;

  -- ---------------------------------------------------------- الشاشات
  FUNCTION summary_html RETURN CLOB;
  FUNCTION leases_html(p_status IN VARCHAR2 DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION lease_html(p_lease_id IN NUMBER) RETURN CLOB;
  FUNCTION schedule_html(p_lease_id IN NUMBER) RETURN CLOB;
  -- قائمة الإيجارات: كل وحدة وحالتها ومستأجرها وإيجارها
  FUNCTION rent_roll_html(p_property_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  FUNCTION expiring_html(p_days IN NUMBER DEFAULT 60, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION overdue_html RETURN CLOB;
  FUNCTION occupancy_html RETURN CLOB;
  FUNCTION agreements_html RETURN CLOB;
  FUNCTION statements_html(p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION statement_html(p_statement_id IN NUMBER) RETURN CLOB;
  FUNCTION meters_html(p_property_id IN NUMBER DEFAULT NULL) RETURN CLOB;
END NOONA_PRP_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_PRP_PKG AS

  c_lease CONSTANT VARCHAR2(30) := 'PRP_LEASE';
  c_dep   CONSTANT VARCHAR2(30) := 'PRP_SECURITY_DEPOSIT';
  c_stmt  CONSTANT VARCHAR2(30) := 'PRP_OWNER_STATEMENT';
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
      WHEN 'RENT' THEN ensure_account('4150', 'إيرادات الإيجارات', '4', 'REVENUE')
      WHEN 'SERVICE' THEN ensure_account('4151', 'إيرادات رسوم الخدمات والمرافق', '4', 'REVENUE')
      WHEN 'FEE' THEN ensure_account('4152', 'أتعاب إدارة الأملاك', '4', 'REVENUE')
      WHEN 'DEDUCT' THEN ensure_account('4153', 'إيرادات خصومات التأمين والغرامات', '4', 'REVENUE')
      WHEN 'RECOVER' THEN ensure_account('4154', 'استرداد مصروفات ملاك العقارات المدارة', '4', 'REVENUE')
      WHEN 'DEPOSIT' THEN ensure_account('2153', 'تأمينات المستأجرين', '21', 'LIABILITY')
      WHEN 'OWNER' THEN ensure_account('2154', 'مستحقات ملاك العقارات المدارة', '21', 'LIABILITY') END;
  END acc;

  FUNCTION setup_accounts RETURN NUMBER IS
    l_n NUMBER := 0;
    l_x NUMBER;
  BEGIN
    guard('PRP_LEASE.CREATE');
    FOR k IN (SELECT column_value c FROM TABLE(sys.odcivarchar2list('RENT:4150', 'SERVICE:4151', 'FEE:4152', 'DEDUCT:4153', 'RECOVER:4154',
                                                                  'DEPOSIT:2153', 'OWNER:2154'))) LOOP
      IF NOONA_INV_PKG.acc_id(SUBSTR(k.c, INSTR(k.c, ':') + 1)) IS NULL THEN
        l_x := acc(SUBSTR(k.c, 1, INSTR(k.c, ':') - 1));
        l_n := l_n + 1;
      END IF;
    END LOOP;
    RETURN l_n;
  END setup_accounts;

  FUNCTION next_no(p_type VARCHAR2, p_prefix VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT company, p_type, NULL, p_prefix, 1, 5, 'N', 'NEVER', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = p_type);
    RETURN NOONA_REFERENCE_PKG.next_doc_no(p_type, company, NULL, TRUNC(SYSDATE), p_type, NULL);
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
    RETURN CASE p_code WHEN 'DRAFT' THEN 'مسودة' WHEN 'APPROVED' THEN 'معتمد' WHEN 'SIGNED' THEN 'موقع' WHEN 'ACTIVE' THEN 'ساري'
      WHEN 'RENEWAL_PENDING' THEN 'بانتظار التجديد' WHEN 'RENEWED' THEN 'مجدد' WHEN 'EXPIRED' THEN 'منتهي' WHEN 'TERMINATED' THEN 'منهي'
      WHEN 'CANCELLED' THEN 'ملغى' WHEN 'SCHEDULED' THEN 'مجدول' WHEN 'INVOICED' THEN 'مفوتر' WHEN 'PARTIALLY_PAID' THEN 'مسدد جزئياً'
      WHEN 'PAID' THEN 'مسدد' WHEN 'OVERDUE' THEN 'متأخر' WHEN 'WAIVED' THEN 'معفى' WHEN 'HELD' THEN 'محتفظ به'
      WHEN 'PARTIALLY_REFUNDED' THEN 'رد جزئي' WHEN 'REFUNDED' THEN 'مردود' WHEN 'FORFEITED' THEN 'مصادر' WHEN 'APPLIED' THEN 'مطبق'
      WHEN 'SENT' THEN 'مرسل' WHEN 'REMITTED' THEN 'محول للمالك' WHEN 'SUSPENDED' THEN 'موقوف' WHEN 'DONE' THEN 'منفذة' ELSE p_code END;
  END status_label;

  FUNCTION badge(p_code VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<span class="nn-badge ' || CASE WHEN p_code IN ('ACTIVE', 'PAID', 'REFUNDED', 'REMITTED', 'RENEWED', 'HELD', 'DONE') THEN 'is-success'
                                            WHEN p_code IN ('OVERDUE', 'TERMINATED', 'CANCELLED', 'EXPIRED', 'FORFEITED') THEN 'is-danger'
                                            WHEN p_code IN ('INVOICED', 'APPROVED', 'PARTIALLY_PAID', 'SENT', 'SIGNED') THEN 'is-info'
                                            WHEN p_code IN ('WAIVED') THEN 'is-muted' ELSE 'is-warning' END || '">' || esc(status_label(p_code)) || '</span>';
  END badge;

  FUNCTION charge_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'RENT' THEN 'الإيجار' WHEN 'SERVICE_CHARGE' THEN 'رسوم الخدمات' WHEN 'UTILITIES' THEN 'المرافق (كهرباء وماء)'
      WHEN 'PARKING' THEN 'المواقف' WHEN 'MAINTENANCE' THEN 'الصيانة' WHEN 'MANAGEMENT_FEE' THEN 'رسوم الإدارة' WHEN 'PENALTY' THEN 'غرامة'
      ELSE 'أخرى' END;
  END charge_label;

  FUNCTION freq_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'MONTHLY' THEN 'شهري' WHEN 'QUARTERLY' THEN 'ربع سنوي' WHEN 'SEMI_ANNUAL' THEN 'نصف سنوي' WHEN 'ANNUAL' THEN 'سنوي'
      WHEN 'UPFRONT' THEN 'مقدماً دفعة واحدة' WHEN 'ONE_TIME' THEN 'مرة واحدة' WHEN 'METERED' THEN 'حسب العداد' ELSE p_code END;
  END freq_label;

  FUNCTION months_of(p_freq VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN CASE p_freq WHEN 'QUARTERLY' THEN 3 WHEN 'SEMI_ANNUAL' THEN 6 WHEN 'ANNUAL' THEN 12 ELSE 1 END;
  END months_of;

  -- السكني معفى، والتجاري والصناعي والتجزئة والمواقف خاضعة
  FUNCTION tax_code_for(p_type VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_type = 'RESIDENTIAL' THEN 'VATEX' ELSE 'VAT15' END;
  END tax_code_for;

  FUNCTION get_lease(p_id NUMBER, p_lock BOOLEAN DEFAULT FALSE) RETURN prp_lease%ROWTYPE IS
    l prp_lease%ROWTYPE;
  BEGIN
    IF p_lock THEN
      SELECT * INTO l FROM prp_lease WHERE id = p_id AND company_id = company FOR UPDATE;
    ELSE
      SELECT * INTO l FROM prp_lease WHERE id = p_id AND company_id = company;
    END IF;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRP-001', 'عقد الإيجار غير موجود', 'Lease not found');
  END get_lease;

  FUNCTION lease_status(p_lease_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM prp_lease WHERE id = p_lease_id AND company_id = company;
    RETURN l;
  END lease_status;

  FUNCTION has_deposit(p_lease_id IN NUMBER) RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM prp_security_deposit WHERE lease_id = p_lease_id AND status_code = 'HELD';
    RETURN CASE WHEN l > 0 THEN 'Y' ELSE 'N' END;
  END has_deposit;

  FUNCTION party_of(p_o JSON_OBJECT_T, p_id_key VARCHAR2, p_name_key VARCHAR2, p_role VARCHAR2) RETURN NUMBER IS
    l_party NUMBER := jn(p_o, p_id_key);
    l_acc   NUMBER;
  BEGIN
    IF l_party IS NULL AND js(p_o, p_name_key) IS NOT NULL THEN
      IF p_role = 'CUSTOMER' THEN
        l_acc := NOONA_SAL_PKG.save_customer(JSON_OBJECT('name' VALUE js(p_o, p_name_key), 'phone' VALUE js(p_o, 'phone'), 'tax' VALUE js(p_o, 'tax'),
                                                         'person' VALUE NVL(js(p_o, 'person'), 'Y'), 'term' VALUE 'NET0'));
        l_party := NOONA_SAL_PKG.customer_party(l_acc);
      ELSE
        l_party := NOONA_PTY_PKG.create_party(NVL(js(p_o, 'partyType'), 'PERSON'), js(p_o, p_name_key), p_role);
      END IF;
    END IF;
    RETURN l_party;
  END party_of;

  -- ================================================================ اتفاقيات الإدارة
  FUNCTION save_agreement(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id    NUMBER := jn(l_o, 'id');
    l_owner NUMBER := party_of(l_o, 'owner', 'ownerName', 'OWNER');
    l_prop  NUMBER := jn(l_o, 'property');
    l_type  VARCHAR2(30) := NVL(js(l_o, 'feeType'), 'PCT_OF_COLLECTION');
    l_pct   NUMBER := jn(l_o, 'feePct');
    l_fix   NUMBER := jn(l_o, 'feeFixed');
    l_rem   VARCHAR2(30) := NVL(js(l_o, 'remit'), 'MONTHLY');
    l_from  DATE := NVL(jd(l_o, 'from'), TRUNC(SYSDATE));
    l_to    DATE := jd(l_o, 'to');
    l_no    VARCHAR2(50);
  BEGIN
    guard('PRP_MANAGEMENT_AGREEMENT.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_owner IS NOT NULL AND l_prop IS NOT NULL, 'NOONA-PRP-010', 'اختر المالك والعقار', 'Owner and property are required');
    NOONA_CORE_PKG.assert((l_type IN ('PCT_OF_COLLECTION', 'PCT_OF_RENT') AND l_pct BETWEEN 0 AND 50) OR (l_type = 'FIXED_MONTHLY' AND l_fix > 0)
                          OR (l_type = 'MIXED' AND l_pct >= 0 AND l_fix >= 0), 'NOONA-PRP-011', 'حدد نسبة الأتعاب (حتى 50%) أو المبلغ الثابت',
                          'Fee percent or fixed amount is required');
    IF l_id IS NULL THEN
      l_no := next_no('PRP_MANAGEMENT_AGREEMENT', 'PMA-');
      INSERT INTO prp_management_agreement (company_id, doc_no, doc_date, owner_party_id, property_id, fee_type, fee_pct, fee_fixed, currency_code,
                                            remit_frequency, status_code, effective_from, effective_to)
      VALUES (company, l_no, TRUNC(SYSDATE), l_owner, l_prop, l_type, l_pct, l_fix, NOONA_GL_PKG.ledger_currency, l_rem, 'ACTIVE', l_from, l_to)
      RETURNING id INTO l_id;
    ELSE
      UPDATE prp_management_agreement SET fee_type = l_type, fee_pct = l_pct, fee_fixed = l_fix, remit_frequency = l_rem, effective_from = l_from,
                                          effective_to = l_to
       WHERE id = l_id AND company_id = company;
    END IF;
    UPDATE re_property SET management_mode = 'MANAGED_FOR_OWNER', owner_party_id = l_owner WHERE id = l_prop AND company_id = company;
    RETURN l_id;
  END save_agreement;

  FUNCTION agreement_for(p_property NUMBER, p_date DATE) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) INTO l FROM prp_management_agreement
     WHERE property_id = p_property AND company_id = company AND status_code = 'ACTIVE'
       AND effective_from <= p_date AND (effective_to IS NULL OR effective_to >= p_date);
    RETURN l;
  END agreement_for;

  -- ================================================================ العقد
  FUNCTION save_lease(p_doc IN CLOB) RETURN NUMBER IS
    l_o      JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id     NUMBER := jn(l_o, 'id');
    l_prop   NUMBER := jn(l_o, 'property');
    l_type   VARCHAR2(30) := NVL(js(l_o, 'type'), 'RESIDENTIAL');
    l_tenant NUMBER;
    l_start  DATE := jd(l_o, 'start');
    l_end    DATE := jd(l_o, 'end');
    l_rent   NUMBER := jn(l_o, 'rent');
    l_freq   VARCHAR2(30) := NVL(js(l_o, 'freq'), 'MONTHLY');
    l_adv    VARCHAR2(1) := NVL(js(l_o, 'advance'), 'Y');
    l_dep    NUMBER := NVL(jn(l_o, 'deposit'), 0);
    l_esc    NUMBER := jn(l_o, 'escalation');
    l_grace  NUMBER := jn(l_o, 'grace');
    l_notice NUMBER := jn(l_o, 'notice');
    l_reg    VARCHAR2(100) := js(l_o, 'registration');
    l_notes  VARCHAR2(1000) := js(l_o, 'notes');
    l_prev   NUMBER := jn(l_o, 'previous');
    l_cust   NUMBER;
    l_st     VARCHAR2(30);
    l_n      NUMBER;
    l_units  PLS_INTEGER := 0;
    l_no     VARCHAR2(50);
    l_agr    NUMBER;
    l_esc_j  VARCHAR2(200);
    l_tc     NUMBER;
    l_unit   re_unit%ROWTYPE;
  BEGIN
    guard('PRP_LEASE.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_prop IS NOT NULL, 'NOONA-PRP-020', 'اختر العقار', 'Property is required');
    NOONA_CORE_PKG.assert(l_start IS NOT NULL AND l_end > l_start, 'NOONA-PRP-021', 'تاريخ النهاية بعد البداية', 'End date must be after start');
    NOONA_CORE_PKG.assert(NVL(l_rent, 0) > 0, 'NOONA-PRP-022', 'أدخل الإيجار السنوي', 'Annual rent is required');
    NOONA_CORE_PKG.assert(l_freq IN ('MONTHLY', 'QUARTERLY', 'SEMI_ANNUAL', 'ANNUAL', 'UPFRONT'), 'NOONA-PRP-023', 'دورية الفوترة غير صحيحة', 'Invalid frequency');
    NOONA_CORE_PKG.assert(l_esc IS NULL OR l_esc BETWEEN 0 AND 50, 'NOONA-PRP-024', 'الزيادة السنوية بين 0 و50%', 'Escalation 0-50%');
    l_tenant := party_of(l_o, 'tenant', 'tenantName', 'CUSTOMER');
    NOONA_CORE_PKG.assert(l_tenant IS NOT NULL, 'NOONA-PRP-025', 'اختر المستأجر أو أدخل اسمه', 'Tenant is required');
    l_cust := NOONA_SAL_PKG.party_account(l_tenant);
    l_agr := agreement_for(l_prop, l_start);
    l_esc_j := CASE WHEN l_esc > 0 THEN '{"type":"PCT","pct":' || TO_CHAR(l_esc, 'FM990.99', 'NLS_NUMERIC_CHARACTERS=''.,''') || ',"every":12}' END;
    IF l_id IS NULL THEN
      l_no := next_no('PRP_LEASE', 'LS-');
      INSERT INTO prp_lease (company_id, doc_no, doc_date, currency_code, exchange_rate, lease_type, property_id, lessee_party_id, customer_account_id,
                             management_agreement_id, start_date, end_date, billing_frequency, billing_in_advance, annual_rent, deposit_amount, escalation_rule,
                             notice_days, grace_days, registration_no, previous_lease_id, notes, status_code)
      VALUES (company, l_no, TRUNC(SYSDATE), NOONA_GL_PKG.ledger_currency, 1, l_type, l_prop, l_tenant, l_cust, l_agr, l_start, l_end, l_freq, l_adv,
              l_rent, l_dep, l_esc_j, l_notice, l_grace, l_reg, l_prev, l_notes, 'DRAFT')
      RETURNING id INTO l_id;
    ELSE
      SELECT status_code INTO l_st FROM prp_lease WHERE id = l_id AND company_id = company FOR UPDATE;
      NOONA_CORE_PKG.assert(l_st = 'DRAFT', 'NOONA-PRP-026', 'لا يعدل العقد بعد تفعيله؛ استخدم التجديد أو الإنهاء', 'Only draft leases can be edited');
      UPDATE prp_lease SET lease_type = l_type, property_id = l_prop, lessee_party_id = l_tenant, customer_account_id = l_cust,
                           management_agreement_id = l_agr, start_date = l_start, end_date = l_end, billing_frequency = l_freq,
                           billing_in_advance = l_adv, annual_rent = l_rent, deposit_amount = l_dep, escalation_rule = l_esc_j, notice_days = l_notice,
                           grace_days = l_grace, registration_no = l_reg, notes = l_notes
       WHERE id = l_id;
      DELETE FROM prp_lease_unit WHERE lease_id = l_id;
      DELETE FROM prp_lease_charge WHERE lease_id = l_id;
    END IF;
    FOR u IN (SELECT DISTINCT TO_NUMBER(v) unit_ref FROM JSON_TABLE(p_doc, '$.units[*]' COLUMNS (v VARCHAR2(30) PATH '$'))) LOOP
      SELECT * INTO l_unit FROM re_unit WHERE id = u.unit_ref AND company_id = company;
      NOONA_CORE_PKG.assert(l_unit.property_id = l_prop, 'NOONA-PRP-027', 'الوحدة ' || l_unit.code || ' ليست في هذا العقار', 'Unit is not in the property');
      NOONA_CORE_PKG.assert(l_unit.usage_type IN ('LEASE', 'MIXED', 'OWNER_USE') AND l_unit.status_code NOT IN ('SOLD', 'HANDED_OVER', 'BLOCKED'),
                            'NOONA-PRP-028', 'الوحدة ' || l_unit.code || ' غير معروضة للتأجير', 'Unit is not for lease');
      -- لا تؤجر الوحدة لعقدين ساريين متداخلين
      SELECT COUNT(*) INTO l_n FROM prp_lease_unit x JOIN prp_lease s ON s.id = x.lease_id
       WHERE x.unit_id = u.unit_ref AND s.id <> l_id AND s.status_code IN ('SIGNED', 'ACTIVE', 'RENEWAL_PENDING')
         AND s.start_date <= l_end AND NVL(s.move_out_date, s.end_date) >= l_start
         AND NVL(s.id, -1) <> NVL(l_prev, -2);
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PRP-029', 'الوحدة ' || l_unit.code || ' مؤجرة بعقد ساري في نفس الفترة', 'Unit is leased in the same period');
      INSERT INTO prp_lease_unit (company_id, lease_id, unit_id, effective_from, effective_to) VALUES (company, l_id, u.unit_ref, l_start, l_end);
      l_units := l_units + 1;
    END LOOP;
    NOONA_CORE_PKG.assert(l_units > 0, 'NOONA-PRP-030', 'اختر وحدة واحدة على الأقل', 'Select at least one unit');
    UPDATE prp_lease_unit SET rent_share = ROUND(l_rent / l_units, 2) WHERE lease_id = l_id;
    l_tc := NOONA_INV_PKG.tax_id(tax_code_for(l_type));
    INSERT INTO prp_lease_charge (company_id, lease_id, charge_type, amount, frequency, tax_code_id, effective_from, effective_to)
    VALUES (company, l_id, 'RENT', l_rent, l_freq, l_tc, l_start, l_end);
    FOR c IN (SELECT * FROM JSON_TABLE(p_doc, '$.charges[*]' COLUMNS (tp VARCHAR2(30) PATH '$.type', amt NUMBER PATH '$.amount', fq VARCHAR2(30) PATH '$.freq'))) LOOP
      CONTINUE WHEN NVL(c.amt, 0) <= 0;
      NOONA_CORE_PKG.assert(c.tp IN ('SERVICE_CHARGE', 'UTILITIES', 'PARKING', 'MAINTENANCE', 'MANAGEMENT_FEE', 'PENALTY', 'OTHER')
                            AND NVL(c.fq, 'MONTHLY') IN ('MONTHLY', 'QUARTERLY', 'SEMI_ANNUAL', 'ANNUAL', 'ONE_TIME'), 'NOONA-PRP-031',
                            'نوع البند أو تكراره غير صحيح', 'Invalid charge');
      -- المبلغ للفترة حسب تكرار البند
      INSERT INTO prp_lease_charge (company_id, lease_id, charge_type, amount, frequency, tax_code_id, effective_from, effective_to)
      VALUES (company, l_id, c.tp, c.amt, NVL(c.fq, 'MONTHLY'), l_tc, l_start, l_end);
    END LOOP;
    RETURN l_id;
  END save_lease;

  PROCEDURE add_row(p_lease prp_lease%ROWTYPE, p_charge NUMBER, p_from DATE, p_to DATE, p_due DATE, p_amount NUMBER, p_tc NUMBER, p_desc VARCHAR2) IS
    l_rate NUMBER := NVL(NOONA_INV_PKG.tax_rate(p_tc, p_due), 0);
  BEGIN
    IF ROUND(p_amount, 2) <= 0 THEN RETURN; END IF;
    INSERT INTO prp_rent_schedule (company_id, lease_id, charge_id, period_from, period_to, due_date, amount, tax_amount, description, status_code)
    VALUES (company, p_lease.id, p_charge, p_from, p_to, p_due, ROUND(p_amount, 2), ROUND(p_amount * l_rate / 100, 2), SUBSTR(p_desc, 1, 200), 'SCHEDULED');
  END add_row;

  PROCEDURE generate_schedule(p_lease prp_lease%ROWTYPE) IS
    l_m     NUMBER;
    l_from  DATE;
    l_to    DATE;
    l_full  DATE;
    l_year  NUMBER;
    l_esc   NUMBER := 0;
    l_amt   NUMBER;
    l_k     PLS_INTEGER;
  BEGIN
    IF p_lease.escalation_rule IS NOT NULL THEN
      l_esc := NVL(JSON_VALUE(p_lease.escalation_rule, '$.pct' RETURNING NUMBER), 0);
    END IF;
    FOR c IN (SELECT * FROM prp_lease_charge WHERE lease_id = p_lease.id ORDER BY CASE charge_type WHEN 'RENT' THEN 0 ELSE 1 END, id) LOOP
      IF c.frequency = 'ONE_TIME' THEN
        add_row(p_lease, c.id, p_lease.start_date, p_lease.start_date, p_lease.start_date, c.amount, c.tax_code_id, charge_label(c.charge_type));
        CONTINUE;
      END IF;
      CONTINUE WHEN c.frequency = 'METERED';
      -- الإيجار سنوي يقسم على الفترات، والبنود الأخرى مبلغها للفترة
      l_m := CASE WHEN c.frequency = 'UPFRONT' THEN MONTHS_BETWEEN(p_lease.end_date + 1, p_lease.start_date) ELSE months_of(c.frequency) END;
      l_from := p_lease.start_date;
      l_k := 0;
      WHILE l_from <= p_lease.end_date LOOP
        l_k := l_k + 1;
        EXIT WHEN l_k > 400;
        l_full := ADD_MONTHS(l_from, CEIL(l_m)) - 1;
        l_to := LEAST(l_full, p_lease.end_date);
        l_year := TRUNC(MONTHS_BETWEEN(l_from, p_lease.start_date) / 12);
        l_amt := CASE WHEN c.charge_type = 'RENT' THEN c.amount * l_m / 12 ELSE c.amount END
               * POWER(1 + l_esc / 100, CASE WHEN c.charge_type = 'RENT' THEN l_year ELSE 0 END);
        -- فترة أخيرة ناقصة: بنسبة الأيام
        IF l_to < l_full THEN
          l_amt := l_amt * (l_to - l_from + 1) / (l_full - l_from + 1);
        END IF;
        add_row(p_lease, c.id, l_from, l_to, CASE WHEN p_lease.billing_in_advance = 'Y' THEN l_from ELSE l_to END, l_amt, c.tax_code_id,
                charge_label(c.charge_type) || ' ' || ds(l_from) || ' إلى ' || ds(l_to));
        l_from := l_to + 1;
      END LOOP;
    END LOOP;
  END generate_schedule;

  PROCEDURE activate_lease(p_lease_id IN NUMBER, p_registration IN VARCHAR2 DEFAULT NULL) IS
    l   prp_lease%ROWTYPE := get_lease(p_lease_id, TRUE);
    l_n NUMBER;
    l_x NUMBER;
  BEGIN
    guard('PRP_LEASE.APPROVE');
    NOONA_CORE_PKG.assert(l.status_code IN ('DRAFT', 'APPROVED'), 'NOONA-PRP-032', 'العقد ' || status_label(l.status_code), 'Lease is not a draft');
    SELECT COUNT(*) INTO l_n FROM prp_lease_unit WHERE lease_id = l.id;
    NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-PRP-030', 'اختر وحدة واحدة على الأقل', 'Select at least one unit');
    l_x := acc('RENT') + acc('SERVICE') + acc('OWNER');
    generate_schedule(l);
    UPDATE prp_lease SET status_code = 'ACTIVE', registration_no = NVL(p_registration, registration_no),
                         move_in_date = CASE WHEN start_date <= TRUNC(SYSDATE) THEN start_date END
     WHERE id = l.id;
    UPDATE re_unit SET status_code = 'LEASED' WHERE id IN (SELECT unit_id FROM prp_lease_unit WHERE lease_id = l.id)
       AND status_code IN ('AVAILABLE', 'RESERVED', 'LEASED', 'OCCUPIED');
    IF l.previous_lease_id IS NOT NULL THEN
      UPDATE prp_lease SET status_code = 'RENEWED' WHERE id = l.previous_lease_id AND status_code IN ('ACTIVE', 'RENEWAL_PENDING', 'EXPIRED');
    END IF;
    NOONA_AUDIT_PKG.log_event('APPROVAL', c_lease, l.id, 'ACTIVATE', 'SUCCESS');
    NOONA_API_PKG.publish('PRP_LEASE.ACTIVATED', c_lease, l.id);
  END activate_lease;

  PROCEDURE refresh_schedule(p_lease_id IN NUMBER DEFAULT NULL) IS
    l_open  NUMBER;
    l_total NUMBER;
  BEGIN
    FOR r IN (SELECT s.sales_invoice_id, MIN(l.grace_days) grace, MIN(s.due_date) due FROM prp_rent_schedule s JOIN prp_lease l ON l.id = s.lease_id
               WHERE l.company_id = company AND (p_lease_id IS NULL OR l.id = p_lease_id) AND s.sales_invoice_id IS NOT NULL
                 AND s.status_code NOT IN ('PAID', 'CANCELLED', 'WAIVED')
               GROUP BY s.sales_invoice_id) LOOP
      SELECT NVL(SUM(open_amount), 0) INTO l_open FROM ar_open_item WHERE source_entity_type = 'SAL_INVOICE' AND source_entity_id = r.sales_invoice_id;
      SELECT total_amount INTO l_total FROM sal_invoice WHERE id = r.sales_invoice_id;
      UPDATE prp_rent_schedule
         SET status_code = CASE WHEN l_open <= 0 THEN 'PAID' WHEN l_open < l_total THEN 'PARTIALLY_PAID'
                                WHEN r.due + NVL(r.grace, 0) < TRUNC(SYSDATE) THEN 'OVERDUE' ELSE 'INVOICED' END
       WHERE sales_invoice_id = r.sales_invoice_id AND status_code NOT IN ('CANCELLED', 'WAIVED');
    END LOOP;
  END refresh_schedule;

  FUNCTION bill_rent(p_lease_id IN NUMBER DEFAULT NULL, p_as_of IN DATE DEFAULT NULL) RETURN NUMBER IS
    l_as    DATE := LEAST(NVL(p_as_of, TRUNC(SYSDATE)), TRUNC(SYSDATE));
    l_n     NUMBER := 0;
    l_arr   JSON_ARRAY_T;
    l_o     JSON_OBJECT_T;
    l_inv   NUMBER;
    l_tc    VARCHAR2(30);
    l_acc   VARCHAR2(10);
    l_ids   SYS.ODCINUMBERLIST;
    l_x     NUMBER;
    l_units VARCHAR2(400);
  BEGIN
    guard('PRP_LEASE.UPDATE');
    l_x := acc('RENT') + acc('SERVICE') + acc('OWNER');
    FOR g IN (SELECT s.lease_id, s.due_date, l.customer_account_id, l.lease_type, l.management_agreement_id, l.doc_no
                FROM prp_rent_schedule s JOIN prp_lease l ON l.id = s.lease_id
               WHERE l.company_id = company AND (p_lease_id IS NULL OR l.id = p_lease_id)
                 AND l.status_code IN ('ACTIVE', 'RENEWAL_PENDING', 'RENEWED', 'EXPIRED', 'TERMINATED')
                 AND s.status_code = 'SCHEDULED' AND s.due_date <= l_as
               GROUP BY s.lease_id, s.due_date, l.customer_account_id, l.lease_type, l.management_agreement_id, l.doc_no
               ORDER BY s.lease_id, s.due_date) LOOP
      SELECT LISTAGG(u.code, '، ') WITHIN GROUP (ORDER BY u.code) INTO l_units FROM prp_lease_unit x JOIN re_unit u ON u.id = x.unit_id WHERE x.lease_id = g.lease_id;
      l_arr := JSON_ARRAY_T();
      l_ids := SYS.ODCINUMBERLIST();
      l_tc := tax_code_for(g.lease_type);
      FOR s IN (SELECT s.id, s.amount, s.description, c.charge_type FROM prp_rent_schedule s LEFT JOIN prp_lease_charge c ON c.id = s.charge_id
                 WHERE s.lease_id = g.lease_id AND s.due_date = g.due_date AND s.status_code = 'SCHEDULED' ORDER BY s.id) LOOP
        -- إيجار أملاك الغير مستحق لمالكه؛ إيرادنا فيه أتعاب الإدارة عند كشف المالك
        l_acc := CASE WHEN g.management_agreement_id IS NOT NULL AND NVL(s.charge_type, 'RENT') = 'RENT' THEN '2154'
                      WHEN NVL(s.charge_type, 'RENT') = 'RENT' THEN '4150' ELSE '4151' END;
        l_o := JSON_OBJECT_T();
        l_o.put('d', s.description || ' - ' || g.doc_no || ' - ' || l_units);
        l_o.put('q', 1); l_o.put('p', s.amount); l_o.put('inc', 'N'); l_o.put('tc', l_tc); l_o.put('acc', l_acc);
        l_arr.append(l_o);
        l_ids.EXTEND; l_ids(l_ids.COUNT) := s.id;
      END LOOP;
      l_o := JSON_OBJECT_T();
      l_o.put('cust', g.customer_account_id); l_o.put('date', ds(g.due_date)); l_o.put('mode', 'CREDIT'); l_o.put('action', 'POST');
      l_o.put('lines', l_arr);
      l_inv := NOONA_SAL_PKG.save_invoice(l_o.to_clob);
      FORALL i IN 1 .. l_ids.COUNT
        UPDATE prp_rent_schedule SET sales_invoice_id = l_inv, status_code = 'INVOICED',
                                     ar_open_item_id = (SELECT MIN(id) FROM ar_open_item WHERE source_entity_type = 'SAL_INVOICE' AND source_entity_id = l_inv)
         WHERE id = l_ids(i);
      l_n := l_n + 1;
    END LOOP;
    refresh_schedule(p_lease_id);
    RETURN l_n;
  END bill_rent;

  FUNCTION receive_deposit(p_lease_id IN NUMBER, p_place IN VARCHAR2, p_date IN DATE DEFAULT NULL) RETURN NUMBER IS
    l       prp_lease%ROWTYPE := get_lease(p_lease_id);
    l_id    NUMBER;
    l_n     NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_ev    NUMBER;
    l_x     NUMBER;
    l_name  VARCHAR2(400);
    l_date  DATE := NVL(p_date, TRUNC(SYSDATE));
  BEGIN
    guard('PRP_SECURITY_DEPOSIT.CREATE');
    NOONA_CORE_PKG.assert(l.deposit_amount > 0, 'NOONA-PRP-040', 'لا يوجد تأمين في العقد', 'Lease has no deposit');
    NOONA_CORE_PKG.assert(p_place IS NOT NULL, 'NOONA-PRP-041', 'اختر الصندوق أو البنك', 'Choose the cash box or bank');
    SELECT COUNT(*) INTO l_n FROM prp_security_deposit WHERE lease_id = l.id AND status_code <> 'REFUNDED';
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PRP-042', 'التأمين مستلم سابقاً', 'Deposit already received');
    SELECT display_name_ar INTO l_name FROM pty_party WHERE id = l.lessee_party_id;
    INSERT INTO prp_security_deposit (company_id, currency_code, exchange_rate, lease_id, received_amount, deducted_amount, refunded_amount, place, status_code)
    VALUES (company, l.currency_code, 1, l.id, l.deposit_amount, 0, 0, p_place, 'HELD')
    RETURNING id INTO l_id;
    add_line(l_lines, NOONA_CSH_PKG.place_account(p_place), l.deposit_amount, 0, NULL, 'تأمين عقد إيجار ' || l.doc_no || ' - ' || l_name);
    add_line(l_lines, acc('DEPOSIT'), 0, l.deposit_amount, l.lessee_party_id, 'تأمين المستأجر ' || l_name || ' - ' || l.doc_no);
    l_ev := post('PRP_DEPOSIT_RECEIVED', c_dep, l_id, l_date, 'تأمين عقد إيجار ' || l.doc_no, l_lines, l.doc_no);
    l_x := NOONA_CSH_PKG.record_settlement('RECEIPT', p_place, l_date, l.deposit_amount, l.lessee_party_id, l_name, c_dep, l_id, 'DEP-' || l_id,
                                           'تأمين عقد إيجار', l_ev);
    UPDATE prp_security_deposit SET receipt_event_id = l_ev WHERE id = l_id;
    RETURN l_id;
  END receive_deposit;

  PROCEDURE release_units(p_lease_id NUMBER) IS
  BEGIN
    UPDATE re_unit u SET status_code = 'AVAILABLE'
     WHERE id IN (SELECT unit_id FROM prp_lease_unit WHERE lease_id = p_lease_id) AND status_code IN ('LEASED', 'OCCUPIED')
       AND NOT EXISTS (SELECT 1 FROM prp_lease_unit x JOIN prp_lease s ON s.id = x.lease_id
                        WHERE x.unit_id = u.id AND s.id <> p_lease_id AND s.status_code IN ('ACTIVE', 'RENEWAL_PENDING'));
  END release_units;

  PROCEDURE terminate_lease(p_lease_id IN NUMBER, p_date IN DATE, p_reason IN VARCHAR2) IS
    l prp_lease%ROWTYPE := get_lease(p_lease_id, TRUE);
  BEGIN
    guard('PRP_LEASE.APPROVE');
    NOONA_CORE_PKG.assert(l.status_code IN ('ACTIVE', 'RENEWAL_PENDING', 'SIGNED'), 'NOONA-PRP-043', 'العقد ' || status_label(l.status_code), 'Lease is not active');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL AND p_date IS NOT NULL, 'NOONA-PRP-044', 'حدد تاريخ الإخلاء والسبب', 'Date and reason are required');
    NOONA_CORE_PKG.assert(p_date >= l.start_date, 'NOONA-PRP-045', 'تاريخ الإنهاء قبل بداية العقد', 'Termination before lease start');
    UPDATE prp_rent_schedule SET status_code = 'CANCELLED' WHERE lease_id = l.id AND status_code = 'SCHEDULED' AND period_from > p_date;
    INSERT INTO prp_lease_event (company_id, lease_id, event_type, effective_date, reason, status_code)
    VALUES (company, l.id, CASE WHEN p_date < l.end_date THEN 'EARLY_TERMINATION' ELSE 'MOVE_OUT' END, p_date, p_reason, 'EFFECTIVE');
    UPDATE prp_lease SET status_code = 'TERMINATED', move_out_date = p_date, termination_reason = p_reason WHERE id = l.id;
    release_units(l.id);
  END terminate_lease;

  PROCEDURE settle_deposit(p_lease_id IN NUMBER, p_deductions IN CLOB, p_place IN VARCHAR2 DEFAULT NULL, p_date IN DATE DEFAULT NULL) IS
    d       prp_security_deposit%ROWTYPE;
    l       prp_lease%ROWTYPE := get_lease(p_lease_id);
    l_ded   NUMBER := 0;
    l_ref   NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_ev    NUMBER;
    l_x     NUMBER;
    l_name  VARCHAR2(400);
    l_date  DATE := NVL(p_date, TRUNC(SYSDATE));
    l_place VARCHAR2(30);
  BEGIN
    guard('PRP_SECURITY_DEPOSIT.UPDATE');
    BEGIN
      SELECT * INTO d FROM prp_security_deposit WHERE lease_id = l.id AND status_code = 'HELD' FOR UPDATE;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-PRP-046', 'لا يوجد تأمين محتفظ به لهذا العقد', 'No deposit held');
    END;
    NOONA_CORE_PKG.assert(l.status_code IN ('TERMINATED', 'EXPIRED', 'RENEWED'), 'NOONA-PRP-047', 'يسوى التأمين بعد انتهاء العقد أو إنهائه',
                          'Settle the deposit after the lease ends');
    IF p_deductions IS NOT NULL THEN
      SELECT NVL(SUM(amt), 0) INTO l_ded FROM JSON_TABLE(p_deductions, '$[*]' COLUMNS (amt NUMBER PATH '$.amount'));
    END IF;
    NOONA_CORE_PKG.assert(l_ded BETWEEN 0 AND d.received_amount, 'NOONA-PRP-048', 'الخصومات أكبر من التأمين (' || fmt(d.received_amount) || ')',
                          'Deductions exceed the deposit');
    l_ref := d.received_amount - l_ded;
    l_place := NVL(p_place, d.place);
    NOONA_CORE_PKG.assert(l_ref = 0 OR l_place IS NOT NULL, 'NOONA-PRP-041', 'اختر الصندوق أو البنك', 'Choose the cash box or bank');
    SELECT display_name_ar INTO l_name FROM pty_party WHERE id = l.lessee_party_id;
    add_line(l_lines, acc('DEPOSIT'), d.received_amount, 0, l.lessee_party_id, 'تسوية تأمين ' || l.doc_no || ' - ' || l_name);
    add_line(l_lines, acc('DEDUCT'), 0, l_ded, l.lessee_party_id, 'خصومات من التأمين (أضرار، مستحقات) - ' || l.doc_no);
    IF l_ref > 0 THEN
      add_line(l_lines, NOONA_CSH_PKG.place_account(l_place), 0, l_ref, NULL, 'رد تأمين ' || l.doc_no || ' - ' || l_name);
    END IF;
    l_ev := post('PRP_DEPOSIT_SETTLED', 'PRP_DEPOSIT_SETTLEMENT', d.id, l_date, 'تسوية تأمين عقد ' || l.doc_no, l_lines, l.doc_no);
    IF l_ref > 0 THEN
      l_x := NOONA_CSH_PKG.record_settlement('PAYMENT', l_place, l_date, l_ref, l.lessee_party_id, l_name, 'PRP_DEPOSIT_SETTLEMENT', d.id, 'DEPR-' || d.id,
                                             'رد تأمين مستأجر', l_ev);
    END IF;
    UPDATE prp_security_deposit SET deducted_amount = l_ded, refunded_amount = l_ref, deduction_details = p_deductions, refund_event_id = l_ev,
                                    status_code = CASE WHEN l_ref = 0 THEN 'FORFEITED' WHEN l_ded > 0 THEN 'PARTIALLY_REFUNDED' ELSE 'REFUNDED' END
     WHERE id = d.id;
  END settle_deposit;

  FUNCTION renew_lease(p_lease_id IN NUMBER, p_new_end IN DATE, p_new_rent IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l     prp_lease%ROWTYPE := get_lease(p_lease_id, TRUE);
    l_o   JSON_OBJECT_T := JSON_OBJECT_T();
    l_u   JSON_ARRAY_T := JSON_ARRAY_T();
    l_c   JSON_ARRAY_T := JSON_ARRAY_T();
    l_x   JSON_OBJECT_T;
    l_id  NUMBER;
    l_n   NUMBER;
  BEGIN
    guard('PRP_LEASE.CREATE');
    NOONA_CORE_PKG.assert(l.status_code IN ('ACTIVE', 'RENEWAL_PENDING', 'EXPIRED'), 'NOONA-PRP-050', 'يجدد العقد الساري أو المنتهي', 'Lease cannot be renewed');
    NOONA_CORE_PKG.assert(p_new_end > l.end_date, 'NOONA-PRP-051', 'نهاية التجديد بعد نهاية العقد الحالي (' || ds(l.end_date) || ')', 'Renewal must end after the current lease');
    SELECT COUNT(*) INTO l_n FROM prp_lease WHERE previous_lease_id = l.id AND status_code NOT IN ('CANCELLED');
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PRP-052', 'يوجد تجديد لهذا العقد', 'A renewal already exists');
    FOR u IN (SELECT unit_id FROM prp_lease_unit WHERE lease_id = l.id) LOOP
      l_u.append(u.unit_id);
    END LOOP;
    FOR c IN (SELECT charge_type, amount, frequency FROM prp_lease_charge WHERE lease_id = l.id AND charge_type <> 'RENT' AND frequency <> 'ONE_TIME') LOOP
      l_x := JSON_OBJECT_T();
      l_x.put('type', c.charge_type); l_x.put('amount', c.amount); l_x.put('freq', c.frequency);
      l_c.append(l_x);
    END LOOP;
    l_o.put('type', l.lease_type); l_o.put('property', l.property_id); l_o.put('tenant', l.lessee_party_id);
    l_o.put('start', ds(l.end_date + 1)); l_o.put('end', ds(p_new_end)); l_o.put('rent', NVL(p_new_rent, l.annual_rent));
    l_o.put('freq', l.billing_frequency); l_o.put('advance', l.billing_in_advance); l_o.put('deposit', 0);
    IF l.escalation_rule IS NOT NULL THEN l_o.put('escalation', JSON_VALUE(l.escalation_rule, '$.pct' RETURNING NUMBER)); END IF;
    l_o.put('grace', l.grace_days); l_o.put('notice', l.notice_days); l_o.put('previous', l.id);
    l_o.put('notes', 'تجديد العقد ' || l.doc_no);
    l_o.put('units', l_u); l_o.put('charges', l_c);
    l_id := save_lease(l_o.to_clob);
    UPDATE prp_lease SET status_code = 'RENEWAL_PENDING' WHERE id = l.id AND status_code = 'ACTIVE';
    RETURN l_id;
  END renew_lease;

  FUNCTION expire_leases RETURN NUMBER IS
    l_n NUMBER := 0;
  BEGIN
    guard('PRP_LEASE.UPDATE');
    FOR l IN (SELECT id FROM prp_lease WHERE company_id = company AND status_code IN ('ACTIVE', 'RENEWAL_PENDING') AND end_date < TRUNC(SYSDATE)
                 AND NOT EXISTS (SELECT 1 FROM prp_lease n WHERE n.previous_lease_id = prp_lease.id AND n.status_code = 'ACTIVE') FOR UPDATE) LOOP
      UPDATE prp_lease SET status_code = 'EXPIRED' WHERE id = l.id;
      release_units(l.id);
      l_n := l_n + 1;
    END LOOP;
    RETURN l_n;
  END expire_leases;

  FUNCTION save_inspection(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER;
    l_unit NUMBER := jn(l_o, 'unit');
    l_ls   NUMBER := jn(l_o, 'lease');
    l_type VARCHAR2(30) := NVL(js(l_o, 'type'), 'PERIODIC');
    l_date DATE := NVL(jd(l_o, 'date'), TRUNC(SYSDATE));
    l_rep  CLOB;
  BEGIN
    guard('PRP_INSPECTION.CREATE');
    NOONA_CORE_PKG.assert(l_unit IS NOT NULL, 'NOONA-PRP-053', 'اختر الوحدة', 'Unit is required');
    IF l_o.has('items') THEN l_rep := l_o.get('items').to_clob; END IF;
    INSERT INTO prp_inspection (company_id, unit_id, lease_id, inspection_type, inspection_date, condition_report, status_code)
    VALUES (company, l_unit, l_ls, l_type, l_date, l_rep, 'DONE')
    RETURNING id INTO l_id;
    RETURN l_id;
  END save_inspection;

  -- ================================================================ العدادات
  FUNCTION save_meter(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := jn(l_o, 'id');
    l_unit NUMBER := jn(l_o, 'unit');
    l_prop NUMBER := jn(l_o, 'property');
    l_type VARCHAR2(30) := NVL(js(l_o, 'type'), 'ELECTRICITY');
    l_no   VARCHAR2(100) := js(l_o, 'no');
    l_acc  VARCHAR2(100) := js(l_o, 'account');
    l_rate NUMBER := jn(l_o, 'rate');
  BEGIN
    guard('PRP_METER.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_no IS NOT NULL AND (l_unit IS NOT NULL OR l_prop IS NOT NULL), 'NOONA-PRP-060', 'رقم العداد والوحدة أو العقار مطلوبة',
                          'Meter number and unit or property are required');
    IF l_unit IS NOT NULL THEN
      SELECT property_id INTO l_prop FROM re_unit WHERE id = l_unit AND company_id = company;
    END IF;
    IF l_id IS NULL THEN
      INSERT INTO prp_meter (company_id, code, unit_id, property_id, meter_type, meter_no, utility_account_no, rate_per_unit, status_code)
      VALUES (company, l_no, l_unit, l_prop, l_type, l_no, l_acc, l_rate, 'ACTIVE')
      RETURNING id INTO l_id;
    ELSE
      UPDATE prp_meter SET unit_id = l_unit, property_id = l_prop, meter_type = l_type, meter_no = l_no, utility_account_no = l_acc, rate_per_unit = l_rate
       WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  END save_meter;

  FUNCTION add_reading(p_meter_id IN NUMBER, p_date IN DATE, p_value IN NUMBER) RETURN NUMBER IS
    l_prev NUMBER;
    l_pd   DATE;
    l_id   NUMBER;
  BEGIN
    guard('PRP_METER.UPDATE');
    SELECT MAX(reading_value) KEEP (DENSE_RANK LAST ORDER BY reading_date), MAX(reading_date) INTO l_prev, l_pd
      FROM prp_meter_reading WHERE meter_id = p_meter_id;
    NOONA_CORE_PKG.assert(l_pd IS NULL OR p_date > l_pd, 'NOONA-PRP-061', 'تاريخ القراءة بعد آخر قراءة (' || ds(l_pd) || ')', 'Reading date must follow the last reading');
    NOONA_CORE_PKG.assert(l_prev IS NULL OR p_value >= l_prev, 'NOONA-PRP-062', 'القراءة أقل من السابقة (' || l_prev || ')', 'Reading is below the previous one');
    INSERT INTO prp_meter_reading (company_id, meter_id, reading_date, reading_value, consumption, source_code)
    VALUES (company, p_meter_id, p_date, p_value, CASE WHEN l_prev IS NOT NULL THEN p_value - l_prev END, 'MANUAL')
    RETURNING id INTO l_id;
    RETURN l_id;
  END add_reading;

  FUNCTION bill_readings RETURN NUMBER IS
    l_n     NUMBER := 0;
    l_lease prp_lease%ROWTYPE;
    l_ls    NUMBER;
    l_rate  NUMBER;
    l_tc    NUMBER;
    l_id    NUMBER;
  BEGIN
    guard('PRP_LEASE.UPDATE');
    FOR r IN (SELECT r.id, r.reading_date, r.consumption, m.unit_id, m.rate_per_unit, m.meter_type, m.meter_no FROM prp_meter_reading r JOIN prp_meter m ON m.id = r.meter_id
               WHERE m.company_id = company AND r.consumption > 0 AND r.rent_schedule_id IS NULL AND m.rate_per_unit > 0 AND m.unit_id IS NOT NULL) LOOP
      SELECT MAX(s.id) INTO l_ls FROM prp_lease_unit x JOIN prp_lease s ON s.id = x.lease_id
       WHERE x.unit_id = r.unit_id AND s.status_code IN ('ACTIVE', 'RENEWAL_PENDING') AND r.reading_date BETWEEN s.start_date AND s.end_date;
      CONTINUE WHEN l_ls IS NULL;
      l_lease := get_lease(l_ls);
      l_tc := NOONA_INV_PKG.tax_id(tax_code_for(l_lease.lease_type));
      l_rate := NVL(NOONA_INV_PKG.tax_rate(l_tc, r.reading_date), 0);
      INSERT INTO prp_rent_schedule (company_id, lease_id, period_from, period_to, due_date, amount, tax_amount, description, status_code)
      VALUES (company, l_ls, r.reading_date, r.reading_date, TRUNC(SYSDATE), ROUND(r.consumption * r.rate_per_unit, 2),
              ROUND(r.consumption * r.rate_per_unit * l_rate / 100, 2),
              SUBSTR(CASE r.meter_type WHEN 'ELECTRICITY' THEN 'استهلاك الكهرباء' WHEN 'WATER' THEN 'استهلاك المياه' WHEN 'GAS' THEN 'استهلاك الغاز'
                                       ELSE 'استهلاك التبريد' END || ' ' || r.consumption || ' وحدة - عداد ' || r.meter_no, 1, 200), 'SCHEDULED')
      RETURNING id INTO l_id;
      UPDATE prp_meter_reading SET rent_schedule_id = l_id WHERE id = r.id;
      l_n := l_n + 1;
    END LOOP;
    RETURN l_n;
  END bill_readings;

  -- ================================================================ كشوف الملاك
  FUNCTION statement_status(p_statement_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM prp_owner_statement WHERE id = p_statement_id AND company_id = company;
    RETURN l;
  END statement_status;

  -- المحصل من إيجارات العقار المدار في الفترة: الجزء المسدد من فواتير الإيجار المستحقة فيها (صافي الضريبة)
  FUNCTION managed_collections(p_agreement NUMBER, p_from DATE, p_to DATE, p_rent OUT NUMBER) RETURN NUMBER IS
    l_col  NUMBER := 0;
    l_open NUMBER;
  BEGIN
    p_rent := 0;
    FOR i IN (SELECT s.sales_invoice_id, SUM(s.amount) rent, MIN(v.total_amount) total, MIN(v.subtotal) net
                FROM prp_rent_schedule s JOIN prp_lease l ON l.id = s.lease_id JOIN prp_lease_charge c ON c.id = s.charge_id
                JOIN sal_invoice v ON v.id = s.sales_invoice_id
               WHERE l.management_agreement_id = p_agreement AND c.charge_type = 'RENT' AND s.due_date BETWEEN p_from AND p_to
                 AND s.status_code NOT IN ('CANCELLED', 'WAIVED')
               GROUP BY s.sales_invoice_id) LOOP
      SELECT NVL(SUM(open_amount), 0) INTO l_open FROM ar_open_item WHERE source_entity_type = 'SAL_INVOICE' AND source_entity_id = i.sales_invoice_id;
      p_rent := p_rent + i.rent;
      l_col := l_col + ROUND(i.rent * (i.total - l_open) / NULLIF(i.total, 0), 2);
    END LOOP;
    RETURN NVL(l_col, 0);
  END managed_collections;

  FUNCTION owner_statement(p_agreement_id IN NUMBER, p_from IN DATE, p_to IN DATE, p_expenses IN NUMBER DEFAULT 0) RETURN NUMBER IS
    a      prp_management_agreement%ROWTYPE;
    l_col  NUMBER;
    l_rent NUMBER;
    l_fee  NUMBER;
    l_id   NUMBER;
    l_n    NUMBER;
    l_no   VARCHAR2(50);
    l_exp  NUMBER := NVL(p_expenses, 0);
  BEGIN
    guard('PRP_OWNER_STATEMENT.CREATE');
    SELECT * INTO a FROM prp_management_agreement WHERE id = p_agreement_id AND company_id = company;
    NOONA_CORE_PKG.assert(p_from IS NOT NULL AND p_to >= p_from AND l_exp >= 0, 'NOONA-PRP-070', 'حدد فترة صحيحة', 'Invalid period');
    SELECT COUNT(*) INTO l_n FROM prp_owner_statement WHERE management_agreement_id = a.id AND period_from <= p_to AND period_to >= p_from;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PRP-071', 'يوجد كشف للمالك يغطي جزءاً من الفترة', 'A statement already covers this period');
    refresh_schedule;
    l_col := managed_collections(a.id, p_from, p_to, l_rent);
    l_fee := ROUND(CASE a.fee_type WHEN 'PCT_OF_COLLECTION' THEN l_col * NVL(a.fee_pct, 0) / 100
                                   WHEN 'PCT_OF_RENT' THEN l_rent * NVL(a.fee_pct, 0) / 100
                                   WHEN 'FIXED_MONTHLY' THEN NVL(a.fee_fixed, 0) * GREATEST(1, ROUND(MONTHS_BETWEEN(p_to + 1, p_from)))
                                   ELSE l_col * NVL(a.fee_pct, 0) / 100 + NVL(a.fee_fixed, 0) * GREATEST(1, ROUND(MONTHS_BETWEEN(p_to + 1, p_from))) END, 2);
    l_no := next_no('PRP_OWNER_STATEMENT', 'OS-');
    INSERT INTO prp_owner_statement (company_id, doc_no, doc_date, management_agreement_id, period_from, period_to, collections, expenses, management_fee,
                                     net_to_owner, status_code)
    VALUES (company, l_no, TRUNC(SYSDATE), a.id, p_from, p_to, l_col, l_exp, l_fee, l_col - l_exp - l_fee, 'DRAFT')
    RETURNING id INTO l_id;
    RETURN l_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-PRP-072', 'اتفاقية الإدارة غير موجودة', 'Agreement not found');
  END owner_statement;

  PROCEDURE approve_statement(p_statement_id IN NUMBER) IS
    s       prp_owner_statement%ROWTYPE;
    a       prp_management_agreement%ROWTYPE;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_ev    NUMBER;
  BEGIN
    guard('PRP_OWNER_STATEMENT.APPROVE');
    SELECT * INTO s FROM prp_owner_statement WHERE id = p_statement_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(s.status_code = 'DRAFT', 'NOONA-PRP-073', 'الكشف معتمد سابقاً', 'Statement already approved');
    SELECT * INTO a FROM prp_management_agreement WHERE id = s.management_agreement_id;
    -- الأتعاب والمصروفات المستردة تخصم من مستحقات المالك
    add_line(l_lines, acc('OWNER'), s.management_fee + s.expenses, 0, a.owner_party_id, 'أتعاب ومصروفات كشف ' || s.doc_no);
    add_line(l_lines, acc('FEE'), 0, s.management_fee, a.owner_party_id, 'أتعاب إدارة ' || NOONA_RE_PKG.property_name(a.property_id) || ' - ' || s.doc_no);
    add_line(l_lines, acc('RECOVER'), 0, s.expenses, a.owner_party_id, 'مصروفات مدفوعة عن المالك - ' || s.doc_no);
    IF s.management_fee + s.expenses > 0 THEN
      l_ev := post('PRP_OWNER_FEE', c_stmt, s.id, s.period_to, 'كشف المالك ' || s.doc_no, l_lines, s.doc_no);
    END IF;
    UPDATE prp_owner_statement SET status_code = 'APPROVED', fee_event_id = l_ev WHERE id = s.id;
  END approve_statement;

  PROCEDURE remit_statement(p_statement_id IN NUMBER, p_place IN VARCHAR2, p_date IN DATE DEFAULT NULL) IS
    s       prp_owner_statement%ROWTYPE;
    a       prp_management_agreement%ROWTYPE;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_ev    NUMBER;
    l_x     NUMBER;
    l_name  VARCHAR2(400);
    l_date  DATE := NVL(p_date, TRUNC(SYSDATE));
  BEGIN
    guard('PRP_OWNER_STATEMENT.APPROVE');
    SELECT * INTO s FROM prp_owner_statement WHERE id = p_statement_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(s.status_code IN ('APPROVED', 'SENT'), 'NOONA-PRP-074', 'اعتمد الكشف قبل التحويل', 'Approve the statement first');
    NOONA_CORE_PKG.assert(s.net_to_owner > 0, 'NOONA-PRP-075', 'لا يوجد صاف مستحق للمالك', 'Nothing due to the owner');
    NOONA_CORE_PKG.assert(p_place IS NOT NULL, 'NOONA-PRP-041', 'اختر الصندوق أو البنك', 'Choose the cash box or bank');
    SELECT * INTO a FROM prp_management_agreement WHERE id = s.management_agreement_id;
    SELECT display_name_ar INTO l_name FROM pty_party WHERE id = a.owner_party_id;
    add_line(l_lines, acc('OWNER'), s.net_to_owner, 0, a.owner_party_id, 'تحويل صافي كشف ' || s.doc_no || ' - ' || l_name);
    add_line(l_lines, NOONA_CSH_PKG.place_account(p_place), 0, s.net_to_owner, NULL, 'تحويل للمالك ' || l_name || ' - ' || s.doc_no);
    l_ev := post('PRP_OWNER_REMITTED', 'PRP_OWNER_REMITTANCE', s.id, l_date, 'تحويل صافي المالك ' || s.doc_no, l_lines, s.doc_no);
    l_x := NOONA_CSH_PKG.record_settlement('PAYMENT', p_place, l_date, s.net_to_owner, a.owner_party_id, l_name, 'PRP_OWNER_REMITTANCE', s.id, s.doc_no,
                                           'تحويل صافي إيرادات المالك', l_ev);
    UPDATE prp_owner_statement SET status_code = 'REMITTED', payment_event_id = l_ev, paid_date = l_date WHERE id = s.id;
  END remit_statement;

  -- ================================================================ الشاشات
  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_cls VARCHAR2 DEFAULT 'is-info') RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_cls || '"><span class="nn-kpi-icon fa ' || p_icon || '" aria-hidden="true"></span><div><div class="nn-kpi-value">'
        || p_value || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION summary_html RETURN CLOB IS
    l_tot NUMBER; l_occ NUMBER; l_act NUMBER; l_exp NUMBER; l_od NUMBER; l_dep NUMBER; l_roll NUMBER; l_co NUMBER := company;
  BEGIN
    guard('PRP_LEASE.VIEW');
    refresh_schedule;
    SELECT COUNT(*), COUNT(CASE WHEN status_code IN ('LEASED', 'OCCUPIED') THEN 1 END) INTO l_tot, l_occ
      FROM re_unit WHERE company_id = l_co AND usage_type IN ('LEASE', 'MIXED');
    SELECT COUNT(*), NVL(SUM(annual_rent), 0), COUNT(CASE WHEN end_date BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE) + 60 THEN 1 END)
      INTO l_act, l_roll, l_exp FROM prp_lease WHERE company_id = l_co AND status_code IN ('ACTIVE', 'RENEWAL_PENDING');
    SELECT NVL(SUM(s.amount + s.tax_amount), 0) INTO l_od FROM prp_rent_schedule s JOIN prp_lease l ON l.id = s.lease_id
     WHERE l.company_id = l_co AND s.status_code IN ('OVERDUE', 'PARTIALLY_PAID');
    SELECT NVL(SUM(received_amount), 0) INTO l_dep FROM prp_security_deposit WHERE company_id = l_co AND status_code = 'HELD';
    RETURN '<div class="nn-kpis">' || kpi('نسبة الإشغال', CASE WHEN l_tot > 0 THEN pct(l_occ * 100 / l_tot) ELSE '—' END || ' <small>(' || l_occ || '/' || l_tot || ')</small>',
                                         'fa-pie-chart', 'is-info')
        || kpi('عقود سارية', l_act, 'fa-file-text-o', 'is-success') || kpi('الإيجار السنوي للعقود السارية', fmt(l_roll), 'fa-money', 'is-info')
        || kpi('تنتهي خلال 60 يوماً', l_exp, 'fa-hourglass-half', CASE WHEN l_exp > 0 THEN 'is-warning' ELSE 'is-muted' END)
        || kpi('إيجارات متأخرة', fmt(l_od), 'fa-exclamation-triangle', CASE WHEN l_od > 0 THEN 'is-danger' ELSE 'is-muted' END)
        || kpi('تأمينات محتفظ بها', fmt(l_dep), 'fa-lock', 'is-muted') || '</div>';
  END summary_html;

  FUNCTION leases_html(p_status IN VARCHAR2 DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
    l_u VARCHAR2(1000);
  BEGIN
    guard('PRP_LEASE.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>العقد</th><th>المستأجر</th><th>العقار والوحدات</th><th>النوع</th><th>من</th><th>إلى</th>'
        || '<th class="n">الإيجار السنوي</th><th>الدورية</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT l.*, p.display_name_ar tname FROM prp_lease l JOIN pty_party p ON p.id = l.lessee_party_id
               WHERE l.company_id = company AND (p_status IS NULL OR l.status_code = p_status
                     OR (p_status = 'OPEN' AND l.status_code IN ('DRAFT', 'APPROVED', 'SIGNED', 'ACTIVE', 'RENEWAL_PENDING')))
               ORDER BY CASE WHEN l.status_code IN ('ACTIVE', 'RENEWAL_PENDING', 'DRAFT') THEN 0 ELSE 1 END, l.end_date, l.id DESC FETCH FIRST 500 ROWS ONLY) LOOP
      l_n := l_n + 1;
      SELECT LISTAGG(u.code, '، ') WITHIN GROUP (ORDER BY u.code) INTO l_u FROM prp_lease_unit x JOIN re_unit u ON u.id = x.unit_id WHERE x.lease_id = r.id;
      l_h := l_h || '<tr><td>' || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', r.id) || '"><b>' || esc(r.doc_no) || '</b></a>'
                                       ELSE '<b>' || esc(r.doc_no) || '</b>' END
          || '</td><td>' || esc(r.tname) || '</td><td>' || esc(NOONA_RE_PKG.property_name(r.property_id)) || ' · ' || esc(l_u) || '</td><td>'
          || CASE r.lease_type WHEN 'RESIDENTIAL' THEN 'سكني' WHEN 'COMMERCIAL' THEN 'تجاري' WHEN 'RETAIL' THEN 'محل تجزئة' WHEN 'INDUSTRIAL' THEN 'صناعي'
                               WHEN 'LAND' THEN 'أرض' ELSE 'مواقف' END
          || '</td><td>' || ds(r.start_date) || '</td><td' || CASE WHEN r.status_code IN ('ACTIVE', 'RENEWAL_PENDING') AND r.end_date < TRUNC(SYSDATE) + 60
                                                                     THEN ' class="is-over"' END || '>' || ds(r.end_date) || '</td><td class="n">'
          || fmt(r.annual_rent) || '</td><td>' || freq_label(r.billing_frequency) || '</td><td>' || badge(r.status_code) || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد عقود إيجار</div>' ELSE l_h || '</tbody></table>' END;
  END leases_html;

  FUNCTION schedule_html(p_lease_id IN NUMBER) RETURN CLOB IS
    l_h  CLOB;
    t_a  NUMBER := 0; t_t NUMBER := 0;
    l_no VARCHAR2(50);
  BEGIN
    guard('PRP_LEASE.VIEW');
    refresh_schedule(p_lease_id);
    l_h := '<table class="nn-prj-t"><thead><tr><th>البيان</th><th>الاستحقاق</th><th class="n">المبلغ</th><th class="n">الضريبة</th><th class="n">الإجمالي</th>'
        || '<th>الفاتورة</th><th>الحالة</th></tr></thead><tbody>';
    FOR s IN (SELECT * FROM prp_rent_schedule WHERE lease_id = p_lease_id ORDER BY due_date, id) LOOP
      l_no := NULL;
      IF s.sales_invoice_id IS NOT NULL THEN SELECT doc_no INTO l_no FROM sal_invoice WHERE id = s.sales_invoice_id; END IF;
      IF s.status_code NOT IN ('CANCELLED', 'WAIVED') THEN t_a := t_a + s.amount; t_t := t_t + s.tax_amount; END IF;
      l_h := l_h || '<tr' || CASE WHEN s.status_code = 'CANCELLED' THEN ' class="is-void"' END || '><td>' || esc(s.description) || '</td><td'
          || CASE WHEN s.status_code = 'OVERDUE' THEN ' class="is-over"' END || '>' || ds(s.due_date) || '</td><td class="n">' || fmt(s.amount)
          || '</td><td class="n">' || fmt(s.tax_amount) || '</td><td class="n">' || fmt(s.amount + s.tax_amount) || '</td><td>' || esc(l_no) || '</td><td>'
          || badge(s.status_code) || '</td></tr>';
    END LOOP;
    RETURN l_h || '</tbody><tfoot><tr><td colspan="2">الإجمالي</td><td class="n">' || fmt(t_a) || '</td><td class="n">' || fmt(t_t) || '</td><td class="n">'
        || fmt(t_a + t_t) || '</td><td colspan="2"></td></tr></tfoot></table>';
  END schedule_html;

  FUNCTION lease_html(p_lease_id IN NUMBER) RETURN CLOB IS
    l     prp_lease%ROWTYPE := get_lease(p_lease_id);
    l_h   CLOB;
    l_t   VARCHAR2(400);
    l_ph  VARCHAR2(100);
    l_agr VARCHAR2(400);
    l_prv VARCHAR2(50);
    l_nxt VARCHAR2(50);
  BEGIN
    guard('PRP_LEASE.VIEW');
    SELECT p.display_name_ar, (SELECT MAX(mobile) FROM ref_contact x WHERE x.party_id = p.id) INTO l_t, l_ph FROM pty_party p WHERE p.id = l.lessee_party_id;
    SELECT MAX(o.display_name_ar) INTO l_agr FROM prp_management_agreement a JOIN pty_party o ON o.id = a.owner_party_id WHERE a.id = l.management_agreement_id;
    SELECT MAX(doc_no) INTO l_prv FROM prp_lease WHERE id = l.previous_lease_id;
    SELECT MAX(doc_no) INTO l_nxt FROM prp_lease WHERE previous_lease_id = l.id AND status_code <> 'CANCELLED';
    l_h := '<div class="nn-prj-chips"><span>العقد ' || esc(l.doc_no) || '</span><span>' || esc(NOONA_RE_PKG.property_name(l.property_id)) || '</span>'
        || badge(l.status_code) || CASE WHEN l.registration_no IS NOT NULL THEN '<span>التوثيق ' || esc(l.registration_no) || '</span>' END
        || CASE WHEN l_agr IS NOT NULL THEN '<span>مدار لصالح ' || esc(l_agr) || '</span>' END
        || CASE WHEN l_prv IS NOT NULL THEN '<span>تجديد للعقد ' || esc(l_prv) || '</span>' END
        || CASE WHEN l_nxt IS NOT NULL THEN '<span>جدد بالعقد ' || esc(l_nxt) || '</span>' END || '</div>'
        || '<table class="nn-prj-cert-info"><tr><th>المستأجر</th><td>' || esc(l_t) || CASE WHEN l_ph IS NOT NULL THEN ' · <span dir="ltr">' || esc(l_ph) || '</span>' END
        || '</td><th>المدة</th><td>' || ds(l.start_date) || ' إلى ' || ds(l.end_date) || '</td></tr>'
        || '<tr><th>الإيجار السنوي</th><td><b>' || fmt(l.annual_rent) || '</b></td><th>الدورية</th><td>' || freq_label(l.billing_frequency)
        || CASE WHEN l.billing_in_advance = 'Y' THEN ' (مقدماً)' ELSE ' (مؤخراً)' END || '</td></tr>'
        || '<tr><th>التأمين</th><td>' || fmt(l.deposit_amount) || '</td><th>الزيادة السنوية</th><td>'
        || CASE WHEN l.escalation_rule IS NOT NULL THEN pct(JSON_VALUE(l.escalation_rule, '$.pct' RETURNING NUMBER)) ELSE 'لا يوجد' END || '</td></tr>'
        || '<tr><th>فترة السماح</th><td>' || NVL(TO_CHAR(l.grace_days), '0') || ' يوم</td><th>مدة الإشعار</th><td>' || NVL(TO_CHAR(l.notice_days), '—') || ' يوم</td></tr>'
        || CASE WHEN l.move_out_date IS NOT NULL THEN '<tr><th>الإخلاء</th><td>' || ds(l.move_out_date) || '</td><th>السبب</th><td>' || esc(l.termination_reason) || '</td></tr>' END
        || '</table><h4 class="nn-prj-h">الوحدات</h4><p>';
    FOR u IN (SELECT x.unit_id, x.rent_share FROM prp_lease_unit x WHERE x.lease_id = l.id) LOOP
      l_h := l_h || '<span class="nn-badge is-muted">' || esc(NOONA_RE_PKG.unit_label(u.unit_id)) || '</span> ';
    END LOOP;
    l_h := l_h || '</p><h4 class="nn-prj-h">البنود</h4><p>';
    FOR c IN (SELECT * FROM prp_lease_charge WHERE lease_id = l.id ORDER BY CASE charge_type WHEN 'RENT' THEN 0 ELSE 1 END, id) LOOP
      l_h := l_h || '<span class="nn-badge is-info">' || esc(charge_label(c.charge_type)) || ' ' || fmt(c.amount) || ' · ' || freq_label(c.frequency) || '</span> ';
    END LOOP;
    l_h := l_h || '</p>';
    FOR d IN (SELECT * FROM prp_security_deposit WHERE lease_id = l.id) LOOP
      l_h := l_h || '<h4 class="nn-prj-h">التأمين</h4><p>المستلم ' || fmt(d.received_amount) || ' · الخصومات ' || fmt(d.deducted_amount) || ' · المردود '
          || fmt(d.refunded_amount) || ' ' || badge(d.status_code) || '</p>';
    END LOOP;
    RETURN l_h || '<h4 class="nn-prj-h">جدول الاستحقاقات</h4>' || schedule_html(l.id);
  END lease_html;

  FUNCTION rent_roll_html(p_property_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
    t   NUMBER := 0;
  BEGIN
    guard('PRP_LEASE.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>العقار</th><th>الوحدة</th><th>النوع</th><th class="n">المساحة</th><th>المستأجر</th><th>العقد</th>'
        || '<th>ينتهي</th><th class="n">الإيجار السنوي</th><th>الحالة</th></tr></thead><tbody>';
    FOR u IN (SELECT u.id, u.property_id, u.code, u.unit_type, NVL(u.net_area_sqm, u.gross_area_sqm) area, u.status_code,
                     l.doc_no, l.end_date, x.rent_share, p.display_name_ar tname
                FROM re_unit u
                LEFT JOIN prp_lease_unit x ON x.unit_id = u.id AND x.lease_id IN (SELECT id FROM prp_lease WHERE status_code IN ('ACTIVE', 'RENEWAL_PENDING'))
                LEFT JOIN prp_lease l ON l.id = x.lease_id LEFT JOIN pty_party p ON p.id = l.lessee_party_id
               WHERE u.company_id = company AND u.usage_type IN ('LEASE', 'MIXED') AND (p_property_id IS NULL OR u.property_id = p_property_id)
               ORDER BY u.property_id, u.code) LOOP
      l_n := l_n + 1;
      t := t + NVL(u.rent_share, 0);
      l_h := l_h || '<tr><td>' || esc(NOONA_RE_PKG.property_name(u.property_id)) || '</td><td><b>' || esc(u.code) || '</b></td><td>'
          || esc(NOONA_RE_PKG.unit_type_label(u.unit_type)) || '</td><td class="n">' || fmt(u.area) || '</td><td>' || esc(u.tname) || '</td><td>' || esc(u.doc_no)
          || '</td><td' || CASE WHEN u.end_date < TRUNC(SYSDATE) + 60 THEN ' class="is-over"' END || '>' || ds(u.end_date) || '</td><td class="n">'
          || CASE WHEN u.rent_share IS NOT NULL THEN fmt(u.rent_share) END || '</td><td>'
          || CASE WHEN u.doc_no IS NOT NULL THEN '<span class="nn-badge is-success">مؤجرة</span>' WHEN u.status_code = 'AVAILABLE' THEN '<span class="nn-badge is-warning">شاغرة</span>'
                  ELSE '<span class="nn-badge is-muted">' || esc(NOONA_RE_PKG.unit_status_label(u.status_code)) || '</span>' END || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد وحدات للتأجير (استخدام الوحدة: للتأجير أو متعدد)</div>'
                ELSE l_h || '</tbody><tfoot><tr><td colspan="7">الإجمالي (' || l_n || ' وحدة)</td><td class="n">' || fmt(t) || '</td><td></td></tr></tfoot></table>' END;
  END rent_roll_html;

  FUNCTION expiring_html(p_days IN NUMBER DEFAULT 60, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('PRP_LEASE.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>العقد</th><th>المستأجر</th><th>العقار</th><th>ينتهي</th><th>المتبقي</th><th class="n">الإيجار</th><th>التجديد</th></tr></thead><tbody>';
    FOR r IN (SELECT l.*, p.display_name_ar tname, (SELECT MAX(doc_no) FROM prp_lease n WHERE n.previous_lease_id = l.id AND n.status_code <> 'CANCELLED') renewal
                FROM prp_lease l JOIN pty_party p ON p.id = l.lessee_party_id
               WHERE l.company_id = company AND l.status_code IN ('ACTIVE', 'RENEWAL_PENDING') AND l.end_date <= TRUNC(SYSDATE) + p_days
               ORDER BY l.end_date) LOOP
      l_n := l_n + 1;
      l_h := l_h || '<tr><td>' || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', r.id) || '">' || esc(r.doc_no) || '</a>' ELSE esc(r.doc_no) END
          || '</td><td>' || esc(r.tname) || '</td><td>' || esc(NOONA_RE_PKG.property_name(r.property_id)) || '</td><td>' || ds(r.end_date) || '</td><td class="is-over">'
          || (r.end_date - TRUNC(SYSDATE)) || ' يوم</td><td class="n">' || fmt(r.annual_rent) || '</td><td>'
          || CASE WHEN r.renewal IS NOT NULL THEN '<span class="nn-badge is-info">' || esc(r.renewal) || '</span>' ELSE '<span class="nn-badge is-warning">لم يجدد</span>' END
          || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد عقود تنتهي خلال ' || p_days || ' يوماً</div>' ELSE l_h || '</tbody></table>' END;
  END expiring_html;

  FUNCTION overdue_html RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
    t   NUMBER := 0;
    l_open NUMBER;
  BEGIN
    guard('PRP_LEASE.VIEW');
    refresh_schedule;
    l_h := '<table class="nn-prj-t"><thead><tr><th>المستأجر</th><th>العقد</th><th>البيان</th><th>الاستحقاق</th><th>التأخير</th><th class="n">المتبقي</th></tr></thead><tbody>';
    FOR s IN (SELECT s.sales_invoice_id, MIN(s.due_date) due, MIN(s.description) dsc, MIN(l.doc_no) doc_no, MIN(p.display_name_ar) tname
                FROM prp_rent_schedule s JOIN prp_lease l ON l.id = s.lease_id JOIN pty_party p ON p.id = l.lessee_party_id
               WHERE l.company_id = company AND s.status_code IN ('OVERDUE', 'PARTIALLY_PAID') AND s.due_date < TRUNC(SYSDATE)
               GROUP BY s.sales_invoice_id ORDER BY MIN(s.due_date)) LOOP
      SELECT NVL(SUM(open_amount), 0) INTO l_open FROM ar_open_item WHERE source_entity_type = 'SAL_INVOICE' AND source_entity_id = s.sales_invoice_id;
      CONTINUE WHEN l_open <= 0;
      l_n := l_n + 1;
      t := t + l_open;
      l_h := l_h || '<tr><td>' || esc(s.tname) || '</td><td>' || esc(s.doc_no) || '</td><td>' || esc(s.dsc) || '</td><td>' || ds(s.due) || '</td><td class="is-over">'
          || (TRUNC(SYSDATE) - s.due) || ' يوم</td><td class="n">' || fmt(l_open) || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد إيجارات متأخرة</div>'
                ELSE l_h || '</tbody><tfoot><tr><td colspan="5">الإجمالي</td><td class="n">' || fmt(t) || '</td></tr></tfoot></table>' END;
  END overdue_html;

  FUNCTION occupancy_html RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('PRP_LEASE.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>العقار</th><th class="n">الوحدات</th><th class="n">مؤجرة</th><th class="n">شاغرة</th><th>الإشغال</th>'
        || '<th class="n">الإيجار السنوي</th></tr></thead><tbody>';
    FOR r IN (SELECT u.property_id, COUNT(*) n, COUNT(CASE WHEN u.status_code IN ('LEASED', 'OCCUPIED') THEN 1 END) occ,
                     COUNT(CASE WHEN u.status_code = 'AVAILABLE' THEN 1 END) vac,
                     (SELECT NVL(SUM(annual_rent), 0) FROM prp_lease l WHERE l.property_id = u.property_id AND l.status_code IN ('ACTIVE', 'RENEWAL_PENDING')) rent
                FROM re_unit u WHERE u.company_id = company AND u.usage_type IN ('LEASE', 'MIXED') GROUP BY u.property_id ORDER BY 1) LOOP
      l_n := l_n + 1;
      l_h := l_h || '<tr><td>' || esc(NOONA_RE_PKG.property_name(r.property_id)) || '</td><td class="n">' || r.n || '</td><td class="n">' || r.occ || '</td><td class="n">'
          || r.vac || '</td><td><div class="nn-prj-bar"><span style="width:' || ROUND(r.occ * 100 / r.n) || '%"></span></div> ' || pct(r.occ * 100 / r.n)
          || '</td><td class="n">' || fmt(r.rent) || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد وحدات للتأجير</div>' ELSE l_h || '</tbody></table>' END;
  END occupancy_html;

  FUNCTION agreements_html RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('PRP_MANAGEMENT_AGREEMENT.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>الاتفاقية</th><th>المالك</th><th>العقار</th><th>الأتعاب</th><th>التحويل</th><th>من</th><th>الحالة</th></tr></thead><tbody>';
    FOR a IN (SELECT a.*, p.display_name_ar oname FROM prp_management_agreement a JOIN pty_party p ON p.id = a.owner_party_id
               WHERE a.company_id = company ORDER BY a.id DESC) LOOP
      l_n := l_n + 1;
      l_h := l_h || '<tr data-agr="' || a.id || '"><td><b>' || esc(a.doc_no) || '</b></td><td>' || esc(a.oname) || '</td><td>' || esc(NOONA_RE_PKG.property_name(a.property_id))
          || '</td><td>' || CASE a.fee_type WHEN 'PCT_OF_COLLECTION' THEN pct(a.fee_pct) || ' من المحصل' WHEN 'PCT_OF_RENT' THEN pct(a.fee_pct) || ' من الإيجار'
                                           WHEN 'FIXED_MONTHLY' THEN fmt(a.fee_fixed) || ' شهرياً' ELSE pct(a.fee_pct) || ' + ' || fmt(a.fee_fixed) || ' شهرياً' END
          || '</td><td>' || CASE a.remit_frequency WHEN 'MONTHLY' THEN 'شهري' ELSE 'ربع سنوي' END || '</td><td>' || ds(a.effective_from) || '</td><td>'
          || badge(a.status_code) || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد اتفاقيات إدارة أملاك</div>' ELSE l_h || '</tbody></table>' END;
  END agreements_html;

  FUNCTION statements_html(p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('PRP_OWNER_STATEMENT.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>الكشف</th><th>المالك</th><th>العقار</th><th>الفترة</th><th class="n">المحصل</th><th class="n">المصروفات</th>'
        || '<th class="n">الأتعاب</th><th class="n">الصافي للمالك</th><th>الحالة</th></tr></thead><tbody>';
    FOR s IN (SELECT s.*, p.display_name_ar oname, a.property_id FROM prp_owner_statement s JOIN prp_management_agreement a ON a.id = s.management_agreement_id
                JOIN pty_party p ON p.id = a.owner_party_id WHERE s.company_id = company ORDER BY s.id DESC) LOOP
      l_n := l_n + 1;
      l_h := l_h || '<tr><td>' || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', s.id) || '"><b>' || esc(s.doc_no) || '</b></a>' ELSE esc(s.doc_no) END
          || '</td><td>' || esc(s.oname) || '</td><td>' || esc(NOONA_RE_PKG.property_name(s.property_id)) || '</td><td>' || ds(s.period_from) || ' ← ' || ds(s.period_to)
          || '</td><td class="n">' || fmt(s.collections) || '</td><td class="n">' || fmt(s.expenses) || '</td><td class="n">' || fmt(s.management_fee)
          || '</td><td class="n"><b>' || fmt(s.net_to_owner) || '</b></td><td>' || badge(s.status_code) || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد كشوف ملاك</div>' ELSE l_h || '</tbody></table>' END;
  END statements_html;

  FUNCTION statement_html(p_statement_id IN NUMBER) RETURN CLOB IS
    s   prp_owner_statement%ROWTYPE;
    a   prp_management_agreement%ROWTYPE;
    l_o VARCHAR2(400);
    l_h CLOB;
    l_open NUMBER;
  BEGIN
    guard('PRP_OWNER_STATEMENT.VIEW');
    SELECT * INTO s FROM prp_owner_statement WHERE id = p_statement_id AND company_id = company;
    SELECT * INTO a FROM prp_management_agreement WHERE id = s.management_agreement_id;
    SELECT display_name_ar INTO l_o FROM pty_party WHERE id = a.owner_party_id;
    l_h := '<div class="nn-prj-cert"><div class="nn-prj-cert-head"><div><b>' || esc(NOONA_APEX_PKG.company_name) || '</b><div>' || esc(NOONA_RE_PKG.property_name(a.property_id))
        || '</div></div><div class="nn-prj-cert-no">كشف حساب المالك<small>' || esc(s.doc_no) || '</small></div></div>'
        || '<table class="nn-prj-cert-info"><tr><th>المالك</th><td>' || esc(l_o) || '</td><th>الفترة</th><td>' || ds(s.period_from) || ' إلى ' || ds(s.period_to) || '</td></tr></table>'
        || '<table class="nn-prj-t"><thead><tr><th>العقد</th><th>البيان</th><th>الاستحقاق</th><th class="n">الإيجار</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT l.doc_no, x.description, x.due_date, x.amount, x.status_code FROM prp_rent_schedule x JOIN prp_lease l ON l.id = x.lease_id
                JOIN prp_lease_charge c ON c.id = x.charge_id
               WHERE l.management_agreement_id = a.id AND c.charge_type = 'RENT' AND x.due_date BETWEEN s.period_from AND s.period_to
                 AND x.status_code NOT IN ('CANCELLED', 'WAIVED') ORDER BY x.due_date) LOOP
      l_h := l_h || '<tr><td>' || esc(r.doc_no) || '</td><td>' || esc(r.description) || '</td><td>' || ds(r.due_date) || '</td><td class="n">' || fmt(r.amount)
          || '</td><td>' || badge(r.status_code) || '</td></tr>';
    END LOOP;
    l_h := l_h || '</tbody></table><table class="nn-prj-cert-sum"><tr><th>المحصل من الإيجارات</th><td>' || fmt(s.collections) || '</td></tr>'
        || '<tr><th>مصروفات مدفوعة عن المالك</th><td>(' || fmt(s.expenses) || ')</td></tr>'
        || '<tr><th>أتعاب الإدارة</th><td>(' || fmt(s.management_fee) || ')</td></tr>'
        || '<tr class="is-total"><th>الصافي المستحق للمالك</th><td>' || fmt(s.net_to_owner) || '</td></tr></table>'
        || '<p>' || badge(s.status_code) || CASE WHEN s.paid_date IS NOT NULL THEN ' حول بتاريخ ' || ds(s.paid_date) END || '</p></div>';
    RETURN l_h;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '<div class="nn-empty">الكشف غير موجود</div>';
  END statement_html;

  FUNCTION meters_html(p_property_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('PRP_METER.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>العداد</th><th>النوع</th><th>الوحدة</th><th>حساب المرفق</th><th class="n">سعر الوحدة</th><th>آخر قراءة</th>'
        || '<th class="n">القراءة</th><th class="n">آخر استهلاك</th></tr></thead><tbody>';
    FOR m IN (SELECT m.*, (SELECT MAX(reading_date) FROM prp_meter_reading r WHERE r.meter_id = m.id) ld,
                     (SELECT MAX(reading_value) KEEP (DENSE_RANK LAST ORDER BY reading_date) FROM prp_meter_reading r WHERE r.meter_id = m.id) lv,
                     (SELECT MAX(consumption) KEEP (DENSE_RANK LAST ORDER BY reading_date) FROM prp_meter_reading r WHERE r.meter_id = m.id) lc
                FROM prp_meter m WHERE m.company_id = company AND m.status_code = 'ACTIVE' AND (p_property_id IS NULL OR m.property_id = p_property_id)
               ORDER BY m.meter_no) LOOP
      l_n := l_n + 1;
      l_h := l_h || '<tr data-meter="' || m.id || '"><td><b>' || esc(m.meter_no) || '</b></td><td>'
          || CASE m.meter_type WHEN 'ELECTRICITY' THEN 'كهرباء' WHEN 'WATER' THEN 'مياه' WHEN 'GAS' THEN 'غاز' ELSE 'تبريد' END || '</td><td>'
          || CASE WHEN m.unit_id IS NOT NULL THEN esc(NOONA_RE_PKG.unit_label(m.unit_id)) ELSE 'عداد مشترك' END || '</td><td dir="ltr">' || esc(m.utility_account_no)
          || '</td><td class="n">' || fmt(m.rate_per_unit) || '</td><td>' || ds(m.ld) || '</td><td class="n">' || m.lv || '</td><td class="n">' || m.lc || '</td></tr>';
    END LOOP;
    RETURN CASE WHEN l_n = 0 THEN '<div class="nn-empty">لا توجد عدادات</div>' ELSE l_h || '</tbody></table>' END;
  END meters_html;
END NOONA_PRP_PKG;
/
SHOW ERRORS PACKAGE BODY NOONA_PRP_PKG
