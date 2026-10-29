-- =============================================================================
-- NOONA PLUS ERP | متابعة المنومين والتمريض: NOONA_HIS_NURSE_PKG
--   ورديات التمريض وجدول المناوبات (الجناح والغرف المسندة ومسؤول الوردية) والممرض المناوب الآن،
--   جدول جرعات المنومين من تكرار الوصفة (OD، BID، TID، QID، Q4H..Q12H، HS، STAT، أو أوقات محددة) وتسجيل كل جرعة،
--   مهام المتابعة التمريضية المتكررة (العلامات الحيوية، السكر، التقليب، الجروح، المدخلات والمخرجات، مرور الطبيب)،
--   لوحة محطة التمريض وتنبيهاتها، والملف الإلكتروني للمريض المنوم.
--   التنبيهات: مهمة مجدولة كل 5 دقائق ترسل إشعاراً للممرضين المناوبين عند حلول موعد الجرعة أو المهمة وعند تأخرها،
--   وتعد الجرعة فائتة بعد 6 ساعات من موعدها دون تسجيل.
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_HIS_NURSE_PKG AUTHID DEFINER AS

  FUNCTION company RETURN NUMBER;
  -- كسر اليوم لوقت HH24:MI (للحساب في SQL)
  FUNCTION day_fraction(p_hhmi IN VARCHAR2) RETURN NUMBER;

  -- ---------------------------------------------------------- الورديات والمناوبات
  -- ورديات افتراضية: صباحية 07-15، مسائية 15-23، ليلية 23-07 (لا تكرر)
  FUNCTION seed_shifts RETURN NUMBER;
  FUNCTION save_shift(p_id IN NUMBER, p_code IN VARCHAR2, p_name IN VARCHAR2, p_from IN VARCHAR2, p_to IN VARCHAR2) RETURN NUMBER;
  -- {"date","shift","ward","nurse","role":"CHARGE|STAFF|ASSISTANT","rooms":"101,102","notes"}
  FUNCTION assign_duty(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE remove_duty(p_id IN NUMBER);
  -- ينسخ مناوبات يوم إلى يوم آخر (لجناح أو للكل)؛ يعيد عدد المناوبات المنسوخة
  FUNCTION copy_roster(p_from IN DATE, p_to IN DATE, p_ward_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
  -- الوردية الحالية وتاريخها
  FUNCTION current_shift(p_at IN DATE DEFAULT NULL) RETURN NUMBER;
  -- أسماء الممرضين المناوبين للجناح (والغرفة إن حددت) الآن
  FUNCTION nurses_on_duty(p_ward_id IN NUMBER, p_room IN VARCHAR2 DEFAULT NULL, p_at IN DATE DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION on_duty_html(p_ward_id IN NUMBER DEFAULT NULL) RETURN CLOB;

  -- ---------------------------------------------------------- جدول الجرعات
  -- أوقات الجرعات من التكرار: '09:00,21:00'، أو 'STAT' لجرعة فورية، أو NULL عند الحاجة (PRN)
  FUNCTION times_for(p_frequency IN VARCHAR2, p_custom IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION schedule_rx(p_rx_id IN NUMBER) RETURN NUMBER;
  -- يمد جداول المنومين 48 ساعة قادمة (للمهمة المجدولة وعند فتح المحطة)
  FUNCTION extend_schedules RETURN NUMBER;
  -- GIVEN | HELD | REFUSED | MISSED
  FUNCTION record_dose(p_schedule_id IN NUMBER, p_outcome IN VARCHAR2, p_nurse IN NUMBER DEFAULT NULL, p_notes IN VARCHAR2 DEFAULT NULL,
                       p_dose IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  PROCEDURE cancel_rx_doses(p_rx_id IN NUMBER);

  -- ---------------------------------------------------------- مهام المتابعة
  PROCEDURE default_tasks(p_visit_id IN NUMBER);
  -- {"visit","type","desc","every","start":"YYYY-MM-DD HH24:MI","end"}
  FUNCTION add_task(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE stop_task(p_task_id IN NUMBER);
  FUNCTION complete_task(p_task_id IN NUMBER, p_value IN VARCHAR2 DEFAULT NULL, p_notes IN VARCHAR2 DEFAULT NULL, p_nurse IN NUMBER DEFAULT NULL)
    RETURN NUMBER;
  -- تسجيل نوع متابعة من شاشة أخرى (مثل قراءة العلامات الحيوية) يحقق مهمته
  PROCEDURE touch_task(p_visit_id IN NUMBER, p_type IN VARCHAR2);
  -- عند الخروج: تلغى الجرعات القادمة وتوقف المهام
  PROCEDURE close_visit_care(p_visit_id IN NUMBER);

  -- ---------------------------------------------------------- المحطة والملف والتنبيهات
  FUNCTION station_html(p_ward_id IN NUMBER) RETURN CLOB;
  FUNCTION due_html(p_ward_id IN NUMBER, p_hours IN NUMBER DEFAULT 2) RETURN CLOB;
  -- {"overdue":n,"due":n,"items":[{"k","at","bed","patient","what","late"}]}
  FUNCTION alerts_json(p_ward_id IN NUMBER) RETURN CLOB;
  FUNCTION inpatient_chart_html(p_visit_id IN NUMBER) RETURN CLOB;
  -- المهمة المجدولة: تمد الجداول وترسل التنبيهات لكل المؤسسات؛ يعيد عدد الإشعارات
  FUNCTION run_alerts RETURN NUMBER;
  FUNCTION task_label(p_type IN VARCHAR2) RETURN VARCHAR2;
END NOONA_HIS_NURSE_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_HIS_NURSE_PKG AS

  c_inpatient CONSTANT VARCHAR2(100) := ',INPATIENT,EMERGENCY,DAY_CASE,';

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;
  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END;
  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;
  FUNCTION day_fraction(p_hhmi IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN (TO_NUMBER(SUBSTR(p_hhmi, 1, 2)) * 60 + TO_NUMBER(SUBSTR(p_hhmi, 4, 2))) / 1440;
  END day_fraction;
  FUNCTION valid_time(p VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN REGEXP_LIKE(p, '^([01][0-9]|2[0-3]):[0-5][0-9]$');
  END valid_time;

  FUNCTION task_label(p_type IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_type WHEN 'VITALS' THEN 'Vital signs' WHEN 'BLOOD_SUGAR' THEN 'Blood sugar' WHEN 'TURNING' THEN 'Position change'
      WHEN 'WOUND_CARE' THEN 'Wound care' WHEN 'INTAKE_OUTPUT' THEN 'Intake / output' WHEN 'DOCTOR_ROUND' THEN 'Doctor round'
      WHEN 'OBSERVATION' THEN 'Observation' ELSE 'Task' END;
  END task_label;

  -- ================================================================ الورديات
  FUNCTION save_shift(p_id IN NUMBER, p_code IN VARCHAR2, p_name IN VARCHAR2, p_from IN VARCHAR2, p_to IN VARCHAR2) RETURN NUMBER IS
    l NUMBER := p_id;
    l_code VARCHAR2(50) := UPPER(TRIM(p_code));
  BEGIN
    guard('HIS_DEPARTMENT.UPDATE');
    NOONA_CORE_PKG.assert(l_code IS NOT NULL AND TRIM(p_name) IS NOT NULL AND valid_time(p_from) AND valid_time(p_to) AND p_from <> p_to,
                          'NOONA-HIS-250', 'الرمز والاسم ووقتا البداية والنهاية (HH24:MI) إلزامية', 'Code, name and HH24:MI times are required');
    IF l IS NULL THEN
      SELECT MIN(id) INTO l FROM his_nurse_shift WHERE company_id = company AND code = l_code;
    END IF;
    IF l IS NULL THEN
      INSERT INTO his_nurse_shift (company_id, code, name_ar, start_time, end_time, is_active, sort_order)
      VALUES (company, l_code, TRIM(p_name), p_from, p_to, 'Y', day_fraction(p_from) * 100)
      RETURNING id INTO l;
    ELSE
      UPDATE his_nurse_shift SET code = l_code, name_ar = TRIM(p_name), start_time = p_from, end_time = p_to WHERE id = l AND company_id = company;
    END IF;
    RETURN l;
  END save_shift;

  FUNCTION seed_shifts RETURN NUMBER IS
    l_n NUMBER;
    l   NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_n FROM his_nurse_shift WHERE company_id = company;
    IF l_n > 0 THEN RETURN 0; END IF;
    l := save_shift(NULL, 'M', 'الصباحية', '07:00', '15:00');
    l := save_shift(NULL, 'E', 'المسائية', '15:00', '23:00');
    l := save_shift(NULL, 'N', 'الليلية', '23:00', '07:00');
    RETURN 3;
  END seed_shifts;

  FUNCTION assign_duty(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_date  DATE := TO_DATE(l_o.get_string('date'), 'YYYY-MM-DD');
    l_shift NUMBER := l_o.get_number('shift');
    l_ward  NUMBER := l_o.get_number('ward');
    l_nurse NUMBER := l_o.get_number('nurse');
    l_role  VARCHAR2(30) := NVL(l_o.get_string('role'), 'STAFF');
    l_rooms VARCHAR2(200) := REPLACE(TRIM(l_o.get_string('rooms')), ' ');
    l_nt    VARCHAR2(500) := l_o.get_string('notes');
    l       NUMBER;
    l_n     NUMBER;
  BEGIN
    guard('HIS_DEPARTMENT.UPDATE');
    NOONA_CORE_PKG.assert(l_date IS NOT NULL AND l_shift IS NOT NULL AND l_ward IS NOT NULL AND l_nurse IS NOT NULL, 'NOONA-HIS-251',
                          'التاريخ والوردية والجناح والممرض إلزامية', 'Date, shift, ward and nurse are required');
    NOONA_CORE_PKG.assert(l_role IN ('CHARGE', 'STAFF', 'ASSISTANT'), 'NOONA-HIS-252', 'الدور غير صحيح', 'Invalid role');
    SELECT COUNT(*) INTO l_n FROM his_nurse_shift WHERE id = l_shift AND company_id = company;
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-HIS-253', 'الوردية غير موجودة', 'Shift not found');
    SELECT MIN(id) INTO l FROM his_nurse_roster WHERE company_id = company AND duty_date = l_date AND shift_id = l_shift AND nurse_id = l_nurse;
    IF l IS NULL THEN
      INSERT INTO his_nurse_roster (company_id, duty_date, shift_id, ward_id, nurse_id, duty_role, rooms, notes)
      VALUES (company, l_date, l_shift, l_ward, l_nurse, l_role, l_rooms, l_nt)
      RETURNING id INTO l;
    ELSE
      UPDATE his_nurse_roster SET ward_id = l_ward, duty_role = l_role, rooms = l_rooms, notes = l_nt WHERE id = l;
    END IF;
    RETURN l;
  END assign_duty;

  PROCEDURE remove_duty(p_id IN NUMBER) IS
  BEGIN
    guard('HIS_DEPARTMENT.UPDATE');
    DELETE FROM his_nurse_roster WHERE id = p_id AND company_id = company;
  END remove_duty;

  FUNCTION copy_roster(p_from IN DATE, p_to IN DATE, p_ward_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('HIS_DEPARTMENT.UPDATE');
    NOONA_CORE_PKG.assert(p_from IS NOT NULL AND p_to IS NOT NULL AND p_from <> p_to, 'NOONA-HIS-254', 'حدد يومين مختلفين', 'Two different dates are required');
    FOR r IN (SELECT * FROM his_nurse_roster WHERE company_id = company AND duty_date = TRUNC(p_from) AND (p_ward_id IS NULL OR ward_id = p_ward_id)) LOOP
      MERGE INTO his_nurse_roster x USING (SELECT TRUNC(p_to) d, r.shift_id s, r.nurse_id n FROM dual) y
         ON (x.company_id = company AND x.duty_date = y.d AND x.shift_id = y.s AND x.nurse_id = y.n)
       WHEN NOT MATCHED THEN INSERT (company_id, duty_date, shift_id, ward_id, nurse_id, duty_role, rooms, notes)
            VALUES (company, y.d, y.s, r.ward_id, y.n, r.duty_role, r.rooms, r.notes);
      l_n := l_n + SQL%ROWCOUNT;
    END LOOP;
    RETURN l_n;
  END copy_roster;

  FUNCTION current_shift(p_at IN DATE DEFAULT NULL) RETURN NUMBER IS
    l_at DATE := NVL(p_at, SYSDATE);
    l    NUMBER;
  BEGIN
    SELECT MIN(s.id) KEEP (DENSE_RANK FIRST ORDER BY s.sort_order) INTO l
      FROM his_nurse_shift s, (SELECT TRUNC(l_at) d FROM dual UNION ALL SELECT TRUNC(l_at) - 1 FROM dual) dd
     WHERE s.company_id = company AND s.is_active = 'Y'
       AND l_at >= dd.d + day_fraction(s.start_time)
       AND l_at < dd.d + day_fraction(s.end_time) + CASE WHEN s.end_time <= s.start_time THEN 1 ELSE 0 END;
    RETURN l;
  END current_shift;

  FUNCTION nurses_on_duty(p_ward_id IN NUMBER, p_room IN VARCHAR2 DEFAULT NULL, p_at IN DATE DEFAULT NULL) RETURN VARCHAR2 IS
    l_at DATE := NVL(p_at, SYSDATE);
    l    VARCHAR2(4000);
  BEGIN
    SELECT LISTAGG(d.name_ar || CASE r.duty_role WHEN 'CHARGE' THEN ' (مسؤول)' END, '، ') WITHIN GROUP (ORDER BY DECODE(r.duty_role, 'CHARGE', 0, 1), d.name_ar)
      INTO l
      FROM his_nurse_roster r JOIN his_nurse_shift s ON s.id = r.shift_id JOIN his_doctor d ON d.id = r.nurse_id
     WHERE r.company_id = company AND r.ward_id = p_ward_id
       AND (p_room IS NULL OR r.rooms IS NULL OR INSTR(',' || r.rooms || ',', ',' || p_room || ',') > 0)
       AND l_at >= r.duty_date + day_fraction(s.start_time)
       AND l_at < r.duty_date + day_fraction(s.end_time) + CASE WHEN s.end_time <= s.start_time THEN 1 ELSE 0 END;
    RETURN l;
  END nurses_on_duty;

  FUNCTION on_duty_html(p_ward_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_h CLOB := '<div class="nn-his-duty">';
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('HIS_VISIT.VIEW');
    FOR r IN (SELECT w.name_ar ward, s.name_ar shift, s.start_time, s.end_time, d.name_ar nurse, r.duty_role, r.rooms, d.mobile
                FROM his_nurse_roster r JOIN his_nurse_shift s ON s.id = r.shift_id JOIN his_doctor d ON d.id = r.nurse_id
                JOIN his_department w ON w.id = r.ward_id
               WHERE r.company_id = company AND (p_ward_id IS NULL OR r.ward_id = p_ward_id)
                 AND SYSDATE >= r.duty_date + day_fraction(s.start_time)
                 AND SYSDATE < r.duty_date + day_fraction(s.end_time) + CASE WHEN s.end_time <= s.start_time THEN 1 ELSE 0 END
               ORDER BY w.name_ar, DECODE(r.duty_role, 'CHARGE', 0, 1), d.name_ar) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<span class="nn-his-nurse' || CASE WHEN r.duty_role = 'CHARGE' THEN ' is-charge' END || '"><b>' || esc(r.nurse) || '</b><small>'
          || esc(r.ward) || ' · ' || esc(r.shift) || ' ' || r.start_time || '-' || r.end_time || NVL2(r.rooms, ' · غرف ' || esc(r.rooms), '')
          || CASE WHEN r.duty_role = 'CHARGE' THEN ' · مسؤول الوردية' END || NVL2(r.mobile, ' · ' || esc(r.mobile), '') || '</small></span>');
    END LOOP;
    IF l_n = 0 THEN
      l_h := l_h || ('<p class="nn-hint">لا يوجد ممرض مناوب مسجل لهذه الوردية؛ أضفه من «ورديات التمريض».</p>');
    END IF;
    RETURN l_h || ('</div>');
  END on_duty_html;

  -- ================================================================ جدول الجرعات
  FUNCTION times_for(p_frequency IN VARCHAR2, p_custom IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
    l_f VARCHAR2(100) := UPPER(TRIM(REGEXP_SUBSTR(NVL(p_frequency, 'OD'), '^\S+')));
  BEGIN
    IF TRIM(p_custom) IS NOT NULL THEN
      RETURN REPLACE(TRIM(p_custom), ' ');
    END IF;
    RETURN CASE
      WHEN l_f IN ('OD', 'QD', 'DAILY', 'ONCE', '1X1', 'Q24H') THEN '09:00'
      WHEN l_f IN ('BID', 'BD', 'Q12H', '1X2') THEN '09:00,21:00'
      WHEN l_f IN ('TID', 'TDS', '1X3') THEN '08:00,14:00,22:00'
      WHEN l_f = 'Q8H' THEN '06:00,14:00,22:00'
      WHEN l_f IN ('QID', 'QDS', '1X4') THEN '06:00,12:00,18:00,00:00'
      WHEN l_f = 'Q6H' THEN '00:00,06:00,12:00,18:00'
      WHEN l_f = 'Q4H' THEN '02:00,06:00,10:00,14:00,18:00,22:00'
      WHEN l_f IN ('HS', 'QHS', 'NOCTE') THEN '22:00'
      WHEN l_f IN ('QAM', 'MANE') THEN '08:00'
      WHEN l_f = 'QPM' THEN '20:00'
      WHEN l_f IN ('STAT', 'NOW') THEN 'STAT'
      WHEN l_f IN ('PRN', 'SOS') THEN NULL
      ELSE '09:00' END;
  END times_for;

  -- يولد مواعيد سطر من بداية الوصفة حتى نهاية مدتها أو 48 ساعة قادمة (أيهما أقرب)؛ لا يكرر الموجود
  FUNCTION schedule_line(p_line_id NUMBER) RETURN NUMBER IS
    l_from DATE;
    l_to   DATE;
    l_times VARCHAR2(200);
    l_t    VARCHAR2(10);
    l_at   DATE;
    l_n    PLS_INTEGER := 0;
    l_tsv  TIMESTAMP WITH LOCAL TIME ZONE;
    k      PLS_INTEGER;
  BEGIN
    FOR r IN (SELECT l.id, l.company_id, l.tenant_id, l.dose, l.frequency, l.duration_days, l.dose_times, NVL(l.route, CASE WHEN REGEXP_LIKE(UPPER(l.frequency), '(^|\s)IV(\s|$)') THEN 'IV' WHEN REGEXP_LIKE(UPPER(l.frequency), '(^|\s)IM(\s|$)') THEN 'IM'
                     WHEN REGEXP_LIKE(UPPER(l.frequency), '(^|\s)(SC|SQ)(\s|$)') THEN 'SC' ELSE 'ORAL' END) route, x.visit_id,
                     CAST(x.rx_at AS DATE) rx_at, x.status_code rxs, v.status_code vst, v.visit_type
                FROM his_prescription_line l JOIN his_prescription x ON x.id = l.prescription_id JOIN his_visit v ON v.id = x.visit_id
               WHERE l.id = p_line_id) LOOP
      CONTINUE WHEN r.rxs NOT IN ('ACTIVE', 'PARTIAL', 'DISPENSED') OR r.vst <> 'OPEN' OR INSTR(c_inpatient, ',' || r.visit_type || ',') = 0;
      l_times := times_for(r.frequency, r.dose_times);
      CONTINUE WHEN l_times IS NULL;
      IF l_times = 'STAT' THEN
        l_tsv := CAST(r.rx_at AS TIMESTAMP WITH LOCAL TIME ZONE);
        INSERT INTO his_med_schedule (tenant_id, company_id, visit_id, line_id, due_at, dose, route, alert_level, status_code)
        SELECT r.tenant_id, r.company_id, r.visit_id, r.id, l_tsv, r.dose, r.route, 0, 'DUE' FROM dual
         WHERE NOT EXISTS (SELECT 1 FROM his_med_schedule WHERE line_id = r.id);
        l_n := l_n + SQL%ROWCOUNT;
        CONTINUE;
      END IF;
      l_from := r.rx_at;
      l_to := LEAST(SYSDATE + 2, CASE WHEN r.duration_days IS NOT NULL THEN r.rx_at + r.duration_days ELSE SYSDATE + 2 END);
      FOR d IN 0 .. TRUNC(l_to) - TRUNC(l_from) LOOP
        k := 1;
        LOOP
          l_t := REGEXP_SUBSTR(l_times, '[^,]+', 1, k);
          EXIT WHEN l_t IS NULL;
          IF valid_time(l_t) THEN
            l_at := TRUNC(l_from) + d + day_fraction(l_t);
            IF l_at >= l_from AND l_at < l_to THEN
              l_tsv := CAST(l_at AS TIMESTAMP WITH LOCAL TIME ZONE);
              INSERT INTO his_med_schedule (tenant_id, company_id, visit_id, line_id, due_at, dose, route, alert_level, status_code)
              SELECT r.tenant_id, r.company_id, r.visit_id, r.id, l_tsv, r.dose, r.route, 0, 'DUE' FROM dual
               WHERE NOT EXISTS (SELECT 1 FROM his_med_schedule WHERE line_id = r.id AND due_at = l_tsv);
              l_n := l_n + SQL%ROWCOUNT;
            END IF;
          END IF;
          k := k + 1;
        END LOOP;
      END LOOP;
    END LOOP;
    RETURN l_n;
  END schedule_line;

  FUNCTION schedule_rx(p_rx_id IN NUMBER) RETURN NUMBER IS
    l_n PLS_INTEGER := 0;
  BEGIN
    FOR l IN (SELECT l.id FROM his_prescription_line l JOIN his_prescription x ON x.id = l.prescription_id
               WHERE x.id = p_rx_id AND x.company_id = company) LOOP
      l_n := l_n + schedule_line(l.id);
    END LOOP;
    RETURN l_n;
  END schedule_rx;

  -- كل الأسطر النشطة للمنومين (المرشح بالشركة الحالية أو بلا قيد في وضع النظام)
  FUNCTION extend_all(p_company NUMBER) RETURN NUMBER IS
    l_n PLS_INTEGER := 0;
  BEGIN
    FOR l IN (SELECT l.id FROM his_prescription_line l JOIN his_prescription x ON x.id = l.prescription_id JOIN his_visit v ON v.id = x.visit_id
               WHERE (p_company IS NULL OR x.company_id = p_company) AND v.status_code = 'OPEN' AND v.visit_type IN ('INPATIENT', 'EMERGENCY', 'DAY_CASE')
                 AND x.status_code IN ('ACTIVE', 'PARTIAL', 'DISPENSED')
                 AND (l.duration_days IS NULL OR CAST(x.rx_at AS DATE) + l.duration_days > SYSDATE)) LOOP
      l_n := l_n + schedule_line(l.id);
    END LOOP;
    RETURN l_n;
  END extend_all;

  FUNCTION extend_schedules RETURN NUMBER IS
  BEGIN
    guard('HIS_VISIT.VIEW');
    RETURN extend_all(company);
  END extend_schedules;

  FUNCTION record_dose(p_schedule_id IN NUMBER, p_outcome IN VARCHAR2, p_nurse IN NUMBER DEFAULT NULL, p_notes IN VARCHAR2 DEFAULT NULL,
                       p_dose IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_s   his_med_schedule%ROWTYPE;
    l_adm NUMBER;
    l_doc CLOB;
  BEGIN
    guard('HIS_ORDER.UPDATE');
    SELECT * INTO l_s FROM his_med_schedule WHERE id = p_schedule_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_s.status_code = 'DUE', 'NOONA-HIS-260', 'الجرعة مسجلة سابقاً أو ملغاة', 'Dose already recorded or cancelled');
    NOONA_CORE_PKG.assert(p_outcome IN ('GIVEN', 'HELD', 'REFUSED', 'MISSED'), 'NOONA-HIS-261', 'النتيجة غير صحيحة', 'Invalid outcome');
    NOONA_CORE_PKG.assert(l_s.due_at <= SYSTIMESTAMP + INTERVAL '2' HOUR, 'NOONA-HIS-262', 'لا تسجل جرعة قبل موعدها بأكثر من ساعتين',
                          'A dose cannot be recorded more than 2 hours early');
    SELECT JSON_OBJECT('line' VALUE l_s.line_id, 'outcome' VALUE p_outcome, 'dose' VALUE NVL(p_dose, l_s.dose), 'route' VALUE l_s.route,
                       'nurse' VALUE p_nurse, 'notes' VALUE SUBSTR('Scheduled ' || TO_CHAR(l_s.due_at, 'HH24:MI') || NVL2(p_notes, ': ' || p_notes, ''), 1, 500)
                       RETURNING CLOB) INTO l_doc FROM dual;
    l_adm := NOONA_HIS_CLIN_PKG.give_medication(l_doc);
    UPDATE his_med_schedule SET status_code = p_outcome, admin_id = l_adm, done_at = SYSTIMESTAMP, nurse_id = p_nurse, notes = p_notes,
                                dose = NVL(p_dose, dose)
     WHERE id = p_schedule_id;
    RETURN l_adm;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-263', 'الجرعة غير موجودة', 'Dose not found');
  END record_dose;

  PROCEDURE cancel_rx_doses(p_rx_id IN NUMBER) IS
  BEGIN
    UPDATE his_med_schedule SET status_code = 'CANCELLED'
     WHERE status_code = 'DUE' AND line_id IN (SELECT id FROM his_prescription_line WHERE prescription_id = p_rx_id) AND company_id = company;
  END cancel_rx_doses;

  -- ================================================================ مهام المتابعة
  FUNCTION add_task(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_vis  NUMBER := l_o.get_number('visit');
    l_type VARCHAR2(30) := NVL(l_o.get_string('type'), 'OTHER');
    l_desc VARCHAR2(500) := TRIM(l_o.get_string('desc'));
    l_ev   NUMBER := l_o.get_number('every');
    l_st   DATE := TO_DATE(l_o.get_string('start'), 'YYYY-MM-DD HH24:MI');
    l_end  DATE := TO_DATE(l_o.get_string('end'), 'YYYY-MM-DD HH24:MI');
    l_vst  VARCHAR2(30);
    l      NUMBER;
  BEGIN
    guard('HIS_VISIT.UPDATE');
    SELECT status_code INTO l_vst FROM his_visit WHERE id = l_vis AND company_id = company;
    NOONA_CORE_PKG.assert(l_vst = 'OPEN', 'NOONA-HIS-051', 'الزيارة مقفلة', 'Visit is closed');
    NOONA_CORE_PKG.assert(l_ev > 0 AND l_ev <= 168, 'NOONA-HIS-264', 'التكرار بالساعات من أقل من ساعة حتى أسبوع', 'Frequency must be 0-168 hours');
    NOONA_CORE_PKG.assert(l_type IN ('VITALS', 'BLOOD_SUGAR', 'TURNING', 'WOUND_CARE', 'INTAKE_OUTPUT', 'DOCTOR_ROUND', 'OBSERVATION', 'OTHER'),
                          'NOONA-HIS-265', 'نوع المتابعة غير صحيح', 'Invalid task type');
    NOONA_CORE_PKG.assert(l_type <> 'OTHER' OR l_desc IS NOT NULL, 'NOONA-HIS-266', 'صف المهمة', 'Describe the task');
    INSERT INTO his_care_task (company_id, visit_id, task_type, description, every_hours, next_due_at, end_at, alert_level, status_code)
    VALUES (company, l_vis, l_type, l_desc, l_ev, CAST(NVL(l_st, SYSDATE) AS TIMESTAMP WITH LOCAL TIME ZONE), CAST(l_end AS TIMESTAMP WITH LOCAL TIME ZONE), 0, 'ACTIVE')
    RETURNING id INTO l;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-050', 'الزيارة غير موجودة', 'Visit not found');
  END add_task;

  PROCEDURE default_tasks(p_visit_id IN NUMBER) IS
    l_n NUMBER;
    l   NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_n FROM his_care_task WHERE visit_id = p_visit_id AND status_code = 'ACTIVE';
    IF l_n > 0 THEN RETURN; END IF;
    l := add_task('{"visit":' || p_visit_id || ',"type":"VITALS","desc":"Vital signs and pain score","every":4}');
    l := add_task('{"visit":' || p_visit_id || ',"type":"DOCTOR_ROUND","desc":"Daily doctor round and plan","every":24,"start":"'
         || TO_CHAR(TRUNC(SYSDATE) + 1 + 9 / 24, 'YYYY-MM-DD HH24:MI') || '"}');
  END default_tasks;

  PROCEDURE stop_task(p_task_id IN NUMBER) IS
  BEGIN
    guard('HIS_VISIT.UPDATE');
    UPDATE his_care_task SET status_code = 'STOPPED' WHERE id = p_task_id AND company_id = company AND status_code = 'ACTIVE';
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-HIS-267', 'المهمة غير موجودة أو موقوفة', 'Task not found or stopped');
  END stop_task;

  FUNCTION complete_task(p_task_id IN NUMBER, p_value IN VARCHAR2 DEFAULT NULL, p_notes IN VARCHAR2 DEFAULT NULL, p_nurse IN NUMBER DEFAULT NULL)
    RETURN NUMBER IS
    l_t his_care_task%ROWTYPE;
    l   NUMBER;
  BEGIN
    guard('HIS_VISIT.UPDATE');
    SELECT * INTO l_t FROM his_care_task WHERE id = p_task_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_t.status_code = 'ACTIVE', 'NOONA-HIS-267', 'المهمة موقوفة', 'Task is stopped');
    INSERT INTO his_care_log (company_id, task_id, visit_id, done_at, nurse_id, result_value, notes)
    VALUES (company, p_task_id, l_t.visit_id, SYSTIMESTAMP, p_nurse, p_value, p_notes)
    RETURNING id INTO l;
    -- الموعد القادم من وقت التنفيذ؛ وتتوقف المهمة بعد نهايتها
    UPDATE his_care_task SET last_done_at = SYSTIMESTAMP, next_due_at = SYSTIMESTAMP + NUMTODSINTERVAL(every_hours, 'HOUR'), alert_level = 0,
                             status_code = CASE WHEN end_at IS NOT NULL AND SYSTIMESTAMP + NUMTODSINTERVAL(every_hours, 'HOUR') > end_at THEN 'STOPPED'
                                                ELSE 'ACTIVE' END
     WHERE id = p_task_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-267', 'المهمة غير موجودة', 'Task not found');
  END complete_task;

  PROCEDURE touch_task(p_visit_id IN NUMBER, p_type IN VARCHAR2) IS
    l NUMBER;
  BEGIN
    FOR t IN (SELECT id FROM his_care_task WHERE visit_id = p_visit_id AND task_type = p_type AND status_code = 'ACTIVE' AND company_id = company) LOOP
      l := complete_task(t.id, NULL, 'Recorded from the nursing chart');
    END LOOP;
  END touch_task;

  PROCEDURE close_visit_care(p_visit_id IN NUMBER) IS
  BEGIN
    UPDATE his_med_schedule SET status_code = CASE WHEN due_at < SYSTIMESTAMP THEN 'MISSED' ELSE 'CANCELLED' END
     WHERE visit_id = p_visit_id AND status_code = 'DUE';
    UPDATE his_care_task SET status_code = 'STOPPED' WHERE visit_id = p_visit_id AND status_code = 'ACTIVE';
  END close_visit_care;

  -- ================================================================ المحطة
  FUNCTION station_html(p_ward_id IN NUMBER) RETURN CLOB IS
    l_h CLOB;
    l_x NUMBER;
  BEGIN
    guard('HIS_VISIT.VIEW');
    l_x := extend_all(company);
    l_h := '<div class="nn-his-station">';
    FOR b IN (SELECT b.bed_no, b.room_no, a.id adm, v.id vid, p.name_ar, p.name_en, p.mrn, p.allergies, v.diagnosis, v.vitals, dr.name_ar doctor,
                     TRUNC(SYSDATE) - TRUNC(CAST(a.admit_at AS DATE)) + 1 los,
                     (SELECT MAX(taken_at) FROM his_vital_sign s WHERE s.visit_id = v.id) last_vs,
                     (SELECT MIN(due_at) FROM his_med_schedule m WHERE m.visit_id = v.id AND m.status_code = 'DUE') next_dose,
                     (SELECT COUNT(*) FROM his_med_schedule m WHERE m.visit_id = v.id AND m.status_code = 'DUE' AND m.due_at < SYSTIMESTAMP - INTERVAL '30' MINUTE) late_doses,
                     (SELECT COUNT(*) FROM his_care_task t WHERE t.visit_id = v.id AND t.status_code = 'ACTIVE' AND t.next_due_at < SYSTIMESTAMP) late_tasks
                FROM his_bed b JOIN his_admission a ON a.bed_id = b.id AND a.status_code = 'ADMITTED' JOIN his_visit v ON v.id = a.visit_id
                JOIN his_patient p ON p.id = v.patient_id LEFT JOIN his_doctor dr ON dr.id = NVL(a.doctor_id, v.doctor_id)
               WHERE b.ward_id = p_ward_id AND b.company_id = company ORDER BY b.bed_no) LOOP
      l_h := l_h || ('<article class="nn-his-pt' || CASE WHEN b.late_doses + b.late_tasks > 0 THEN ' is-late' END || '" data-visit="' || b.vid || '">'
          || '<header><b>' || esc(b.bed_no) || '</b><small>' || esc(b.room_no) || ' · Day ' || b.los || '</small></header>'
          || '<div class="nm">' || esc(b.name_ar) || ' <small>' || esc(b.mrn) || '</small></div>'
          || NVL2(b.allergies, '<span class="nn-rst-chip is-cancelled">Allergy: ' || esc(b.allergies) || '</span>', '')
          || '<div dir="ltr"><small>Dx</small> ' || esc(NVL(b.diagnosis, '-')) || '</div>'
          || '<div dir="ltr"><small>Vitals</small> ' || esc(NVL(b.vitals, '-'))
          || CASE WHEN b.last_vs IS NULL OR b.last_vs < SYSTIMESTAMP - INTERVAL '6' HOUR THEN ' <span class="nn-neg">(' || NVL(TO_CHAR(b.last_vs, 'HH24:MI'), 'none') || ')</span>'
                  ELSE ' <small>(' || TO_CHAR(b.last_vs, 'HH24:MI') || ')</small>' END || '</div>'
          || '<div dir="ltr"><small>Next dose</small> ' || NVL(TO_CHAR(b.next_dose, 'MM-DD HH24:MI'), '-')
          || CASE WHEN b.late_doses > 0 THEN ' <span class="nn-rst-chip is-cancelled">' || b.late_doses || ' overdue</span>' END
          || CASE WHEN b.late_tasks > 0 THEN ' <span class="nn-rst-chip is-cancelled">' || b.late_tasks || ' task(s) due</span>' END || '</div>'
          || '<footer><small>' || esc(NVL(b.doctor, '-')) || '</small><small>' || esc(NVL(nurses_on_duty(p_ward_id, b.room_no), 'لا ممرض مناوب')) || '</small></footer>'
          || '</article>');
    END LOOP;
    RETURN l_h || ('</div>');
  END station_html;

  FUNCTION due_html(p_ward_id IN NUMBER, p_hours IN NUMBER DEFAULT 2) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('HIS_VISIT.VIEW');
    l_h := '<table class="nn-rst-cred nn-his-lab"><thead><tr><th>الموعد</th><th>السرير</th><th>المريض</th><th>المهمة</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT * FROM (
                SELECT m.due_at, b.bed_no, p.name_ar pname, NVL(i.name_en, i.name_ar) || ' ' || m.dose || ' ' || m.route what, 'D' k, m.id
                  FROM his_med_schedule m JOIN his_prescription_line l ON l.id = m.line_id JOIN inv_item i ON i.id = l.item_id
                  JOIN his_admission a ON a.visit_id = m.visit_id AND a.status_code = 'ADMITTED' JOIN his_bed b ON b.id = a.bed_id
                  JOIN his_visit v ON v.id = m.visit_id JOIN his_patient p ON p.id = v.patient_id
                 WHERE m.company_id = company AND b.ward_id = p_ward_id AND m.status_code = 'DUE' AND m.due_at <= SYSTIMESTAMP + NUMTODSINTERVAL(p_hours, 'HOUR')
                UNION ALL
                SELECT t.next_due_at, b.bed_no, p.name_ar, task_label(t.task_type) || NVL2(t.description, ': ' || t.description, ''), 'T', t.id
                  FROM his_care_task t JOIN his_admission a ON a.visit_id = t.visit_id AND a.status_code = 'ADMITTED' JOIN his_bed b ON b.id = a.bed_id
                  JOIN his_visit v ON v.id = t.visit_id JOIN his_patient p ON p.id = v.patient_id
                 WHERE t.company_id = company AND b.ward_id = p_ward_id AND t.status_code = 'ACTIVE' AND t.next_due_at <= SYSTIMESTAMP + NUMTODSINTERVAL(p_hours, 'HOUR'))
               ORDER BY due_at) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr class="' || CASE WHEN r.due_at < SYSTIMESTAMP - INTERVAL '30' MINUTE THEN 'is-late' WHEN r.due_at <= SYSTIMESTAMP + INTERVAL '15' MINUTE THEN 'is-due' END
          || '"><td>' || TO_CHAR(r.due_at, 'HH24:MI') || '</td><td>' || esc(r.bed_no) || '</td><td>' || esc(r.pname) || '</td><td>'
          || CASE r.k WHEN 'D' THEN '&#128138; ' ELSE '&#128203; ' END || esc(r.what) || '</td><td>'
          || CASE WHEN r.due_at < SYSTIMESTAMP - INTERVAL '30' MINUTE THEN 'Overdue' WHEN r.due_at <= SYSTIMESTAMP + INTERVAL '15' MINUTE THEN 'Due now' ELSE 'Upcoming' END
          || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN
      l_h := l_h || ('<tr><td colspan="5">Nothing due in the next ' || p_hours || ' hours.</td></tr>');
    END IF;
    RETURN l_h || ('</tbody></table>');
  END due_html;

  FUNCTION alerts_json(p_ward_id IN NUMBER) RETURN CLOB IS
    l_items CLOB;
    l_late  NUMBER;
    l_due   NUMBER;
    l       CLOB;
  BEGIN
    guard('HIS_VISIT.VIEW');
    SELECT NVL(SUM(CASE WHEN due_at < SYSTIMESTAMP - INTERVAL '30' MINUTE THEN 1 ELSE 0 END), 0),
           NVL(SUM(CASE WHEN due_at >= SYSTIMESTAMP - INTERVAL '30' MINUTE THEN 1 ELSE 0 END), 0),
           JSON_ARRAYAGG(JSON_OBJECT('k' VALUE k, 'at' VALUE TO_CHAR(due_at, 'HH24:MI'), 'bed' VALUE bed_no, 'patient' VALUE pname, 'what' VALUE what,
                                     'late' VALUE CASE WHEN due_at < SYSTIMESTAMP - INTERVAL '30' MINUTE THEN 'Y' ELSE 'N' END) ORDER BY due_at RETURNING CLOB)
      INTO l_late, l_due, l_items
      FROM (SELECT 'D' || m.id k, m.due_at, b.bed_no, p.name_ar pname, NVL(i.name_en, i.name_ar) || ' ' || m.dose what
              FROM his_med_schedule m JOIN his_prescription_line l ON l.id = m.line_id JOIN inv_item i ON i.id = l.item_id
              JOIN his_admission a ON a.visit_id = m.visit_id AND a.status_code = 'ADMITTED' JOIN his_bed b ON b.id = a.bed_id
              JOIN his_visit v ON v.id = m.visit_id JOIN his_patient p ON p.id = v.patient_id
             WHERE m.company_id = company AND (p_ward_id IS NULL OR b.ward_id = p_ward_id) AND m.status_code = 'DUE'
               AND m.due_at <= SYSTIMESTAMP + INTERVAL '15' MINUTE
            UNION ALL
            SELECT 'T' || t.id, t.next_due_at, b.bed_no, p.name_ar, task_label(t.task_type)
              FROM his_care_task t JOIN his_admission a ON a.visit_id = t.visit_id AND a.status_code = 'ADMITTED' JOIN his_bed b ON b.id = a.bed_id
              JOIN his_visit v ON v.id = t.visit_id JOIN his_patient p ON p.id = v.patient_id
             WHERE t.company_id = company AND (p_ward_id IS NULL OR b.ward_id = p_ward_id) AND t.status_code = 'ACTIVE'
               AND t.next_due_at <= SYSTIMESTAMP + INTERVAL '15' MINUTE);
    l_items := NVL(l_items, TO_CLOB('[]'));
    SELECT JSON_OBJECT('overdue' VALUE l_late, 'due' VALUE l_due, 'items' VALUE l_items FORMAT JSON RETURNING CLOB) INTO l FROM dual;
    RETURN l;
  END alerts_json;

  -- ================================================================ الملف الإلكتروني للمنوم
  FUNCTION inpatient_chart_html(p_visit_id IN NUMBER) RETURN CLOB IS
    l_h CLOB;
    l_x NUMBER;
  BEGIN
    guard('HIS_VISIT.VIEW');
    l_x := extend_all(company);
    FOR v IN (SELECT v.*, p.name_ar, p.name_en pen, p.mrn, p.gender, p.birth_date, p.allergies, p.chronic_diseases, p.blood_group,
                     a.admission_no, a.admit_at, a.admit_reason, a.status_code ast, a.discharge_at, a.discharge_summary, b.bed_no, b.room_no, b.ward_id,
                     w.name_ar ward, dr.name_ar doctor
                FROM his_visit v JOIN his_patient p ON p.id = v.patient_id
                LEFT JOIN his_admission a ON a.visit_id = v.id LEFT JOIN his_bed b ON b.id = a.bed_id LEFT JOIN his_department w ON w.id = b.ward_id
                LEFT JOIN his_doctor dr ON dr.id = NVL(a.doctor_id, v.doctor_id)
               WHERE v.id = p_visit_id AND v.company_id = company) LOOP
      l_h := '<div class="nn-his-chart" dir="ltr"><div class="nn-his-card"><div class="nn-his-head"><div><b>' || esc(NVL(v.pen, v.name_ar))
          || CASE WHEN v.pen IS NOT NULL THEN ' / ' || esc(v.name_ar) END || '</b> <span class="nn-rst-chip">' || esc(v.mrn) || '</span> <span class="nn-rst-chip">'
          || CASE v.gender WHEN 'M' THEN 'Male' ELSE 'Female' END || ' · ' || TRUNC(MONTHS_BETWEEN(SYSDATE, v.birth_date) / 12) || ' y'
          || NVL2(v.blood_group, ' · ' || esc(v.blood_group), '') || '</span>'
          || NVL2(v.allergies, ' <span class="nn-rst-chip is-cancelled">Allergies: ' || esc(v.allergies) || '</span>', '')
          || '<br><small>' || esc(v.admission_no) || ' · ' || esc(v.ward) || ' · Bed ' || esc(v.bed_no) || NVL2(v.room_no, ' (' || esc(v.room_no) || ')', '')
          || ' · Admitted ' || TO_CHAR(v.admit_at, 'YYYY-MM-DD HH24:MI') || ' · Day ' || (TRUNC(NVL(CAST(v.discharge_at AS DATE), SYSDATE)) - TRUNC(CAST(v.admit_at AS DATE)) + 1)
          || ' · ' || esc(v.doctor) || '</small><br><small>Diagnosis: <b>' || esc(NVL(v.diagnosis, v.admit_reason)) || '</b>'
          || NVL2(v.icd10, ' (' || esc(v.icd10) || ')', '') || NVL2(v.chronic_diseases, ' · Chronic: ' || esc(v.chronic_diseases), '') || '</small>'
          || CASE WHEN v.ast = 'ADMITTED' AND v.ward_id IS NOT NULL THEN '<br><small>Nurse on duty: ' || esc(NVL(nurses_on_duty(v.ward_id, v.room_no), '-')) || '</small>' END
          || CASE WHEN v.ast = 'DISCHARGED' THEN '<br><small>Discharged ' || TO_CHAR(v.discharge_at, 'YYYY-MM-DD HH24:MI') || ': ' || esc(v.discharge_summary) || '</small>' END
          || '</div></div></div>';
      -- جدول الجرعات: أمس واليوم والغد
      l_h := l_h || ('<h3>Medication schedule (MAR)</h3><table class="nn-rst-cred nn-his-lab nn-his-mar"><thead><tr><th>Medicine</th><th>Schedule</th></tr></thead><tbody>');
      FOR l IN (SELECT l.id, NVL(i.name_en, i.name_ar) med, l.dose, l.frequency, NVL(l.route, 'ORAL') route, x.status_code rxs,
                       NOONA_HIS_NURSE_PKG.times_for(l.frequency, l.dose_times) tms
                  FROM his_prescription x JOIN his_prescription_line l ON l.prescription_id = x.id JOIN inv_item i ON i.id = l.item_id
                 WHERE x.visit_id = p_visit_id AND x.status_code <> 'CANCELLED' ORDER BY x.rx_at, l.line_no) LOOP
        l_h := l_h || ('<tr><td><b>' || esc(l.med) || '</b><br><small>' || esc(l.dose || ' ' || l.frequency || ' ' || l.route)
            || CASE WHEN l.tms IS NULL THEN ' · PRN' ELSE ' · ' || esc(l.tms) END || '</small></td><td>');
        FOR m IN (SELECT m.due_at, m.status_code, m.done_at FROM his_med_schedule m WHERE m.line_id = l.id
                   AND m.due_at BETWEEN SYSTIMESTAMP - INTERVAL '1' DAY AND SYSTIMESTAMP + INTERVAL '1' DAY ORDER BY m.due_at) LOOP
          l_h := l_h || ('<span class="nn-his-dose ds-' || LOWER(CASE WHEN m.status_code = 'DUE' AND m.due_at < SYSTIMESTAMP - INTERVAL '30' MINUTE THEN 'LATE'
                                                              ELSE m.status_code END) || '" title="' || m.status_code || NVL2(m.done_at, ' ' || TO_CHAR(m.done_at, 'HH24:MI'), '')
              || '">' || TO_CHAR(m.due_at, 'DD HH24:MI') || '</span>');
        END LOOP;
        l_h := l_h || ('</td></tr>');
      END LOOP;
      l_h := l_h || ('</tbody></table>');
      -- مهام المتابعة
      l_h := l_h || ('<h3>Care plan</h3><table class="nn-rst-cred nn-his-lab"><thead><tr><th>Task</th><th>Every</th><th>Last</th><th>Next</th><th>Last value</th></tr></thead><tbody>');
      FOR t IN (SELECT t.*, (SELECT MAX(c.result_value) KEEP (DENSE_RANK LAST ORDER BY c.done_at) FROM his_care_log c WHERE c.task_id = t.id AND c.result_value IS NOT NULL) lastv
                  FROM his_care_task t WHERE t.visit_id = p_visit_id ORDER BY t.status_code, t.next_due_at) LOOP
        l_h := l_h || ('<tr class="' || CASE WHEN t.status_code = 'STOPPED' THEN 'is-void' WHEN t.next_due_at < SYSTIMESTAMP THEN 'is-late' END || '"><td>'
            || esc(task_label(t.task_type)) || NVL2(t.description, '<br><small>' || esc(t.description) || '</small>', '') || '</td><td>' || t.every_hours || ' h</td><td>'
            || TO_CHAR(t.last_done_at, 'MM-DD HH24:MI') || '</td><td>' || CASE WHEN t.status_code = 'ACTIVE' THEN TO_CHAR(t.next_due_at, 'MM-DD HH24:MI') ELSE 'Stopped' END
            || '</td><td>' || esc(t.lastv) || '</td></tr>');
      END LOOP;
      l_h := l_h || ('</tbody></table><h3>Vital signs</h3>' || NOONA_HIS_CLIN_PKG.vitals_html(p_visit_id)
          || '<h3>Clinical notes</h3>' || NOONA_HIS_CLIN_PKG.notes_html(p_visit_id) || '</div>');
    END LOOP;
    RETURN l_h;
  END inpatient_chart_html;

  -- ================================================================ التنبيهات (مهمة مجدولة)
  FUNCTION notify(p_tenant NUMBER, p_ward NUMBER, p_room VARCHAR2, p_event VARCHAR2, p_entity VARCHAR2, p_id NUMBER, p_key VARCHAR2, p_title VARCHAR2,
                  p_due TIMESTAMP WITH LOCAL TIME ZONE) RETURN NUMBER IS
    l_evt NUMBER;
    l_n   PLS_INTEGER := 0;
  BEGIN
    SELECT MIN(id) INTO l_evt FROM ntf_event_type WHERE code = p_event;
    IF l_evt IS NULL THEN RETURN 0; END IF;
    FOR m IN (SELECT DISTINCT um.id
                FROM his_nurse_roster r JOIN his_nurse_shift s ON s.id = r.shift_id JOIN his_doctor d ON d.id = r.nurse_id
                JOIN sec_user_membership um ON um.tenant_id = r.tenant_id AND um.status_code = 'ACTIVE'
                 AND (um.employee_id = d.employee_id OR um.user_id IN (SELECT u.id FROM sec_user u WHERE UPPER(u.username) = UPPER(d.user_name)))
               WHERE r.tenant_id = p_tenant AND r.ward_id = p_ward
                 AND (p_room IS NULL OR r.rooms IS NULL OR INSTR(',' || r.rooms || ',', ',' || p_room || ',') > 0)
                 AND SYSDATE >= r.duty_date + day_fraction(s.start_time)
                 AND SYSDATE < r.duty_date + day_fraction(s.end_time) + CASE WHEN s.end_time <= s.start_time THEN 1 ELSE 0 END) LOOP
      BEGIN
        INSERT INTO ntf_notification (tenant_id, event_type_id, membership_id, source_entity_type, source_entity_id, title, link_url,
                                      idempotency_key, due_at, correlation_id, confidentiality_level)
        VALUES (p_tenant, l_evt, m.id, p_entity, p_id, SUBSTR(p_title, 1, 500), 'f?p=NOONA_HIS:NURSE-STATION:::NO::P75_WARD:' || p_ward,
                'HIS:' || p_entity || ':' || p_key || ':' || m.id, p_due, NOONA_CTX_PKG.correlation_id, 'CONFIDENTIAL');
        l_n := l_n + 1;
      EXCEPTION WHEN DUP_VAL_ON_INDEX THEN NULL;
      END;
    END LOOP;
    RETURN l_n;
  END notify;

  FUNCTION run_alerts RETURN NUMBER IS
    l_n   PLS_INTEGER := 0;
    l_x   NUMBER;
    l_lvl NUMBER;
  BEGIN
    NOONA_CORE_PKG.begin_system;
    BEGIN
      l_x := extend_all(NULL);
      -- جرعات لم تسجل بعد 6 ساعات من موعدها تعد فائتة
      UPDATE his_med_schedule SET status_code = 'MISSED', notes = 'Not recorded within 6 hours'
       WHERE status_code = 'DUE' AND due_at < SYSTIMESTAMP - INTERVAL '6' HOUR;
      FOR d IN (SELECT m.id, m.tenant_id, m.due_at, m.alert_level, b.ward_id, b.room_no, b.bed_no, p.name_ar, NVL(i.name_en, i.name_ar) med, m.dose
                  FROM his_med_schedule m JOIN his_prescription_line l ON l.id = m.line_id JOIN inv_item i ON i.id = l.item_id
                  JOIN his_admission a ON a.visit_id = m.visit_id AND a.status_code = 'ADMITTED' JOIN his_bed b ON b.id = a.bed_id
                  JOIN his_visit v ON v.id = m.visit_id JOIN his_patient p ON p.id = v.patient_id
                 WHERE m.status_code = 'DUE' AND ((m.alert_level = 0 AND m.due_at <= SYSTIMESTAMP + INTERVAL '15' MINUTE)
                    OR (m.alert_level < 2 AND m.due_at < SYSTIMESTAMP - INTERVAL '30' MINUTE))
                 FOR UPDATE OF m.alert_level SKIP LOCKED) LOOP
        l_lvl := CASE WHEN d.due_at < SYSTIMESTAMP - INTERVAL '30' MINUTE THEN 2 ELSE 1 END;
        l_n := l_n + notify(d.tenant_id, d.ward_id, d.room_no, 'HIS_DOSE_DUE', 'HIS_MED_SCHEDULE', d.id, d.id || ':' || l_lvl,
                            CASE l_lvl WHEN 2 THEN 'جرعة متأخرة: ' ELSE 'موعد جرعة: ' END || d.med || ' ' || d.dose || ' - ' || d.name_ar || ' - سرير ' || d.bed_no
                            || ' (' || TO_CHAR(d.due_at, 'HH24:MI') || ')', d.due_at);
        UPDATE his_med_schedule SET alert_level = l_lvl WHERE id = d.id;
      END LOOP;
      FOR t IN (SELECT t.id, t.tenant_id, t.next_due_at, t.task_type, t.alert_level, b.ward_id, b.room_no, b.bed_no, p.name_ar
                  FROM his_care_task t JOIN his_admission a ON a.visit_id = t.visit_id AND a.status_code = 'ADMITTED' JOIN his_bed b ON b.id = a.bed_id
                  JOIN his_visit v ON v.id = t.visit_id JOIN his_patient p ON p.id = v.patient_id
                 WHERE t.status_code = 'ACTIVE' AND ((t.alert_level = 0 AND t.next_due_at <= SYSTIMESTAMP + INTERVAL '15' MINUTE)
                    OR (t.alert_level < 2 AND t.next_due_at < SYSTIMESTAMP - INTERVAL '30' MINUTE))
                 FOR UPDATE OF t.alert_level SKIP LOCKED) LOOP
        l_lvl := CASE WHEN t.next_due_at < SYSTIMESTAMP - INTERVAL '30' MINUTE THEN 2 ELSE 1 END;
        l_n := l_n + notify(t.tenant_id, t.ward_id, t.room_no, 'HIS_CARE_DUE', 'HIS_CARE_TASK', t.id,
                            t.id || ':' || TO_CHAR(t.next_due_at, 'YYMMDDHH24MI') || ':' || l_lvl,
                            CASE l_lvl WHEN 2 THEN 'متابعة متأخرة: ' ELSE 'موعد متابعة: ' END || task_label(t.task_type) || ' - ' || t.name_ar || ' - سرير ' || t.bed_no
                            || ' (' || TO_CHAR(t.next_due_at, 'HH24:MI') || ')', t.next_due_at);
        UPDATE his_care_task SET alert_level = l_lvl WHERE id = t.id;
      END LOOP;
    EXCEPTION WHEN OTHERS THEN
      NOONA_CORE_PKG.end_system;
      RAISE;
    END;
    NOONA_CORE_PKG.end_system;
    RETURN l_n;
  END run_alerts;
END NOONA_HIS_NURSE_PKG;
/
