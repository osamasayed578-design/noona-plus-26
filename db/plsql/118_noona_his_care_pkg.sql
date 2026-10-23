-- =============================================================================
-- NOONA PLUS ERP | المستشفيات - الرعاية السريرية: NOONA_HIS_CARE_PKG (المرحلة الثانية)
--   مكونات التحاليل ومعدلاتها حسب الجنس والعمر وإدخال النتائج بالتقييم الآلي (منخفض/مرتفع/حرج)، قوالب تقارير الأشعة،
--   الصيدلية الداخلية (الوصفة ← طلبات دوائية تفوتر ← تسليم يصرف من مستودع الصيدلية)، التنويم (الأسرة، الدخول، النقل،
--   ترحيل أيام السرير، الخروج)، جدولة العمليات بمنع التعارض، خطط العلاج الطبيعي بالجلسات، الأجهزة الطبية ومعايرتها.
--   الفوترة والتسعير والتأمين والصرف من المخزون عبر NOONA_HIS_PKG (طلبات الزيارة).
-- =============================================================================

CREATE OR REPLACE PACKAGE NOONA_HIS_CARE_PKG AUTHID DEFINER AS

  FUNCTION company RETURN NUMBER;
  -- معدلات نموذجية لتحاليل الدليل، وقوالب الأشعة، وأسرة الجناح - لا تكرر الموجود
  FUNCTION seed_defaults RETURN NUMBER;

  -- ---------------------------------------------------------- المعامل
  FUNCTION set_lab_param(p_service_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_unit IN VARCHAR2, p_low IN NUMBER, p_high IN NUMBER,
                         p_crit_low IN NUMBER DEFAULT NULL, p_crit_high IN NUMBER DEFAULT NULL, p_gender IN VARCHAR2 DEFAULT NULL,
                         p_age_from IN NUMBER DEFAULT NULL, p_age_to IN NUMBER DEFAULT NULL, p_ref_text IN VARCHAR2 DEFAULT NULL,
                         p_name_en IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  -- المكونات المناسبة لجنس المريض وعمره مع القيم المدخلة: [{"p","code","n","unit","low","high","ref","v","t","f"}]
  FUNCTION lab_params_json(p_order_id IN NUMBER) RETURN CLOB;
  FUNCTION flag_of(p_param_id IN NUMBER, p_value IN NUMBER) RETURN VARCHAR2;
  -- 'Y' إذا كان للتحليل مكونات تدخل نتائجها في جدول
  FUNCTION has_params(p_order_id IN NUMBER) RETURN VARCHAR2;
  -- جدول إدخال النتائج (apex_item: f01 القيم، f02 المكونات)
  FUNCTION lab_grid_html(p_order_id IN NUMBER) RETURN CLOB;
  -- [{"p":param,"v":5.2} | {"p":param,"t":"Negative"}] ؛ p_complete = 'Y' ينجز الطلب (ويصرف المواد)
  PROCEDURE save_lab_results(p_order_id IN NUMBER, p_values IN CLOB, p_complete IN VARCHAR2 DEFAULT 'N', p_performer IN NUMBER DEFAULT NULL,
                             p_comment IN VARCHAR2 DEFAULT NULL);
  FUNCTION save_template(p_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_service_id IN NUMBER, p_modality IN VARCHAR2,
                         p_body IN VARCHAR2) RETURN NUMBER;
  FUNCTION template_for(p_order_id IN NUMBER) RETURN VARCHAR2;

  -- ---------------------------------------------------------- الصيدلية الداخلية
  FUNCTION med_service(p_item_id IN NUMBER) RETURN NUMBER;
  FUNCTION default_pharmacy RETURN NUMBER;
  -- {"visit","doctor","pharmacy","notes","lines":[{"i":item,"q":10,"dose":"500mg","freq":"3 مرات يومياً","days":5,"instr":"بعد الأكل"}]}
  FUNCTION prescribe(p_doc IN CLOB) RETURN NUMBER;
  -- ينشئ طلبات الأدوية (تفوتر بتغطية التأمين)؛ p_lines فارغ = كل المتبقي
  PROCEDURE bill_prescription(p_rx_id IN NUMBER, p_lines IN CLOB DEFAULT NULL);
  -- تسليم الأدوية المفوترة (أو للمنوم): يصرف من مستودع الصيدلية
  PROCEDURE deliver_prescription(p_rx_id IN NUMBER);
  PROCEDURE cancel_prescription(p_rx_id IN NUMBER);

  -- ---------------------------------------------------------- التنويم
  FUNCTION save_bed(p_id IN NUMBER, p_ward_id IN NUMBER, p_bed_no IN VARCHAR2, p_room IN VARCHAR2, p_class IN VARCHAR2 DEFAULT 'WARD',
                    p_service_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
  PROCEDURE set_bed_status(p_bed_id IN NUMBER, p_status IN VARCHAR2);
  -- {"patient","visit","doctor","bed","reason","bill_to","approval"} ؛ يفتح زيارة تنويم إن لم تحدد
  FUNCTION admit(p_doc IN CLOB) RETURN NUMBER;
  -- ترحيل أيام السرير حتى التاريخ لكل المنومين (أو تنويم واحد)؛ يعيد عدد الأيام المحملة
  FUNCTION charge_beds(p_to IN DATE DEFAULT NULL, p_admission_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
  PROCEDURE transfer_bed(p_admission_id IN NUMBER, p_bed_id IN NUMBER, p_reason IN VARCHAR2);
  PROCEDURE discharge(p_admission_id IN NUMBER, p_type IN VARCHAR2, p_summary IN VARCHAR2);
  FUNCTION bed_board_html RETURN CLOB;

  -- ---------------------------------------------------------- العمليات
  -- {"visit","service","theater","surgeon","anesthetist","anesthesia","start":"YYYY-MM-DD HH24:MI","duration"}
  FUNCTION schedule_surgery(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE start_surgery(p_surgery_id IN NUMBER);
  PROCEDURE finish_surgery(p_surgery_id IN NUMBER, p_notes IN VARCHAR2);
  PROCEDURE cancel_surgery(p_surgery_id IN NUMBER, p_reason IN VARCHAR2);
  FUNCTION or_board_html(p_date IN DATE) RETURN CLOB;

  -- ---------------------------------------------------------- العلاج الطبيعي والوحدات العلاجية
  -- {"visit","service","sessions","therapist","frequency","goals"} ؛ طلب واحد بعدد الجلسات
  FUNCTION create_plan(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION record_session(p_plan_id IN NUMBER, p_therapist IN NUMBER, p_notes IN VARCHAR2) RETURN NUMBER;

  -- ---------------------------------------------------------- الأجهزة
  -- {"id","code","name","dept","modality","manufacturer","model","serial","asset","installed","warranty","cal_days"}
  FUNCTION save_device(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE log_device(p_device_id IN NUMBER, p_type IN VARCHAR2, p_date IN DATE, p_vendor IN VARCHAR2, p_cost IN NUMBER, p_notes IN VARCHAR2);
  FUNCTION devices_html RETURN CLOB;
END NOONA_HIS_CARE_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_HIS_CARE_PKG AS

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;
  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END;
  FUNCTION fmt0(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(NVL(p, 0), 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.,''');
  END fmt0;
  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;
  FUNCTION d(p VARCHAR2) RETURN DATE IS BEGIN RETURN TO_DATE(p, 'YYYY-MM-DD'); END;
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
  FUNCTION srv_id(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM his_service WHERE company_id = company AND code = p_code;
    RETURN l;
  END srv_id;

  -- ================================================================ المعامل
  FUNCTION set_lab_param(p_service_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_unit IN VARCHAR2, p_low IN NUMBER, p_high IN NUMBER,
                         p_crit_low IN NUMBER DEFAULT NULL, p_crit_high IN NUMBER DEFAULT NULL, p_gender IN VARCHAR2 DEFAULT NULL,
                         p_age_from IN NUMBER DEFAULT NULL, p_age_to IN NUMBER DEFAULT NULL, p_ref_text IN VARCHAR2 DEFAULT NULL,
                         p_name_en IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l NUMBER;
    l_srt NUMBER;
  BEGIN
    guard('HIS_SERVICE.UPDATE');
    NOONA_CORE_PKG.assert(p_service_id IS NOT NULL AND TRIM(p_code) IS NOT NULL AND TRIM(p_name_ar) IS NOT NULL, 'NOONA-HIS-100',
                          'التحليل ورمز المكون واسمه إلزامية', 'Test, code and name are required');
    NOONA_CORE_PKG.assert(p_low IS NULL OR p_high IS NULL OR p_low <= p_high, 'NOONA-HIS-101', 'الحد الأدنى أكبر من الأعلى', 'Low exceeds high');
    SELECT MIN(id), NVL(MAX(sort_order), 0) + 1 INTO l, l_srt FROM his_lab_param
     WHERE service_id = p_service_id AND code = UPPER(TRIM(p_code)) AND NVL(gender, '-') = NVL(p_gender, '-')
       AND NVL(age_from, -1) = NVL(p_age_from, -1) AND NVL(age_to, -1) = NVL(p_age_to, -1);
    IF l IS NULL THEN
      SELECT NVL(MAX(sort_order), 0) + 1 INTO l_srt FROM his_lab_param WHERE service_id = p_service_id;
      SELECT NVL(MIN(sort_order), l_srt) INTO l_srt FROM his_lab_param WHERE service_id = p_service_id AND code = UPPER(TRIM(p_code));
      INSERT INTO his_lab_param (company_id, service_id, code, name_ar, name_en, unit, gender, age_from, age_to, ref_low, ref_high, crit_low, crit_high, ref_text,
                                 sort_order)
      VALUES (company, p_service_id, UPPER(TRIM(p_code)), TRIM(p_name_ar), TRIM(p_name_en), p_unit, p_gender, p_age_from, p_age_to, p_low, p_high, p_crit_low, p_crit_high,
              p_ref_text, l_srt)
      RETURNING id INTO l;
    ELSE
      UPDATE his_lab_param SET name_ar = TRIM(p_name_ar), name_en = NVL(TRIM(p_name_en), name_en), unit = p_unit, ref_low = p_low, ref_high = p_high, crit_low = p_crit_low,
                               crit_high = p_crit_high, ref_text = p_ref_text
       WHERE id = l;
    END IF;
    RETURN l;
  END set_lab_param;

  FUNCTION flag_of(p_param_id IN NUMBER, p_value IN NUMBER) RETURN VARCHAR2 IS
    l his_lab_param%ROWTYPE;
  BEGIN
    IF p_value IS NULL THEN RETURN NULL; END IF;
    SELECT * INTO l FROM his_lab_param WHERE id = p_param_id;
    RETURN CASE WHEN l.crit_low IS NOT NULL AND p_value < l.crit_low THEN 'LL' WHEN l.crit_high IS NOT NULL AND p_value > l.crit_high THEN 'HH'
                WHEN l.ref_low IS NOT NULL AND p_value < l.ref_low THEN 'L' WHEN l.ref_high IS NOT NULL AND p_value > l.ref_high THEN 'H' ELSE 'N' END;
  END flag_of;

  FUNCTION has_params(p_order_id IN NUMBER) RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM his_order o JOIN his_lab_param p ON p.service_id = o.service_id WHERE o.id = p_order_id AND o.company_id = company;
    RETURN CASE WHEN l > 0 THEN 'Y' ELSE 'N' END;
  END has_params;

  FUNCTION lab_grid_html(p_order_id IN NUMBER) RETURN CLOB IS
    l_h CLOB;
    l_j CLOB := lab_params_json(p_order_id);
  BEGIN
    l_h := '<table class="nn-rst-cred nn-his-lab" dir="ltr"><thead><tr><th>Test</th><th>Result</th><th>Unit</th><th>Reference range</th><th>Flag</th></tr></thead><tbody>';
    FOR r IN (SELECT * FROM JSON_TABLE(l_j, '$[*]' COLUMNS (p NUMBER PATH '$.p', code VARCHAR2(30) PATH '$.code', n VARCHAR2(200) PATH '$.n',
                unit VARCHAR2(30) PATH '$.unit', low NUMBER PATH '$.low', high NUMBER PATH '$.high', ref VARCHAR2(200) PATH '$.ref',
                v NUMBER PATH '$.v', t VARCHAR2(200) PATH '$.t', f VARCHAR2(5) PATH '$.f'))) LOOP
      l_h := l_h || '<tr class="lf-' || LOWER(NVL(r.f, 'n')) || '"><td><b>' || esc(r.n) || '</b> <small>' || esc(r.code) || '</small>'
          || APEX_ITEM.HIDDEN(2, r.p) || '</td><td>' || APEX_ITEM.TEXT(1, NVL(r.t, RTRIM(RTRIM(TO_CHAR(r.v, 'FM9999990D999', 'NLS_NUMERIC_CHARACTERS=''.,'''), '0'), '.')),
             10, 30, 'class="nn-rst-in" style="max-width:140px" aria-label="' || esc(r.n) || '"') || '</td><td>' || esc(r.unit) || '</td><td>'
          || esc(NVL(r.ref, CASE WHEN r.low IS NOT NULL OR r.high IS NOT NULL THEN r.low || ' - ' || r.high END)) || '</td><td>'
          || CASE r.f WHEN 'H' THEN 'High' WHEN 'L' THEN 'Low' WHEN 'HH' THEN 'Critical high' WHEN 'LL' THEN 'Critical low' WHEN 'N' THEN 'Normal' END || '</td></tr>';
    END LOOP;
    RETURN l_h || '</tbody></table>';
  END lab_grid_html;

  FUNCTION lab_params_json(p_order_id IN NUMBER) RETURN CLOB IS
    l     CLOB;
    l_g   VARCHAR2(1);
    l_age NUMBER;
    l_srv NUMBER;
  BEGIN
    guard('HIS_ORDER.VIEW');
    SELECT p.gender, MONTHS_BETWEEN(SYSDATE, p.birth_date) / 12, o.service_id INTO l_g, l_age, l_srv
      FROM his_order o JOIN his_visit v ON v.id = o.visit_id JOIN his_patient p ON p.id = v.patient_id
     WHERE o.id = p_order_id AND o.company_id = company;
    -- لكل رمز: المعدل الأنسب (الجنس والعمر قبل العام)
    SELECT JSON_ARRAYAGG(JSON_OBJECT('p' VALUE x.id, 'code' VALUE x.code, 'n' VALUE NVL(x.name_en, x.name_ar), 'unit' VALUE x.unit, 'low' VALUE x.ref_low,
             'high' VALUE x.ref_high, 'ref' VALUE x.ref_text, 'v' VALUE r.value_num, 't' VALUE r.value_text, 'f' VALUE r.flag) ORDER BY x.sort_order
             RETURNING CLOB)
      INTO l
      FROM (SELECT p.*, ROW_NUMBER() OVER (PARTITION BY p.code ORDER BY CASE WHEN p.gender IS NOT NULL THEN 0 ELSE 1 END,
                                                                       CASE WHEN p.age_from IS NOT NULL OR p.age_to IS NOT NULL THEN 0 ELSE 1 END) rn
              FROM his_lab_param p
             WHERE p.service_id = l_srv AND (p.gender IS NULL OR p.gender = l_g)
               AND (l_age IS NULL OR ((p.age_from IS NULL OR l_age >= p.age_from) AND (p.age_to IS NULL OR l_age < p.age_to)))) x
      LEFT JOIN his_lab_result r ON r.order_id = p_order_id AND r.param_id = x.id
     WHERE x.rn = 1;
    RETURN NVL(l, TO_CLOB('[]'));
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-060', 'الطلب غير موجود', 'Order not found');
  END lab_params_json;

  PROCEDURE save_lab_results(p_order_id IN NUMBER, p_values IN CLOB, p_complete IN VARCHAR2 DEFAULT 'N', p_performer IN NUMBER DEFAULT NULL,
                             p_comment IN VARCHAR2 DEFAULT NULL) IS
    l_st   VARCHAR2(30);
    l_srv  NUMBER;
    l_f    VARCHAR2(5);
    l_n    NUMBER;
    l_sum  VARCHAR2(4000);
    l_flag VARCHAR2(30);
  BEGIN
    guard('HIS_ORDER.UPDATE');
    SELECT status_code, service_id INTO l_st, l_srv FROM his_order WHERE id = p_order_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_st IN ('ORDERED', 'IN_PROGRESS'), 'NOONA-HIS-068', 'حالة الطلب لا تسمح', 'Invalid order status');
    FOR r IN (SELECT * FROM JSON_TABLE(p_values, '$[*]' COLUMNS (p NUMBER PATH '$.p', v NUMBER PATH '$.v', t VARCHAR2(200) PATH '$.t'))) LOOP
      CONTINUE WHEN r.p IS NULL;
      SELECT COUNT(*) INTO l_n FROM his_lab_param WHERE id = r.p AND service_id = l_srv;
      NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-HIS-102', 'المكون لا يخص هذا التحليل', 'Parameter does not belong to the test');
      IF r.v IS NULL AND TRIM(r.t) IS NULL THEN
        DELETE FROM his_lab_result WHERE order_id = p_order_id AND param_id = r.p;
      ELSE
        l_f := CASE WHEN r.v IS NOT NULL THEN flag_of(r.p, r.v) END;
        MERGE INTO his_lab_result x USING (SELECT p_order_id o, r.p p FROM dual) s ON (x.order_id = s.o AND x.param_id = s.p)
         WHEN MATCHED THEN UPDATE SET x.value_num = r.v, x.value_text = TRIM(r.t), x.flag = l_f
         WHEN NOT MATCHED THEN INSERT (company_id, order_id, param_id, value_num, value_text, flag) VALUES (company, s.o, s.p, r.v, TRIM(r.t), l_f);
      END IF;
    END LOOP;
    IF l_st = 'ORDERED' THEN
      NOONA_HIS_PKG.start_order(p_order_id);
    END IF;
    IF p_complete = 'Y' THEN
      SELECT COUNT(*) INTO l_n FROM his_lab_result WHERE order_id = p_order_id;
      NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-HIS-103', 'أدخل قيمة مكون واحد على الأقل', 'Enter at least one value');
      -- الملخص والتقييم: حرجة إن وجدت قيمة حرجة، وغير طبيعية إن خرجت قيمة عن المعدل
      SELECT LISTAGG(p.code || ' ' || NVL(r.value_text, RTRIM(RTRIM(TO_CHAR(r.value_num, 'FM9999990D999', 'NLS_NUMERIC_CHARACTERS=''.,'''), '0'), '.'))
                     || CASE WHEN r.flag NOT IN ('N') THEN ' (' || r.flag || ')' END, ', ') WITHIN GROUP (ORDER BY p.sort_order),
             CASE WHEN MAX(CASE WHEN r.flag IN ('LL', 'HH') THEN 2 WHEN r.flag IN ('L', 'H') THEN 1 ELSE 0 END) = 2 THEN 'CRITICAL'
                  WHEN MAX(CASE WHEN r.flag IN ('L', 'H') THEN 1 ELSE 0 END) = 1 THEN 'ABNORMAL' ELSE 'NORMAL' END
        INTO l_sum, l_flag
        FROM his_lab_result r JOIN his_lab_param p ON p.id = r.param_id WHERE r.order_id = p_order_id;
      NOONA_HIS_PKG.complete_order(p_order_id, SUBSTR(l_sum || CASE WHEN TRIM(p_comment) IS NOT NULL THEN CHR(10) || p_comment END, 1, 4000), l_flag,
                                   p_performer);
    END IF;
  END save_lab_results;

  FUNCTION save_template(p_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_service_id IN NUMBER, p_modality IN VARCHAR2,
                         p_body IN VARCHAR2) RETURN NUMBER IS
    l NUMBER := p_id;
  BEGIN
    guard('HIS_SERVICE.UPDATE');
    NOONA_CORE_PKG.assert(TRIM(p_code) IS NOT NULL AND TRIM(p_body) IS NOT NULL AND (p_service_id IS NOT NULL OR p_modality IS NOT NULL), 'NOONA-HIS-104',
                          'الرمز والنص والخدمة أو الجهاز إلزامية', 'Code, body and service or modality are required');
    IF l IS NULL THEN
      SELECT MIN(id) INTO l FROM his_report_template WHERE company_id = company AND code = UPPER(TRIM(p_code));
    END IF;
    IF l IS NULL THEN
      INSERT INTO his_report_template (company_id, code, name_ar, service_id, modality, body, is_active)
      VALUES (company, UPPER(TRIM(p_code)), NVL(TRIM(p_name_ar), UPPER(TRIM(p_code))), p_service_id, p_modality, p_body, 'Y')
      RETURNING id INTO l;
    ELSE
      UPDATE his_report_template SET name_ar = NVL(TRIM(p_name_ar), name_ar), service_id = p_service_id, modality = p_modality, body = p_body WHERE id = l;
    END IF;
    RETURN l;
  END save_template;

  FUNCTION template_for(p_order_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT MAX(t.body) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN t.service_id = o.service_id THEN 0 ELSE 1 END)
      INTO l
      FROM his_order o JOIN his_service s ON s.id = o.service_id
      JOIN his_report_template t ON t.company_id = o.company_id AND t.is_active = 'Y' AND (t.service_id = o.service_id OR (t.service_id IS NULL AND t.modality = s.modality))
     WHERE o.id = p_order_id;
    RETURN l;
  END template_for;

  -- ================================================================ الصيدلية
  FUNCTION default_pharmacy RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM his_department WHERE company_id = company AND dept_type = 'PHARMACY' AND status_code = 'ACTIVE';
    RETURN l;
  END default_pharmacy;

  FUNCTION med_service(p_item_id IN NUMBER) RETURN NUMBER IS
    l     NUMBER;
    l_i   inv_item%ROWTYPE;
    l_pr  NUMBER;
    l_inc VARCHAR2(1);
    l_doc CLOB;
  BEGIN
    SELECT MIN(id) INTO l FROM his_service WHERE company_id = company AND item_id = p_item_id AND service_type = 'MEDICATION';
    IF l IS NOT NULL THEN RETURN l; END IF;
    SELECT * INTO l_i FROM inv_item WHERE id = p_item_id;
    NOONA_CORE_PKG.assert(NOONA_INV_PKG.is_stocked(p_item_id) = 'Y', 'NOONA-HIS-110', 'الدواء يجب أن يكون صنفاً مخزنياً', 'Medicine must be a stock item');
    SELECT MAX(sale_price), MAX(prices_include_tax) INTO l_pr, l_inc FROM inv_item_company WHERE item_id = p_item_id AND company_id = company;
    NOONA_CORE_PKG.assert(l_pr IS NOT NULL, 'NOONA-HIS-111', 'لا يوجد سعر بيع للدواء ' || l_i.name_ar, 'Medicine has no sale price');
    -- أسعار الدليل قبل الضريبة
    l_pr := CASE WHEN l_inc = 'Y' THEN ROUND(l_pr / 1.15, 2) ELSE l_pr END;
    SELECT JSON_OBJECT('code' VALUE 'MED-' || l_i.item_no, 'name' VALUE l_i.name_ar, 'name_en' VALUE NVL(l_i.name_en, l_i.name_ar), 'type' VALUE 'MEDICATION', 'dept' VALUE default_pharmacy,
                       'price' VALUE l_pr, 'item' VALUE p_item_id RETURNING CLOB) INTO l_doc FROM dual;
    RETURN NOONA_HIS_PKG.save_service(l_doc);
  END med_service;

  FUNCTION prescribe(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_vis  NUMBER := l_o.get_number('visit');
    l_doc  NUMBER := l_o.get_number('doctor');
    l_ph   NUMBER := l_o.get_number('pharmacy');
    l_nt   VARCHAR2(500) := l_o.get_string('notes');
    l_id   NUMBER;
    l_no   PLS_INTEGER := 0;
    l_st   VARCHAR2(30);
    l_x    NUMBER;
    l_rxno VARCHAR2(50);
  BEGIN
    guard('HIS_ORDER.CREATE');
    SELECT status_code, NVL(l_doc, doctor_id) INTO l_st, l_doc FROM his_visit WHERE id = l_vis AND company_id = company;
    NOONA_CORE_PKG.assert(l_st = 'OPEN', 'NOONA-HIS-051', 'الزيارة مقفلة', 'Visit is closed');
    l_ph := NVL(l_ph, default_pharmacy);
    NOONA_CORE_PKG.assert(l_ph IS NOT NULL, 'NOONA-HIS-112', 'لا توجد صيدلية داخلية معرفة', 'No pharmacy department');
    l_rxno := next_no('HIS_PRESCRIPTION', 'RX-');
    INSERT INTO his_prescription (company_id, rx_no, visit_id, doctor_id, pharmacy_id, rx_at, notes, status_code)
    VALUES (company, l_rxno, l_vis, l_doc, l_ph, SYSTIMESTAMP, l_nt, 'ACTIVE')
    RETURNING id INTO l_id;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (i NUMBER PATH '$.i', q NUMBER PATH '$.q', dose VARCHAR2(100) PATH '$.dose',
                freq VARCHAR2(100) PATH '$.freq', days NUMBER PATH '$.days', instr VARCHAR2(500) PATH '$.instr'))) LOOP
      CONTINUE WHEN r.i IS NULL;
      NOONA_CORE_PKG.assert(NVL(r.q, 0) > 0, 'NOONA-HIS-113', 'كمية الدواء يجب أن تكون موجبة', 'Quantity must be positive');
      l_x := med_service(r.i);
      l_no := l_no + 1;
      INSERT INTO his_prescription_line (company_id, prescription_id, line_no, item_id, dose, frequency, duration_days, quantity, dispensed_qty, instructions)
      VALUES (company, l_id, l_no, r.i, r.dose, r.freq, r.days, r.q, 0, r.instr);
    END LOOP;
    NOONA_CORE_PKG.assert(l_no > 0, 'NOONA-HIS-114', 'أضف دواءً واحداً على الأقل', 'Add at least one medicine');
    RETURN l_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-050', 'الزيارة غير موجودة', 'Visit not found');
  END prescribe;

  PROCEDURE bill_prescription(p_rx_id IN NUMBER, p_lines IN CLOB DEFAULT NULL) IS
    l_rx his_prescription%ROWTYPE;
    l_o  NUMBER;
    l_q  NUMBER;
    l_n  PLS_INTEGER := 0;
  BEGIN
    guard('HIS_ORDER.CREATE');
    SELECT * INTO l_rx FROM his_prescription WHERE id = p_rx_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_rx.status_code IN ('ACTIVE', 'PARTIAL'), 'NOONA-HIS-115', 'الوصفة مصروفة أو ملغاة', 'Prescription is closed');
    FOR ln IN (SELECT * FROM his_prescription_line WHERE prescription_id = p_rx_id AND order_id IS NULL ORDER BY line_no) LOOP
      l_q := ln.quantity;
      IF p_lines IS NOT NULL THEN
        SELECT MAX(q) INTO l_q FROM JSON_TABLE(p_lines, '$[*]' COLUMNS (l NUMBER PATH '$.l', q NUMBER PATH '$.q')) WHERE l = ln.id;
      END IF;
      CONTINUE WHEN NVL(l_q, 0) <= 0;
      NOONA_CORE_PKG.assert(l_q <= ln.quantity, 'NOONA-HIS-116', 'الكمية أكبر من المطلوب في الوصفة', 'Quantity exceeds the prescription');
      l_o := NOONA_HIS_PKG.add_order(l_rx.visit_id, med_service(ln.item_id), l_q, l_rx.doctor_id, 'وصفة ' || l_rx.rx_no);
      UPDATE his_order SET department_id = l_rx.pharmacy_id WHERE id = l_o;
      UPDATE his_prescription_line SET order_id = l_o, quantity = l_q WHERE id = ln.id;
      l_n := l_n + 1;
    END LOOP;
    NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-HIS-117', 'لا توجد أصناف للفوترة في الوصفة', 'Nothing to bill');
  END bill_prescription;

  PROCEDURE deliver_prescription(p_rx_id IN NUMBER) IS
    l_rx his_prescription%ROWTYPE;
    l_n  PLS_INTEGER := 0;
    l_left NUMBER;
  BEGIN
    guard('HIS_ORDER.UPDATE');
    SELECT * INTO l_rx FROM his_prescription WHERE id = p_rx_id AND company_id = company FOR UPDATE;
    FOR ln IN (SELECT l.id, l.order_id, l.quantity, o.status_code FROM his_prescription_line l JOIN his_order o ON o.id = l.order_id
                WHERE l.prescription_id = p_rx_id AND l.dispensed_qty < l.quantity AND o.status_code IN ('ORDERED', 'IN_PROGRESS')) LOOP
      NOONA_HIS_PKG.complete_order(ln.order_id, 'Dispensed by pharmacy', 'NORMAL');   -- يتحقق من السداد ويصرف من مستودع الصيدلية
      UPDATE his_prescription_line SET dispensed_qty = quantity WHERE id = ln.id;
      l_n := l_n + 1;
    END LOOP;
    NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-HIS-118', 'لا توجد أدوية مفوترة جاهزة للتسليم', 'Nothing ready to deliver');
    SELECT COUNT(*) INTO l_left FROM his_prescription_line WHERE prescription_id = p_rx_id AND dispensed_qty < quantity;
    UPDATE his_prescription SET status_code = CASE WHEN l_left = 0 THEN 'DISPENSED' ELSE 'PARTIAL' END WHERE id = p_rx_id;
  END deliver_prescription;

  PROCEDURE cancel_prescription(p_rx_id IN NUMBER) IS
    l_n NUMBER;
  BEGIN
    guard('HIS_ORDER.UPDATE');
    SELECT COUNT(*) INTO l_n FROM his_prescription_line WHERE prescription_id = p_rx_id AND dispensed_qty > 0;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-119', 'صرف جزء من الوصفة؛ لا تلغى', 'Part of the prescription was dispensed');
    FOR ln IN (SELECT order_id FROM his_prescription_line WHERE prescription_id = p_rx_id AND order_id IS NOT NULL) LOOP
      NOONA_HIS_PKG.cancel_order(ln.order_id, 'إلغاء الوصفة');
    END LOOP;
    UPDATE his_prescription SET status_code = 'CANCELLED' WHERE id = p_rx_id AND company_id = company;
  END cancel_prescription;

  -- ================================================================ التنويم
  FUNCTION save_bed(p_id IN NUMBER, p_ward_id IN NUMBER, p_bed_no IN VARCHAR2, p_room IN VARCHAR2, p_class IN VARCHAR2 DEFAULT 'WARD',
                    p_service_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l NUMBER := p_id;
    l_n NUMBER;
    l_srv NUMBER := NVL(p_service_id, srv_id('BED-DAY'));
  BEGIN
    guard('HIS_DEPARTMENT.UPDATE');
    NOONA_CORE_PKG.assert(p_ward_id IS NOT NULL AND TRIM(p_bed_no) IS NOT NULL, 'NOONA-HIS-120', 'الجناح ورقم السرير إلزاميان', 'Ward and bed are required');
    SELECT COUNT(*) INTO l_n FROM his_bed WHERE company_id = company AND bed_no = UPPER(TRIM(p_bed_no)) AND id <> NVL(p_id, -1);
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-121', 'رقم السرير مستخدم', 'Bed number already exists');
    IF l IS NULL THEN
      INSERT INTO his_bed (company_id, ward_id, bed_no, room_no, bed_class, day_service_id, status_code)
      VALUES (company, p_ward_id, UPPER(TRIM(p_bed_no)), p_room, NVL(p_class, 'WARD'), l_srv, 'AVAILABLE')
      RETURNING id INTO l;
    ELSE
      UPDATE his_bed SET ward_id = p_ward_id, bed_no = UPPER(TRIM(p_bed_no)), room_no = p_room, bed_class = NVL(p_class, bed_class),
                         day_service_id = NVL(p_service_id, day_service_id) WHERE id = l AND company_id = company;
    END IF;
    RETURN l;
  END save_bed;

  PROCEDURE set_bed_status(p_bed_id IN NUMBER, p_status IN VARCHAR2) IS
    l VARCHAR2(30);
  BEGIN
    guard('HIS_DEPARTMENT.UPDATE');
    SELECT status_code INTO l FROM his_bed WHERE id = p_bed_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l <> 'OCCUPIED' AND p_status IN ('AVAILABLE', 'CLEANING', 'BLOCKED'), 'NOONA-HIS-122',
                          'السرير مشغول بمريض؛ تتغير حالته بالخروج أو النقل', 'Bed is occupied');
    UPDATE his_bed SET status_code = p_status WHERE id = p_bed_id;
  END set_bed_status;

  FUNCTION take_bed(p_bed_id NUMBER) RETURN his_bed%ROWTYPE IS
    l his_bed%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM his_bed WHERE id = p_bed_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l.status_code = 'AVAILABLE', 'NOONA-HIS-123', 'السرير ' || l.bed_no || ' غير متاح', 'Bed is not available');
    UPDATE his_bed SET status_code = 'OCCUPIED' WHERE id = p_bed_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-124', 'السرير غير موجود', 'Bed not found');
  END take_bed;

  FUNCTION admit(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_pat  NUMBER := l_o.get_number('patient');
    l_vis  NUMBER := l_o.get_number('visit');
    l_doc  NUMBER := l_o.get_number('doctor');
    l_bed  NUMBER := l_o.get_number('bed');
    l_rs   VARCHAR2(1000) := l_o.get_string('reason');
    l_bill VARCHAR2(30) := l_o.get_string('bill_to');
    l_apr  VARCHAR2(50) := l_o.get_string('approval');
    l_b    his_bed%ROWTYPE;
    l_id   NUMBER;
    l_n    NUMBER;
    l_v    CLOB;
    l_ano  VARCHAR2(50);
  BEGIN
    guard('HIS_VISIT.CREATE');
    NOONA_CORE_PKG.assert(l_bed IS NOT NULL, 'NOONA-HIS-125', 'اختر السرير', 'Choose a bed');
    l_b := take_bed(l_bed);
    IF l_vis IS NULL THEN
      SELECT JSON_OBJECT('patient' VALUE l_pat, 'dept' VALUE l_b.ward_id, 'type' VALUE 'INPATIENT', 'bill_to' VALUE l_bill, 'approval' VALUE l_apr,
                         'complaint' VALUE l_rs RETURNING CLOB) INTO l_v FROM dual;
      l_vis := NOONA_HIS_PKG.open_visit(l_v);
      UPDATE his_visit SET doctor_id = l_doc WHERE id = l_vis;
    ELSE
      UPDATE his_visit SET visit_type = 'INPATIENT' WHERE id = l_vis AND company_id = company;
    END IF;
    SELECT COUNT(*) INTO l_n FROM his_admission WHERE visit_id = l_vis;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-126', 'الزيارة منومة سابقاً', 'Visit already admitted');
    l_ano := next_no('HIS_ADMISSION', 'AD-');
    INSERT INTO his_admission (company_id, admission_no, visit_id, bed_id, doctor_id, admit_at, charged_to, admit_reason, status_code)
    VALUES (company, l_ano, l_vis, l_bed, l_doc, SYSTIMESTAMP, TRUNC(SYSDATE) - 1, l_rs, 'ADMITTED')
    RETURNING id INTO l_id;
    INSERT INTO his_bed_move (company_id, admission_id, from_bed_id, to_bed_id, moved_at, reason) VALUES (company, l_id, NULL, l_bed, SYSTIMESTAMP, 'دخول');
    RETURN l_id;
  END admit;

  FUNCTION charge_beds(p_to IN DATE DEFAULT NULL, p_admission_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_to   DATE := TRUNC(NVL(p_to, SYSDATE));
    l_days NUMBER;
    l_tot  NUMBER := 0;
    l_o    NUMBER;
  BEGIN
    guard('HIS_ORDER.CREATE');
    FOR a IN (SELECT a.id, a.visit_id, a.charged_to, a.doctor_id, b.day_service_id, b.bed_no
                FROM his_admission a JOIN his_bed b ON b.id = a.bed_id
               WHERE a.company_id = company AND a.status_code = 'ADMITTED' AND (p_admission_id IS NULL OR a.id = p_admission_id)
                 AND a.charged_to < l_to FOR UPDATE OF a.charged_to) LOOP
      l_days := l_to - a.charged_to;
      IF a.day_service_id IS NOT NULL AND l_days > 0 THEN
        l_o := NOONA_HIS_PKG.add_order(a.visit_id, a.day_service_id, l_days, a.doctor_id,
                                       'أيام السرير ' || a.bed_no || ' من ' || TO_CHAR(a.charged_to + 1, 'YYYY-MM-DD') || ' إلى ' || TO_CHAR(l_to, 'YYYY-MM-DD'));
        -- يوم السرير خدمة منفذة بطبيعتها
        UPDATE his_order SET status_code = 'COMPLETED', started_at = SYSTIMESTAMP, completed_at = SYSTIMESTAMP, result_flag = 'NORMAL'
         WHERE id = l_o AND status_code = 'ORDERED';
        l_tot := l_tot + l_days;
      END IF;
      UPDATE his_admission SET charged_to = l_to WHERE id = a.id;
    END LOOP;
    RETURN l_tot;
  END charge_beds;

  PROCEDURE transfer_bed(p_admission_id IN NUMBER, p_bed_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_a his_admission%ROWTYPE;
    l_b his_bed%ROWTYPE;
    l_n NUMBER;
  BEGIN
    guard('HIS_VISIT.UPDATE');
    SELECT * INTO l_a FROM his_admission WHERE id = p_admission_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_a.status_code = 'ADMITTED', 'NOONA-HIS-127', 'المريض غير منوم', 'Patient is not admitted');
    NOONA_CORE_PKG.assert(p_bed_id <> l_a.bed_id, 'NOONA-HIS-128', 'اختر سريراً آخر', 'Choose another bed');
    -- الأيام السابقة بسعر السرير القديم
    l_n := charge_beds(TRUNC(SYSDATE) - 1, p_admission_id);
    l_b := take_bed(p_bed_id);
    UPDATE his_bed SET status_code = 'CLEANING' WHERE id = l_a.bed_id;
    UPDATE his_admission SET bed_id = p_bed_id WHERE id = p_admission_id;
    INSERT INTO his_bed_move (company_id, admission_id, from_bed_id, to_bed_id, moved_at, reason)
    VALUES (company, p_admission_id, l_a.bed_id, p_bed_id, SYSTIMESTAMP, SUBSTR(p_reason, 1, 500));
  END transfer_bed;

  PROCEDURE discharge(p_admission_id IN NUMBER, p_type IN VARCHAR2, p_summary IN VARCHAR2) IS
    l_a his_admission%ROWTYPE;
    l_n NUMBER;
  BEGIN
    guard('HIS_VISIT.UPDATE');
    SELECT * INTO l_a FROM his_admission WHERE id = p_admission_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_a.status_code = 'ADMITTED', 'NOONA-HIS-127', 'المريض غير منوم', 'Patient is not admitted');
    NOONA_CORE_PKG.assert(p_type IN ('HOME', 'TRANSFER', 'AGAINST_ADVICE', 'DECEASED') AND TRIM(p_summary) IS NOT NULL, 'NOONA-HIS-129',
                          'حدد نوع الخروج واكتب ملخص الخروج', 'Discharge type and summary are required');
    -- يوم الدخول يحمل ولو خرج في اليوم نفسه، ويوم الخروج لا يحمل
    l_n := charge_beds(GREATEST(TRUNC(SYSDATE) - 1, TRUNC(CAST(l_a.admit_at AS DATE))), p_admission_id);
    UPDATE his_admission SET status_code = 'DISCHARGED', discharge_at = SYSTIMESTAMP, discharge_type = p_type, discharge_summary = p_summary
     WHERE id = p_admission_id;
    UPDATE his_bed SET status_code = 'CLEANING' WHERE id = l_a.bed_id;
  END discharge;

  FUNCTION bed_board_html RETURN CLOB IS
    l_h CLOB := '<div class="nn-his-beds">';
    l_co NUMBER := company;
  BEGIN
    guard('HIS_VISIT.VIEW');
    FOR w IN (SELECT d.id, d.name_ar, COUNT(b.id) n, SUM(CASE WHEN b.status_code = 'OCCUPIED' THEN 1 ELSE 0 END) occ
                FROM his_department d JOIN his_bed b ON b.ward_id = d.id WHERE d.company_id = l_co GROUP BY d.id, d.name_ar ORDER BY d.name_ar) LOOP
      l_h := l_h || '<section class="nn-his-ward"><h3>' || esc(w.name_ar) || ' <small>' || w.occ || ' / ' || w.n || ' مشغول</small></h3><div class="nn-his-bedgrid">';
      FOR b IN (SELECT b.id, b.bed_no, b.room_no, b.bed_class, b.status_code, a.id adm, a.admission_no, p.name_ar, p.mrn,
                       TRUNC(SYSDATE) - TRUNC(CAST(a.admit_at AS DATE)) los, v.id vid
                  FROM his_bed b LEFT JOIN his_admission a ON a.bed_id = b.id AND a.status_code = 'ADMITTED'
                  LEFT JOIN his_visit v ON v.id = a.visit_id LEFT JOIN his_patient p ON p.id = v.patient_id
                 WHERE b.ward_id = w.id ORDER BY b.bed_no) LOOP
        l_h := l_h || '<div class="nn-his-bed bs-' || LOWER(b.status_code) || '" data-bed="' || b.id || '" data-adm="' || b.adm || '" data-visit="' || b.vid
            || '"><b>' || esc(b.bed_no) || '</b><small>' || esc(b.room_no) || ' · ' || esc(CASE b.bed_class WHEN 'PRIVATE' THEN 'خاص' WHEN 'SEMI_PRIVATE' THEN 'شبه خاص'
               WHEN 'SUITE' THEN 'جناح' WHEN 'ICU' THEN 'عناية مركزة' WHEN 'NICU' THEN 'حضانة' WHEN 'ISOLATION' THEN 'عزل' ELSE 'عام' END) || '</small>'
            || CASE WHEN b.adm IS NOT NULL THEN '<span>' || esc(b.name_ar) || '</span><small>' || esc(b.mrn) || ' · يوم ' || (b.los + 1) || '</small>'
                    ELSE '<span>' || CASE b.status_code WHEN 'AVAILABLE' THEN 'متاح' WHEN 'CLEANING' THEN 'تحت التنظيف' WHEN 'BLOCKED' THEN 'موقوف' END || '</span>' END
            || '</div>';
      END LOOP;
      l_h := l_h || '</div></section>';
    END LOOP;
    RETURN l_h || '</div>';
  END bed_board_html;

  -- ================================================================ العمليات
  FUNCTION schedule_surgery(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_vis  NUMBER := l_o.get_number('visit');
    l_srv  NUMBER := l_o.get_number('service');
    l_th   VARCHAR2(30) := UPPER(TRIM(l_o.get_string('theater')));
    l_sur  NUMBER := l_o.get_number('surgeon');
    l_an   NUMBER := l_o.get_number('anesthetist');
    l_ant  VARCHAR2(30) := l_o.get_string('anesthesia');
    l_st   TIMESTAMP := TO_TIMESTAMP(l_o.get_string('start'), 'YYYY-MM-DD HH24:MI');
    l_dur  NUMBER := NVL(l_o.get_number('duration'), 60);
    l_end  TIMESTAMP;
    l_typ  VARCHAR2(30);
    l_n    NUMBER;
    l_ord  NUMBER;
    l_id   NUMBER;
  BEGIN
    guard('HIS_ORDER.CREATE');
    NOONA_CORE_PKG.assert(l_vis IS NOT NULL AND l_srv IS NOT NULL AND l_th IS NOT NULL AND l_sur IS NOT NULL AND l_st IS NOT NULL, 'NOONA-HIS-130',
                          'الزيارة والعملية والغرفة والجراح والموعد إلزامية', 'Visit, surgery, theater, surgeon and time are required');
    SELECT service_type INTO l_typ FROM his_service WHERE id = l_srv;
    NOONA_CORE_PKG.assert(l_typ IN ('MINOR_SURGERY', 'MAJOR_SURGERY', 'PROCEDURE'), 'NOONA-HIS-131', 'الخدمة ليست عملية أو إجراء', 'Not a surgery');
    NOONA_CORE_PKG.assert(l_dur BETWEEN 10 AND 1440, 'NOONA-HIS-132', 'مدة العملية بين 10 دقائق و24 ساعة', 'Invalid duration');
    l_end := l_st + NUMTODSINTERVAL(l_dur, 'MINUTE');
    -- لا تعارض في الغرفة أو للجراح
    SELECT COUNT(*) INTO l_n FROM his_surgery
     WHERE company_id = company AND status_code IN ('SCHEDULED', 'IN_PROGRESS') AND start_at < l_end AND start_at + NUMTODSINTERVAL(duration_min, 'MINUTE') > l_st
       AND (theater = l_th OR surgeon_id = l_sur OR (l_an IS NOT NULL AND anesthetist_id = l_an));
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-133', 'يتعارض الموعد مع عملية أخرى في الغرفة أو للجراح أو طبيب التخدير', 'Schedule conflict');
    l_ord := NOONA_HIS_PKG.add_order(l_vis, l_srv, 1, l_sur, 'عملية ' || TO_CHAR(l_st, 'YYYY-MM-DD HH24:MI') || ' غرفة ' || l_th);
    INSERT INTO his_surgery (company_id, visit_id, order_id, service_id, theater, surgeon_id, anesthetist_id, anesthesia, start_at, duration_min, status_code)
    VALUES (company, l_vis, l_ord, l_srv, l_th, l_sur, l_an, l_ant, l_st, l_dur, 'SCHEDULED')
    RETURNING id INTO l_id;
    RETURN l_id;
  END schedule_surgery;

  PROCEDURE start_surgery(p_surgery_id IN NUMBER) IS
    l his_surgery%ROWTYPE;
  BEGIN
    guard('HIS_ORDER.UPDATE');
    SELECT * INTO l FROM his_surgery WHERE id = p_surgery_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l.status_code = 'SCHEDULED', 'NOONA-HIS-134', 'العملية ليست مجدولة', 'Surgery is not scheduled');
    NOONA_HIS_PKG.start_order(l.order_id);
    UPDATE his_surgery SET status_code = 'IN_PROGRESS', actual_start = SYSTIMESTAMP WHERE id = p_surgery_id;
  END start_surgery;

  PROCEDURE finish_surgery(p_surgery_id IN NUMBER, p_notes IN VARCHAR2) IS
    l his_surgery%ROWTYPE;
  BEGIN
    guard('HIS_ORDER.UPDATE');
    SELECT * INTO l FROM his_surgery WHERE id = p_surgery_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l.status_code = 'IN_PROGRESS', 'NOONA-HIS-135', 'العملية لم تبدأ', 'Surgery has not started');
    NOONA_CORE_PKG.assert(TRIM(p_notes) IS NOT NULL, 'NOONA-HIS-136', 'اكتب تقرير العملية', 'Operative notes are required');
    NOONA_HIS_PKG.complete_order(l.order_id, p_notes, 'NORMAL', l.surgeon_id);
    UPDATE his_surgery SET status_code = 'DONE', actual_end = SYSTIMESTAMP, operative_notes = p_notes WHERE id = p_surgery_id;
  END finish_surgery;

  PROCEDURE cancel_surgery(p_surgery_id IN NUMBER, p_reason IN VARCHAR2) IS
    l his_surgery%ROWTYPE;
  BEGIN
    guard('HIS_ORDER.UPDATE');
    SELECT * INTO l FROM his_surgery WHERE id = p_surgery_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l.status_code = 'SCHEDULED', 'NOONA-HIS-134', 'العملية ليست مجدولة', 'Surgery is not scheduled');
    NOONA_HIS_PKG.cancel_order(l.order_id, p_reason);
    UPDATE his_surgery SET status_code = 'CANCELLED', operative_notes = SUBSTR('إلغاء: ' || p_reason, 1, 4000) WHERE id = p_surgery_id;
  END cancel_surgery;

  FUNCTION or_board_html(p_date IN DATE) RETURN CLOB IS
    l_h CLOB := '<div class="nn-his-board">';
    l_d DATE := TRUNC(NVL(p_date, SYSDATE));
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('HIS_VISIT.VIEW');
    FOR t IN (SELECT DISTINCT theater FROM his_surgery WHERE company_id = company AND TRUNC(CAST(start_at AS DATE)) = l_d AND status_code <> 'CANCELLED'
              ORDER BY theater) LOOP
      l_n := l_n + 1;
      l_h := l_h || '<section class="nn-his-col"><header><b>غرفة ' || esc(t.theater) || '</b></header>';
      FOR s IN (SELECT s.id, TO_CHAR(s.start_at, 'HH24:MI') st, TO_CHAR(s.start_at + NUMTODSINTERVAL(s.duration_min, 'MINUTE'), 'HH24:MI') en, s.status_code,
                       NOONA_HIS_PKG.service_name(sv.id) sname, p.name_ar pname, p.mrn, dr.name_ar sur, an.name_ar ane, s.anesthesia, o.status_code ost, o.invoice_id, v.visit_type
                  FROM his_surgery s JOIN his_service sv ON sv.id = s.service_id JOIN his_visit v ON v.id = s.visit_id JOIN his_patient p ON p.id = v.patient_id
                  JOIN his_doctor dr ON dr.id = s.surgeon_id LEFT JOIN his_doctor an ON an.id = s.anesthetist_id JOIN his_order o ON o.id = s.order_id
                 WHERE s.company_id = company AND s.theater = t.theater AND TRUNC(CAST(s.start_at AS DATE)) = l_d AND s.status_code <> 'CANCELLED'
                 ORDER BY s.start_at) LOOP
        l_h := l_h || '<div class="nn-his-appt ap-' || CASE s.status_code WHEN 'DONE' THEN 'completed' WHEN 'IN_PROGRESS' THEN 'arrived' ELSE 'booked' END
            || '" data-surgery="' || s.id || '"><b>' || s.st || '-' || s.en || '</b> ' || esc(s.sname) || '<small>' || esc(s.pname) || ' (' || esc(s.mrn) || ') · '
            || esc(s.sur) || CASE WHEN s.ane IS NOT NULL THEN ' · تخدير: ' || esc(s.ane) END
            || CASE WHEN s.ost = 'APPROVAL_PENDING' THEN ' · بانتظار موافقة التأمين' WHEN s.invoice_id IS NULL AND s.visit_type NOT IN ('INPATIENT', 'DAY_CASE', 'EMERGENCY')
                    THEN ' · غير مسددة' END || '</small><span>'
            || CASE s.status_code WHEN 'DONE' THEN 'منجزة' WHEN 'IN_PROGRESS' THEN 'جارية' ELSE 'مجدولة' END || '</span></div>';
      END LOOP;
      l_h := l_h || '</section>';
    END LOOP;
    IF l_n = 0 THEN
      l_h := l_h || '<p class="nn-hint">لا توجد عمليات مجدولة في هذا اليوم</p>';
    END IF;
    RETURN l_h || '</div>';
  END or_board_html;

  -- ================================================================ العلاج الطبيعي
  FUNCTION create_plan(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_vis NUMBER := l_o.get_number('visit');
    l_srv NUMBER := l_o.get_number('service');
    l_n   NUMBER := l_o.get_number('sessions');
    l_th  NUMBER := l_o.get_number('therapist');
    l_fr  VARCHAR2(100) := l_o.get_string('frequency');
    l_gl  VARCHAR2(1000) := l_o.get_string('goals');
    l_ord NUMBER;
    l_id  NUMBER;
    l_typ VARCHAR2(30);
  BEGIN
    guard('HIS_ORDER.CREATE');
    NOONA_CORE_PKG.assert(l_vis IS NOT NULL AND l_srv IS NOT NULL AND NVL(l_n, 0) BETWEEN 1 AND 100, 'NOONA-HIS-140',
                          'الزيارة والجلسة وعدد الجلسات (1-100) إلزامية', 'Visit, service and sessions (1..100) are required');
    SELECT service_type INTO l_typ FROM his_service WHERE id = l_srv;
    NOONA_CORE_PKG.assert(l_typ IN ('PHYSIOTHERAPY', 'THERAPY', 'NURSING', 'DENTAL'), 'NOONA-HIS-141', 'الخدمة ليست جلسات علاجية', 'Not a session service');
    l_ord := NOONA_HIS_PKG.add_order(l_vis, l_srv, l_n, l_th, 'خطة ' || l_n || ' جلسات' || NVL2(l_fr, ' - ' || l_fr, ''));
    INSERT INTO his_therapy_plan (company_id, visit_id, service_id, order_id, therapist_id, sessions_total, sessions_done, frequency, goals, status_code)
    VALUES (company, l_vis, l_srv, l_ord, l_th, l_n, 0, l_fr, l_gl, 'ACTIVE')
    RETURNING id INTO l_id;
    RETURN l_id;
  END create_plan;

  FUNCTION record_session(p_plan_id IN NUMBER, p_therapist IN NUMBER, p_notes IN VARCHAR2) RETURN NUMBER IS
    l    his_therapy_plan%ROWTYPE;
    l_st VARCHAR2(30);
  BEGIN
    guard('HIS_ORDER.UPDATE');
    SELECT * INTO l FROM his_therapy_plan WHERE id = p_plan_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l.status_code = 'ACTIVE', 'NOONA-HIS-142', 'الخطة منتهية أو ملغاة', 'Plan is closed');
    SELECT status_code INTO l_st FROM his_order WHERE id = l.order_id;
    IF l_st = 'ORDERED' THEN
      NOONA_HIS_PKG.start_order(l.order_id);   -- يتحقق من السداد والموافقة
    END IF;
    INSERT INTO his_therapy_session (company_id, plan_id, session_no, session_at, therapist_id, notes)
    VALUES (company, p_plan_id, l.sessions_done + 1, SYSTIMESTAMP, NVL(p_therapist, l.therapist_id), p_notes);
    UPDATE his_therapy_plan SET sessions_done = sessions_done + 1 WHERE id = p_plan_id;
    IF l.sessions_done + 1 >= l.sessions_total THEN
      NOONA_HIS_PKG.complete_order(l.order_id, 'اكتملت ' || l.sessions_total || ' جلسات. ' || p_notes, 'NORMAL', NVL(p_therapist, l.therapist_id));
      UPDATE his_therapy_plan SET status_code = 'COMPLETED' WHERE id = p_plan_id;
    END IF;
    RETURN l.sessions_done + 1;
  END record_session;

  -- ================================================================ الأجهزة
  FUNCTION save_device(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := l_o.get_number('id');
    l_code VARCHAR2(50) := UPPER(TRIM(l_o.get_string('code')));
    l_name VARCHAR2(200) := TRIM(l_o.get_string('name'));
    l_dept NUMBER := l_o.get_number('dept');
    l_mod  VARCHAR2(30) := l_o.get_string('modality');
    l_mf   VARCHAR2(100) := l_o.get_string('manufacturer');
    l_md   VARCHAR2(100) := l_o.get_string('model');
    l_sn   VARCHAR2(100) := l_o.get_string('serial');
    l_as   NUMBER := l_o.get_number('asset');
    l_in   DATE := d(l_o.get_string('installed'));
    l_wr   DATE := d(l_o.get_string('warranty'));
    l_cd   NUMBER := l_o.get_number('cal_days');
    l_n    NUMBER;
  BEGIN
    guard('HIS_DEPARTMENT.UPDATE');
    NOONA_CORE_PKG.assert(l_code IS NOT NULL AND l_name IS NOT NULL AND l_dept IS NOT NULL, 'NOONA-HIS-150', 'رمز الجهاز واسمه والقسم إلزامية',
                          'Code, name and department are required');
    SELECT COUNT(*) INTO l_n FROM his_device WHERE company_id = company AND code = l_code AND id <> NVL(l_id, -1);
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-151', 'رمز الجهاز مستخدم', 'Device code already exists');
    IF l_id IS NULL THEN
      INSERT INTO his_device (company_id, code, name_ar, department_id, modality, manufacturer, model, serial_no, fa_asset_id, installed_on, warranty_to,
                              calibration_days, next_calibration, status_code)
      VALUES (company, l_code, l_name, l_dept, l_mod, l_mf, l_md, l_sn, l_as, l_in, l_wr, l_cd,
              CASE WHEN l_cd IS NOT NULL THEN NVL(l_in, TRUNC(SYSDATE)) + l_cd END, 'IN_SERVICE')
      RETURNING id INTO l_id;
    ELSE
      UPDATE his_device SET code = l_code, name_ar = l_name, department_id = l_dept, modality = l_mod, manufacturer = l_mf, model = l_md, serial_no = l_sn,
                            fa_asset_id = l_as, installed_on = l_in, warranty_to = l_wr, calibration_days = l_cd,
                            next_calibration = CASE WHEN l_cd IS NOT NULL THEN NVL(last_calibration, NVL(l_in, TRUNC(SYSDATE))) + l_cd END
       WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  END save_device;

  PROCEDURE log_device(p_device_id IN NUMBER, p_type IN VARCHAR2, p_date IN DATE, p_vendor IN VARCHAR2, p_cost IN NUMBER, p_notes IN VARCHAR2) IS
    l his_device%ROWTYPE;
    l_d DATE := TRUNC(NVL(p_date, SYSDATE));
  BEGIN
    guard('HIS_DEPARTMENT.UPDATE');
    SELECT * INTO l FROM his_device WHERE id = p_device_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(p_type IN ('CALIBRATION', 'PREVENTIVE', 'REPAIR', 'BREAKDOWN', 'RETURN_TO_SERVICE'), 'NOONA-HIS-152', 'نوع السجل غير معروف',
                          'Unknown log type');
    NOONA_CORE_PKG.assert(l_d <= TRUNC(SYSDATE), 'NOONA-HIS-153', 'التاريخ في المستقبل', 'Date is in the future');
    INSERT INTO his_device_log (company_id, device_id, log_type, log_date, vendor, cost, notes)
    VALUES (company, p_device_id, p_type, l_d, p_vendor, p_cost, p_notes);
    IF p_type = 'CALIBRATION' THEN
      UPDATE his_device SET last_calibration = l_d, next_calibration = CASE WHEN calibration_days IS NOT NULL THEN l_d + calibration_days END
       WHERE id = p_device_id;
    ELSIF p_type = 'BREAKDOWN' THEN
      UPDATE his_device SET status_code = 'OUT_OF_SERVICE' WHERE id = p_device_id;
    ELSIF p_type IN ('RETURN_TO_SERVICE', 'REPAIR') THEN
      UPDATE his_device SET status_code = 'IN_SERVICE' WHERE id = p_device_id;
    END IF;
  END log_device;

  FUNCTION devices_html RETURN CLOB IS
    l_h CLOB;
    l_out NUMBER; l_due NUMBER; l_n NUMBER;
  BEGIN
    guard('HIS_DEPARTMENT.VIEW');
    SELECT COUNT(*), COUNT(CASE WHEN status_code = 'OUT_OF_SERVICE' THEN 1 END), COUNT(CASE WHEN next_calibration <= TRUNC(SYSDATE) + 14 THEN 1 END)
      INTO l_n, l_out, l_due FROM his_device WHERE company_id = company AND status_code <> 'RETIRED';
    l_h := '<div class="nn-rst-kpis"><div class="nn-rst-kpi is-main"><span>الأجهزة</span><b>' || l_n || '</b></div>'
        || '<div class="nn-rst-kpi ' || CASE WHEN l_out > 0 THEN 'is-neg' END || '"><span>خارج الخدمة</span><b>' || l_out || '</b></div>'
        || '<div class="nn-rst-kpi ' || CASE WHEN l_due > 0 THEN 'is-warn' END || '"><span>معايرة مستحقة خلال 14 يوماً</span><b>' || l_due || '</b></div></div>';
    RETURN l_h;
  END devices_html;

  -- ================================================================ الإعدادات النموذجية
  FUNCTION seed_defaults RETURN NUMBER IS
    l_n NUMBER := 0;
    l_x NUMBER;
    l_s NUMBER;
    l_w NUMBER;
    PROCEDURE p(p_srv VARCHAR2, p_code VARCHAR2, p_name VARCHAR2, p_unit VARCHAR2, p_low NUMBER, p_high NUMBER, p_cl NUMBER DEFAULT NULL,
                p_ch NUMBER DEFAULT NULL, p_g VARCHAR2 DEFAULT NULL, p_ref VARCHAR2 DEFAULT NULL, p_en VARCHAR2 DEFAULT NULL) IS
    BEGIN
      l_s := srv_id(p_srv);
      IF l_s IS NOT NULL THEN
        l_x := set_lab_param(l_s, p_code, p_name, p_unit, p_low, p_high, p_cl, p_ch, p_g, NULL, NULL, p_ref, p_en);
        l_n := l_n + 1;
      END IF;
    END p;
  BEGIN
    guard('HIS_SERVICE.UPDATE');
    -- دليل الخدمات: يضيف الجديد ويكمل الأسماء الإنجليزية للفحوص والأشعة والإجراءات المحملة سابقاً
    l_x := NOONA_HIS_PKG.seed_catalog;
    -- صورة الدم الكاملة (حسب الجنس للهيموجلوبين وكريات الدم الحمراء)
    p('LAB-CBC', 'WBC', 'كريات الدم البيضاء', '10^9/L', 4, 11, 2, 30, p_en => 'White Blood Cells');
    p('LAB-CBC', 'RBC', 'كريات الدم الحمراء', '10^12/L', 4.5, 5.9, NULL, NULL, 'M', p_en => 'Red Blood Cells');
    p('LAB-CBC', 'RBC', 'كريات الدم الحمراء', '10^12/L', 4.1, 5.1, NULL, NULL, 'F', p_en => 'Red Blood Cells');
    p('LAB-CBC', 'HB', 'الهيموجلوبين', 'g/dL', 13.5, 17.5, 7, 20, 'M', p_en => 'Hemoglobin');
    p('LAB-CBC', 'HB', 'الهيموجلوبين', 'g/dL', 12, 15.5, 7, 20, 'F', p_en => 'Hemoglobin');
    p('LAB-CBC', 'PLT', 'الصفائح الدموية', '10^9/L', 150, 400, 50, 1000, p_en => 'Platelets');
    p('LAB-ESR', 'ESR', 'سرعة الترسيب', 'mm/hr', 0, 20, p_en => 'ESR');
    p('LAB-FBS', 'GLU', 'سكر الدم الصائم', 'mg/dL', 70, 100, 50, 400, p_en => 'Glucose (fasting)');
    p('LAB-HBA1C', 'A1C', 'السكر التراكمي', '%', 4, 5.6, p_en => 'HbA1c');
    p('LAB-LIPID', 'CHOL', 'الكوليسترول الكلي', 'mg/dL', NULL, 200, p_en => 'Total Cholesterol');
    p('LAB-LIPID', 'LDL', 'الكوليسترول الضار', 'mg/dL', NULL, 100, p_en => 'LDL Cholesterol');
    p('LAB-LIPID', 'HDL', 'الكوليسترول النافع', 'mg/dL', 40, NULL, p_en => 'HDL Cholesterol');
    p('LAB-LIPID', 'TG', 'الدهون الثلاثية', 'mg/dL', NULL, 150, p_en => 'Triglycerides');
    p('LAB-KFT', 'CREA', 'الكرياتينين', 'mg/dL', 0.6, 1.2, NULL, 5, p_en => 'Creatinine');
    p('LAB-KFT', 'UREA', 'اليوريا', 'mg/dL', 15, 40, p_en => 'Urea');
    p('LAB-KFT', 'K', 'البوتاسيوم', 'mmol/L', 3.5, 5.1, 2.5, 6.5, p_en => 'Potassium');
    p('LAB-LFT', 'ALT', 'إنزيم ALT', 'U/L', 7, 56, p_en => 'ALT (SGPT)');
    p('LAB-LFT', 'AST', 'إنزيم AST', 'U/L', 10, 40, p_en => 'AST (SGOT)');
    p('LAB-LFT', 'TBIL', 'البيليروبين الكلي', 'mg/dL', 0.1, 1.2, p_en => 'Total Bilirubin');
    p('LAB-TSH', 'TSH', 'هرمون الغدة الدرقية', 'mIU/L', 0.4, 4, p_en => 'TSH');
    p('LAB-VITD', 'VITD', 'فيتامين د', 'ng/mL', 30, 100, 10, NULL, p_en => '25-OH Vitamin D');
    p('LAB-UR', 'COLOR', 'اللون', NULL, NULL, NULL, p_ref => 'Pale yellow', p_en => 'Color');
    p('LAB-UR', 'PUS', 'خلايا الصديد', '/HPF', 0, 5, p_en => 'Pus Cells');
    p('LAB-UR', 'PROT', 'البروتين', NULL, NULL, NULL, p_ref => 'Negative', p_en => 'Protein');
    -- قوالب تقارير الأشعة والتشخيص (بالإنجليزية)
    l_x := save_template(NULL, 'TPL-XR', 'X-Ray report', NULL, 'XRAY',
      'Technique:' || CHR(10) || 'Findings: No fracture or dislocation. Soft tissues are unremarkable.' || CHR(10) || 'Impression: Normal study.');
    l_x := save_template(NULL, 'TPL-US', 'Ultrasound report', NULL, 'ULTRASOUND',
      'Liver: Normal size and echotexture.' || CHR(10) || 'Gallbladder: No stones.' || CHR(10) || 'Kidneys: Normal size, no stones or hydronephrosis.'
      || CHR(10) || 'Impression:');
    l_x := save_template(NULL, 'TPL-CT', 'CT report', NULL, 'CT', 'Technique:' || CHR(10) || 'Findings:' || CHR(10) || 'Impression:');
    l_x := save_template(NULL, 'TPL-MRI', 'MRI report', NULL, 'MRI', 'Technique:' || CHR(10) || 'Findings:' || CHR(10) || 'Impression:');
    l_x := save_template(NULL, 'TPL-ECG', 'ECG report', NULL, 'ECG', 'Rhythm: Sinus' || CHR(10) || 'Rate:' || CHR(10) || 'Axis:' || CHR(10)
                         || 'ST/T: No acute changes' || CHR(10) || 'Impression:');
    l_x := save_template(NULL, 'TPL-ECHO', 'Echocardiography report', NULL, 'ECHO', 'LV function / EF:' || CHR(10) || 'Valves:' || CHR(10)
                         || 'Pericardium:' || CHR(10) || 'Impression:');
    -- أسرة جناح التنويم
    SELECT MIN(id) INTO l_w FROM his_department WHERE company_id = company AND dept_type = 'INPATIENT_WARD';
    IF l_w IS NOT NULL THEN
      SELECT COUNT(*) INTO l_x FROM his_bed WHERE ward_id = l_w;
      IF l_x = 0 THEN
        FOR k IN 1 .. 8 LOOP
          l_x := save_bed(NULL, l_w, 'W-' || LPAD(k, 2, '0'), 'غرفة ' || (100 + CEIL(k / 2)), CASE WHEN k <= 2 THEN 'PRIVATE' ELSE 'SEMI_PRIVATE' END);
        END LOOP;
        l_n := l_n + 8;
      END IF;
    END IF;
    RETURN l_n;
  END seed_defaults;

END NOONA_HIS_CARE_PKG;
/
