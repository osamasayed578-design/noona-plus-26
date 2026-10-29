-- =============================================================================
-- NOONA PLUS ERP | المستشفيات والمراكز الطبية: NOONA_HIS_PKG
--   الأقسام (عيادات، معامل منفصلة، أشعة وموجات، تشخيص القلب، صيدليات داخلية، علاج طبيعي ووحدات علاجية، عمليات، تنويم)
--   بمستودعاتها ومراكز تكلفتها، الأطباء وساعات العمل، دليل الخدمات ومواد كل خدمة، شركات التأمين والجهات المتعاقدة بفئات
--   التغطية وأسعار العقود، المرضى والحجوزات والزيارات، الطلبات الطبية والموافقات والنتائج، صرف مواد المعمل والأشعة من مستودع
--   القسم، والفاتورة بحصة المريض (تدفع فوراً أو على حسابه) وحصة الجهة (مطالبة على ذمتها) مع الضريبة والقيد المحاسبي.
--   الضريبة: الخدمات الصحية للمواطن السعودي بنسبة صفر، ولغيره 15%.
-- =============================================================================

CREATE OR REPLACE PACKAGE NOONA_HIS_PKG AUTHID DEFINER AS

  -- نسبة ضريبة القيمة المضافة القياسية لدولة الشركة (من حزمة الدولة)
  FUNCTION c_vat RETURN NUMBER;

  FUNCTION company RETURN NUMBER;
  -- الحسابات والترقيم
  FUNCTION quick_setup RETURN NUMBER;
  FUNCTION is_ready RETURN VARCHAR2;
  -- أقسام وخدمات نموذجية (عيادات، معامل منفصلة، أشعة، قلب، علاج طبيعي، عمليات، تنويم، صيدلية) - لا تكرر الموجود
  FUNCTION seed_catalog RETURN NUMBER;

  -- ---------------------------------------------------------- الإعداد
  -- p_own_store = 'Y': ينشئ للقسم مستودعاً ومركز تكلفة باسمه (المعامل والصيدليات والأشعة)
  FUNCTION save_department(p_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_type IN VARCHAR2, p_specialty IN VARCHAR2 DEFAULT NULL,
                           p_own_store IN VARCHAR2 DEFAULT 'N', p_location IN VARCHAR2 DEFAULT NULL, p_status IN VARCHAR2 DEFAULT 'ACTIVE') RETURN NUMBER;
  -- {"id","code","name","type","modality","dept","price","billing_code","duration","sample","tat","range","approval":"Y","status"}
  FUNCTION save_service(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE set_material(p_service_id IN NUMBER, p_item_id IN NUMBER, p_qty IN NUMBER);
  -- {"id","code","name","dept","title","specialty","license","license_expiry","mobile","consult_service","commission","user","employee","status"}
  FUNCTION save_doctor(p_doc IN CLOB) RETURN NUMBER;
  -- يوم واحد (1 الأحد ... 7 السبت)؛ تستبدل فترة اليوم نفسه التي تبدأ بنفس الوقت
  PROCEDURE set_schedule(p_doctor_id IN NUMBER, p_weekday IN NUMBER, p_from IN VARCHAR2, p_to IN VARCHAR2, p_slot IN NUMBER DEFAULT 15,
                         p_room IN VARCHAR2 DEFAULT NULL);
  PROCEDURE clear_schedule(p_doctor_id IN NUMBER, p_weekday IN NUMBER);
  -- {"id","code","name","type","discount","claim_days","contract","from","to","phone","email","status"} - ينشئ حساب ذمة للجهة
  FUNCTION save_payer(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION save_plan(p_id IN NUMBER, p_payer_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_patient_pct IN NUMBER,
                     p_max_share IN NUMBER DEFAULT NULL, p_approval_limit IN NUMBER DEFAULT NULL, p_excluded IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  PROCEDURE set_payer_price(p_payer_id IN NUMBER, p_service_id IN NUMBER, p_price IN NUMBER, p_covered IN VARCHAR2 DEFAULT 'Y',
                            p_approval IN VARCHAR2 DEFAULT 'N');

  -- ---------------------------------------------------------- المرضى والمواعيد
  -- {"id","name","name_en","gender","birth","id_type","id_no","nationality","mobile","blood","allergies","chronic","plan","member","policy",
  --  "ins_expiry","address","emergency"} ؛ يرفض تكرار الهوية
  FUNCTION save_patient(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION find_patients_json(p_term IN VARCHAR2) RETURN CLOB;
  FUNCTION patient_label(p_patient_id IN NUMBER) RETURN VARCHAR2;
  -- الأوقات المتاحة للطبيب في يوم: ["09:00","09:15",...]
  FUNCTION free_slots(p_doctor_id IN NUMBER, p_date IN DATE) RETURN VARCHAR2;
  -- رقم اليوم مستقلاً عن إعدادات المنطقة: 1 الأحد ... 7 السبت
  FUNCTION weekday_of(p_date IN DATE) RETURN NUMBER;
  -- {"patient","doctor","dept","service","date","time","channel","notes"}
  FUNCTION book(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE cancel_appointment(p_appointment_id IN NUMBER, p_reason IN VARCHAR2);
  PROCEDURE mark_no_show(p_appointment_id IN NUMBER);
  -- وصول المريض: يفتح الزيارة ويضيف خدمة الموعد؛ يعيد رقم الزيارة
  FUNCTION arrive(p_appointment_id IN NUMBER) RETURN NUMBER;

  -- ---------------------------------------------------------- الزيارات والطلبات
  -- {"patient","dept","doctor","type","appointment","bill_to":"CASH|PAYER","approval","complaint"} ؛ تضاف خدمة الكشف الافتراضية للطبيب
  FUNCTION open_visit(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE update_visit(p_doc IN CLOB);
  FUNCTION add_order(p_visit_id IN NUMBER, p_service_id IN NUMBER, p_qty IN NUMBER DEFAULT 1, p_ordered_by IN NUMBER DEFAULT NULL,
                     p_notes IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  PROCEDURE cancel_order(p_order_id IN NUMBER, p_reason IN VARCHAR2);
  PROCEDURE set_approval(p_order_id IN NUMBER, p_approval_no IN VARCHAR2, p_approved IN VARCHAR2 DEFAULT 'Y');
  -- توزيع حصص الطلبات غير المفوترة (السعر، التغطية، نسبة المريض وحده الأعلى، الضريبة)
  PROCEDURE recalc_visit(p_visit_id IN NUMBER);
  -- العلاج بالتأمين اختياري: تحويل زيارة مفتوحة بين التأمين (فئة المريض) والدفع النقدي؛ يعاد تسعير الخدمات غير المفوترة
  PROCEDURE set_billing(p_visit_id IN NUMBER, p_bill_to IN VARCHAR2);
  PROCEDURE close_visit(p_visit_id IN NUMBER);
  FUNCTION is_open(p_visit_id IN NUMBER) RETURN VARCHAR2;

  -- ---------------------------------------------------------- التنفيذ (المعامل والأشعة والعيادات)
  FUNCTION collect_sample(p_order_id IN NUMBER) RETURN VARCHAR2;
  PROCEDURE start_order(p_order_id IN NUMBER);
  -- يحفظ النتيجة ويصرف مواد الخدمة من مستودع القسم بقيد صرف لمركز تكلفته
  PROCEDURE complete_order(p_order_id IN NUMBER, p_result IN CLOB, p_flag IN VARCHAR2 DEFAULT 'NORMAL', p_performer IN NUMBER DEFAULT NULL);

  -- ---------------------------------------------------------- الفوترة
  -- {"visit","method":"CASH|MADA|...|CREDIT","place":"BOX:1","ref"} ؛ تفوتر الطلبات غير المفوترة الجاهزة؛ يعيد رقم الفاتورة
  FUNCTION create_invoice(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE cancel_invoice(p_invoice_id IN NUMBER, p_reason IN VARCHAR2);
  FUNCTION unbilled_total(p_visit_id IN NUMBER, p_part IN VARCHAR2 DEFAULT 'PATIENT') RETURN NUMBER;
  FUNCTION payer_account(p_payer_id IN NUMBER) RETURN NUMBER;

  -- ---------------------------------------------------------- العرض والتقارير
  FUNCTION type_label(p_type IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION dept_type_label(p_type IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION order_status_label(p_status IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION appt_status_label(p_status IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION modality_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  -- اسم الخدمة للعرض: الفحوص والأشعة والتشخيص والأدوية والعمليات بالإنجليزية، وغيرها بالعربية
  FUNCTION service_name(p_service_id IN NUMBER) RETURN VARCHAR2;
  -- حساب الإيراد حسب نوع الخدمة (4120..4127) ومعرف الحساب بالرمز
  FUNCTION revenue_code(p_type IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION acc(p_code IN VARCHAR2) RETURN NUMBER;
  FUNCTION summary_html RETURN CLOB;
  FUNCTION visit_html(p_visit_id IN NUMBER) RETURN CLOB;
  FUNCTION invoice_html(p_invoice_id IN NUMBER) RETURN CLOB;
  FUNCTION result_html(p_order_id IN NUMBER) RETURN CLOB;
  FUNCTION day_board_html(p_date IN DATE, p_dept_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  FUNCTION revenue_html(p_from IN DATE, p_to IN DATE) RETURN CLOB;
  FUNCTION claims_html(p_payer_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN CLOB;
END NOONA_HIS_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_HIS_PKG AS

  c_inv CONSTANT VARCHAR2(30) := 'HIS_INVOICE';
  TYPE t_price IS RECORD (unit NUMBER, covered VARCHAR2(1), approval VARCHAR2(1), pct NUMBER);

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;
  FUNCTION c_vat RETURN NUMBER IS
  BEGIN
    RETURN NOONA_INV_PKG.tax_rate(NOONA_INV_PKG.tax_id('VAT15'), TRUNC(SYSDATE));
  END c_vat;

  FUNCTION company_country RETURN VARCHAR2 IS
    l VARCHAR2(2);
  BEGIN
    SELECT MAX(country_code) INTO l FROM org_company WHERE id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
    RETURN l;
  END company_country;

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END;
  FUNCTION fmt0(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(NVL(p, 0), 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.,''');
  END fmt0;
  FUNCTION d(p VARCHAR2) RETURN DATE IS BEGIN RETURN TO_DATE(p, 'YYYY-MM-DD'); END;
  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  FUNCTION acc(p_code IN VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM gl_account WHERE coa_id = NOONA_GL_PKG.primary_coa AND account_code = p_code;
    RETURN l;
  END acc;
  FUNCTION need_acc(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER := acc(p_code);
  BEGIN
    NOONA_CORE_PKG.assert(l IS NOT NULL, 'NOONA-HIS-001', 'الحساب ' || p_code || ' غير معرف؛ نفذ «تجهيز المستشفى»', 'Account missing');
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
  FUNCTION next_no(p_type VARCHAR2, p_prefix VARCHAR2, p_entity VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
  BEGIN
    ensure_sequence(p_type, p_prefix);
    RETURN NOONA_REFERENCE_PKG.next_doc_no(p_type, company, NULL, TRUNC(SYSDATE), NVL(p_entity, p_type), NULL);
  END next_no;

  -- ================================================================ المسميات
  FUNCTION type_label(p_type IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_type WHEN 'CONSULTATION' THEN 'كشف' WHEN 'FOLLOW_UP' THEN 'مراجعة' WHEN 'EMERGENCY' THEN 'طوارئ' WHEN 'LAB' THEN 'تحليل مخبري'
      WHEN 'RADIOLOGY' THEN 'أشعة وموجات' WHEN 'CARDIO_DIAG' THEN 'تشخيص القلب' WHEN 'PROCEDURE' THEN 'إجراء طبي' WHEN 'MINOR_SURGERY' THEN 'عملية صغرى'
      WHEN 'MAJOR_SURGERY' THEN 'عملية كبرى' WHEN 'PHYSIOTHERAPY' THEN 'علاج طبيعي' WHEN 'THERAPY' THEN 'جلسة علاجية' WHEN 'NURSING' THEN 'خدمة تمريضية'
      WHEN 'DENTAL' THEN 'أسنان' WHEN 'BED' THEN 'تنويم (يوم سرير)' WHEN 'MEDICATION' THEN 'دواء ومستلزمات' WHEN 'PACKAGE' THEN 'باقة'
      ELSE 'خدمة أخرى' END;
  END type_label;

  FUNCTION dept_type_label(p_type IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_type WHEN 'CLINIC' THEN 'عيادة' WHEN 'EMERGENCY' THEN 'طوارئ' WHEN 'LAB' THEN 'معمل' WHEN 'RADIOLOGY' THEN 'أشعة وموجات'
      WHEN 'CARDIO_DIAG' THEN 'تشخيص القلب' WHEN 'PHARMACY' THEN 'صيدلية داخلية' WHEN 'INPATIENT_WARD' THEN 'جناح تنويم'
      WHEN 'OPERATING_THEATER' THEN 'غرف العمليات' WHEN 'PHYSIOTHERAPY' THEN 'علاج طبيعي' WHEN 'THERAPY_UNIT' THEN 'وحدة علاجية'
      WHEN 'DENTAL' THEN 'أسنان' WHEN 'DIALYSIS' THEN 'غسيل كلوي' WHEN 'NURSING' THEN 'تمريض' ELSE 'أخرى' END;
  END dept_type_label;

  FUNCTION order_status_label(p_status IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_status WHEN 'ORDERED' THEN 'مطلوب' WHEN 'APPROVAL_PENDING' THEN 'بانتظار موافقة التأمين' WHEN 'IN_PROGRESS' THEN 'قيد التنفيذ'
      WHEN 'COMPLETED' THEN 'منجز' WHEN 'CANCELLED' THEN 'ملغى' ELSE p_status END;
  END order_status_label;

  FUNCTION appt_status_label(p_status IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_status WHEN 'BOOKED' THEN 'محجوز' WHEN 'CONFIRMED' THEN 'مؤكد' WHEN 'ARRIVED' THEN 'حضر' WHEN 'COMPLETED' THEN 'منجز'
      WHEN 'NO_SHOW' THEN 'لم يحضر' WHEN 'CANCELLED' THEN 'ملغى' ELSE p_status END;
  END appt_status_label;

  FUNCTION modality_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'XRAY' THEN 'أشعة سينية' WHEN 'CT' THEN 'أشعة مقطعية' WHEN 'MRI' THEN 'رنين مغناطيسي' WHEN 'ULTRASOUND' THEN 'موجات صوتية'
      WHEN 'DOPPLER' THEN 'دوبلر' WHEN 'MAMMOGRAPHY' THEN 'ماموجرام' WHEN 'FLUOROSCOPY' THEN 'أشعة بالصبغة' WHEN 'DEXA' THEN 'هشاشة العظام'
      WHEN 'NUCLEAR' THEN 'طب نووي' WHEN 'PET' THEN 'مسح PET' WHEN 'ECG' THEN 'رسم قلب' WHEN 'ECHO' THEN 'إيكو القلب' WHEN 'STRESS_TEST' THEN 'جهد'
      WHEN 'HOLTER' THEN 'هولتر' WHEN 'EEG' THEN 'رسم مخ' WHEN 'EMG' THEN 'رسم عصب وعضلات' WHEN 'ENDOSCOPY' THEN 'مناظير' ELSE p_code END;
  END modality_label;

  FUNCTION service_name(p_service_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT CASE WHEN service_type IN ('LAB', 'RADIOLOGY', 'CARDIO_DIAG', 'MEDICATION', 'PROCEDURE', 'MINOR_SURGERY', 'MAJOR_SURGERY')
                THEN NVL(name_en, name_ar) ELSE name_ar END
      INTO l FROM his_service WHERE id = p_service_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
  END service_name;

  -- حساب الإيراد حسب نوع الخدمة
  FUNCTION revenue_code(p_type IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_type IN ('CONSULTATION', 'FOLLOW_UP', 'EMERGENCY', 'DENTAL') THEN '4120' WHEN p_type = 'LAB' THEN '4121'
                WHEN p_type IN ('RADIOLOGY', 'CARDIO_DIAG') THEN '4122' WHEN p_type IN ('PROCEDURE', 'MINOR_SURGERY', 'MAJOR_SURGERY') THEN '4123'
                WHEN p_type IN ('PHYSIOTHERAPY', 'THERAPY') THEN '4124' WHEN p_type IN ('BED', 'NURSING') THEN '4125'
                WHEN p_type = 'MEDICATION' THEN '4126' ELSE '4127' END;
  END revenue_code;

  -- ================================================================ التجهيز
  FUNCTION is_ready RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = 'HIS_VISIT';
    RETURN CASE WHEN l > 0 AND acc('4121') IS NOT NULL THEN 'Y' ELSE 'N' END;
  END is_ready;

  FUNCTION quick_setup RETURN NUMBER IS
    l NUMBER;
  BEGIN
    guard('HIS_DEPARTMENT.CREATE');
    IF NOONA_GL_PKG.primary_ledger IS NULL THEN
      l := NOONA_GL_PKG.quick_setup;
    END IF;
    IF NOONA_SAL_PKG.is_ready = 'N' THEN
      l := NOONA_SAL_PKG.quick_setup;
    END IF;
    l := ensure_account('1114', 'ذمم شركات التأمين والجهات المتعاقدة', '11', 'ASSET');
    l := ensure_account('1115', 'ذمم المرضى', '11', 'ASSET');
    l := ensure_account('4120', 'إيرادات الكشوفات والعيادات', '4', 'REVENUE');
    l := ensure_account('4121', 'إيرادات المختبرات', '4', 'REVENUE');
    l := ensure_account('4122', 'إيرادات الأشعة والتشخيص', '4', 'REVENUE');
    l := ensure_account('4123', 'إيرادات العمليات والإجراءات', '4', 'REVENUE');
    l := ensure_account('4124', 'إيرادات العلاج الطبيعي والوحدات العلاجية', '4', 'REVENUE');
    l := ensure_account('4125', 'إيرادات التنويم والتمريض', '4', 'REVENUE');
    l := ensure_account('4126', 'إيرادات الأدوية والمستلزمات الطبية', '4', 'REVENUE');
    l := ensure_account('4127', 'إيرادات طبية أخرى', '4', 'REVENUE');
    ensure_sequence('HIS_PATIENT', 'MRN');
    ensure_sequence('HIS_APPOINTMENT', 'AP-');
    ensure_sequence('HIS_VISIT', 'V-');
    ensure_sequence(c_inv, 'MI-');
    ensure_sequence('HIS_SAMPLE', 'S');
    NOONA_AUDIT_PKG.log_event('CONFIG', 'HIS_DEPARTMENT', NULL, 'QUICK_SETUP', 'SUCCESS');
    RETURN 10;
  END quick_setup;

  -- ================================================================ الأقسام والخدمات
  FUNCTION save_department(p_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_type IN VARCHAR2, p_specialty IN VARCHAR2 DEFAULT NULL,
                           p_own_store IN VARCHAR2 DEFAULT 'N', p_location IN VARCHAR2 DEFAULT NULL, p_status IN VARCHAR2 DEFAULT 'ACTIVE') RETURN NUMBER IS
    l     NUMBER := p_id;
    l_code VARCHAR2(50) := UPPER(TRIM(p_code));
    l_wh  NUMBER;
    l_cc  NUMBER;
    l_n   NUMBER;
  BEGIN
    guard('HIS_DEPARTMENT.' || CASE WHEN p_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_code IS NOT NULL AND TRIM(p_name_ar) IS NOT NULL, 'NOONA-HIS-010', 'رمز القسم واسمه إلزاميان', 'Code and name are required');
    SELECT COUNT(*) INTO l_n FROM his_department WHERE company_id = company AND code = l_code AND id <> NVL(p_id, -1);
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-011', 'رمز القسم مستخدم: ' || l_code, 'Department code already exists');
    IF l IS NOT NULL THEN
      SELECT warehouse_id, cost_center_id INTO l_wh, l_cc FROM his_department WHERE id = l AND company_id = company;
    END IF;
    -- مركز تكلفة لكل قسم، ومستودع مستقل للمعامل والصيدليات والأشعة (مواد كل معمل منفصلة عن غيره)
    IF l_cc IS NULL THEN
      SELECT MIN(id) INTO l_cc FROM gl_cost_center WHERE company_id = company AND code = 'HIS-' || l_code;
      IF l_cc IS NULL THEN
        l_cc := NOONA_GL_PKG.create_cost_center('HIS-' || l_code, TRIM(p_name_ar));
      END IF;
    END IF;
    IF p_own_store = 'Y' AND l_wh IS NULL THEN
      SELECT MIN(id) INTO l_wh FROM inv_warehouse WHERE company_id = company AND code = 'H-' || l_code;
      IF l_wh IS NULL THEN
        l_wh := NOONA_INV_PKG.create_warehouse('H-' || l_code, 'مستودع ' || TRIM(p_name_ar), 'STORE', l_cc);
      END IF;
    END IF;
    IF l IS NULL THEN
      INSERT INTO his_department (company_id, code, name_ar, dept_type, specialty, warehouse_id, cost_center_id, location_text, sort_order, status_code)
      VALUES (company, l_code, TRIM(p_name_ar), p_type, p_specialty, l_wh, l_cc, p_location, 0, NVL(p_status, 'ACTIVE'))
      RETURNING id INTO l;
    ELSE
      UPDATE his_department SET code = l_code, name_ar = TRIM(p_name_ar), dept_type = p_type, specialty = p_specialty, warehouse_id = l_wh,
                                cost_center_id = l_cc, location_text = NVL(p_location, location_text), status_code = NVL(p_status, status_code)
       WHERE id = l AND company_id = company;
    END IF;
    RETURN l;
  END save_department;

  FUNCTION save_service(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := l_o.get_number('id');
    l_code VARCHAR2(50) := UPPER(TRIM(l_o.get_string('code')));
    l_name VARCHAR2(200) := TRIM(l_o.get_string('name'));
    l_en   VARCHAR2(200) := TRIM(l_o.get_string('name_en'));
    l_type VARCHAR2(30) := l_o.get_string('type');
    l_mod  VARCHAR2(30) := l_o.get_string('modality');
    l_dept NUMBER := l_o.get_number('dept');
    l_pr   NUMBER := NVL(l_o.get_number('price'), 0);
    l_bc   VARCHAR2(50) := l_o.get_string('billing_code');
    l_dur  NUMBER := l_o.get_number('duration');
    l_smp  VARCHAR2(30) := l_o.get_string('sample');
    l_tat  NUMBER := l_o.get_number('tat');
    l_rng  VARCHAR2(500) := l_o.get_string('range');
    l_apr  VARCHAR2(1) := NVL(l_o.get_string('approval'), 'N');
    l_st   VARCHAR2(30) := NVL(l_o.get_string('status'), 'ACTIVE');
    l_item NUMBER := l_o.get_number('item');
    l_n    NUMBER;
  BEGIN
    guard('HIS_SERVICE.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_code IS NOT NULL AND l_name IS NOT NULL AND l_type IS NOT NULL, 'NOONA-HIS-012', 'رمز الخدمة واسمها ونوعها إلزامية',
                          'Code, name and type are required');
    NOONA_CORE_PKG.assert(l_pr >= 0, 'NOONA-HIS-013', 'السعر لا يكون سالباً', 'Price cannot be negative');
    SELECT COUNT(*) INTO l_n FROM his_service WHERE company_id = company AND code = l_code AND id <> NVL(l_id, -1);
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-014', 'رمز الخدمة مستخدم: ' || l_code, 'Service code already exists');
    IF l_id IS NULL THEN
      INSERT INTO his_service (company_id, code, name_ar, name_en, service_type, modality, department_id, billing_code, price, duration_min, sample_type,
                               turnaround_hours, normal_range, needs_approval, item_id, status_code)
      VALUES (company, l_code, l_name, l_en, l_type, l_mod, l_dept, l_bc, l_pr, l_dur, l_smp, l_tat, l_rng, l_apr, l_item, l_st)
      RETURNING id INTO l_id;
    ELSE
      UPDATE his_service SET code = l_code, name_ar = l_name, name_en = l_en, service_type = l_type, modality = l_mod, department_id = l_dept, billing_code = l_bc,
                             price = l_pr, duration_min = l_dur, sample_type = l_smp, turnaround_hours = l_tat, normal_range = l_rng,
                             needs_approval = l_apr, item_id = l_item, status_code = l_st
       WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  END save_service;

  PROCEDURE set_material(p_service_id IN NUMBER, p_item_id IN NUMBER, p_qty IN NUMBER) IS
  BEGIN
    guard('HIS_SERVICE.UPDATE');
    IF NVL(p_qty, 0) <= 0 THEN
      DELETE FROM his_service_material WHERE service_id = p_service_id AND item_id = p_item_id;
      RETURN;
    END IF;
    NOONA_CORE_PKG.assert(NOONA_INV_PKG.is_stocked(p_item_id) = 'Y', 'NOONA-HIS-015', 'المادة يجب أن تكون صنفاً مخزنياً', 'Item must be a stock item');
    MERGE INTO his_service_material m
    USING (SELECT p_service_id s, p_item_id i FROM dual) x ON (m.service_id = x.s AND m.item_id = x.i)
     WHEN MATCHED THEN UPDATE SET m.quantity = p_qty
     WHEN NOT MATCHED THEN INSERT (company_id, service_id, item_id, quantity) VALUES (company, x.s, x.i, p_qty);
  END set_material;

  FUNCTION save_doctor(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := l_o.get_number('id');
    l_code VARCHAR2(50) := UPPER(TRIM(l_o.get_string('code')));
    l_name VARCHAR2(200) := TRIM(l_o.get_string('name'));
    l_dept NUMBER := l_o.get_number('dept');
    l_tit  VARCHAR2(30) := NVL(l_o.get_string('title'), 'SPECIALIST');
    l_spc  VARCHAR2(100) := l_o.get_string('specialty');
    l_lic  VARCHAR2(50) := l_o.get_string('license');
    l_lexp DATE := d(l_o.get_string('license_expiry'));
    l_mob  VARCHAR2(30) := l_o.get_string('mobile');
    l_cs   NUMBER := l_o.get_number('consult_service');
    l_com  NUMBER := l_o.get_number('commission');
    l_usr  VARCHAR2(128) := UPPER(TRIM(l_o.get_string('user')));
    l_emp  NUMBER := l_o.get_number('employee');
    l_st   VARCHAR2(30) := NVL(l_o.get_string('status'), 'ACTIVE');
    l_n    NUMBER;
  BEGIN
    guard('HIS_DOCTOR.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_name IS NOT NULL AND l_dept IS NOT NULL, 'NOONA-HIS-016', 'اسم الطبيب والقسم إلزاميان', 'Name and department are required');
    IF l_code IS NULL THEN
      SELECT 'DR' || LPAD(COUNT(*) + 1, 3, '0') INTO l_code FROM his_doctor WHERE company_id = company;
    END IF;
    SELECT COUNT(*) INTO l_n FROM his_doctor WHERE company_id = company AND code = l_code AND id <> NVL(l_id, -1);
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-017', 'رمز الطبيب مستخدم: ' || l_code, 'Doctor code already exists');
    IF l_id IS NULL THEN
      INSERT INTO his_doctor (company_id, code, name_ar, department_id, employee_id, title, specialty, license_no, license_expiry, mobile,
                              consult_service_id, commission_pct, user_name, status_code)
      VALUES (company, l_code, l_name, l_dept, l_emp, l_tit, l_spc, l_lic, l_lexp, l_mob, l_cs, l_com, l_usr, l_st)
      RETURNING id INTO l_id;
    ELSE
      UPDATE his_doctor SET code = l_code, name_ar = l_name, department_id = l_dept, employee_id = l_emp, title = l_tit, specialty = l_spc,
                            license_no = l_lic, license_expiry = l_lexp, mobile = l_mob, consult_service_id = l_cs, commission_pct = l_com,
                            user_name = l_usr, status_code = l_st
       WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  END save_doctor;

  FUNCTION mins(p_hhmi VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN TO_NUMBER(SUBSTR(p_hhmi, 1, 2)) * 60 + TO_NUMBER(SUBSTR(p_hhmi, 4, 2));
  END mins;
  FUNCTION hhmi(p_mins NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN LPAD(TRUNC(p_mins / 60), 2, '0') || ':' || LPAD(MOD(p_mins, 60), 2, '0');
  END hhmi;

  PROCEDURE set_schedule(p_doctor_id IN NUMBER, p_weekday IN NUMBER, p_from IN VARCHAR2, p_to IN VARCHAR2, p_slot IN NUMBER DEFAULT 15,
                         p_room IN VARCHAR2 DEFAULT NULL) IS
    l_dept NUMBER;
    l_n    NUMBER;
  BEGIN
    guard('HIS_DOCTOR.UPDATE');
    NOONA_CORE_PKG.assert(p_weekday BETWEEN 1 AND 7 AND REGEXP_LIKE(p_from, '^[0-2][0-9]:[0-5][0-9]$') AND REGEXP_LIKE(p_to, '^[0-2][0-9]:[0-5][0-9]$')
                          AND p_to > p_from, 'NOONA-HIS-018', 'حدد اليوم ووقتي البداية والنهاية (HH24:MI) والنهاية بعد البداية',
                          'Day, from and to are required');
    NOONA_CORE_PKG.assert(NVL(p_slot, 15) BETWEEN 5 AND 240, 'NOONA-HIS-019', 'مدة الموعد بين 5 و240 دقيقة', 'Slot must be 5..240 minutes');
    SELECT department_id INTO l_dept FROM his_doctor WHERE id = p_doctor_id AND company_id = company;
    -- لا تداخل مع فترة أخرى في نفس اليوم
    SELECT COUNT(*) INTO l_n FROM his_doctor_schedule
     WHERE doctor_id = p_doctor_id AND weekday = p_weekday AND from_time <> p_from AND effective_to IS NULL
       AND from_time < p_to AND to_time > p_from;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-020', 'الفترة تتداخل مع فترة أخرى للطبيب في نفس اليوم', 'Overlapping working hours');
    DELETE FROM his_doctor_schedule WHERE doctor_id = p_doctor_id AND weekday = p_weekday AND from_time = p_from;
    INSERT INTO his_doctor_schedule (company_id, doctor_id, weekday, from_time, to_time, slot_minutes, department_id, room, effective_from)
    VALUES (company, p_doctor_id, p_weekday, p_from, p_to, NVL(p_slot, 15), l_dept, p_room, TRUNC(SYSDATE) - 365);
  END set_schedule;

  PROCEDURE clear_schedule(p_doctor_id IN NUMBER, p_weekday IN NUMBER) IS
  BEGIN
    guard('HIS_DOCTOR.UPDATE');
    DELETE FROM his_doctor_schedule WHERE doctor_id = p_doctor_id AND company_id = company AND (p_weekday IS NULL OR weekday = p_weekday);
  END clear_schedule;

  -- ================================================================ الجهات
  FUNCTION payer_account(p_payer_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT customer_account_id INTO l FROM his_payer WHERE id = p_payer_id;
    RETURN l;
  END payer_account;

  FUNCTION save_payer(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := l_o.get_number('id');
    l_code VARCHAR2(50) := UPPER(TRIM(l_o.get_string('code')));
    l_name VARCHAR2(200) := TRIM(l_o.get_string('name'));
    l_type VARCHAR2(30) := NVL(l_o.get_string('type'), 'INSURANCE');
    l_dis  NUMBER := l_o.get_number('discount');
    l_days NUMBER := l_o.get_number('claim_days');
    l_cno  VARCHAR2(50) := l_o.get_string('contract');
    l_fr   DATE := d(l_o.get_string('from'));
    l_to   DATE := d(l_o.get_string('to'));
    l_ph   VARCHAR2(30) := l_o.get_string('phone');
    l_em   VARCHAR2(320) := l_o.get_string('email');
    l_st   VARCHAR2(30) := NVL(l_o.get_string('status'), 'ACTIVE');
    l_acc  NUMBER;
    l_n    NUMBER;
    l_doc  CLOB;
  BEGIN
    guard('HIS_PAYER.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_code IS NOT NULL AND l_name IS NOT NULL, 'NOONA-HIS-021', 'رمز الجهة واسمها إلزاميان', 'Code and name are required');
    NOONA_CORE_PKG.assert(NVL(l_dis, 0) BETWEEN 0 AND 100, 'NOONA-HIS-022', 'نسبة الخصم بين 0 و100', 'Discount must be 0..100');
    SELECT COUNT(*) INTO l_n FROM his_payer WHERE company_id = company AND code = l_code AND id <> NVL(l_id, -1);
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-023', 'رمز الجهة مستخدم: ' || l_code, 'Payer code already exists');
    IF l_id IS NOT NULL THEN
      SELECT customer_account_id INTO l_acc FROM his_payer WHERE id = l_id AND company_id = company;
    END IF;
    -- حساب عميل للجهة على ذمم شركات التأمين (1114): المطالبات والتحصيل بسند تحصيل المبيعات
    SELECT JSON_OBJECT('id' VALUE l_acc, 'name' VALUE l_name, 'person' VALUE 'N', 'phone' VALUE l_ph, 'email' VALUE l_em,
                       'term' VALUE CASE WHEN NVL(l_days, 30) <= 30 THEN 'NET30' ELSE 'NET60' END RETURNING CLOB)
      INTO l_doc FROM dual;
    l_acc := NOONA_SAL_PKG.save_customer(l_doc);
    l_n := need_acc('1114');
    UPDATE ar_customer_account SET receivable_account_id = l_n WHERE id = l_acc;
    IF l_id IS NULL THEN
      INSERT INTO his_payer (company_id, code, name_ar, payer_type, customer_account_id, discount_pct, claim_days, contract_no, contract_from, contract_to,
                             phone, email, status_code)
      VALUES (company, l_code, l_name, l_type, l_acc, l_dis, l_days, l_cno, l_fr, l_to, l_ph, l_em, l_st)
      RETURNING id INTO l_id;
    ELSE
      UPDATE his_payer SET code = l_code, name_ar = l_name, payer_type = l_type, customer_account_id = l_acc, discount_pct = l_dis, claim_days = l_days,
                           contract_no = l_cno, contract_from = l_fr, contract_to = l_to, phone = l_ph, email = l_em, status_code = l_st
       WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  END save_payer;

  FUNCTION save_plan(p_id IN NUMBER, p_payer_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_patient_pct IN NUMBER,
                     p_max_share IN NUMBER DEFAULT NULL, p_approval_limit IN NUMBER DEFAULT NULL, p_excluded IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l NUMBER := p_id;
  BEGIN
    guard('HIS_PAYER.UPDATE');
    NOONA_CORE_PKG.assert(p_payer_id IS NOT NULL AND TRIM(p_code) IS NOT NULL AND TRIM(p_name_ar) IS NOT NULL, 'NOONA-HIS-024',
                          'الجهة ورمز الفئة واسمها إلزامية', 'Payer, code and name are required');
    NOONA_CORE_PKG.assert(NVL(p_patient_pct, 0) BETWEEN 0 AND 100, 'NOONA-HIS-025', 'نسبة تحمل المريض بين 0 و100', 'Patient share must be 0..100');
    IF l IS NULL THEN
      INSERT INTO his_payer_plan (company_id, payer_id, code, name_ar, patient_share_pct, max_patient_share, approval_limit, excluded_types, is_active)
      VALUES (company, p_payer_id, UPPER(TRIM(p_code)), TRIM(p_name_ar), NVL(p_patient_pct, 0), p_max_share, p_approval_limit,
              UPPER(REPLACE(p_excluded, ' ')), 'Y')
      RETURNING id INTO l;
    ELSE
      UPDATE his_payer_plan SET code = UPPER(TRIM(p_code)), name_ar = TRIM(p_name_ar), patient_share_pct = NVL(p_patient_pct, 0),
                                max_patient_share = p_max_share, approval_limit = p_approval_limit, excluded_types = UPPER(REPLACE(p_excluded, ' '))
       WHERE id = l AND company_id = company;
    END IF;
    RETURN l;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-026', 'رمز الفئة مستخدم لهذه الجهة', 'Plan code already exists');
  END save_plan;

  PROCEDURE set_payer_price(p_payer_id IN NUMBER, p_service_id IN NUMBER, p_price IN NUMBER, p_covered IN VARCHAR2 DEFAULT 'Y',
                            p_approval IN VARCHAR2 DEFAULT 'N') IS
  BEGIN
    guard('HIS_PAYER.UPDATE');
    NOONA_CORE_PKG.assert(p_price IS NULL OR p_price >= 0, 'NOONA-HIS-013', 'السعر لا يكون سالباً', 'Price cannot be negative');
    MERGE INTO his_payer_price p
    USING (SELECT p_payer_id pa, p_service_id s FROM dual) x ON (p.payer_id = x.pa AND p.service_id = x.s)
     WHEN MATCHED THEN UPDATE SET p.price = p_price, p.is_covered = NVL(p_covered, 'Y'), p.needs_approval = NVL(p_approval, 'N')
     WHEN NOT MATCHED THEN INSERT (company_id, payer_id, service_id, price, is_covered, needs_approval)
          VALUES (company, x.pa, x.s, p_price, NVL(p_covered, 'Y'), NVL(p_approval, 'N'));
  END set_payer_price;

  -- ================================================================ المرضى
  FUNCTION patient_label(p_patient_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT name_ar || ' (' || mrn || ')' INTO l FROM his_patient WHERE id = p_patient_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
  END patient_label;

  FUNCTION save_patient(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := l_o.get_number('id');
    l_name VARCHAR2(200) := TRIM(l_o.get_string('name'));
    l_ne   VARCHAR2(200) := l_o.get_string('name_en');
    l_g    VARCHAR2(1) := UPPER(l_o.get_string('gender'));
    l_b    DATE := d(l_o.get_string('birth'));
    l_it   VARCHAR2(30) := l_o.get_string('id_type');
    l_ino  VARCHAR2(30) := TRIM(l_o.get_string('id_no'));
    l_nat  VARCHAR2(2) := UPPER(l_o.get_string('nationality'));
    l_mob  VARCHAR2(30) := TRIM(l_o.get_string('mobile'));
    l_bl   VARCHAR2(5) := l_o.get_string('blood');
    l_al   VARCHAR2(1000) := l_o.get_string('allergies');
    l_ch   VARCHAR2(1000) := l_o.get_string('chronic');
    l_pl   NUMBER := l_o.get_number('plan');
    l_mem  VARCHAR2(50) := l_o.get_string('member');
    l_pol  VARCHAR2(50) := l_o.get_string('policy');
    l_ie   DATE := d(l_o.get_string('ins_expiry'));
    l_ad   VARCHAR2(500) := l_o.get_string('address');
    l_em   VARCHAR2(200) := l_o.get_string('emergency');
    l_n    NUMBER;
    l_mrn  VARCHAR2(30);
  BEGIN
    guard('HIS_PATIENT.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_name IS NOT NULL AND l_g IN ('M', 'F'), 'NOONA-HIS-030', 'اسم المريض والجنس إلزاميان', 'Name and gender are required');
    NOONA_CORE_PKG.assert(l_b IS NULL OR l_b <= TRUNC(SYSDATE), 'NOONA-HIS-031', 'تاريخ الميلاد في المستقبل', 'Birth date is in the future');
    -- الهوية الوطنية لمواطني دولة المنشأة: الجنسية من دولة الشركة إن لم تحدد (تبنى عليها ضريبة الخدمات الصحية للمواطن)
    IF l_nat IS NULL AND l_it = 'NATIONAL_ID' THEN
      l_nat := company_country;
    END IF;
    IF l_nat IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM ref_country WHERE country_code = l_nat;
      NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-HIS-032', 'رمز الجنسية غير معروف: ' || l_nat, 'Unknown nationality');
    END IF;
    IF l_ino IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM his_patient WHERE company_id = company AND id_no = l_ino AND id <> NVL(l_id, -1) AND status_code <> 'MERGED';
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-033', 'يوجد مريض مسجل بنفس رقم الهوية ' || l_ino, 'A patient with this ID already exists');
    END IF;
    NOONA_CORE_PKG.assert(l_pl IS NULL OR l_mem IS NOT NULL, 'NOONA-HIS-034', 'أدخل رقم عضوية التأمين/الجهة', 'Member number is required');
    IF l_id IS NULL THEN
      l_mrn := next_no('HIS_PATIENT', 'MRN');
      INSERT INTO his_patient (company_id, mrn, name_ar, name_en, gender, birth_date, id_type, id_no, nationality, mobile, blood_group, allergies,
                               chronic_diseases, payer_plan_id, member_no, policy_no, insurance_expiry, address, emergency_contact, status_code)
      VALUES (company, l_mrn, l_name, l_ne, l_g, l_b, l_it, l_ino, l_nat, l_mob, l_bl, l_al, l_ch, l_pl, l_mem, l_pol, l_ie, l_ad, l_em, 'ACTIVE')
      RETURNING id INTO l_id;
    ELSE
      UPDATE his_patient SET name_ar = l_name, name_en = l_ne, gender = l_g, birth_date = l_b, id_type = l_it, id_no = l_ino, nationality = l_nat,
                             mobile = l_mob, blood_group = l_bl, allergies = l_al, chronic_diseases = l_ch, payer_plan_id = l_pl, member_no = l_mem,
                             policy_no = l_pol, insurance_expiry = l_ie, address = l_ad, emergency_contact = l_em
       WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  END save_patient;

  FUNCTION find_patients_json(p_term IN VARCHAR2) RETURN CLOB IS
    l   CLOB;
    l_q VARCHAR2(200) := '%' || LOWER(TRIM(p_term)) || '%';
  BEGIN
    guard('HIS_PATIENT.VIEW');
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE id, 'mrn' VALUE mrn, 'n' VALUE name_ar, 'm' VALUE mobile, 'idno' VALUE id_no) RETURNING CLOB)
      INTO l
      FROM (SELECT id, mrn, name_ar, mobile, id_no FROM his_patient
             WHERE company_id = company AND status_code = 'ACTIVE'
               AND LOWER(mrn || ' ' || name_ar || ' ' || name_en || ' ' || mobile || ' ' || id_no) LIKE l_q
             ORDER BY name_ar)
     WHERE ROWNUM <= 30;
    RETURN NVL(l, TO_CLOB('[]'));
  END find_patients_json;

  -- ================================================================ المواعيد
  FUNCTION weekday_of(p_date IN DATE) RETURN NUMBER IS
  BEGIN
    RETURN MOD(TRUNC(p_date) - TRUNC(p_date, 'IW') + 1, 7) + 1;
  END weekday_of;

  FUNCTION free_slots(p_doctor_id IN NUMBER, p_date IN DATE) RETURN VARCHAR2 IS
    l_out VARCHAR2(4000);
    l_wd  NUMBER := weekday_of(p_date);   -- 1 = الأحد
    l_t   NUMBER;
    l_n   NUMBER;
    l_s   VARCHAR2(5);
    l_now NUMBER := CASE WHEN TRUNC(p_date) = TRUNC(SYSDATE) THEN mins(TO_CHAR(SYSDATE, 'HH24:MI')) ELSE -1 END;
  BEGIN
    FOR s IN (SELECT from_time, to_time, slot_minutes FROM his_doctor_schedule
               WHERE doctor_id = p_doctor_id AND weekday = l_wd AND effective_from <= p_date AND (effective_to IS NULL OR effective_to >= p_date)
               ORDER BY from_time) LOOP
      l_t := mins(s.from_time);
      WHILE l_t + s.slot_minutes <= mins(s.to_time) LOOP
        l_s := hhmi(l_t);
        SELECT COUNT(*) INTO l_n FROM his_appointment
         WHERE doctor_id = p_doctor_id AND appt_date = TRUNC(p_date) AND start_time = l_s AND status_code NOT IN ('CANCELLED', 'NO_SHOW');
        IF l_n = 0 AND l_t > l_now AND NVL(LENGTH(l_out), 0) < 3900 THEN
          l_out := l_out || CASE WHEN l_out IS NOT NULL THEN ',' END || '"' || hhmi(l_t) || '"';
        END IF;
        l_t := l_t + s.slot_minutes;
      END LOOP;
    END LOOP;
    RETURN '[' || l_out || ']';
  END free_slots;

  FUNCTION book(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_pat  NUMBER := l_o.get_number('patient');
    l_doc  NUMBER := l_o.get_number('doctor');
    l_dept NUMBER := l_o.get_number('dept');
    l_srv  NUMBER := l_o.get_number('service');
    l_dt   DATE := d(l_o.get_string('date'));
    l_tm   VARCHAR2(5) := l_o.get_string('time');
    l_ch   VARCHAR2(30) := NVL(l_o.get_string('channel'), 'PHONE');
    l_nt   VARCHAR2(500) := l_o.get_string('notes');
    l_slot NUMBER;
    l_n    NUMBER;
    l_id   NUMBER;
    l_wd   NUMBER;
    l_no   VARCHAR2(50);
    l_end  VARCHAR2(5);
  BEGIN
    guard('HIS_APPOINTMENT.CREATE');
    NOONA_CORE_PKG.assert(l_pat IS NOT NULL AND l_dt IS NOT NULL AND REGEXP_LIKE(l_tm, '^[0-2][0-9]:[0-5][0-9]$'), 'NOONA-HIS-040',
                          'المريض والتاريخ والوقت إلزامية', 'Patient, date and time are required');
    NOONA_CORE_PKG.assert(l_dt >= TRUNC(SYSDATE), 'NOONA-HIS-041', 'لا يحجز في تاريخ سابق', 'Cannot book in the past');
    IF l_doc IS NOT NULL THEN
      SELECT department_id, NVL(l_srv, consult_service_id) INTO l_n, l_srv FROM his_doctor WHERE id = l_doc AND company_id = company;
      l_dept := NVL(l_dept, l_n);
      l_wd := weekday_of(l_dt);
      SELECT MAX(slot_minutes) INTO l_slot FROM his_doctor_schedule
       WHERE doctor_id = l_doc AND weekday = l_wd AND from_time <= l_tm AND to_time > l_tm;
      NOONA_CORE_PKG.assert(l_slot IS NOT NULL, 'NOONA-HIS-042', 'الوقت خارج ساعات عمل الطبيب', 'Outside the doctor''s working hours');
      SELECT COUNT(*) INTO l_n FROM his_appointment
       WHERE doctor_id = l_doc AND appt_date = l_dt AND start_time = l_tm AND status_code NOT IN ('CANCELLED', 'NO_SHOW');
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-043', 'الموعد محجوز لمريض آخر؛ اختر وقتاً متاحاً', 'Slot already booked');
    END IF;
    NOONA_CORE_PKG.assert(l_dept IS NOT NULL, 'NOONA-HIS-044', 'اختر الطبيب أو القسم', 'Choose a doctor or department');
    SELECT COUNT(*) INTO l_n FROM his_appointment
     WHERE patient_id = l_pat AND appt_date = l_dt AND start_time = l_tm AND status_code NOT IN ('CANCELLED', 'NO_SHOW');
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-045', 'للمريض موعد آخر في نفس الوقت', 'Patient already has an appointment at this time');
    l_no := next_no('HIS_APPOINTMENT', 'AP-');
    l_end := CASE WHEN l_slot IS NOT NULL THEN hhmi(mins(l_tm) + l_slot) END;
    INSERT INTO his_appointment (company_id, appt_no, patient_id, doctor_id, department_id, service_id, appt_date, start_time, end_time, channel, notes,
                                 status_code)
    VALUES (company, l_no, l_pat, l_doc, l_dept, l_srv, l_dt, l_tm, l_end, l_ch, l_nt, 'BOOKED')
    RETURNING id INTO l_id;
    RETURN l_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-046', 'الطبيب غير موجود', 'Doctor not found');
  END book;

  PROCEDURE cancel_appointment(p_appointment_id IN NUMBER, p_reason IN VARCHAR2) IS
    l VARCHAR2(30);
  BEGIN
    guard('HIS_APPOINTMENT.UPDATE');
    SELECT status_code INTO l FROM his_appointment WHERE id = p_appointment_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l IN ('BOOKED', 'CONFIRMED'), 'NOONA-HIS-047', 'يلغى الموعد المحجوز فقط', 'Only booked appointments can be cancelled');
    UPDATE his_appointment SET status_code = 'CANCELLED', cancel_reason = SUBSTR(p_reason, 1, 500) WHERE id = p_appointment_id;
  END cancel_appointment;

  PROCEDURE mark_no_show(p_appointment_id IN NUMBER) IS
    l VARCHAR2(30);
  BEGIN
    guard('HIS_APPOINTMENT.UPDATE');
    SELECT status_code INTO l FROM his_appointment WHERE id = p_appointment_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l IN ('BOOKED', 'CONFIRMED'), 'NOONA-HIS-047', 'يلغى الموعد المحجوز فقط', 'Only booked appointments can be changed');
    UPDATE his_appointment SET status_code = 'NO_SHOW' WHERE id = p_appointment_id;
  END mark_no_show;

  -- ================================================================ التسعير والتغطية
  FUNCTION price_of(p_service_id NUMBER, p_plan_id NUMBER, p_bill_to VARCHAR2, p_ins_expiry DATE) RETURN t_price IS
    l     t_price;
    l_s   his_service%ROWTYPE;
    l_pl  his_payer_plan%ROWTYPE;
    l_pay his_payer%ROWTYPE;
    l_cp  NUMBER;
    l_cov VARCHAR2(1);
    l_apr VARCHAR2(1);
    l_n   NUMBER;
  BEGIN
    SELECT * INTO l_s FROM his_service WHERE id = p_service_id;
    l.unit := l_s.price; l.covered := 'N'; l.approval := 'N'; l.pct := 100;
    IF p_bill_to = 'PAYER' AND p_plan_id IS NOT NULL THEN
      SELECT * INTO l_pl FROM his_payer_plan WHERE id = p_plan_id;
      SELECT * INTO l_pay FROM his_payer WHERE id = l_pl.payer_id;
      SELECT COUNT(*), MAX(price), MAX(is_covered), MAX(needs_approval) INTO l_n, l_cp, l_cov, l_apr
        FROM his_payer_price WHERE payer_id = l_pay.id AND service_id = p_service_id;
      l.unit := NVL(l_cp, ROUND(l_s.price * (1 - NVL(l_pay.discount_pct, 0) / 100), 2));
      l.covered := CASE WHEN l_pay.status_code <> 'ACTIVE' OR l_pl.is_active = 'N' THEN 'N'
                        WHEN p_ins_expiry IS NOT NULL AND p_ins_expiry < TRUNC(SYSDATE) THEN 'N'
                        WHEN l_pay.contract_to IS NOT NULL AND l_pay.contract_to < TRUNC(SYSDATE) THEN 'N'
                        WHEN ',' || l_pl.excluded_types || ',' LIKE '%,' || l_s.service_type || ',%' THEN 'N'
                        WHEN l_n > 0 AND l_cov = 'N' THEN 'N' ELSE 'Y' END;
      IF l.covered = 'N' THEN
        l.unit := l_s.price;   -- غير المغطاة بالسعر النقدي على المريض
      ELSE
        l.pct := NVL(l_pl.patient_share_pct, 0);
        l.approval := CASE WHEN l_s.needs_approval = 'Y' OR l_apr = 'Y' OR (l_pl.approval_limit IS NOT NULL AND l.unit > l_pl.approval_limit)
                           THEN 'Y' ELSE 'N' END;
      END IF;
    END IF;
    RETURN l;
  END price_of;

  PROCEDURE recalc_visit(p_visit_id IN NUMBER) IS
    l_v    his_visit%ROWTYPE;
    l_p    his_patient%ROWTYPE;
    l_pl   his_payer_plan%ROWTYPE;
    l_pr   t_price;
    l_cap  NUMBER;
    l_used NUMBER := 0;
    l_rate NUMBER;
    l_gross NUMBER;
    l_net  NUMBER;
    l_pt   NUMBER;
    l_py   NUMBER;
  BEGIN
    SELECT * INTO l_v FROM his_visit WHERE id = p_visit_id;
    SELECT * INTO l_p FROM his_patient WHERE id = l_v.patient_id;
    -- السعودية: الخدمات الصحية الخاصة للمواطن بنسبة صفرية (تتحملها الدولة)
    l_rate := CASE WHEN l_p.nationality = 'SA' AND company_country = 'SA' THEN 0 ELSE c_vat END;
    IF l_v.bill_to = 'PAYER' AND l_v.payer_plan_id IS NOT NULL THEN
      SELECT * INTO l_pl FROM his_payer_plan WHERE id = l_v.payer_plan_id;
      l_cap := l_pl.max_patient_share;
      -- ما تحمله المريض في فواتير سابقة للزيارة نفسها يدخل في الحد الأعلى
      SELECT NVL(SUM(patient_net), 0) INTO l_used FROM his_order
       WHERE visit_id = p_visit_id AND invoice_id IS NOT NULL AND covered = 'Y' AND status_code <> 'CANCELLED';
    END IF;
    FOR o IN (SELECT id, service_id, quantity, status_code, approval_no FROM his_order
               WHERE visit_id = p_visit_id AND invoice_id IS NULL AND status_code <> 'CANCELLED' ORDER BY line_no FOR UPDATE) LOOP
      l_pr := price_of(o.service_id, l_v.payer_plan_id, l_v.bill_to, l_p.insurance_expiry);
      l_gross := ROUND(l_pr.unit * o.quantity, 2);
      l_net := l_gross;
      IF l_pr.covered = 'Y' THEN
        l_pt := ROUND(l_net * l_pr.pct / 100, 2);
        IF l_cap IS NOT NULL THEN
          l_pt := LEAST(l_pt, GREATEST(l_cap - l_used, 0));
        END IF;
        l_used := l_used + l_pt;
        l_py := l_net - l_pt;
      ELSE
        l_pt := l_net; l_py := 0;
      END IF;
      UPDATE his_order SET unit_price = l_pr.unit, gross_amount = l_gross, discount_amount = 0, patient_net = l_pt, payer_net = l_py,
                           vat_rate = l_rate, patient_vat = ROUND(l_pt * l_rate / 100, 2), payer_vat = ROUND(l_py * l_rate / 100, 2),
                           covered = l_pr.covered,
                           status_code = CASE WHEN o.status_code IN ('ORDERED', 'APPROVAL_PENDING')
                                              THEN CASE WHEN l_pr.approval = 'Y' AND o.approval_no IS NULL THEN 'APPROVAL_PENDING' ELSE 'ORDERED' END
                                              ELSE o.status_code END
       WHERE id = o.id;
    END LOOP;
    UPDATE his_visit v SET
      gross_amount = (SELECT NVL(SUM(gross_amount), 0) FROM his_order WHERE visit_id = v.id AND status_code <> 'CANCELLED'),
      patient_total = (SELECT NVL(SUM(patient_net + patient_vat), 0) FROM his_order WHERE visit_id = v.id AND status_code <> 'CANCELLED'),
      payer_total = (SELECT NVL(SUM(payer_net + payer_vat), 0) FROM his_order WHERE visit_id = v.id AND status_code <> 'CANCELLED')
     WHERE id = p_visit_id;
  END recalc_visit;

  -- ================================================================ الزيارات
  FUNCTION get_visit(p_id NUMBER) RETURN his_visit%ROWTYPE IS
    l his_visit%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM his_visit WHERE id = p_id AND company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-050', 'الزيارة غير موجودة', 'Visit not found');
  END get_visit;

  FUNCTION add_order(p_visit_id IN NUMBER, p_service_id IN NUMBER, p_qty IN NUMBER DEFAULT 1, p_ordered_by IN NUMBER DEFAULT NULL,
                     p_notes IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_v    his_visit%ROWTYPE := get_visit(p_visit_id);
    l_s    his_service%ROWTYPE;
    l_no   NUMBER;
    l_id   NUMBER;
  BEGIN
    guard('HIS_ORDER.CREATE');
    NOONA_CORE_PKG.assert(l_v.status_code = 'OPEN', 'NOONA-HIS-051', 'الزيارة مقفلة', 'Visit is closed');
    NOONA_CORE_PKG.assert(NVL(p_qty, 1) > 0, 'NOONA-HIS-052', 'الكمية يجب أن تكون موجبة', 'Quantity must be positive');
    BEGIN
      SELECT * INTO l_s FROM his_service WHERE id = p_service_id AND company_id = company AND status_code = 'ACTIVE';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-HIS-053', 'الخدمة غير موجودة أو موقوفة', 'Service not found');
    END;
    SELECT NVL(MAX(line_no), 0) + 1 INTO l_no FROM his_order WHERE visit_id = p_visit_id;
    INSERT INTO his_order (company_id, visit_id, line_no, service_id, department_id, quantity, ordered_by_id, unit_price, gross_amount, notes, status_code)
    VALUES (company, p_visit_id, l_no, p_service_id, NVL(l_s.department_id, l_v.department_id), NVL(p_qty, 1), NVL(p_ordered_by, l_v.doctor_id),
            l_s.price, 0, p_notes, 'ORDERED')
    RETURNING id INTO l_id;
    recalc_visit(p_visit_id);
    RETURN l_id;
  END add_order;

  FUNCTION open_visit(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_pat  NUMBER := l_o.get_number('patient');
    l_dept NUMBER := l_o.get_number('dept');
    l_doc  NUMBER := l_o.get_number('doctor');
    l_type VARCHAR2(30) := NVL(l_o.get_string('type'), 'OUTPATIENT');
    l_apt  NUMBER := l_o.get_number('appointment');
    l_bill VARCHAR2(30) := l_o.get_string('bill_to');
    l_apr  VARCHAR2(50) := l_o.get_string('approval');
    l_cc   VARCHAR2(1000) := l_o.get_string('complaint');
    l_p    his_patient%ROWTYPE;
    l_srv  NUMBER;
    l_id   NUMBER;
    l_x    NUMBER;
    l_n    NUMBER;
    l_vno  VARCHAR2(50);
  BEGIN
    guard('HIS_VISIT.CREATE');
    BEGIN
      SELECT * INTO l_p FROM his_patient WHERE id = l_pat AND company_id = company AND status_code = 'ACTIVE';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-HIS-054', 'المريض غير موجود', 'Patient not found');
    END;
    IF l_doc IS NOT NULL THEN
      SELECT NVL(l_dept, department_id), consult_service_id INTO l_dept, l_srv FROM his_doctor WHERE id = l_doc AND company_id = company;
    END IF;
    IF l_apt IS NOT NULL THEN
      SELECT NVL(service_id, l_srv) INTO l_srv FROM his_appointment WHERE id = l_apt;
    END IF;
    NOONA_CORE_PKG.assert(l_dept IS NOT NULL, 'NOONA-HIS-055', 'اختر القسم أو الطبيب', 'Choose a department or doctor');
    -- زيارة مفتوحة للمريض في نفس القسم اليوم تعاد بدل فتح أخرى
    SELECT MIN(id) INTO l_x FROM his_visit
     WHERE patient_id = l_pat AND department_id = l_dept AND status_code = 'OPEN' AND visit_at >= CAST(TRUNC(SYSDATE) AS TIMESTAMP)
       AND (l_bill IS NULL OR bill_to = l_bill);   -- طلب طريقة دفع أخرى (نقدي بدل التأمين) يفتح زيارة مستقلة
    IF l_x IS NOT NULL AND l_apt IS NULL THEN
      RETURN l_x;
    END IF;
    l_bill := NVL(l_bill, CASE WHEN l_p.payer_plan_id IS NOT NULL AND NVL(l_p.insurance_expiry, SYSDATE) >= TRUNC(SYSDATE) THEN 'PAYER' ELSE 'CASH' END);
    NOONA_CORE_PKG.assert(l_bill = 'CASH' OR l_p.payer_plan_id IS NOT NULL, 'NOONA-HIS-056', 'المريض غير مسجل على تأمين أو جهة متعاقدة',
                          'Patient has no payer');
    l_vno := next_no('HIS_VISIT', 'V-');
    INSERT INTO his_visit (company_id, branch_id, visit_no, visit_type, patient_id, department_id, doctor_id, appointment_id, visit_at, bill_to,
                           payer_plan_id, approval_no, chief_complaint, status_code)
    VALUES (company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), l_vno, l_type, l_pat, l_dept, l_doc, l_apt, SYSTIMESTAMP,
            l_bill, CASE WHEN l_bill = 'PAYER' THEN l_p.payer_plan_id END, l_apr, l_cc, 'OPEN')
    RETURNING id INTO l_id;
    IF l_apt IS NOT NULL THEN
      UPDATE his_appointment SET status_code = 'ARRIVED', visit_id = l_id WHERE id = l_apt;
    END IF;
    IF l_srv IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM his_service WHERE id = l_srv AND status_code = 'ACTIVE';
      IF l_n > 0 THEN
        l_x := add_order(l_id, l_srv, 1, l_doc);
      END IF;
    END IF;
    RETURN l_id;
  END open_visit;

  FUNCTION arrive(p_appointment_id IN NUMBER) RETURN NUMBER IS
    l_a his_appointment%ROWTYPE;
    l_doc CLOB;
  BEGIN
    SELECT * INTO l_a FROM his_appointment WHERE id = p_appointment_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_a.status_code IN ('BOOKED', 'CONFIRMED'), 'NOONA-HIS-048', 'الموعد ليس محجوزاً (' || appt_status_label(l_a.status_code) || ')',
                          'Appointment is not booked');
    SELECT JSON_OBJECT('patient' VALUE l_a.patient_id, 'dept' VALUE l_a.department_id, 'doctor' VALUE l_a.doctor_id, 'appointment' VALUE l_a.id)
      INTO l_doc FROM dual;
    RETURN open_visit(l_doc);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-049', 'الموعد غير موجود', 'Appointment not found');
  END arrive;

  PROCEDURE update_visit(p_doc IN CLOB) IS
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id NUMBER := l_o.get_number('id');
    l_v  his_visit%ROWTYPE := get_visit(l_id);
    l_cc VARCHAR2(1000) := l_o.get_string('complaint');
    l_dg VARCHAR2(1000) := l_o.get_string('diagnosis');
    l_ic VARCHAR2(100) := l_o.get_string('icd10');
    l_vt VARCHAR2(1000) := l_o.get_string('vitals');
    l_nt VARCHAR2(4000) := l_o.get_string('notes');
    l_ap VARCHAR2(50) := l_o.get_string('approval');
  BEGIN
    guard('HIS_VISIT.UPDATE');
    NOONA_CORE_PKG.assert(l_v.status_code = 'OPEN', 'NOONA-HIS-051', 'الزيارة مقفلة', 'Visit is closed');
    UPDATE his_visit SET chief_complaint = NVL(l_cc, chief_complaint), diagnosis = NVL(l_dg, diagnosis), icd10 = NVL(l_ic, icd10),
                         vitals = NVL(l_vt, vitals), doctor_notes = NVL(l_nt, doctor_notes), approval_no = NVL(l_ap, approval_no)
     WHERE id = l_id;
  END update_visit;

  FUNCTION get_order(p_id NUMBER) RETURN his_order%ROWTYPE IS
    l his_order%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM his_order WHERE id = p_id AND company_id = company FOR UPDATE;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-060', 'الطلب غير موجود', 'Order not found');
  END get_order;

  PROCEDURE cancel_order(p_order_id IN NUMBER, p_reason IN VARCHAR2) IS
    l his_order%ROWTYPE := get_order(p_order_id);
  BEGIN
    guard('HIS_ORDER.UPDATE');
    NOONA_CORE_PKG.assert(l.status_code IN ('ORDERED', 'APPROVAL_PENDING'), 'NOONA-HIS-061', 'لا يلغى طلب بدأ تنفيذه أو أنجز', 'Order already started');
    NOONA_CORE_PKG.assert(l.invoice_id IS NULL, 'NOONA-HIS-062', 'الطلب مفوتر؛ ألغ الفاتورة أولاً', 'Order is invoiced; cancel the invoice first');
    UPDATE his_order SET status_code = 'CANCELLED', notes = SUBSTR(NVL(p_reason, notes), 1, 500) WHERE id = p_order_id;
    recalc_visit(l.visit_id);
  END cancel_order;

  PROCEDURE set_approval(p_order_id IN NUMBER, p_approval_no IN VARCHAR2, p_approved IN VARCHAR2 DEFAULT 'Y') IS
    l his_order%ROWTYPE := get_order(p_order_id);
    l_v his_visit%ROWTYPE;
  BEGIN
    guard('HIS_ORDER.UPDATE');
    NOONA_CORE_PKG.assert(l.status_code = 'APPROVAL_PENDING', 'NOONA-HIS-063', 'الطلب لا ينتظر موافقة', 'Order is not pending approval');
    IF p_approved = 'Y' THEN
      NOONA_CORE_PKG.assert(TRIM(p_approval_no) IS NOT NULL, 'NOONA-HIS-064', 'أدخل رقم الموافقة', 'Approval number is required');
      UPDATE his_order SET approval_no = TRIM(p_approval_no), status_code = 'ORDERED' WHERE id = p_order_id;
    ELSE
      -- الرفض: تتحول الخدمة نقدية على المريض
      l_v := get_visit(l.visit_id);
      UPDATE his_order SET covered = 'N', unit_price = (SELECT price FROM his_service WHERE id = l.service_id), status_code = 'ORDERED',
                           notes = SUBSTR('رفض التأمين: ' || p_approval_no || ' ' || notes, 1, 500)
       WHERE id = p_order_id;
      UPDATE his_order SET gross_amount = ROUND(unit_price * quantity, 2), patient_net = ROUND(unit_price * quantity, 2), payer_net = 0, payer_vat = 0,
                           patient_vat = ROUND(ROUND(unit_price * quantity, 2) * vat_rate / 100, 2)
       WHERE id = p_order_id;
      UPDATE his_visit v SET
        gross_amount = (SELECT NVL(SUM(gross_amount), 0) FROM his_order WHERE visit_id = v.id AND status_code <> 'CANCELLED'),
        patient_total = (SELECT NVL(SUM(patient_net + patient_vat), 0) FROM his_order WHERE visit_id = v.id AND status_code <> 'CANCELLED'),
        payer_total = (SELECT NVL(SUM(payer_net + payer_vat), 0) FROM his_order WHERE visit_id = v.id AND status_code <> 'CANCELLED')
       WHERE id = l.visit_id;
    END IF;
  END set_approval;

  PROCEDURE set_billing(p_visit_id IN NUMBER, p_bill_to IN VARCHAR2) IS
    l_v his_visit%ROWTYPE := get_visit(p_visit_id);
    l_p his_patient%ROWTYPE;
  BEGIN
    guard('HIS_VISIT.UPDATE');
    NOONA_CORE_PKG.assert(l_v.status_code = 'OPEN', 'NOONA-HIS-051', 'الزيارة مقفلة', 'Visit is closed');
    NOONA_CORE_PKG.assert(p_bill_to IN ('CASH', 'PAYER'), 'NOONA-HIS-057', 'طريقة الدفع نقدي أو تأمين', 'Billing must be CASH or PAYER');
    SELECT * INTO l_p FROM his_patient WHERE id = l_v.patient_id;
    NOONA_CORE_PKG.assert(p_bill_to = 'CASH' OR l_p.payer_plan_id IS NOT NULL, 'NOONA-HIS-056', 'المريض غير مسجل على تأمين أو جهة متعاقدة',
                          'Patient has no coverage');
    UPDATE his_visit SET bill_to = p_bill_to, payer_plan_id = CASE WHEN p_bill_to = 'PAYER' THEN l_p.payer_plan_id END,
                         eligibility_status = CASE WHEN p_bill_to = 'CASH' THEN NULL ELSE eligibility_status END
     WHERE id = p_visit_id;
    -- النقدي لا يحتاج موافقات: تلغى حالة انتظار الموافقة؛ التأمين يعيدها حسب العقد
    UPDATE his_order SET status_code = 'ORDERED' WHERE visit_id = p_visit_id AND status_code = 'APPROVAL_PENDING' AND invoice_id IS NULL;
    recalc_visit(p_visit_id);
  END set_billing;

  FUNCTION is_open(p_visit_id IN NUMBER) RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM his_visit WHERE id = p_visit_id AND company_id = company AND status_code = 'OPEN';
    RETURN CASE WHEN l > 0 THEN 'Y' ELSE 'N' END;
  END is_open;

  PROCEDURE close_visit(p_visit_id IN NUMBER) IS
    l_v his_visit%ROWTYPE := get_visit(p_visit_id);
    l_n NUMBER;
  BEGIN
    guard('HIS_VISIT.UPDATE');
    NOONA_CORE_PKG.assert(l_v.status_code = 'OPEN', 'NOONA-HIS-051', 'الزيارة مقفلة', 'Visit is closed');
    -- الصرف من الصيدلية الداخلية اختياري: أدوية الوصفات غير المسددة تلغى عند الإقفال وتبقى الوصفة سارية للصرف لاحقاً أو خارجياً
    FOR r IN (SELECT o.id, l.id lid FROM his_order o JOIN his_prescription_line l ON l.order_id = o.id
               WHERE o.visit_id = p_visit_id AND o.invoice_id IS NULL AND o.status_code IN ('ORDERED', 'APPROVAL_PENDING')) LOOP
      UPDATE his_prescription_line SET order_id = NULL WHERE id = r.lid;
      cancel_order(r.id, 'Not dispensed at visit closure');
    END LOOP;
    SELECT COUNT(*) INTO l_n FROM his_order WHERE visit_id = p_visit_id AND status_code <> 'CANCELLED' AND invoice_id IS NULL;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-065', 'توجد خدمات غير مفوترة؛ فوترها أو ألغها قبل إقفال الزيارة', 'Unbilled services remain');
    UPDATE his_visit SET status_code = 'CLOSED', closed_at = SYSTIMESTAMP WHERE id = p_visit_id;
    UPDATE his_appointment SET status_code = 'COMPLETED' WHERE visit_id = p_visit_id AND status_code = 'ARRIVED';
  END close_visit;

  -- ================================================================ التنفيذ
  PROCEDURE assert_payable(p_o his_order%ROWTYPE) IS
    l_t VARCHAR2(30);
  BEGIN
    SELECT visit_type INTO l_t FROM his_visit WHERE id = p_o.visit_id;
    -- العيادات الخارجية: تسدد قبل التنفيذ؛ الطوارئ والتنويم تنفذ ثم تفوتر
    NOONA_CORE_PKG.assert(p_o.invoice_id IS NOT NULL OR l_t IN ('EMERGENCY', 'INPATIENT', 'DAY_CASE'), 'NOONA-HIS-066',
                          'الخدمة لم تسدد بعد؛ حوّل المريض للمحاسبة', 'Service is not paid yet');
    NOONA_CORE_PKG.assert(p_o.status_code <> 'APPROVAL_PENDING', 'NOONA-HIS-067', 'الخدمة بانتظار موافقة التأمين', 'Pending insurance approval');
  END assert_payable;

  FUNCTION collect_sample(p_order_id IN NUMBER) RETURN VARCHAR2 IS
    l his_order%ROWTYPE := get_order(p_order_id);
    l_no VARCHAR2(30);
  BEGIN
    guard('HIS_ORDER.UPDATE');
    assert_payable(l);
    NOONA_CORE_PKG.assert(l.status_code IN ('ORDERED', 'IN_PROGRESS'), 'NOONA-HIS-068', 'حالة الطلب لا تسمح', 'Invalid order status');
    l_no := NVL(l.sample_no, next_no('HIS_SAMPLE', 'S', 'HIS_ORDER'));
    UPDATE his_order SET sample_no = l_no, sample_at = NVL(sample_at, SYSTIMESTAMP), status_code = 'IN_PROGRESS', started_at = NVL(started_at, SYSTIMESTAMP)
     WHERE id = p_order_id;
    RETURN l_no;
  END collect_sample;

  PROCEDURE start_order(p_order_id IN NUMBER) IS
    l his_order%ROWTYPE := get_order(p_order_id);
  BEGIN
    guard('HIS_ORDER.UPDATE');
    assert_payable(l);
    NOONA_CORE_PKG.assert(l.status_code = 'ORDERED', 'NOONA-HIS-068', 'حالة الطلب لا تسمح', 'Invalid order status');
    UPDATE his_order SET status_code = 'IN_PROGRESS', started_at = SYSTIMESTAMP WHERE id = p_order_id;
  END start_order;

  PROCEDURE complete_order(p_order_id IN NUMBER, p_result IN CLOB, p_flag IN VARCHAR2 DEFAULT 'NORMAL', p_performer IN NUMBER DEFAULT NULL) IS
    l      his_order%ROWTYPE := get_order(p_order_id);
    l_dep  his_department%ROWTYPE;
    l_lines VARCHAR2(32767);
    l_doc  CLOB;
    l_txn  NUMBER;
    l_cost NUMBER;
    l_vno  VARCHAR2(30);
    l_sn   VARCHAR2(200);
  BEGIN
    guard('HIS_ORDER.UPDATE');
    assert_payable(l);
    NOONA_CORE_PKG.assert(l.status_code IN ('ORDERED', 'IN_PROGRESS'), 'NOONA-HIS-068', 'حالة الطلب لا تسمح', 'Invalid order status');
    SELECT * INTO l_dep FROM his_department WHERE id = l.department_id;
    -- صرف مواد الخدمة (كواشف، أنابيب، أفلام، مستلزمات) من مستودع القسم لمركز تكلفته
    FOR m IN (SELECT item_id, quantity * l.quantity q FROM his_service_material WHERE service_id = l.service_id
              UNION ALL   -- الدواء نفسه للخدمات الدوائية (الصرف من الصيدلية)
              SELECT item_id, l.quantity FROM his_service WHERE id = l.service_id AND item_id IS NOT NULL) LOOP
      l_lines := l_lines || CASE WHEN l_lines IS NOT NULL THEN ',' END || '{"i":' || m.item_id || ',"q":'
              || TO_CHAR(m.q, 'FM9999999990D999999', 'NLS_NUMERIC_CHARACTERS=''.,''') || '}';
    END LOOP;
    IF l_lines IS NOT NULL THEN
      NOONA_CORE_PKG.assert(l_dep.warehouse_id IS NOT NULL, 'NOONA-HIS-069', 'القسم ' || l_dep.name_ar || ' ليس له مستودع لصرف المواد',
                            'Department has no warehouse');
      SELECT v.visit_no, s.name_ar INTO l_vno, l_sn FROM his_visit v, his_service s WHERE v.id = l.visit_id AND s.id = l.service_id;
      l_doc := '{"type":"CONSUMPTION","date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '","wh":' || l_dep.warehouse_id || ',"cc":' || l_dep.cost_center_id
            || ',"desc":' || NOONA_CORE_PKG.json_text(SUBSTR('مواد ' || l_sn || ' - زيارة ' || l_vno, 1, 200)) || ',"action":"POST","lines":[' || l_lines || ']}';
      l_txn := NOONA_INV_PKG.save_stock_doc(l_doc);
      SELECT NVL(SUM(ABS(total_cost)), 0) INTO l_cost FROM inv_transaction_line WHERE transaction_id = l_txn;
    END IF;
    UPDATE his_order SET status_code = 'COMPLETED', completed_at = SYSTIMESTAMP, started_at = NVL(started_at, SYSTIMESTAMP), result_text = p_result,
                         result_flag = NVL(p_flag, 'NORMAL'), result_by = NOONA_CTX_PKG.current_user_name,
                         performed_by_id = NVL(p_performer, performed_by_id), material_txn_id = l_txn, material_cost = l_cost
     WHERE id = p_order_id;
  END complete_order;

  -- ================================================================ الفوترة
  FUNCTION unbilled_total(p_visit_id IN NUMBER, p_part IN VARCHAR2 DEFAULT 'PATIENT') RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(CASE WHEN p_part = 'PATIENT' THEN patient_net + patient_vat ELSE payer_net + payer_vat END), 0) INTO l
      FROM his_order WHERE visit_id = p_visit_id AND invoice_id IS NULL AND status_code NOT IN ('CANCELLED', 'APPROVAL_PENDING');
    RETURN l;
  END unbilled_total;

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
    p_lines(p_lines.COUNT).cost_center_id := CASE WHEN p_cc IS NOT NULL AND NOONA_GL_PKG.cc_rule(p_acc) <> 'FORBIDDEN' THEN p_cc END;
  END add_line;

  -- حساب عميل للمريض (للمتبقي على حسابه) عند الحاجة
  FUNCTION patient_account(p_patient his_patient%ROWTYPE) RETURN NUMBER IS
    l_acc NUMBER := p_patient.customer_account_id;
    l_rec NUMBER;
    l_doc CLOB;
  BEGIN
    IF l_acc IS NULL THEN
      SELECT JSON_OBJECT('name' VALUE p_patient.name_ar || ' - ' || p_patient.mrn, 'person' VALUE 'Y', 'phone' VALUE p_patient.mobile, 'term' VALUE 'NET30'
                         RETURNING CLOB) INTO l_doc FROM dual;
      l_acc := NOONA_SAL_PKG.save_customer(l_doc);
      l_rec := need_acc('1115');
      UPDATE ar_customer_account SET receivable_account_id = l_rec WHERE id = l_acc;
      UPDATE his_patient SET customer_account_id = l_acc WHERE id = p_patient.id;
    END IF;
    RETURN l_acc;
  END patient_account;

  PROCEDURE open_item(p_acc NUMBER, p_inv NUMBER, p_no VARCHAR2, p_amount NUMBER, p_days NUMBER, p_branch NUMBER) IS
  BEGIN
    INSERT INTO ar_open_item (company_id, branch_id, source_entity_type, source_entity_id, currency_code, exchange_rate, customer_account_id,
                              item_type, doc_no, doc_date, due_date, installment_no, original_amount, open_amount, original_func, open_func, status_code)
    VALUES (company, p_branch, c_inv, p_inv, NOONA_GL_PKG.ledger_currency, 1, p_acc, 'INVOICE', p_no, TRUNC(SYSDATE), TRUNC(SYSDATE) + NVL(p_days, 30),
            1, p_amount, p_amount, p_amount, p_amount, 'OPEN');
  END open_item;

  FUNCTION create_invoice(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_vid   NUMBER := l_o.get_number('visit');
    l_meth  VARCHAR2(30) := NVL(l_o.get_string('method'), 'CASH');
    l_place VARCHAR2(30) := l_o.get_string('place');
    l_ref   VARCHAR2(100) := l_o.get_string('ref');
    l_v     his_visit%ROWTYPE;
    l_p     his_patient%ROWTYPE;
    l_pay   his_payer%ROWTYPE;
    l_mt    VARCHAR2(30);
    l_id    NUMBER;
    l_no    VARCHAR2(50);
    l_n     NUMBER;
    l_gross NUMBER; l_pn NUMBER; l_pv NUMBER; l_yn NUMBER; l_yv NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
    l_ev    NUMBER;
    l_pacc  NUMBER;
    l_desc  VARCHAR2(1000);
    l_rec   NUMBER;
    l_cc    NUMBER;
  BEGIN
    guard('HIS_INVOICE.CREATE');
    l_v := get_visit(l_vid);
    SELECT * INTO l_p FROM his_patient WHERE id = l_v.patient_id;
    recalc_visit(l_vid);
    SELECT COUNT(*), NVL(SUM(gross_amount), 0), NVL(SUM(patient_net), 0), NVL(SUM(patient_vat), 0), NVL(SUM(payer_net), 0), NVL(SUM(payer_vat), 0)
      INTO l_n, l_gross, l_pn, l_pv, l_yn, l_yv
      FROM his_order WHERE visit_id = l_vid AND invoice_id IS NULL AND status_code NOT IN ('CANCELLED', 'APPROVAL_PENDING');
    NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-HIS-070', 'لا توجد خدمات جاهزة للفوترة في الزيارة', 'Nothing to invoice');
    IF l_pn + l_pv > 0 THEN
      SELECT MAX(method_type) INTO l_mt FROM ref_payment_method WHERE code = l_meth AND is_active = 'Y';
      NOONA_CORE_PKG.assert(l_mt IS NOT NULL, 'NOONA-HIS-071', 'طريقة الدفع غير معرفة: ' || l_meth, 'Unknown payment method');
      IF l_mt <> 'CREDIT' THEN
        IF l_place IS NULL THEN
          IF l_mt = 'CASH' THEN
            SELECT 'BOX:' || MIN(id) INTO l_place FROM csh_cash_box WHERE company_id = company AND status_code = 'ACTIVE';
          ELSE
            SELECT 'BANK:' || MIN(id) INTO l_place FROM csh_bank_account WHERE company_id = company AND status_code = 'ACTIVE';
          END IF;
        END IF;
        NOONA_CORE_PKG.assert(l_place IS NOT NULL AND l_place NOT IN ('BOX:', 'BANK:'), 'NOONA-HIS-072', 'اختر الصندوق أو البنك المستلم',
                              'Choose the cash box or bank');
      END IF;
    END IF;
    IF l_v.bill_to = 'PAYER' AND l_yn + l_yv > 0 THEN
      SELECT y.* INTO l_pay FROM his_payer y JOIN his_payer_plan p ON p.payer_id = y.id WHERE p.id = l_v.payer_plan_id;
    END IF;
    l_no := next_no(c_inv, 'MI-');
    INSERT INTO his_invoice (company_id, branch_id, doc_no, doc_date, visit_id, patient_id, payer_id, gross_amount, discount_amount, patient_net, patient_vat,
                             payer_net, payer_vat, patient_total, payer_total, paid_amount, payment_method, payment_place, payment_ref, claim_status,
                             status_code)
    VALUES (company, l_v.branch_id, l_no, TRUNC(SYSDATE), l_vid, l_v.patient_id, l_pay.id, l_gross, 0, l_pn, l_pv, l_yn, l_yv, l_pn + l_pv, l_yn + l_yv,
            CASE WHEN l_mt <> 'CREDIT' THEN l_pn + l_pv ELSE 0 END, CASE WHEN l_pn + l_pv > 0 THEN l_meth END, l_place, l_ref,
            CASE WHEN l_yn + l_yv > 0 THEN 'PENDING' ELSE 'NONE' END, 'POSTED')
    RETURNING id INTO l_id;
    UPDATE his_order SET invoice_id = l_id WHERE visit_id = l_vid AND invoice_id IS NULL AND status_code NOT IN ('CANCELLED', 'APPROVAL_PENDING');
    -- القيد: المريض (نقد/بنك أو ذمته) + الجهة (ذمتها) = الإيراد حسب نوع الخدمة ومركز تكلفة القسم + الضريبة
    l_desc := 'فاتورة ' || l_no || ' - ' || patient_label(l_v.patient_id) || ' - زيارة ' || l_v.visit_no;
    IF l_pn + l_pv > 0 THEN
      IF l_mt = 'CREDIT' THEN
        l_pacc := patient_account(l_p);
        SELECT receivable_account_id INTO l_rec FROM ar_customer_account WHERE id = l_pacc;
        l_rec := NVL(l_rec, need_acc('1115'));
        add_line(l_lines, l_rec, l_pn + l_pv, 0, 'حصة المريض على حسابه - ' || l_desc, NOONA_SAL_PKG.customer_party(l_pacc));
        open_item(l_pacc, l_id, l_no, l_pn + l_pv, 30, l_v.branch_id);
      ELSE
        add_line(l_lines, NOONA_CSH_PKG.place_account(l_place), l_pn + l_pv, 0, 'تحصيل حصة المريض - ' || l_desc);
      END IF;
    END IF;
    IF l_yn + l_yv > 0 THEN
      SELECT receivable_account_id INTO l_rec FROM ar_customer_account WHERE id = l_pay.customer_account_id;
      l_rec := NVL(l_rec, need_acc('1114'));
      add_line(l_lines, l_rec, l_yn + l_yv, 0, 'مطالبة ' || l_pay.name_ar || ' - ' || l_desc, NOONA_SAL_PKG.customer_party(l_pay.customer_account_id));
      open_item(l_pay.customer_account_id, l_id, l_no, l_yn + l_yv, l_pay.claim_days, l_v.branch_id);
    END IF;
    FOR r IN (SELECT NVL(d.revenue_account_id, acc(revenue_code(s.service_type))) racc, d.cost_center_id cc, SUM(o.patient_net + o.payer_net) net
                FROM his_order o JOIN his_service s ON s.id = o.service_id JOIN his_department d ON d.id = o.department_id
               WHERE o.invoice_id = l_id
               GROUP BY NVL(d.revenue_account_id, acc(revenue_code(s.service_type))), d.cost_center_id) LOOP
      add_line(l_lines, NVL(r.racc, need_acc('4127')), 0, r.net, 'إيرادات طبية - ' || l_desc, NULL, r.cc);
    END LOOP;
    IF l_pv + l_yv > 0 THEN
      add_line(l_lines, need_acc('2104'), 0, l_pv + l_yv, 'ضريبة القيمة المضافة - ' || l_desc);
    END IF;
    IF l_lines.COUNT >= 2 THEN
      l_j := NOONA_ACE_PKG.post_source('HIS_INVOICE_POSTED', 'MEDICAL', c_inv, l_id, TRUNC(SYSDATE), l_desc, NOONA_GL_PKG.ledger_currency, 1, l_lines,
                                       l_no, l_v.branch_id, 'MEDICAL');
      SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
      UPDATE his_invoice SET accounting_event_id = l_ev, posted_at = SYSTIMESTAMP, posted_by = NOONA_CTX_PKG.current_user_name WHERE id = l_id;
    END IF;
    UPDATE his_visit SET paid_amount = paid_amount + CASE WHEN l_mt <> 'CREDIT' THEN l_pn + l_pv ELSE 0 END WHERE id = l_vid;
    NOONA_AUDIT_PKG.log_event('POSTING', c_inv, l_id, 'POST', 'SUCCESS');
    RETURN l_id;
  END create_invoice;

  PROCEDURE cancel_invoice(p_invoice_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_i his_invoice%ROWTYPE;
    l_n NUMBER;
    l_j NUMBER;
  BEGIN
    guard('HIS_INVOICE.UPDATE');
    SELECT * INTO l_i FROM his_invoice WHERE id = p_invoice_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_i.status_code = 'POSTED', 'NOONA-HIS-073', 'الفاتورة ملغاة سابقاً', 'Invoice already cancelled');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-HIS-074', 'اذكر سبب الإلغاء', 'Reason is required');
    SELECT COUNT(*) INTO l_n FROM his_order WHERE invoice_id = p_invoice_id AND status_code IN ('IN_PROGRESS', 'COMPLETED');
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-075', 'بدأ تنفيذ بعض خدمات الفاتورة؛ لا تلغى', 'Some services were already performed');
    SELECT COUNT(*) INTO l_n FROM his_order WHERE invoice_id = p_invoice_id AND commission_id IS NOT NULL;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-077', 'سويت عمولة الطبيب عن خدمات الفاتورة؛ ألغ التسوية أولاً', 'Doctor commission already settled');
    SELECT COUNT(*) INTO l_n FROM ar_open_item WHERE source_entity_type = c_inv AND source_entity_id = p_invoice_id AND open_amount <> original_amount;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-076', 'حصل جزء من مطالبة الفاتورة؛ اعكس التحصيل أولاً', 'Part of the invoice was collected');
    IF l_i.accounting_event_id IS NOT NULL THEN
      l_j := NOONA_ACE_PKG.reverse_source(c_inv, p_invoice_id, TRUNC(SYSDATE), p_reason);
    END IF;
    UPDATE ar_open_item SET open_amount = 0, open_func = 0, status_code = 'CANCELLED' WHERE source_entity_type = c_inv AND source_entity_id = p_invoice_id;
    UPDATE his_order SET invoice_id = NULL WHERE invoice_id = p_invoice_id;
    UPDATE his_invoice SET status_code = 'CANCELLED', claim_status = 'NONE' WHERE id = p_invoice_id;
    UPDATE his_visit SET paid_amount = paid_amount - l_i.paid_amount WHERE id = l_i.visit_id;
    NOONA_AUDIT_PKG.log_event('POSTING', c_inv, p_invoice_id, 'CANCEL', 'SUCCESS', p_new_values => '{"reason":' || NOONA_CORE_PKG.json_text(p_reason) || '}');
  END cancel_invoice;

  -- ================================================================ الأقسام والخدمات النموذجية
  FUNCTION seed_catalog RETURN NUMBER IS
    l_n NUMBER := 0;
    l_x NUMBER;
    TYPE t_map IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
    dp t_map;
    FUNCTION dep(p_code VARCHAR2, p_name VARCHAR2, p_type VARCHAR2, p_spec VARCHAR2, p_store VARCHAR2 DEFAULT 'N') RETURN NUMBER IS
      l NUMBER;
    BEGIN
      SELECT MIN(id) INTO l FROM his_department WHERE company_id = company AND code = p_code;
      IF l IS NULL THEN
        l := save_department(NULL, p_code, p_name, p_type, p_spec, p_store);
        l_n := l_n + 1;
      END IF;
      RETURN l;
    END dep;
    PROCEDURE srv(p_code VARCHAR2, p_name VARCHAR2, p_type VARCHAR2, p_dept VARCHAR2, p_price NUMBER, p_mod VARCHAR2 DEFAULT NULL,
                  p_sample VARCHAR2 DEFAULT NULL, p_tat NUMBER DEFAULT NULL, p_range VARCHAR2 DEFAULT NULL, p_apr VARCHAR2 DEFAULT 'N',
                  p_en VARCHAR2 DEFAULT NULL) IS
      l NUMBER;
      l_doc CLOB;
    BEGIN
      SELECT COUNT(*) INTO l FROM his_service WHERE company_id = company AND code = p_code;
      IF l = 0 THEN
        SELECT JSON_OBJECT('code' VALUE p_code, 'name' VALUE p_name, 'name_en' VALUE p_en, 'type' VALUE p_type, 'dept' VALUE dp(p_dept),
                           'price' VALUE p_price, 'modality' VALUE p_mod, 'sample' VALUE p_sample, 'tat' VALUE p_tat, 'range' VALUE p_range,
                           'approval' VALUE p_apr)
          INTO l_doc FROM dual;
        l := save_service(l_doc);
      ELSE
        -- تحميل سابق: الاسم الإنجليزي للفحوص والأشعة إن لم يكن معرفاً
        UPDATE his_service SET name_en = p_en WHERE company_id = company AND code = p_code AND name_en IS NULL;
      END IF;
    END srv;
  BEGIN
    guard('HIS_DEPARTMENT.CREATE');
    l_x := quick_setup;
    -- العيادات
    dp('IM') := dep('IM', 'عيادة الباطنة', 'CLINIC', 'باطنة');
    dp('PED') := dep('PED', 'عيادة الأطفال', 'CLINIC', 'أطفال');
    dp('OBG') := dep('OBG', 'عيادة النساء والولادة', 'CLINIC', 'نساء وولادة');
    dp('ORTH') := dep('ORTH', 'عيادة العظام', 'CLINIC', 'عظام');
    dp('DERM') := dep('DERM', 'عيادة الجلدية', 'CLINIC', 'جلدية');
    dp('ENT') := dep('ENT', 'عيادة الأنف والأذن والحنجرة', 'CLINIC', 'أنف وأذن وحنجرة');
    dp('DENT') := dep('DENT', 'عيادة الأسنان', 'DENTAL', 'أسنان', 'Y');
    dp('ER') := dep('ER', 'الطوارئ', 'EMERGENCY', 'طوارئ', 'Y');
    -- معامل منفصلة بمستودعاتها
    dp('LCHEM') := dep('LCHEM', 'معمل الكيمياء الحيوية', 'LAB', 'كيمياء حيوية', 'Y');
    dp('LHEM') := dep('LHEM', 'معمل أمراض الدم', 'LAB', 'أمراض دم', 'Y');
    dp('LMIC') := dep('LMIC', 'معمل الأحياء الدقيقة', 'LAB', 'أحياء دقيقة', 'Y');
    dp('LIMM') := dep('LIMM', 'معمل المناعة والهرمونات', 'LAB', 'مناعة وهرمونات', 'Y');
    dp('LPATH') := dep('LPATH', 'معمل الأنسجة والخلايا', 'LAB', 'علم الأمراض', 'Y');
    -- الأشعة والتشخيص
    dp('RXR') := dep('RXR', 'الأشعة العادية', 'RADIOLOGY', 'أشعة سينية', 'Y');
    dp('RCT') := dep('RCT', 'الأشعة المقطعية', 'RADIOLOGY', 'مقطعية', 'Y');
    dp('RMRI') := dep('RMRI', 'الرنين المغناطيسي', 'RADIOLOGY', 'رنين', 'Y');
    dp('RUS') := dep('RUS', 'الموجات فوق الصوتية', 'RADIOLOGY', 'موجات صوتية', 'Y');
    dp('CARD') := dep('CARD', 'تشخيص القلب (رسم وإيكو)', 'CARDIO_DIAG', 'قلب', 'Y');
    -- العلاج والعمليات والتنويم والصيدلية
    dp('PT') := dep('PT', 'العلاج الطبيعي', 'PHYSIOTHERAPY', 'علاج طبيعي', 'Y');
    dp('DIAL') := dep('DIAL', 'وحدة الغسيل الكلوي', 'DIALYSIS', 'كلى', 'Y');
    dp('OR') := dep('OR', 'غرف العمليات', 'OPERATING_THEATER', 'جراحة', 'Y');
    dp('WARD') := dep('WARD', 'جناح التنويم', 'INPATIENT_WARD', 'تنويم', 'Y');
    dp('PHAR') := dep('PHAR', 'الصيدلية الداخلية', 'PHARMACY', 'صيدلة', 'Y');
    -- الخدمات
    srv('CON-GP', 'كشف طبيب عام', 'CONSULTATION', 'IM', 100, p_en => 'General Practitioner Consultation');
    srv('CON-SP', 'كشف أخصائي', 'CONSULTATION', 'IM', 200, p_en => 'Specialist Consultation');
    srv('CON-CS', 'كشف استشاري', 'CONSULTATION', 'IM', 300, p_en => 'Consultant Consultation');
    srv('FU', 'مراجعة', 'FOLLOW_UP', 'IM', 0, p_en => 'Follow-up Visit');
    srv('ER-VISIT', 'كشف طوارئ', 'EMERGENCY', 'ER', 250, p_en => 'Emergency Consultation');
    srv('DENT-EX', 'كشف أسنان', 'DENTAL', 'DENT', 150, p_en => 'Dental Examination');
    srv('DENT-FILL', 'حشو عصب', 'DENTAL', 'DENT', 900, p_apr => 'Y', p_en => 'Root Canal Filling');
    srv('LAB-CBC', 'صورة دم كاملة CBC', 'LAB', 'LHEM', 60, NULL, 'BLOOD', 4, 'WBC 4-11 ×10⁹/L, Hb 12-16 g/dL', p_en => 'Complete Blood Count (CBC)');
    srv('LAB-ESR', 'سرعة الترسيب ESR', 'LAB', 'LHEM', 40, NULL, 'BLOOD', 4, '0-20 mm/hr', p_en => 'Erythrocyte Sedimentation Rate (ESR)');
    srv('LAB-FBS', 'سكر صائم', 'LAB', 'LCHEM', 30, NULL, 'SERUM', 2, '70-100 mg/dL', p_en => 'Fasting Blood Sugar (FBS)');
    srv('LAB-HBA1C', 'السكر التراكمي HbA1c', 'LAB', 'LCHEM', 90, NULL, 'BLOOD', 6, '4-5.6 %', p_en => 'Glycated Hemoglobin (HbA1c)');
    srv('LAB-LIPID', 'دهون الدم الكاملة', 'LAB', 'LCHEM', 120, NULL, 'SERUM', 6, 'Cholesterol < 200 mg/dL', p_en => 'Lipid Profile');
    srv('LAB-KFT', 'وظائف الكلى', 'LAB', 'LCHEM', 110, NULL, 'SERUM', 6, 'Creatinine 0.6-1.2 mg/dL', p_en => 'Kidney Function Test (KFT)');
    srv('LAB-LFT', 'وظائف الكبد', 'LAB', 'LCHEM', 130, NULL, 'SERUM', 6, 'ALT 7-56 U/L', p_en => 'Liver Function Test (LFT)');
    srv('LAB-TSH', 'هرمون الغدة الدرقية TSH', 'LAB', 'LIMM', 100, NULL, 'SERUM', 24, '0.4-4.0 mIU/L', p_en => 'Thyroid Stimulating Hormone (TSH)');
    srv('LAB-VITD', 'فيتامين د', 'LAB', 'LIMM', 180, NULL, 'SERUM', 24, '30-100 ng/mL', p_en => 'Vitamin D (25-OH)');
    srv('LAB-UR', 'تحليل بول كامل', 'LAB', 'LMIC', 35, NULL, 'URINE', 2, NULL, p_en => 'Urinalysis (Complete)');
    srv('LAB-UCS', 'مزرعة بول', 'LAB', 'LMIC', 120, NULL, 'URINE', 72, NULL, p_en => 'Urine Culture & Sensitivity');
    srv('LAB-BIOP', 'فحص عينة نسيج', 'LAB', 'LPATH', 450, NULL, 'TISSUE', 120, NULL, 'Y', p_en => 'Tissue Biopsy Histopathology');
    srv('XR-CHEST', 'أشعة سينية على الصدر', 'RADIOLOGY', 'RXR', 120, 'XRAY', p_en => 'X-Ray Chest PA');
    srv('XR-LIMB', 'أشعة سينية على الأطراف', 'RADIOLOGY', 'RXR', 110, 'XRAY', p_en => 'X-Ray Extremity');
    srv('CT-BRAIN', 'أشعة مقطعية على المخ', 'RADIOLOGY', 'RCT', 900, 'CT', p_apr => 'Y', p_en => 'CT Brain without Contrast');
    srv('CT-ABD', 'أشعة مقطعية على البطن بالصبغة', 'RADIOLOGY', 'RCT', 1400, 'CT', p_apr => 'Y', p_en => 'CT Abdomen with Contrast');
    srv('MRI-SPINE', 'رنين مغناطيسي على الفقرات', 'RADIOLOGY', 'RMRI', 1800, 'MRI', p_apr => 'Y', p_en => 'MRI Lumbar Spine');
    srv('MRI-KNEE', 'رنين مغناطيسي على الركبة', 'RADIOLOGY', 'RMRI', 1600, 'MRI', p_apr => 'Y', p_en => 'MRI Knee');
    srv('US-ABD', 'موجات صوتية على البطن', 'RADIOLOGY', 'RUS', 300, 'ULTRASOUND', p_en => 'Ultrasound Abdomen');
    srv('US-PREG', 'موجات صوتية للحمل', 'RADIOLOGY', 'RUS', 250, 'ULTRASOUND', p_en => 'Obstetric Ultrasound');
    srv('US-DOP', 'دوبلر الأوعية', 'RADIOLOGY', 'RUS', 550, 'DOPPLER', p_en => 'Doppler Ultrasound (Vascular)');
    srv('MAMMO', 'ماموجرام', 'RADIOLOGY', 'RXR', 450, 'MAMMOGRAPHY', p_en => 'Mammography Bilateral');
    srv('ECG', 'رسم قلب', 'CARDIO_DIAG', 'CARD', 80, 'ECG', p_en => 'Electrocardiogram (ECG)');
    srv('ECHO', 'إيكو القلب', 'CARDIO_DIAG', 'CARD', 600, 'ECHO', p_en => 'Echocardiography');
    srv('STRESS', 'اختبار الجهد', 'CARDIO_DIAG', 'CARD', 750, 'STRESS_TEST', p_apr => 'Y', p_en => 'Exercise Stress Test');
    srv('PT-SES', 'جلسة علاج طبيعي', 'PHYSIOTHERAPY', 'PT', 180, p_en => 'Physiotherapy Session');
    srv('DIAL-SES', 'جلسة غسيل كلوي', 'THERAPY', 'DIAL', 900, p_apr => 'Y', p_en => 'Hemodialysis Session');
    srv('PROC-DRESS', 'غيار جرح', 'PROCEDURE', 'ER', 80, p_en => 'Wound Dressing');
    srv('PROC-SUT', 'خياطة جرح', 'MINOR_SURGERY', 'ER', 350, p_en => 'Wound Suturing');
    srv('SURG-MIN', 'عملية صغرى (تخدير موضعي)', 'MINOR_SURGERY', 'OR', 2500, p_apr => 'Y', p_en => 'Minor Surgery (Local Anesthesia)');
    srv('SURG-APP', 'استئصال الزائدة بالمنظار', 'MAJOR_SURGERY', 'OR', 12000, p_apr => 'Y', p_en => 'Laparoscopic Appendectomy');
    srv('SURG-CS', 'ولادة قيصرية', 'MAJOR_SURGERY', 'OR', 15000, p_apr => 'Y', p_en => 'Cesarean Section');
    srv('BED-DAY', 'يوم تنويم (غرفة خاصة)', 'BED', 'WARD', 900, p_en => 'Private Room - Bed Day');
    srv('NURS-INJ', 'إعطاء حقنة', 'NURSING', 'ER', 30, p_en => 'Injection Administration');
    RETURN l_n;
  END seed_catalog;

  -- ================================================================ العرض والتقارير
  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_sub VARCHAR2 DEFAULT NULL, p_cls VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-rst-kpi ' || p_cls || '"><span>' || esc(p_label) || '</span><b>' || p_value || '</b>'
        || CASE WHEN p_sub IS NOT NULL THEN '<small>' || p_sub || '</small>' END || '</div>';
  END kpi;

  FUNCTION summary_html RETURN CLOB IS
    l_co NUMBER := company;
    l_ap NUMBER; l_arr NUMBER; l_vis NUMBER; l_open NUMBER; l_lab NUMBER; l_rad NUMBER; l_apr NUMBER; l_rev NUMBER; l_cash NUMBER; l_claim NUMBER;
    l_from TIMESTAMP := CAST(TRUNC(SYSDATE) AS TIMESTAMP);
  BEGIN
    guard('HIS_VISIT.VIEW');
    SELECT COUNT(*), COUNT(CASE WHEN status_code IN ('ARRIVED', 'COMPLETED') THEN 1 END) INTO l_ap, l_arr
      FROM his_appointment WHERE company_id = l_co AND appt_date = TRUNC(SYSDATE) AND status_code <> 'CANCELLED';
    SELECT COUNT(*), COUNT(CASE WHEN status_code = 'OPEN' THEN 1 END) INTO l_vis, l_open FROM his_visit WHERE company_id = l_co AND visit_at >= l_from;
    SELECT COUNT(CASE WHEN d.dept_type = 'LAB' THEN 1 END), COUNT(CASE WHEN d.dept_type IN ('RADIOLOGY', 'CARDIO_DIAG') THEN 1 END),
           COUNT(CASE WHEN o.status_code = 'APPROVAL_PENDING' THEN 1 END)
      INTO l_lab, l_rad, l_apr
      FROM his_order o JOIN his_department d ON d.id = o.department_id
     WHERE o.company_id = l_co AND o.status_code IN ('ORDERED', 'IN_PROGRESS', 'APPROVAL_PENDING');
    SELECT NVL(SUM(patient_net + payer_net), 0), NVL(SUM(paid_amount), 0), NVL(SUM(payer_total), 0) INTO l_rev, l_cash, l_claim
      FROM his_invoice WHERE company_id = l_co AND doc_date = TRUNC(SYSDATE) AND status_code = 'POSTED';
    RETURN '<div class="nn-rst-kpis">'
        || kpi('مواعيد اليوم', TO_CHAR(l_ap), l_arr || ' حضروا', 'is-main')
        || kpi('زيارات اليوم', TO_CHAR(l_vis), l_open || ' مفتوحة')
        || kpi('طلبات المعامل', TO_CHAR(l_lab), 'تحت التنفيذ أو بانتظار السحب')
        || kpi('الأشعة والتشخيص', TO_CHAR(l_rad), 'تحت التنفيذ')
        || kpi('بانتظار موافقة التأمين', TO_CHAR(l_apr), NULL, CASE WHEN l_apr > 0 THEN 'is-warn' END)
        || kpi('إيراد اليوم', fmt0(l_rev), 'محصل ' || fmt0(l_cash) || ' · مطالبات ' || fmt0(l_claim))
        || '</div>';
  END summary_html;

  FUNCTION visit_html(p_visit_id IN NUMBER) RETURN CLOB IS
    l_v his_visit%ROWTYPE := get_visit(p_visit_id);
    l_p his_patient%ROWTYPE;
    l_h CLOB;
    l_plan VARCHAR2(400);
  BEGIN
    guard('HIS_VISIT.VIEW');
    SELECT * INTO l_p FROM his_patient WHERE id = l_v.patient_id;
    IF l_v.payer_plan_id IS NOT NULL THEN
      SELECT y.name_ar || ' - ' || p.name_ar || ' (تحمل المريض ' || p.patient_share_pct || '%)' INTO l_plan
        FROM his_payer_plan p JOIN his_payer y ON y.id = p.payer_id WHERE p.id = l_v.payer_plan_id;
    END IF;
    l_h := '<div class="nn-his-card"><div class="nn-his-head"><div><b>' || esc(l_p.name_ar) || '</b> <span class="nn-rst-chip">' || esc(l_p.mrn)
        || '</span> <span class="nn-rst-chip">' || CASE l_p.gender WHEN 'M' THEN 'ذكر' ELSE 'أنثى' END
        || CASE WHEN l_p.birth_date IS NOT NULL THEN ' · ' || TRUNC(MONTHS_BETWEEN(SYSDATE, l_p.birth_date) / 12) || ' سنة' END || '</span>'
        || CASE WHEN l_p.allergies IS NOT NULL THEN ' <span class="nn-rst-chip is-cancelled">حساسية: ' || esc(l_p.allergies) || '</span>' END
        || '<br><small>زيارة ' || esc(l_v.visit_no) || ' · ' || TO_CHAR(l_v.visit_at, 'YYYY-MM-DD HH24:MI') || ' · '
        || CASE l_v.bill_to WHEN 'PAYER' THEN esc(l_plan) ELSE 'نقدي' END || CASE WHEN l_p.nationality = 'SA' THEN ' · معفى من الضريبة' END
        || CASE l_v.eligibility_status WHEN 'ELIGIBLE' THEN ' <span class="nn-rst-chip is-paid">مؤهل · ' || esc(l_v.eligibility_ref) || '</span>'
                WHEN 'NOT_ELIGIBLE' THEN ' <span class="nn-rst-chip is-cancelled">غير مؤهل · ' || esc(l_v.eligibility_ref) || '</span>'
                WHEN 'ERROR' THEN ' <span class="nn-rst-chip">تعذر التحقق من الأهلية</span>' END
        || CASE WHEN l_v.triage_level IS NOT NULL THEN ' <span class="nn-rst-chip nn-his-tl tl-' || l_v.triage_level || '">CTAS ' || l_v.triage_level || '</span>' END
        || '</small></div><div class="nn-his-tot"><span>على المريض <b>' || fmt0(l_v.patient_total) || '</b></span><span>على الجهة <b>'
        || fmt0(l_v.payer_total) || '</b></span><span>المدفوع <b>' || fmt0(l_v.paid_amount) || '</b></span></div></div>'
        || '<table class="nn-rst-cred"><thead><tr><th>#</th><th>الخدمة</th><th>القسم</th><th>الحالة</th><th class="n">السعر</th><th class="n">على المريض</th>'
        || '<th class="n">على الجهة</th><th>الفاتورة</th><th>النتيجة</th></tr></thead><tbody>';
    FOR r IN (SELECT o.*, service_name(s.id) sname, s.service_type, d.name_ar dname, i.doc_no inv_no
                FROM his_order o JOIN his_service s ON s.id = o.service_id JOIN his_department d ON d.id = o.department_id
                LEFT JOIN his_invoice i ON i.id = o.invoice_id
               WHERE o.visit_id = p_visit_id ORDER BY o.line_no) LOOP
      l_h := l_h || ('<tr class="' || CASE WHEN r.status_code = 'CANCELLED' THEN 'is-void' END || '"><td>' || r.line_no || '</td><td>' || esc(r.sname)
          || CASE WHEN r.quantity <> 1 THEN ' × ' || r.quantity END || '<br><small>' || esc(type_label(r.service_type))
          || CASE WHEN r.covered = 'N' AND l_v.bill_to = 'PAYER' THEN ' · غير مغطاة' END || CASE WHEN r.approval_no IS NOT NULL THEN ' · موافقة ' || esc(r.approval_no) END
          || CASE WHEN r.status_code = 'APPROVAL_PENDING' AND r.preauth_status IN ('PENDING', 'REQUESTED') THEN ' · طلب إلكتروني قيد المراجعة '
                  || esc(r.preauth_ref) WHEN r.status_code = 'APPROVAL_PENDING' AND r.preauth_status = 'ERROR' THEN ' · تعذر إرسال طلب الموافقة' END
          || '</small></td><td>' || esc(r.dname) || '</td><td><span class="nn-his-st st-' || LOWER(r.status_code) || '">' || order_status_label(r.status_code)
          || '</span>' || CASE WHEN r.sample_no IS NOT NULL THEN '<br><small>عينة ' || esc(r.sample_no) || '</small>' END || '</td><td class="n">'
          || fmt0(r.gross_amount) || '</td><td class="n">' || fmt0(r.patient_net + r.patient_vat) || '</td><td class="n">' || fmt0(r.payer_net + r.payer_vat)
          || '</td><td>' || NVL(esc(r.inv_no), '<span class="nn-neg">غير مفوتر</span>') || '</td><td>'
          || CASE WHEN r.status_code = 'COMPLETED' THEN '<span class="nn-his-flag fl-' || LOWER(NVL(r.result_flag, 'NORMAL')) || '">'
                  || CASE r.result_flag WHEN 'CRITICAL' THEN 'حرجة' WHEN 'ABNORMAL' THEN 'غير طبيعية' ELSE 'طبيعية' END || '</span> '
                  || esc(DBMS_LOB.SUBSTR(r.result_text, 120, 1)) END || '</td></tr>');
    END LOOP;
    l_h := l_h || ('</tbody></table>');
    IF l_v.diagnosis IS NOT NULL OR l_v.chief_complaint IS NOT NULL THEN
      l_h := l_h || ('<div class="nn-his-notes nn-ltr" dir="ltr"><b>Chief complaint:</b> ' || esc(l_v.chief_complaint)
          || CASE WHEN l_v.vitals IS NOT NULL THEN '<br><b>Vital signs:</b> ' || esc(l_v.vitals) END || '<br><b>Diagnosis:</b> ' || esc(l_v.diagnosis)
          || CASE WHEN l_v.icd10 IS NOT NULL THEN ' (ICD-10: ' || esc(l_v.icd10) || ')' END
          || CASE WHEN l_v.doctor_notes IS NOT NULL THEN '<br><b>Clinical notes / Plan:</b> ' || REPLACE(esc(DBMS_LOB.SUBSTR(l_v.doctor_notes, 3000, 1)), CHR(10), '<br>') END
          || '</div>');
    END IF;
    RETURN l_h || ('</div>');
  END visit_html;

  FUNCTION invoice_html(p_invoice_id IN NUMBER) RETURN CLOB IS
    l_i   his_invoice%ROWTYPE;
    l_v   his_visit%ROWTYPE;
    l_p   his_patient%ROWTYPE;
    l_h   CLOB;
    l_pay VARCHAR2(200);
  BEGIN
    guard('HIS_INVOICE.VIEW');
    SELECT * INTO l_i FROM his_invoice WHERE id = p_invoice_id AND company_id = company;
    SELECT * INTO l_v FROM his_visit WHERE id = l_i.visit_id;
    SELECT * INTO l_p FROM his_patient WHERE id = l_i.patient_id;
    IF l_i.payer_id IS NOT NULL THEN
      SELECT name_ar INTO l_pay FROM his_payer WHERE id = l_i.payer_id;
    END IF;
    l_h := '<div class="nn-his-inv"><div class="nn-his-inv-h"><div><b>' || esc(NOONA_SAL_PKG.seller_name) || '</b><br>الرقم الضريبي: '
        || esc(NOONA_SAL_PKG.seller_vat) || '</div><div><h2>' || CASE WHEN l_i.status_code = 'CANCELLED' THEN 'فاتورة ملغاة' ELSE 'فاتورة ضريبية' END
        || '</h2>' || esc(l_i.doc_no) || ' · ' || TO_CHAR(l_i.doc_date, 'YYYY-MM-DD') || '</div></div>'
        || '<table class="nn-his-meta"><tr><td>المريض</td><td><b>' || esc(l_p.name_ar) || '</b> (' || esc(l_p.mrn) || ')</td><td>الهوية</td><td>'
        || esc(l_p.id_no) || '</td></tr><tr><td>الزيارة</td><td>' || esc(l_v.visit_no) || '</td><td>الجهة</td><td>' || NVL(esc(l_pay), 'نقدي')
        || CASE WHEN l_p.member_no IS NOT NULL AND l_pay IS NOT NULL THEN ' · عضوية ' || esc(l_p.member_no) END || '</td></tr></table>'
        || '<table class="nn-rst-cred"><thead><tr><th>الخدمة</th><th class="n">الكمية</th><th class="n">السعر</th><th class="n">الإجمالي</th>'
        || '<th class="n">على المريض</th><th class="n">على الجهة</th><th class="n">الضريبة</th></tr></thead><tbody>';
    FOR r IN (SELECT o.*, service_name(s.id) sname, s.billing_code FROM his_order o JOIN his_service s ON s.id = o.service_id
               WHERE o.invoice_id = p_invoice_id OR (l_i.status_code = 'CANCELLED' AND 1 = 0) ORDER BY o.line_no) LOOP
      l_h := l_h || ('<tr><td>' || esc(r.sname) || CASE WHEN r.billing_code IS NOT NULL THEN ' <small>' || esc(r.billing_code) || '</small>' END
          || CASE WHEN r.approval_no IS NOT NULL THEN '<br><small>موافقة ' || esc(r.approval_no) || '</small>' END || '</td><td class="n">' || r.quantity
          || '</td><td class="n">' || fmt0(r.unit_price) || '</td><td class="n">' || fmt0(r.gross_amount) || '</td><td class="n">' || fmt0(r.patient_net)
          || '</td><td class="n">' || fmt0(r.payer_net) || '</td><td class="n">' || fmt0(r.patient_vat + r.payer_vat) || '</td></tr>');
    END LOOP;
    l_h := l_h || ('</tbody></table><table class="nn-his-totals">'
        || '<tr><td>حصة المريض قبل الضريبة</td><td>' || fmt0(l_i.patient_net) || '</td></tr><tr><td>ضريبة القيمة المضافة على المريض</td><td>'
        || fmt0(l_i.patient_vat) || '</td></tr><tr class="g"><td>المطلوب من المريض</td><td>' || fmt0(l_i.patient_total) || '</td></tr>'
        || CASE WHEN l_i.payer_total > 0 THEN '<tr><td>حصة ' || esc(l_pay) || ' (شاملة الضريبة ' || fmt0(l_i.payer_vat) || ')</td><td>'
                || fmt0(l_i.payer_total) || '</td></tr>' END
        || '<tr><td>المدفوع</td><td>' || fmt0(l_i.paid_amount) || CASE WHEN l_i.payment_method IS NOT NULL THEN ' (' || esc(l_i.payment_method) || ')' END
        || '</td></tr></table>'
        || CASE WHEN l_p.nationality = 'SA' THEN '<p class="nn-hint">الخدمات الصحية للمواطن بنسبة ضريبة صفر.</p>' END || '</div>');
    RETURN l_h;
  END invoice_html;

  -- جدول مكونات التحليل (المرحلة الثانية)
  FUNCTION lab_table(p_order_id NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(32767);
  BEGIN
    FOR r IN (SELECT NVL(p.name_en, p.name_ar) name_ar, p.code, p.unit, r.value_num, r.value_text, r.flag,
                     NVL(p.ref_text, CASE WHEN p.ref_low IS NOT NULL OR p.ref_high IS NOT NULL
                                          THEN NVL(TO_CHAR(p.ref_low), '') || ' - ' || NVL(TO_CHAR(p.ref_high), '') END) rng
                FROM his_lab_result r JOIN his_lab_param p ON p.id = r.param_id WHERE r.order_id = p_order_id ORDER BY p.sort_order, p.id) LOOP
      l := l || ('<tr class="lf-' || LOWER(NVL(r.flag, 'N')) || '"><td>' || esc(r.name_ar) || ' <small>' || esc(r.code) || '</small></td><td class="n"><b>'
         || NVL(esc(r.value_text), RTRIM(RTRIM(TO_CHAR(r.value_num, 'FM9999990D999', 'NLS_NUMERIC_CHARACTERS=''.,'''), '0'), '.')) || '</b> '
         || CASE r.flag WHEN 'H' THEN 'H' WHEN 'L' THEN 'L' WHEN 'HH' THEN 'HH (critical)' WHEN 'LL' THEN 'LL (critical)' END || '</td><td>' || esc(r.unit) || '</td><td>'
         || esc(r.rng) || '</td></tr>');
    END LOOP;
    RETURN CASE WHEN l IS NOT NULL THEN '<table class="nn-rst-cred nn-his-lab"><thead><tr><th>Test</th><th class="n">Result</th><th>Unit</th>'
                || '<th>Reference range</th></tr></thead><tbody>' || l || '</tbody></table>' END;
  END lab_table;

  FUNCTION result_html(p_order_id IN NUMBER) RETURN CLOB IS
    l_h CLOB;
  BEGIN
    guard('HIS_ORDER.VIEW');
    -- التقرير الطبي بالإنجليزية (من اليسار لليمين)
    FOR r IN (SELECT o.*, service_name(s.id) sname, s.normal_range, s.sample_type, s.modality, s.service_type, NVL(d.name_en, d.name_ar) dname, v.visit_no,
                     NVL(p.name_en, p.name_ar) pname, p.mrn, p.gender, p.birth_date,
                     (SELECT NVL(name_en, name_ar) FROM his_doctor WHERE id = o.ordered_by_id) dr,
                     (SELECT NVL(name_en, name_ar) FROM his_doctor WHERE id = o.performed_by_id) pr
                FROM his_order o JOIN his_service s ON s.id = o.service_id JOIN his_department d ON d.id = o.department_id
                JOIN his_visit v ON v.id = o.visit_id JOIN his_patient p ON p.id = v.patient_id
               WHERE o.id = p_order_id AND o.company_id = company) LOOP
      l_h := '<div class="nn-his-inv nn-ltr" dir="ltr"><div class="nn-his-inv-h"><div><b>' || esc(NOONA_SAL_PKG.seller_name) || '</b><br>' || esc(r.dname)
          || '</div><div><h2>' || CASE WHEN r.service_type = 'LAB' THEN 'Laboratory Report' WHEN r.modality IN ('ECG', 'ECHO', 'STRESS_TEST', 'HOLTER') THEN 'Cardiology Report'
                                       WHEN r.modality IS NOT NULL THEN 'Radiology Report' ELSE 'Medical Report' END || '</h2>' || esc(r.visit_no)
          || CASE WHEN r.sample_no IS NOT NULL THEN ' · Sample ' || esc(r.sample_no) END || '</div></div>'
          || '<table class="nn-his-meta"><tr><td>Patient</td><td><b>' || esc(r.pname) || '</b> (' || esc(r.mrn) || ')</td><td>Sex / Age</td><td>'
          || CASE r.gender WHEN 'M' THEN 'Male' ELSE 'Female' END || CASE WHEN r.birth_date IS NOT NULL THEN ' / ' || TRUNC(MONTHS_BETWEEN(SYSDATE, r.birth_date) / 12) || ' Y' END
          || '</td></tr><tr><td>Examination</td><td><b>' || esc(r.sname) || '</b></td><td>Requested by</td><td>' || esc(r.dr) || '</td></tr>'
          || '<tr><td>' || CASE WHEN r.sample_type IS NOT NULL THEN 'Specimen' ELSE 'Reference' END || '</td><td>'
          || esc(CASE WHEN r.sample_type IS NOT NULL THEN INITCAP(r.sample_type) || CASE WHEN r.sample_at IS NOT NULL THEN ' · collected ' || TO_CHAR(r.sample_at, 'YYYY-MM-DD HH24:MI') END
                      ELSE r.normal_range END)
          || '</td><td>Reported</td><td>' || TO_CHAR(r.completed_at, 'YYYY-MM-DD HH24:MI') || '</td></tr></table>'
          || '<div class="nn-his-result fl-' || LOWER(NVL(r.result_flag, 'NORMAL')) || '">'
          || lab_table(r.id) || REPLACE(esc(DBMS_LOB.SUBSTR(r.result_text, 30000, 1)), CHR(10), '<br>') || '</div><p class="nn-hint">Verified by: '
          || esc(NVL(r.pr, r.result_by)) || ' · Interpretation: ' || CASE r.result_flag WHEN 'CRITICAL' THEN 'CRITICAL value' WHEN 'ABNORMAL' THEN 'Abnormal'
                                                                       ELSE 'Normal' END || '</p></div>';
    END LOOP;
    RETURN NVL(l_h, '<p class="nn-hint">No result</p>');
  END result_html;

  FUNCTION day_board_html(p_date IN DATE, p_dept_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_h CLOB := '<div class="nn-his-board">';
    l_d DATE := NVL(p_date, TRUNC(SYSDATE));
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('HIS_APPOINTMENT.VIEW');
    FOR dr IN (SELECT d.id, d.name_ar, d.specialty, dp.name_ar dname,
                      (SELECT LISTAGG(s.from_time || '-' || s.to_time, ' / ') WITHIN GROUP (ORDER BY s.from_time) FROM his_doctor_schedule s
                        WHERE s.doctor_id = d.id AND s.weekday = weekday_of(l_d)) hours
                 FROM his_doctor d JOIN his_department dp ON dp.id = d.department_id
                WHERE d.company_id = company AND d.status_code = 'ACTIVE' AND (p_dept_id IS NULL OR d.department_id = p_dept_id)
                  AND (EXISTS (SELECT 1 FROM his_doctor_schedule s WHERE s.doctor_id = d.id AND s.weekday = weekday_of(l_d))
                       OR EXISTS (SELECT 1 FROM his_appointment a WHERE a.doctor_id = d.id AND a.appt_date = l_d))
                ORDER BY dp.sort_order, dp.name_ar, d.name_ar) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<section class="nn-his-col"><header><b>' || esc(dr.name_ar) || '</b><small>' || esc(dr.dname) || ' · ' || NVL(esc(dr.hours), 'خارج الدوام')
          || '</small></header>');
      FOR a IN (SELECT a.id, a.start_time, a.status_code, p.name_ar, p.mrn, p.mobile, s.name_ar sname, a.visit_id
                  FROM his_appointment a JOIN his_patient p ON p.id = a.patient_id LEFT JOIN his_service s ON s.id = a.service_id
                 WHERE a.doctor_id = dr.id AND a.appt_date = l_d AND a.status_code <> 'CANCELLED' ORDER BY a.start_time) LOOP
        l_h := l_h || ('<div class="nn-his-appt ap-' || LOWER(a.status_code) || '" data-appt="' || a.id || '" data-visit="' || a.visit_id || '"><b>' || a.start_time
            || '</b> ' || esc(a.name_ar) || '<small>' || esc(a.mrn) || ' · ' || esc(a.mobile) || ' · ' || esc(a.sname) || '</small><span>'
            || appt_status_label(a.status_code) || '</span></div>');
      END LOOP;
      l_h := l_h || ('<div class="nn-his-free">متاح: ' || REPLACE(REPLACE(REPLACE(free_slots(dr.id, l_d), '"'), '['), ']') || '</div></section>');
    END LOOP;
    IF l_n = 0 THEN
      l_h := l_h || ('<p class="nn-hint">لا يوجد أطباء بدوام في هذا اليوم</p>');
    END IF;
    RETURN l_h || ('</div>');
  END day_board_html;

  FUNCTION revenue_html(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_h CLOB;
    l_t1 NUMBER := 0; l_t2 NUMBER := 0; l_t3 NUMBER := 0; l_t4 NUMBER := 0;
    l_co NUMBER := company;
  BEGIN
    guard('HIS_INVOICE.VIEW');
    l_h := '<h3>الإيرادات حسب القسم</h3><table class="nn-rst-cred"><thead><tr><th>القسم</th><th>النوع</th><th class="n">الخدمات</th><th class="n">حصة المرضى</th>'
        || '<th class="n">حصة الجهات</th><th class="n">صافي الإيراد</th><th class="n">تكلفة المواد</th></tr></thead><tbody>';
    FOR r IN (SELECT d.name_ar, d.dept_type, COUNT(*) n, SUM(o.patient_net) pn, SUM(o.payer_net) yn, SUM(NVL(o.material_cost, 0)) mc
                FROM his_order o JOIN his_invoice i ON i.id = o.invoice_id JOIN his_department d ON d.id = o.department_id
               WHERE i.company_id = l_co AND i.status_code = 'POSTED' AND i.doc_date BETWEEN p_from AND p_to
               GROUP BY d.name_ar, d.dept_type ORDER BY SUM(o.patient_net + o.payer_net) DESC) LOOP
      l_h := l_h || ('<tr><td>' || esc(r.name_ar) || '</td><td>' || dept_type_label(r.dept_type) || '</td><td class="n">' || r.n || '</td><td class="n">'
          || fmt0(r.pn) || '</td><td class="n">' || fmt0(r.yn) || '</td><td class="n"><b>' || fmt0(r.pn + r.yn) || '</b></td><td class="n">' || fmt0(r.mc) || '</td></tr>');
      l_t1 := l_t1 + r.pn; l_t2 := l_t2 + r.yn; l_t3 := l_t3 + r.mc;
    END LOOP;
    l_h := l_h || ('</tbody><tfoot><tr><td colspan="3">الإجمالي</td><td class="n">' || fmt0(l_t1) || '</td><td class="n">' || fmt0(l_t2) || '</td><td class="n">'
        || fmt0(l_t1 + l_t2) || '</td><td class="n">' || fmt0(l_t3) || '</td></tr></tfoot></table>');
    l_h := l_h || ('<h3>حسب الجهة</h3><table class="nn-rst-cred"><thead><tr><th>الجهة</th><th class="n">الفواتير</th><th class="n">المطالبات</th>'
        || '<th class="n">المحصل من المطالبات</th><th class="n">المتبقي</th></tr></thead><tbody>');
    l_t1 := 0; l_t2 := 0;
    FOR r IN (SELECT NVL(y.name_ar, 'نقدي') nm, COUNT(*) n, SUM(i.payer_total) cl,
                     SUM((SELECT NVL(SUM(original_amount - open_amount), 0) FROM ar_open_item a
                           WHERE a.source_entity_type = c_inv AND a.source_entity_id = i.id AND a.customer_account_id = y.customer_account_id)) paid
                FROM his_invoice i LEFT JOIN his_payer y ON y.id = i.payer_id
               WHERE i.company_id = l_co AND i.status_code = 'POSTED' AND i.doc_date BETWEEN p_from AND p_to
               GROUP BY NVL(y.name_ar, 'نقدي') ORDER BY 3 DESC) LOOP
      l_h := l_h || ('<tr><td>' || esc(r.nm) || '</td><td class="n">' || r.n || '</td><td class="n">' || fmt0(r.cl) || '</td><td class="n">' || fmt0(r.paid)
          || '</td><td class="n">' || fmt0(r.cl - r.paid) || '</td></tr>');
      l_t1 := l_t1 + r.cl; l_t2 := l_t2 + r.paid;
    END LOOP;
    l_h := l_h || ('</tbody><tfoot><tr><td colspan="2">الإجمالي</td><td class="n">' || fmt0(l_t1) || '</td><td class="n">' || fmt0(l_t2) || '</td><td class="n">'
        || fmt0(l_t1 - l_t2) || '</td></tr></tfoot></table>');
    l_h := l_h || ('<h3>حسب الطبيب</h3><table class="nn-rst-cred"><thead><tr><th>الطبيب</th><th class="n">الزيارات</th><th class="n">الخدمات المطلوبة</th>'
        || '<th class="n">قيمة الخدمات</th><th class="n">النسبة المستحقة</th></tr></thead><tbody>');
    FOR r IN (SELECT dr.name_ar, COUNT(DISTINCT o.visit_id) v, COUNT(*) n, SUM(o.patient_net + o.payer_net) amt,
                     SUM(o.patient_net + o.payer_net) * NVL(MAX(dr.commission_pct), 0) / 100 com
                FROM his_order o JOIN his_invoice i ON i.id = o.invoice_id JOIN his_doctor dr ON dr.id = o.ordered_by_id
               WHERE i.company_id = l_co AND i.status_code = 'POSTED' AND i.doc_date BETWEEN p_from AND p_to
               GROUP BY dr.name_ar ORDER BY 4 DESC) LOOP
      l_h := l_h || ('<tr><td>' || esc(r.name_ar) || '</td><td class="n">' || r.v || '</td><td class="n">' || r.n || '</td><td class="n">' || fmt0(r.amt)
          || '</td><td class="n">' || fmt0(r.com) || '</td></tr>');
      l_t4 := l_t4 + r.com;
    END LOOP;
    RETURN l_h || ('</tbody></table>');
  END revenue_html;

  FUNCTION claims_html(p_payer_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_h   CLOB;
    l_pay his_payer%ROWTYPE;
    l_t   NUMBER := 0;
    l_o   NUMBER := 0;
    l_n   PLS_INTEGER := 0;
  BEGIN
    guard('HIS_INVOICE.VIEW');
    SELECT * INTO l_pay FROM his_payer WHERE id = p_payer_id AND company_id = company;
    l_h := '<div class="nn-his-inv"><div class="nn-his-inv-h"><div><b>' || esc(NOONA_SAL_PKG.seller_name) || '</b></div><div><h2>كشف مطالبة</h2>'
        || esc(l_pay.name_ar) || ' · عقد ' || esc(l_pay.contract_no) || '<br>من ' || TO_CHAR(p_from, 'YYYY-MM-DD') || ' إلى ' || TO_CHAR(p_to, 'YYYY-MM-DD')
        || '</div></div><table class="nn-rst-cred"><thead><tr><th>الفاتورة</th><th>التاريخ</th><th>المريض</th><th>رقم العضوية</th><th>الخدمات</th>'
        || '<th>الموافقات</th><th class="n">المطالبة</th><th class="n">المتبقي</th></tr></thead><tbody>';
    FOR r IN (SELECT i.id, i.doc_no, i.doc_date, p.name_ar, p.member_no, i.payer_total,
                     (SELECT NVL(SUM(open_amount), 0) FROM ar_open_item a WHERE a.source_entity_type = c_inv AND a.source_entity_id = i.id
                         AND a.customer_account_id = l_pay.customer_account_id) open_amt,
                     (SELECT LISTAGG(service_name(s.id), '، ') WITHIN GROUP (ORDER BY o.line_no) FROM his_order o JOIN his_service s ON s.id = o.service_id
                       WHERE o.invoice_id = i.id AND o.payer_net > 0) srv,
                     (SELECT LISTAGG(o.approval_no, '، ') WITHIN GROUP (ORDER BY o.line_no) FROM his_order o WHERE o.invoice_id = i.id AND o.approval_no IS NOT NULL) apr
                FROM his_invoice i JOIN his_patient p ON p.id = i.patient_id
               WHERE i.payer_id = p_payer_id AND i.status_code = 'POSTED' AND i.payer_total > 0 AND i.doc_date BETWEEN p_from AND p_to
               ORDER BY i.doc_date, i.doc_no) LOOP
      l_n := l_n + 1;
      l_t := l_t + r.payer_total; l_o := l_o + r.open_amt;
      l_h := l_h || ('<tr><td>' || esc(r.doc_no) || '</td><td>' || TO_CHAR(r.doc_date, 'YYYY-MM-DD') || '</td><td>' || esc(r.name_ar) || '</td><td>'
          || esc(r.member_no) || '</td><td>' || esc(r.srv) || '</td><td>' || esc(r.apr) || '</td><td class="n">' || fmt0(r.payer_total) || '</td><td class="n">'
          || fmt0(r.open_amt) || '</td></tr>');
    END LOOP;
    RETURN l_h || ('</tbody><tfoot><tr><td colspan="6">' || l_n || ' فاتورة</td><td class="n">' || fmt0(l_t) || '</td><td class="n">' || fmt0(l_o)
        || '</td></tr></tfoot></table></div>');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '<p class="nn-hint">اختر الجهة</p>';
  END claims_html;

END NOONA_HIS_PKG;
/
