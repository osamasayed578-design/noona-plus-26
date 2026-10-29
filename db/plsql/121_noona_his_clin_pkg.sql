-- =============================================================================
-- NOONA PLUS ERP | السجل السريري والتمريض وعمولات الأطباء: NOONA_HIS_CLIN_PKG
--   الفرز في الطوارئ (CTAS 1-5) ولوحة الطوارئ، العلامات الحيوية المتكررة، الملاحظات السريرية (تمريض، متابعة، استشارة، خروج)،
--   سجل إعطاء الأدوية للمنومين والطوارئ (MAR)، التقارير الطبية والإجازات المرضية والتحويل برمز تحقق، الملف الطبي للمريض،
--   وتسوية عمولات الأطباء بقيد استحقاق (من حـ/ عمولات الأطباء 5220 إلى حـ/ عمولات أطباء مستحقة 2111) تصرف بسند صرف.
--   المحتوى السريري بالإنجليزية.
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_HIS_CLIN_PKG AUTHID DEFINER AS

  FUNCTION company RETURN NUMBER;

  -- ---------------------------------------------------------- الطوارئ
  PROCEDURE set_triage(p_visit_id IN NUMBER, p_level IN VARCHAR2);
  FUNCTION triage_label(p_level IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION er_board_html RETURN CLOB;

  -- ---------------------------------------------------------- التمريض
  -- {"visit","bp":"120/80","pulse","temp","rr","spo2","weight","height","pain","glucose","notes"}
  FUNCTION record_vitals(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION vitals_html(p_visit_id IN NUMBER) RETURN CLOB;
  FUNCTION add_note(p_visit_id IN NUMBER, p_type IN VARCHAR2, p_text IN VARCHAR2, p_author IN NUMBER DEFAULT NULL) RETURN NUMBER;
  -- {"line","outcome":"GIVEN|HELD|REFUSED|MISSED","dose","route","nurse","notes"}
  FUNCTION give_medication(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION mar_html(p_visit_id IN NUMBER) RETURN CLOB;
  FUNCTION notes_html(p_visit_id IN NUMBER) RETURN CLOB;

  -- ---------------------------------------------------------- التقارير الطبية
  -- {"visit","type":"SICK_LEAVE|MEDICAL_REPORT|REFERRAL|FITNESS|COMPANION","from","to","referral_to","body","doctor"}
  FUNCTION issue_certificate(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE cancel_certificate(p_id IN NUMBER, p_reason IN VARCHAR2);
  FUNCTION certificate_html(p_id IN NUMBER) RETURN CLOB;
  FUNCTION cert_type_label(p_type IN VARCHAR2) RETURN VARCHAR2;

  -- ---------------------------------------------------------- الملف الطبي
  FUNCTION patient_history_html(p_patient_id IN NUMBER) RETURN CLOB;

  -- ---------------------------------------------------------- عمولات الأطباء
  FUNCTION commission_preview_html(p_from IN DATE, p_to IN DATE) RETURN CLOB;
  -- يسوي عمولات الفترة لكل طبيب له نسبة (أو لطبيب واحد)؛ يعيد عدد التسويات
  FUNCTION settle_commissions(p_from IN DATE, p_to IN DATE, p_doctor_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
  PROCEDURE cancel_commission(p_id IN NUMBER, p_reason IN VARCHAR2);
END NOONA_HIS_CLIN_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_HIS_CLIN_PKG AS

  c_com CONSTANT VARCHAR2(30) := 'HIS_COMMISSION';

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;
  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END;
  FUNCTION fmt0(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(NVL(p, 0), 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.,''');
  END fmt0;
  FUNCTION num(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN RTRIM(RTRIM(TO_CHAR(p, 'FM9999990D99', 'NLS_NUMERIC_CHARACTERS=''.,'''), '0'), '.');
  END num;
  FUNCTION d(p VARCHAR2) RETURN DATE IS BEGIN RETURN TO_DATE(p, 'YYYY-MM-DD'); END;
  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;
  FUNCTION next_no(p_type VARCHAR2, p_prefix VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT company, p_type, NULL, p_prefix, 1, 6, 'N', 'NEVER', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = p_type);
    RETURN NOONA_REFERENCE_PKG.next_doc_no(p_type, company, NULL, TRUNC(SYSDATE), p_type, NULL);
  END next_no;
  FUNCTION get_visit(p_id NUMBER) RETURN his_visit%ROWTYPE IS
    l his_visit%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM his_visit WHERE id = p_id AND company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-050', 'الزيارة غير موجودة', 'Visit not found');
  END get_visit;
  FUNCTION age_of(p_birth DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_birth IS NULL THEN NULL WHEN MONTHS_BETWEEN(SYSDATE, p_birth) < 24 THEN TRUNC(MONTHS_BETWEEN(SYSDATE, p_birth)) || ' mo'
                ELSE TRUNC(MONTHS_BETWEEN(SYSDATE, p_birth) / 12) || ' y' END;
  END age_of;

  -- ================================================================ الطوارئ
  FUNCTION triage_label(p_level IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_level WHEN '1' THEN '1 - Resuscitation' WHEN '2' THEN '2 - Emergent' WHEN '3' THEN '3 - Urgent' WHEN '4' THEN '4 - Less urgent'
                        WHEN '5' THEN '5 - Non urgent' ELSE 'Not triaged' END;
  END triage_label;

  PROCEDURE set_triage(p_visit_id IN NUMBER, p_level IN VARCHAR2) IS
    l_v his_visit%ROWTYPE := get_visit(p_visit_id);
  BEGIN
    guard('HIS_VISIT.UPDATE');
    NOONA_CORE_PKG.assert(l_v.status_code = 'OPEN', 'NOONA-HIS-051', 'الزيارة مقفلة', 'Visit is closed');
    NOONA_CORE_PKG.assert(p_level IN ('1', '2', '3', '4', '5'), 'NOONA-HIS-220', 'مستوى الفرز من 1 إلى 5', 'Triage level must be 1-5');
    UPDATE his_visit SET triage_level = p_level, triage_at = SYSTIMESTAMP, triage_by = NOONA_CTX_PKG.current_user_name WHERE id = p_visit_id;
  END set_triage;

  FUNCTION er_board_html RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('HIS_VISIT.VIEW');
    l_h := '<div class="nn-his-er">';
    FOR r IN (SELECT v.id, v.visit_no, v.triage_level, v.chief_complaint, v.vitals, ROUND((CAST(SYSTIMESTAMP AS DATE) - CAST(v.visit_at AS DATE)) * 1440) mins,
                     p.name_ar, p.mrn, p.gender, p.birth_date, p.allergies, dr.name_ar doctor,
                     (SELECT COUNT(*) FROM his_order o WHERE o.visit_id = v.id AND o.status_code IN ('ORDERED', 'IN_PROGRESS', 'APPROVAL_PENDING')) pend
                FROM his_visit v JOIN his_patient p ON p.id = v.patient_id LEFT JOIN his_doctor dr ON dr.id = v.doctor_id
               WHERE v.company_id = company AND v.status_code = 'OPEN' AND v.visit_type = 'EMERGENCY'
               ORDER BY CASE WHEN v.triage_level IS NULL THEN 0 ELSE TO_NUMBER(v.triage_level) END, v.visit_at) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<div class="nn-his-ercard tl-' || NVL(r.triage_level, '0') || '" data-visit="' || r.id || '"><header><b>' || esc(triage_label(r.triage_level))
          || '</b><span>' || r.mins || ' min</span></header><div><b>' || esc(r.name_ar) || '</b> <small>' || r.mrn || ' · '
          || CASE r.gender WHEN 'M' THEN 'M' ELSE 'F' END || ' · ' || age_of(r.birth_date) || '</small></div>'
          || '<div dir="ltr">' || esc(r.chief_complaint) || '</div>' || NVL2(r.vitals, '<small dir="ltr">' || esc(r.vitals) || '</small>', '')
          || NVL2(r.allergies, '<span class="nn-rst-chip is-cancelled">Allergy: ' || esc(r.allergies) || '</span>', '')
          || '<footer><small>' || esc(NVL(r.doctor, '-')) || '</small><small>' || r.pend || ' طلب مفتوح</small></footer></div>');
    END LOOP;
    IF l_n = 0 THEN
      l_h := l_h || ('<p class="nn-hint">لا يوجد مرضى في الطوارئ الآن.</p>');
    END IF;
    RETURN l_h || ('</div>');
  END er_board_html;

  -- ================================================================ العلامات الحيوية والملاحظات
  FUNCTION record_vitals(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_vis  NUMBER := l_o.get_number('visit');
    l_bp   VARCHAR2(20) := TRIM(l_o.get_string('bp'));
    l_sys  NUMBER;
    l_dia  NUMBER;
    l_pul  NUMBER := l_o.get_number('pulse');
    l_tmp  NUMBER := l_o.get_number('temp');
    l_rr   NUMBER := l_o.get_number('rr');
    l_spo  NUMBER := l_o.get_number('spo2');
    l_wt   NUMBER := l_o.get_number('weight');
    l_ht   NUMBER := l_o.get_number('height');
    l_pain NUMBER := l_o.get_number('pain');
    l_glu  NUMBER := l_o.get_number('glucose');
    l_nt   VARCHAR2(500) := l_o.get_string('notes');
    l_v    his_visit%ROWTYPE := get_visit(l_vis);
    l_id   NUMBER;
    l_sum  VARCHAR2(1000);
  BEGIN
    guard('HIS_VISIT.UPDATE');
    NOONA_CORE_PKG.assert(l_v.status_code = 'OPEN', 'NOONA-HIS-051', 'الزيارة مقفلة', 'Visit is closed');
    IF l_bp IS NOT NULL THEN
      NOONA_CORE_PKG.assert(REGEXP_LIKE(l_bp, '^\d{2,3}\s*/\s*\d{2,3}$'), 'NOONA-HIS-221', 'الضغط بصيغة 120/80', 'Blood pressure as 120/80');
      l_sys := TO_NUMBER(TRIM(REGEXP_SUBSTR(l_bp, '\d+', 1, 1)));
      l_dia := TO_NUMBER(TRIM(REGEXP_SUBSTR(l_bp, '\d+', 1, 2)));
    END IF;
    NOONA_CORE_PKG.assert((l_sys IS NULL OR l_sys BETWEEN 40 AND 300) AND (l_dia IS NULL OR l_dia BETWEEN 20 AND 200)
                          AND (l_pul IS NULL OR l_pul BETWEEN 20 AND 250) AND (l_tmp IS NULL OR l_tmp BETWEEN 30 AND 45)
                          AND (l_rr IS NULL OR l_rr BETWEEN 4 AND 80) AND (l_spo IS NULL OR l_spo BETWEEN 40 AND 100)
                          AND (l_wt IS NULL OR l_wt BETWEEN 0.3 AND 400) AND (l_ht IS NULL OR l_ht BETWEEN 20 AND 250)
                          AND (l_pain IS NULL OR l_pain BETWEEN 0 AND 10) AND (l_glu IS NULL OR l_glu BETWEEN 10 AND 1500),
                          'NOONA-HIS-222', 'قيمة علامة حيوية خارج المدى المعقول', 'A vital sign is out of the plausible range');
    NOONA_CORE_PKG.assert(COALESCE(l_sys, l_pul, l_tmp, l_rr, l_spo, l_wt, l_ht, l_pain, l_glu) IS NOT NULL, 'NOONA-HIS-223', 'أدخل قراءة واحدة على الأقل',
                          'Enter at least one reading');
    INSERT INTO his_vital_sign (company_id, visit_id, taken_at, bp_sys, bp_dia, pulse, temperature, resp_rate, spo2, weight, height, pain_score, glucose, notes)
    VALUES (company, l_vis, SYSTIMESTAMP, l_sys, l_dia, l_pul, l_tmp, l_rr, l_spo, l_wt, l_ht, l_pain, l_glu, l_nt)
    RETURNING id INTO l_id;
    -- خلاصة آخر قراءة في ملف الزيارة
    l_sum := RTRIM(CASE WHEN l_sys IS NOT NULL THEN 'BP ' || l_sys || '/' || l_dia || ', ' END || CASE WHEN l_tmp IS NOT NULL THEN 'T ' || num(l_tmp) || ', ' END
             || CASE WHEN l_pul IS NOT NULL THEN 'HR ' || l_pul || ', ' END || CASE WHEN l_rr IS NOT NULL THEN 'RR ' || l_rr || ', ' END
             || CASE WHEN l_spo IS NOT NULL THEN 'SpO2 ' || l_spo || '%, ' END || CASE WHEN l_wt IS NOT NULL THEN 'Wt ' || num(l_wt) || ' kg, ' END
             || CASE WHEN l_ht IS NOT NULL THEN 'Ht ' || num(l_ht) || ' cm, ' END || CASE WHEN l_pain IS NOT NULL THEN 'Pain ' || l_pain || '/10, ' END
             || CASE WHEN l_glu IS NOT NULL THEN 'RBS ' || num(l_glu) || ' mg/dL, ' END, ', ');
    UPDATE his_visit SET vitals = SUBSTR(l_sum, 1, 1000) WHERE id = l_vis;
    -- القراءة تحقق مهمة متابعة العلامات الحيوية (والسكر إن قيس)
    NOONA_HIS_NURSE_PKG.touch_task(l_vis, 'VITALS');
    IF l_glu IS NOT NULL THEN
      NOONA_HIS_NURSE_PKG.touch_task(l_vis, 'BLOOD_SUGAR');
    END IF;
    RETURN l_id;
  END record_vitals;

  FUNCTION vitals_html(p_visit_id IN NUMBER) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('HIS_VISIT.VIEW');
    l_h := '<table class="nn-rst-cred nn-his-lab" dir="ltr"><thead><tr><th>Time</th><th>BP</th><th>HR</th><th>Temp</th><th>RR</th><th>SpO2</th><th>Wt</th>'
        || '<th>Pain</th><th>RBS</th><th>Notes</th><th>By</th></tr></thead><tbody>';
    FOR r IN (SELECT * FROM his_vital_sign WHERE visit_id = p_visit_id AND company_id = company ORDER BY taken_at DESC) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr><td>' || TO_CHAR(r.taken_at, 'MM-DD HH24:MI') || '</td><td' || CASE WHEN r.bp_sys >= 160 OR r.bp_sys < 90 THEN ' class="nn-neg"' END || '>'
          || CASE WHEN r.bp_sys IS NOT NULL THEN r.bp_sys || '/' || r.bp_dia END || '</td><td' || CASE WHEN r.pulse > 120 OR r.pulse < 50 THEN ' class="nn-neg"' END
          || '>' || r.pulse || '</td><td' || CASE WHEN r.temperature >= 38 OR r.temperature < 35 THEN ' class="nn-neg"' END || '>' || num(r.temperature)
          || '</td><td>' || r.resp_rate || '</td><td' || CASE WHEN r.spo2 < 92 THEN ' class="nn-neg"' END || '>' || NVL2(r.spo2, r.spo2 || '%', '')
          || '</td><td>' || num(r.weight) || '</td><td>' || r.pain_score || '</td><td>' || num(r.glucose) || '</td><td>' || esc(r.notes) || '</td><td>'
          || esc(r.created_by) || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN
      l_h := l_h || ('<tr><td colspan="11">No readings yet.</td></tr>');
    END IF;
    RETURN l_h || ('</tbody></table>');
  END vitals_html;

  FUNCTION add_note(p_visit_id IN NUMBER, p_type IN VARCHAR2, p_text IN VARCHAR2, p_author IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_v his_visit%ROWTYPE := get_visit(p_visit_id);
    l   NUMBER;
  BEGIN
    guard('HIS_VISIT.UPDATE');
    NOONA_CORE_PKG.assert(l_v.status_code <> 'CANCELLED', 'NOONA-HIS-051', 'الزيارة ملغاة', 'Visit is cancelled');
    NOONA_CORE_PKG.assert(TRIM(p_text) IS NOT NULL, 'NOONA-HIS-224', 'اكتب الملاحظة', 'Note text is required');
    NOONA_CORE_PKG.assert(p_type IN ('NURSING', 'PROGRESS', 'CONSULTATION', 'PROCEDURE', 'DISCHARGE'), 'NOONA-HIS-225', 'نوع الملاحظة غير صحيح',
                          'Invalid note type');
    INSERT INTO his_clinical_note (company_id, visit_id, note_type, note_at, author_id, note_text)
    VALUES (company, p_visit_id, p_type, SYSTIMESTAMP, p_author, TRIM(p_text))
    RETURNING id INTO l;
    RETURN l;
  END add_note;

  FUNCTION notes_html(p_visit_id IN NUMBER) RETURN CLOB IS
    l_h CLOB;
  BEGIN
    guard('HIS_VISIT.VIEW');
    l_h := '<div class="nn-his-notes-list" dir="ltr">';
    FOR r IN (SELECT n.*, d.name_ar author FROM his_clinical_note n LEFT JOIN his_doctor d ON d.id = n.author_id
               WHERE n.visit_id = p_visit_id AND n.company_id = company ORDER BY n.note_at DESC) LOOP
      l_h := l_h || ('<article><header><b>' || INITCAP(r.note_type) || '</b> <small>' || TO_CHAR(r.note_at, 'YYYY-MM-DD HH24:MI') || ' · '
          || esc(NVL(r.author, r.created_by)) || '</small></header><p>' || REPLACE(esc(r.note_text), CHR(10), '<br>') || '</p></article>');
    END LOOP;
    RETURN l_h || ('</div>');
  END notes_html;

  -- ================================================================ إعطاء الأدوية
  FUNCTION give_medication(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_line NUMBER := l_o.get_number('line');
    l_out  VARCHAR2(30) := NVL(l_o.get_string('outcome'), 'GIVEN');
    l_dose VARCHAR2(100) := l_o.get_string('dose');
    l_rt   VARCHAR2(30) := NVL(l_o.get_string('route'), 'ORAL');
    l_nur  NUMBER := l_o.get_number('nurse');
    l_nt   VARCHAR2(500) := l_o.get_string('notes');
    l_vis  NUMBER;
    l_rxs  VARCHAR2(30);
    l_v    his_visit%ROWTYPE;
    l_ldose VARCHAR2(100);
    l      NUMBER;
  BEGIN
    guard('HIS_ORDER.UPDATE');
    SELECT x.visit_id, x.status_code, l.dose INTO l_vis, l_rxs, l_ldose FROM his_prescription_line l JOIN his_prescription x ON x.id = l.prescription_id
     WHERE l.id = l_line AND l.company_id = company;
    l_v := get_visit(l_vis);
    NOONA_CORE_PKG.assert(l_v.status_code = 'OPEN' AND l_v.visit_type IN ('INPATIENT', 'EMERGENCY', 'DAY_CASE'), 'NOONA-HIS-226',
                          'سجل إعطاء الأدوية للمنومين والطوارئ في زيارة مفتوحة', 'MAR applies to open inpatient or emergency visits');
    NOONA_CORE_PKG.assert(l_rxs NOT IN ('CANCELLED', 'EXPIRED'), 'NOONA-HIS-227', 'الوصفة ملغاة أو منتهية', 'Prescription is cancelled or expired');
    NOONA_CORE_PKG.assert(l_out = 'GIVEN' OR TRIM(l_nt) IS NOT NULL, 'NOONA-HIS-228', 'اذكر سبب عدم الإعطاء', 'Reason is required when not given');
    INSERT INTO his_med_admin (company_id, visit_id, line_id, given_at, dose, route, outcome, nurse_id, notes)
    VALUES (company, l_vis, l_line, SYSTIMESTAMP, NVL(l_dose, l_ldose), l_rt, l_out, l_nur, l_nt)
    RETURNING id INTO l;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-229', 'الدواء الموصوف غير موجود', 'Prescribed medicine not found');
  END give_medication;

  FUNCTION mar_html(p_visit_id IN NUMBER) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('HIS_VISIT.VIEW');
    l_h := '<table class="nn-rst-cred nn-his-lab" dir="ltr"><thead><tr><th>Medicine</th><th>Order</th><th>Given (24h)</th><th>Last</th><th>Last outcome</th>'
        || '</tr></thead><tbody>';
    FOR r IN (SELECT l.id, NVL(i.name_en, i.name_ar) med, l.dose, l.frequency, l.duration_days, x.rx_no, x.status_code rxs,
                     (SELECT COUNT(*) FROM his_med_admin a WHERE a.line_id = l.id AND a.outcome = 'GIVEN' AND a.given_at >= SYSTIMESTAMP - INTERVAL '1' DAY) g24,
                     (SELECT MAX(a.given_at) FROM his_med_admin a WHERE a.line_id = l.id) last_at,
                     (SELECT MAX(a.outcome || ' ' || a.route) KEEP (DENSE_RANK LAST ORDER BY a.given_at) FROM his_med_admin a WHERE a.line_id = l.id) last_out
                FROM his_prescription x JOIN his_prescription_line l ON l.prescription_id = x.id JOIN inv_item i ON i.id = l.item_id
               WHERE x.visit_id = p_visit_id AND x.company_id = company AND x.status_code NOT IN ('CANCELLED')
               ORDER BY x.rx_at, l.line_no) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr><td><b>' || esc(r.med) || '</b> <small>' || esc(r.rx_no) || '</small></td><td>' || esc(r.dose || ' ' || r.frequency)
          || NVL2(r.duration_days, ' x ' || r.duration_days || 'd', '') || '</td><td>' || r.g24 || '</td><td>' || TO_CHAR(r.last_at, 'MM-DD HH24:MI')
          || '</td><td>' || esc(r.last_out) || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN
      l_h := l_h || ('<tr><td colspan="5">No medicines prescribed.</td></tr>');
    END IF;
    RETURN l_h || ('</tbody></table>');
  END mar_html;

  -- ================================================================ التقارير الطبية
  FUNCTION cert_type_label(p_type IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_type WHEN 'SICK_LEAVE' THEN 'Sick Leave' WHEN 'MEDICAL_REPORT' THEN 'Medical Report' WHEN 'REFERRAL' THEN 'Referral Letter'
                       WHEN 'FITNESS' THEN 'Fitness Certificate' WHEN 'COMPANION' THEN 'Companion Certificate' ELSE p_type END;
  END cert_type_label;

  FUNCTION issue_certificate(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_vis  NUMBER := l_o.get_number('visit');
    l_type VARCHAR2(30) := l_o.get_string('type');
    l_from DATE := d(l_o.get_string('from'));
    l_to   DATE := d(l_o.get_string('to'));
    l_ref  VARCHAR2(200) := TRIM(l_o.get_string('referral_to'));
    l_body VARCHAR2(4000) := TRIM(l_o.get_string('body'));
    l_doc  NUMBER := l_o.get_number('doctor');
    l_v    his_visit%ROWTYPE := get_visit(l_vis);
    l_p    his_patient%ROWTYPE;
    l_days NUMBER;
    l_no   VARCHAR2(50);
    l      NUMBER;
  BEGIN
    guard('HIS_VISIT.UPDATE');
    NOONA_CORE_PKG.assert(l_v.status_code <> 'CANCELLED', 'NOONA-HIS-051', 'الزيارة ملغاة', 'Visit is cancelled');
    NOONA_CORE_PKG.assert(l_type IN ('SICK_LEAVE', 'MEDICAL_REPORT', 'REFERRAL', 'FITNESS', 'COMPANION'), 'NOONA-HIS-230', 'نوع التقرير غير صحيح',
                          'Invalid certificate type');
    l_doc := NVL(l_doc, l_v.doctor_id);
    NOONA_CORE_PKG.assert(l_doc IS NOT NULL, 'NOONA-HIS-231', 'حدد الطبيب المصدر', 'Issuing doctor is required');
    IF l_type IN ('SICK_LEAVE', 'COMPANION') THEN
      NOONA_CORE_PKG.assert(l_from IS NOT NULL AND l_to IS NOT NULL AND l_to >= l_from, 'NOONA-HIS-232', 'حدد فترة الإجازة', 'Leave period is required');
      NOONA_CORE_PKG.assert(l_from >= TRUNC(CAST(l_v.visit_at AS DATE)) - 1, 'NOONA-HIS-233', 'لا تبدأ الإجازة قبل تاريخ الزيارة',
                            'Leave cannot start before the visit');
      l_days := l_to - l_from + 1;
    ELSIF l_type = 'REFERRAL' THEN
      NOONA_CORE_PKG.assert(l_ref IS NOT NULL, 'NOONA-HIS-234', 'حدد جهة التحويل', 'Referral destination is required');
    END IF;
    SELECT * INTO l_p FROM his_patient WHERE id = l_v.patient_id;
    IF l_body IS NULL THEN
      l_body := CASE l_type
        WHEN 'SICK_LEAVE' THEN 'This is to certify that the above-named patient was examined on ' || TO_CHAR(CAST(l_v.visit_at AS DATE), 'DD Mon YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
             || NVL2(l_v.diagnosis, ' and diagnosed with ' || l_v.diagnosis || NVL2(l_v.icd10, ' (' || l_v.icd10 || ')', ''), '')
             || '. The patient is advised sick leave for ' || l_days || ' day(s) from ' || TO_CHAR(l_from, 'DD Mon YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') || ' to ' || TO_CHAR(l_to, 'DD Mon YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') || '.'
        WHEN 'COMPANION' THEN 'This is to certify that the bearer accompanied the above-named patient for ' || l_days || ' day(s) from '
             || TO_CHAR(l_from, 'DD Mon YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') || ' to ' || TO_CHAR(l_to, 'DD Mon YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') || '.'
        WHEN 'REFERRAL' THEN 'Kindly see the above-named patient for further evaluation and management.'
             || NVL2(l_v.diagnosis, ' Provisional diagnosis: ' || l_v.diagnosis || NVL2(l_v.icd10, ' (' || l_v.icd10 || ')', '') || '.', '')
             || NVL2(l_v.chief_complaint, ' Presenting complaint: ' || l_v.chief_complaint || '.', '')
        WHEN 'FITNESS' THEN 'This is to certify that the above-named patient was examined and found medically fit.'
        ELSE NVL2(l_v.chief_complaint, 'Presenting complaint: ' || l_v.chief_complaint || '. ', '') || NVL2(l_v.vitals, 'Vital signs: ' || l_v.vitals || '. ', '')
             || NVL2(l_v.diagnosis, 'Diagnosis: ' || l_v.diagnosis || NVL2(l_v.icd10, ' (' || l_v.icd10 || ')', '') || '. ', '')
             || NVL2(l_v.doctor_notes, 'Plan: ' || l_v.doctor_notes, '') END;
    END IF;
    l_no := next_no('HIS_CERTIFICATE', 'MC-');
    INSERT INTO his_certificate (company_id, cert_no, visit_id, cert_type, issued_on, from_date, to_date, days, referral_to, body, doctor_id, verify_code, status_code)
    VALUES (company, l_no, l_vis, l_type, TRUNC(SYSDATE), l_from, l_to, l_days, l_ref, SUBSTR(l_body, 1, 4000), l_doc, DBMS_RANDOM.STRING('X', 10), 'ISSUED')
    RETURNING id INTO l;
    RETURN l;
  END issue_certificate;

  PROCEDURE cancel_certificate(p_id IN NUMBER, p_reason IN VARCHAR2) IS
  BEGIN
    guard('HIS_VISIT.UPDATE');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-HIS-074', 'اذكر سبب الإلغاء', 'Reason is required');
    UPDATE his_certificate SET status_code = 'CANCELLED', body = SUBSTR(body || CHR(10) || '[Cancelled: ' || p_reason || ']', 1, 4000)
     WHERE id = p_id AND company_id = company AND status_code = 'ISSUED';
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-HIS-235', 'التقرير غير موجود أو ملغى', 'Certificate not found or cancelled');
  END cancel_certificate;

  FUNCTION certificate_html(p_id IN NUMBER) RETURN CLOB IS
    l_h CLOB;
  BEGIN
    guard('HIS_VISIT.VIEW');
    FOR c IN (SELECT c.*, v.visit_no, v.visit_type, p.name_ar, p.name_en pname_en, p.mrn, p.gender, p.birth_date, p.id_no, p.nationality,
                     d.name_ar dname, d.name_en dname_en, d.license_no, d.specialty, NVL(co.trade_name_ar, co.legal_name_ar) co_ar, NVL(co.trade_name_en, co.legal_name_en) co_en, dp.name_ar dept
                FROM his_certificate c JOIN his_visit v ON v.id = c.visit_id JOIN his_patient p ON p.id = v.patient_id
                LEFT JOIN his_doctor d ON d.id = c.doctor_id JOIN org_company co ON co.id = c.company_id JOIN his_department dp ON dp.id = v.department_id
               WHERE c.id = p_id AND c.company_id = company) LOOP
      l_h := '<div class="nn-his-cert" dir="ltr" lang="en">' || CASE WHEN c.status_code = 'CANCELLED' THEN '<div class="nn-his-void">CANCELLED</div>' END
          || '<header><div><b>' || esc(NVL(c.co_en, c.co_ar)) || '</b><br><small>' || esc(c.co_ar) || '</small></div><div class="r"><b>'
          || esc(cert_type_label(c.cert_type)) || '</b><br><small>No. ' || esc(c.cert_no) || ' · ' || TO_CHAR(c.issued_on, 'DD Mon YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') || '</small></div></header>'
          || '<table class="nn-his-certp"><tr><th>Patient</th><td>' || esc(NVL(c.pname_en, c.name_ar)) || CASE WHEN c.pname_en IS NOT NULL THEN ' / ' || esc(c.name_ar) END
          || '</td><th>MRN</th><td>' || esc(c.mrn) || '</td></tr><tr><th>ID No.</th><td>' || esc(c.id_no) || '</td><th>Sex / Age</th><td>'
          || CASE c.gender WHEN 'M' THEN 'Male' ELSE 'Female' END || ' / ' || age_of(c.birth_date) || '</td></tr><tr><th>Nationality</th><td>' || esc(c.nationality)
          || '</td><th>Visit</th><td>' || esc(c.visit_no) || ' · ' || esc(c.dept) || '</td></tr>'
          || CASE WHEN c.from_date IS NOT NULL THEN '<tr><th>Period</th><td colspan="3">' || TO_CHAR(c.from_date, 'DD Mon YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') || ' - ' || TO_CHAR(c.to_date, 'DD Mon YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
                  || ' (' || c.days || ' day' || CASE WHEN c.days > 1 THEN 's' END || ')</td></tr>' END
          || CASE WHEN c.referral_to IS NOT NULL THEN '<tr><th>Referred to</th><td colspan="3">' || esc(c.referral_to) || '</td></tr>' END
          || '</table><div class="nn-his-certb">' || REPLACE(esc(c.body), CHR(10), '<br>') || '</div>'
          || '<footer><div><b>' || esc(NVL(c.dname_en, c.dname)) || '</b><br><small>' || esc(c.specialty) || NVL2(c.license_no, ' · License ' || esc(c.license_no), '')
          || '</small></div><div class="r"><small>Verification code</small><br><b>' || esc(c.verify_code) || '</b></div></footer></div>';
    END LOOP;
    RETURN l_h;
  END certificate_html;

  -- ================================================================ الملف الطبي
  FUNCTION patient_history_html(p_patient_id IN NUMBER) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('HIS_VISIT.VIEW');
    FOR p IN (SELECT * FROM his_patient WHERE id = p_patient_id AND company_id = company) LOOP
      l_h := '<div class="nn-his-emr" dir="ltr"><div class="nn-his-card"><div class="nn-his-head"><div><b>' || esc(NVL(p.name_en, p.name_ar))
          || CASE WHEN p.name_en IS NOT NULL THEN ' / ' || esc(p.name_ar) END || '</b><br><small>' || esc(p.mrn) || ' · '
          || CASE p.gender WHEN 'M' THEN 'Male' ELSE 'Female' END || ' · ' || age_of(p.birth_date) || NVL2(p.blood_group, ' · Blood ' || esc(p.blood_group), '')
          || '</small></div></div>'
          || NVL2(p.allergies, '<div><span class="nn-rst-chip is-cancelled">Allergies: ' || esc(p.allergies) || '</span></div>', '')
          || NVL2(p.chronic_diseases, '<div><small>Chronic conditions: ' || esc(p.chronic_diseases) || '</small></div>', '') || '</div>';
    END LOOP;
    IF l_h IS NULL THEN RETURN NULL; END IF;
    FOR v IN (SELECT v.*, d.name_ar dept, dr.name_ar doctor FROM his_visit v JOIN his_department d ON d.id = v.department_id
                LEFT JOIN his_doctor dr ON dr.id = v.doctor_id
               WHERE v.patient_id = p_patient_id AND v.company_id = company AND v.status_code <> 'CANCELLED' ORDER BY v.visit_at DESC) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<section class="nn-his-emrv"><header><b>' || TO_CHAR(v.visit_at, 'YYYY-MM-DD') || '</b> · ' || INITCAP(REPLACE(v.visit_type, '_', ' '))
          || ' · ' || esc(v.dept) || NVL2(v.doctor, ' · ' || esc(v.doctor), '') || ' <small>' || esc(v.visit_no) || '</small>'
          || CASE WHEN v.visit_type IN ('INPATIENT', 'EMERGENCY', 'DAY_CASE') THEN ' <a href="f?p=' || SYS_CONTEXT('APEX$SESSION', 'APP_ID') || ':76:'
                  || SYS_CONTEXT('APEX$SESSION', 'APP_SESSION') || '::NO:RP,76:P76_VISIT:' || v.id || '">Inpatient chart</a>' END || '</header>'
          || NVL2(v.chief_complaint, '<div><small>Complaint</small> ' || esc(v.chief_complaint) || '</div>', '')
          || NVL2(v.vitals, '<div><small>Vitals</small> ' || esc(v.vitals) || '</div>', '')
          || NVL2(v.diagnosis, '<div><small>Diagnosis</small> <b>' || esc(v.diagnosis) || '</b>' || NVL2(v.icd10, ' (' || esc(v.icd10) || ')', '') || '</div>', '')
          || NVL2(v.doctor_notes, '<div><small>Plan</small> ' || esc(v.doctor_notes) || '</div>', ''));
      FOR o IN (SELECT o.id, NOONA_HIS_PKG.service_name(o.service_id) sname, o.result_flag, DBMS_LOB.SUBSTR(o.result_text, 300, 1) res
                  FROM his_order o JOIN his_service s ON s.id = o.service_id
                 WHERE o.visit_id = v.id AND o.status_code = 'COMPLETED' AND s.service_type IN ('LAB', 'RADIOLOGY', 'CARDIO_DIAG', 'PROCEDURE', 'MINOR_SURGERY', 'MAJOR_SURGERY')
                 ORDER BY o.line_no) LOOP
        l_h := l_h || ('<div class="nn-his-emro"><a href="f?p=' || SYS_CONTEXT('APEX$SESSION', 'APP_ID') || ':52:' || SYS_CONTEXT('APEX$SESSION', 'APP_SESSION') || '::NO:RP,52:P52_ID:' || o.id || '">'
            || esc(o.sname) || '</a>' || CASE WHEN o.result_flag IN ('ABNORMAL', 'CRITICAL') THEN ' <span class="nn-rst-chip is-cancelled">' || INITCAP(o.result_flag)
            || '</span>' END || ' <small>' || esc(o.res) || '</small></div>');
      END LOOP;
      FOR m IN (SELECT NVL(i.name_en, i.name_ar) med, l.dose, l.frequency, l.duration_days FROM his_prescription x
                  JOIN his_prescription_line l ON l.prescription_id = x.id JOIN inv_item i ON i.id = l.item_id
                 WHERE x.visit_id = v.id AND x.status_code <> 'CANCELLED' ORDER BY x.id, l.line_no) LOOP
        l_h := l_h || ('<div class="nn-his-emro"><small>Rx</small> ' || esc(m.med) || ' <small>' || esc(m.dose || ' ' || m.frequency)
            || NVL2(m.duration_days, ' x ' || m.duration_days || 'd', '') || '</small></div>');
      END LOOP;
      FOR c IN (SELECT cert_no, cert_type, days FROM his_certificate WHERE visit_id = v.id AND status_code = 'ISSUED') LOOP
        l_h := l_h || ('<div class="nn-his-emro"><small>' || esc(cert_type_label(c.cert_type)) || '</small> ' || esc(c.cert_no)
            || NVL2(c.days, ' (' || c.days || 'd)', '') || '</div>');
      END LOOP;
      l_h := l_h || ('</section>');
    END LOOP;
    IF l_n = 0 THEN
      l_h := l_h || ('<p class="nn-hint">No visits yet.</p>');
    END IF;
    RETURN l_h || ('</div>');
  END patient_history_html;

  -- ================================================================ عمولات الأطباء
  FUNCTION commission_preview_html(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_h CLOB;
    l_t NUMBER := 0;
  BEGIN
    guard('HIS_INVOICE.VIEW');
    l_h := '<table class="nn-rst-cred"><thead><tr><th>الطبيب</th><th class="n">الخدمات</th><th class="n">الإيراد غير المسوى</th><th class="n">النسبة</th>'
        || '<th class="n">العمولة المستحقة</th></tr></thead><tbody>';
    FOR r IN (SELECT dr.name_ar, dr.commission_pct, COUNT(*) n, SUM(o.patient_net + o.payer_net) base
                FROM his_order o JOIN his_invoice i ON i.id = o.invoice_id JOIN his_doctor dr ON dr.id = o.ordered_by_id
               WHERE o.company_id = company AND i.status_code = 'POSTED' AND i.doc_date BETWEEN p_from AND p_to AND o.status_code <> 'CANCELLED'
                 AND o.commission_id IS NULL AND NVL(dr.commission_pct, 0) > 0
               GROUP BY dr.name_ar, dr.commission_pct ORDER BY 4 DESC) LOOP
      l_h := l_h || ('<tr><td>' || esc(r.name_ar) || '</td><td class="n">' || r.n || '</td><td class="n">' || fmt0(r.base) || '</td><td class="n">'
          || num(r.commission_pct) || '%</td><td class="n">' || fmt0(ROUND(r.base * r.commission_pct / 100, 2)) || '</td></tr>');
      l_t := l_t + ROUND(r.base * r.commission_pct / 100, 2);
    END LOOP;
    RETURN l_h || ('</tbody><tfoot><tr><td colspan="4">الإجمالي</td><td class="n">' || fmt0(l_t) || '</td></tr></tfoot></table>');
  END commission_preview_html;

  FUNCTION ensure_account(p_code VARCHAR2, p_name VARCHAR2, p_parent VARCHAR2, p_type VARCHAR2) RETURN NUMBER IS
    l NUMBER := NOONA_HIS_PKG.acc(p_code);
  BEGIN
    IF l IS NULL THEN
      l := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, p_code, p_name, p_parent, p_type, 'Y', NULL);
    END IF;
    RETURN l;
  END ensure_account;

  FUNCTION settle_commissions(p_from IN DATE, p_to IN DATE, p_doctor_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_n     PLS_INTEGER := 0;
    l_exp   NUMBER;
    l_pay   NUMBER;
    l_id    NUMBER;
    l_no    VARCHAR2(50);
    l_amt   NUMBER;
    l_j     NUMBER;
    l_ev    NUMBER;
    l_lines NOONA_GL_PKG.t_lines;
  BEGIN
    guard('HIS_INVOICE.CREATE');
    NOONA_CORE_PKG.assert(p_from IS NOT NULL AND p_to IS NOT NULL AND p_from <= p_to AND p_to <= TRUNC(SYSDATE), 'NOONA-HIS-240', 'حدد فترة منتهية',
                          'A closed period is required');
    l_exp := ensure_account('5220', 'عمولات الأطباء', '52', 'EXPENSE');
    l_pay := ensure_account('2111', 'عمولات الأطباء المستحقة', '21', 'LIABILITY');
    FOR dr IN (SELECT d.id, d.name_ar, d.commission_pct, SUM(o.patient_net + o.payer_net) base
                 FROM his_order o JOIN his_invoice i ON i.id = o.invoice_id JOIN his_doctor d ON d.id = o.ordered_by_id
                WHERE o.company_id = company AND i.status_code = 'POSTED' AND i.doc_date BETWEEN p_from AND p_to AND o.status_code <> 'CANCELLED'
                  AND o.commission_id IS NULL AND NVL(d.commission_pct, 0) > 0 AND (p_doctor_id IS NULL OR d.id = p_doctor_id)
                GROUP BY d.id, d.name_ar, d.commission_pct ORDER BY d.name_ar) LOOP
      l_amt := ROUND(dr.base * dr.commission_pct / 100, 2);
      CONTINUE WHEN l_amt <= 0;
      l_no := next_no(c_com, 'DC-');
      INSERT INTO his_commission (company_id, doc_no, doc_date, doctor_id, period_from, period_to, base_amount, commission_pct, amount, status_code)
      VALUES (company, l_no, TRUNC(SYSDATE), dr.id, p_from, p_to, dr.base, dr.commission_pct, l_amt, 'POSTED')
      RETURNING id INTO l_id;
      UPDATE his_order o SET commission_id = l_id
       WHERE o.company_id = company AND o.ordered_by_id = dr.id AND o.commission_id IS NULL AND o.status_code <> 'CANCELLED'
         AND o.invoice_id IN (SELECT i.id FROM his_invoice i WHERE i.status_code = 'POSTED' AND i.doc_date BETWEEN p_from AND p_to);
      l_lines := NOONA_GL_PKG.t_lines();
      l_lines.EXTEND;
      l_lines(1).account_id := l_exp; l_lines(1).debit := l_amt; l_lines(1).description := 'عمولة ' || dr.name_ar || ' ' || TO_CHAR(p_from, 'YYYY-MM-DD') || ' - ' || TO_CHAR(p_to, 'YYYY-MM-DD');
      l_lines.EXTEND;
      l_lines(2).account_id := l_pay; l_lines(2).credit := l_amt; l_lines(2).description := 'عمولة مستحقة ' || dr.name_ar;
      l_j := NOONA_ACE_PKG.post_source('HIS_COMMISSION_ACCRUED', 'MEDICAL', c_com, l_id, TRUNC(SYSDATE), 'عمولة ' || dr.name_ar || ' - ' || l_no,
                                       NOONA_GL_PKG.ledger_currency, 1, l_lines, l_no, NULL, 'MEDICAL');
      SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
      UPDATE his_commission SET accounting_event_id = l_ev, posted_at = SYSTIMESTAMP, posted_by = NOONA_CTX_PKG.current_user_name WHERE id = l_id;
      l_n := l_n + 1;
    END LOOP;
    NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-HIS-241', 'لا توجد عمولات غير مسواة في الفترة', 'No unsettled commissions in the period');
    RETURN l_n;
  END settle_commissions;

  PROCEDURE cancel_commission(p_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_st VARCHAR2(30);
    l_j  NUMBER;
  BEGIN
    guard('HIS_INVOICE.UPDATE');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-HIS-074', 'اذكر سبب الإلغاء', 'Reason is required');
    SELECT status_code INTO l_st FROM his_commission WHERE id = p_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_st = 'POSTED', 'NOONA-HIS-242', 'التسوية ملغاة سابقاً', 'Settlement already cancelled');
    l_j := NOONA_ACE_PKG.reverse_source(c_com, p_id, TRUNC(SYSDATE), p_reason);
    UPDATE his_order SET commission_id = NULL WHERE commission_id = p_id;
    UPDATE his_commission SET status_code = 'CANCELLED' WHERE id = p_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-243', 'التسوية غير موجودة', 'Settlement not found');
  END cancel_commission;
END NOONA_HIS_CLIN_PKG;
/
