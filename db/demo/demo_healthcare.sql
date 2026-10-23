-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية للمستشفى (بعد التحديث 25) - تشغل بحساب NOONA_APP ولا تكرر
-- (تكتشف الجهة ذات الرمز DEMO-INS1):
--   sqlplus NOONA_APP@//host:1521/PDB @demo/demo_healthcare.sql ADMIN
-- المحتوى:
--   * الأقسام النموذجية: عيادات، طوارئ، خمسة معامل منفصلة بمستودعاتها، أشعة عادية ومقطعية ورنين وموجات، تشخيص القلب،
--     علاج طبيعي، غسيل كلوي، عمليات، تنويم، صيدلية داخلية، ودليل خدمات بأسعار
--   * مواد المعامل والأشعة بأرصدة افتتاحية في مستودع كل قسم، مربوطة بالفحوص
--   * 10 أطباء بساعات عمل (صباحية ومسائية) وطوارئ على مدار الأسبوع
--   * شركتا تأمين بفئات (VIP، أ، ب) وأسعار عقود، وشركة متعاقدة لموظفيها
--   * 14 مريضاً (مواطنون ومقيمون، مؤمنون ونقديون)، زيارات خمسة أيام سابقة بطلبات ونتائج وفواتير، مواعيد اليوم والغد،
--     طلبات بانتظار موافقة التأمين، تحصيل جزئي من شركة التأمين
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE
COLUMN 1 NEW_VALUE 1 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
DEFINE ADMIN_USER = '&1'

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/

DECLARE
  c_admin CONSTANT VARCHAR2(128) := NVL(UPPER(TRIM('&ADMIN_USER')), 'ADMIN');
  l_co    NUMBER;
  l_n     NUMBER;
  l_x     NUMBER;
  l_v     NUMBER;
  l_o     NUMBER;
  l_inv   NUMBER;
  l_ins1  NUMBER;
  l_ins2  NUMBER;
  l_corp  NUMBER;
  l_lines VARCHAR2(4000);
  TYPE t_map IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
  dr      t_map;    -- الأطباء
  pl      t_map;    -- فئات التغطية
  pt      t_map;    -- المرضى
  mat     t_map;    -- المواد

  PROCEDURE say(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
  FUNCTION srv(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM his_service WHERE company_id = l_co AND code = p_code; RETURN l;
  END srv;
  FUNCTION dep(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM his_department WHERE company_id = l_co AND code = p_code; RETURN l;
  END dep;
  FUNCTION whs(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT warehouse_id INTO l FROM his_department WHERE company_id = l_co AND code = p_code; RETURN l;
  END whs;
  -- مادة مخزنية بأرصدة افتتاحية في مستودع القسم وربطها بالخدمات
  PROCEDURE material(p_key VARCHAR2, p_name VARCHAR2, p_dept VARCHAR2, p_qty NUMBER, p_cost NUMBER) IS
  BEGIN
    mat(p_key) := NOONA_INV_PKG.save_item('{"name":"' || p_name || '","type":"CONSUMABLE","sell":"N"}');
    l_x := NOONA_INV_PKG.save_stock_doc('{"type":"OPENING","date":"' || TO_CHAR(SYSDATE - 10, 'YYYY-MM-DD') || '","wh":' || whs(p_dept)
           || ',"action":"POST","desc":"رصيد افتتاحي ' || p_name || '","lines":[{"i":' || mat(p_key) || ',"q":' || p_qty || ',"c":' || p_cost || '}]}');
  END material;
  FUNCTION doctor(p_name VARCHAR2, p_dept VARCHAR2, p_title VARCHAR2, p_spec VARCHAR2, p_consult VARCHAR2, p_comm NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN NOONA_HIS_PKG.save_doctor('{"name":"' || p_name || '","dept":' || dep(p_dept) || ',"title":"' || p_title || '","specialty":"' || p_spec
      || '","license":"SCFHS-' || TRUNC(DBMS_RANDOM.VALUE(100000, 999999)) || '","license_expiry":"' || TO_CHAR(ADD_MONTHS(SYSDATE, 14), 'YYYY-MM-DD')
      || '","consult_service":' || CASE WHEN p_consult IS NOT NULL THEN TO_CHAR(srv(p_consult)) ELSE 'null' END || ',"commission":' || p_comm || '}');
  END doctor;
  PROCEDURE hours(p_dr NUMBER, p_from VARCHAR2, p_to VARCHAR2, p_slot NUMBER, p_days VARCHAR2 DEFAULT '1,2,3,4,5') IS
  BEGIN
    FOR d IN (SELECT TO_NUMBER(REGEXP_SUBSTR(p_days, '[^,]+', 1, LEVEL)) wd FROM dual CONNECT BY REGEXP_SUBSTR(p_days, '[^,]+', 1, LEVEL) IS NOT NULL) LOOP
      NOONA_HIS_PKG.set_schedule(p_dr, d.wd, p_from, p_to, p_slot);
    END LOOP;
  END hours;
  FUNCTION patient(p_name VARCHAR2, p_g VARCHAR2, p_birth VARCHAR2, p_nat VARCHAR2, p_id VARCHAR2, p_mob VARCHAR2, p_plan VARCHAR2 DEFAULT NULL,
                   p_allergy VARCHAR2 DEFAULT NULL, p_chronic VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
  BEGIN
    RETURN NOONA_HIS_PKG.save_patient('{"name":"' || p_name || '","gender":"' || p_g || '","birth":"' || p_birth || '","nationality":"' || p_nat
      || '","id_type":"' || CASE WHEN p_nat = 'SA' THEN 'NATIONAL_ID' ELSE 'IQAMA' END || '","id_no":"' || p_id || '","mobile":"' || p_mob || '"'
      || CASE WHEN p_plan IS NOT NULL THEN ',"plan":' || pl(p_plan) || ',"member":"' || p_plan || '-' || SUBSTR(p_id, -6) || '","ins_expiry":"'
              || TO_CHAR(ADD_MONTHS(SYSDATE, 8), 'YYYY-MM-DD') || '"' END
      || CASE WHEN p_allergy IS NOT NULL THEN ',"allergies":"' || p_allergy || '"' END
      || CASE WHEN p_chronic IS NOT NULL THEN ',"chronic":"' || p_chronic || '"' END || '}');
  END patient;
  -- زيارة سابقة: طلبات، موافقات، فاتورة، تنفيذ ونتائج، ثم إرجاع التاريخ
  PROCEDURE past_visit(p_pt VARCHAR2, p_dr VARCHAR2, p_days NUMBER, p_hour NUMBER, p_extra VARCHAR2, p_method VARCHAR2, p_diag VARCHAR2, p_icd VARCHAR2,
                       p_results VARCHAR2 DEFAULT NULL) IS
    l_part VARCHAR2(50);
    k PLS_INTEGER := 1;
    l_at TIMESTAMP := CAST(TRUNC(SYSDATE) - p_days AS TIMESTAMP) + NUMTODSINTERVAL(p_hour, 'HOUR');
  BEGIN
    l_v := NOONA_HIS_PKG.open_visit('{"patient":' || pt(p_pt) || ',"doctor":' || dr(p_dr) || '}');
    LOOP
      l_part := REGEXP_SUBSTR(p_extra, '[^ ]+', 1, k);
      EXIT WHEN l_part IS NULL;
      l_o := NOONA_HIS_PKG.add_order(l_v, srv(l_part));
      k := k + 1;
    END LOOP;
    FOR o IN (SELECT id FROM his_order WHERE visit_id = l_v AND status_code = 'APPROVAL_PENDING') LOOP
      NOONA_HIS_PKG.set_approval(o.id, 'APR-' || TRUNC(DBMS_RANDOM.VALUE(100000, 999999)));
    END LOOP;
    l_inv := NOONA_HIS_PKG.create_invoice('{"visit":' || l_v || ',"method":"' || p_method || '"}');
    FOR o IN (SELECT o.id, s.service_type, s.code FROM his_order o JOIN his_service s ON s.id = o.service_id
               WHERE o.visit_id = l_v ORDER BY o.line_no) LOOP
      IF o.service_type = 'LAB' THEN
        l_part := NOONA_HIS_PKG.collect_sample(o.id);
      END IF;
      NOONA_HIS_PKG.complete_order(o.id,
        CASE o.code WHEN 'LAB-CBC' THEN 'WBC 7.2, RBC 4.8, Hb 13.9 g/dL, PLT 260' WHEN 'LAB-FBS' THEN 'Glucose (fasting): 142 mg/dL'
                    WHEN 'LAB-HBA1C' THEN 'HbA1c: 7.4 %' WHEN 'LAB-LIPID' THEN 'Total cholesterol 228, LDL 151, HDL 41, TG 180 mg/dL'
                    WHEN 'LAB-TSH' THEN 'TSH: 2.1 mIU/L' WHEN 'LAB-VITD' THEN 'Vitamin D: 14 ng/mL (deficiency)' WHEN 'LAB-UR' THEN 'Urine: clear, no pus cells'
                    WHEN 'XR-CHEST' THEN 'Chest X-ray PA: clear lung fields, normal cardiac silhouette.'
                    WHEN 'US-ABD' THEN 'Abdominal ultrasound: mild fatty liver, normal gallbladder and kidneys.'
                    WHEN 'ECG' THEN 'Sinus rhythm 78 bpm, no ST changes.' WHEN 'ECHO' THEN 'EF 60%, normal valves, no pericardial effusion.'
                    WHEN 'MRI-KNEE' THEN 'MRI right knee: grade II medial meniscus tear, mild effusion.'
                    WHEN 'CT-BRAIN' THEN 'CT brain without contrast: no acute intracranial abnormality.'
                    ELSE 'تم ' || CASE WHEN o.service_type IN ('CONSULTATION', 'FOLLOW_UP') THEN 'الكشف' ELSE 'الإجراء' END END,
        CASE WHEN o.code IN ('LAB-FBS', 'LAB-HBA1C', 'LAB-LIPID', 'LAB-VITD', 'MRI-KNEE') THEN 'ABNORMAL' ELSE 'NORMAL' END);
    END LOOP;
    NOONA_HIS_PKG.update_visit('{"id":' || l_v || ',"diagnosis":"' || p_diag || '","icd10":"' || p_icd || '","vitals":"BP 128/82, T 36.9, HR 80"}');
    NOONA_HIS_PKG.close_visit(l_v);
    UPDATE his_visit SET visit_at = l_at, closed_at = l_at + INTERVAL '50' MINUTE WHERE id = l_v;
    UPDATE his_invoice SET doc_date = TRUNC(l_at) WHERE visit_id = l_v;
    UPDATE his_order SET started_at = l_at + INTERVAL '20' MINUTE, completed_at = l_at + INTERVAL '45' MINUTE,
                         sample_at = CASE WHEN sample_no IS NOT NULL THEN l_at + INTERVAL '15' MINUTE END WHERE visit_id = l_v;
  END past_visit;
BEGIN
  NOONA_APEX_PKG.post_auth(c_admin, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  SELECT COUNT(*) INTO l_n FROM his_payer WHERE company_id = l_co AND code = 'DEMO-INS1';
  IF l_n > 0 THEN
    say('بيانات المستشفى التجريبية محملة سابقاً لهذه الشركة؛ لم يضف شيء.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;
  l_n := NOONA_HIS_PKG.seed_catalog;
  say('الأقسام ودليل الخدمات: ' || l_n || ' قسم جديد');

  -- مواد المعامل والأشعة والعمليات في مستودع كل قسم
  material('TUBE', 'أنابيب سحب دم (EDTA)', 'LHEM', 1000, 0.6);
  material('CBCR', 'كاشف عد الدم الكامل', 'LHEM', 400, 3.5);
  material('GLU', 'كاشف سكر الدم', 'LCHEM', 500, 1.2);
  material('LIPR', 'كاشف دهون الدم', 'LCHEM', 300, 6);
  material('A1C', 'كاشف السكر التراكمي', 'LCHEM', 200, 9);
  material('HRM', 'كاشف الهرمونات', 'LIMM', 200, 12);
  material('URC', 'شرائط تحليل البول', 'LMIC', 500, 0.8);
  material('FILM', 'أفلام أشعة رقمية', 'RXR', 600, 4);
  material('GEL', 'جل الموجات الصوتية (لتر)', 'RUS', 80, 15);
  material('ELEC', 'أقطاب رسم القلب', 'CARD', 2000, 0.3);
  material('CONT', 'صبغة الأشعة المقطعية', 'RCT', 100, 65);
  material('SUTK', 'طقم خياطة جروح', 'ER', 200, 18);
  NOONA_HIS_PKG.set_material(srv('LAB-CBC'), mat('TUBE'), 1);   NOONA_HIS_PKG.set_material(srv('LAB-CBC'), mat('CBCR'), 1);
  NOONA_HIS_PKG.set_material(srv('LAB-FBS'), mat('GLU'), 1);    NOONA_HIS_PKG.set_material(srv('LAB-LIPID'), mat('LIPR'), 1);
  NOONA_HIS_PKG.set_material(srv('LAB-HBA1C'), mat('A1C'), 1);  NOONA_HIS_PKG.set_material(srv('LAB-TSH'), mat('HRM'), 1);
  NOONA_HIS_PKG.set_material(srv('LAB-VITD'), mat('HRM'), 1);   NOONA_HIS_PKG.set_material(srv('LAB-UR'), mat('URC'), 1);
  NOONA_HIS_PKG.set_material(srv('XR-CHEST'), mat('FILM'), 1);  NOONA_HIS_PKG.set_material(srv('XR-LIMB'), mat('FILM'), 2);
  NOONA_HIS_PKG.set_material(srv('US-ABD'), mat('GEL'), 0.05);  NOONA_HIS_PKG.set_material(srv('US-PREG'), mat('GEL'), 0.05);
  NOONA_HIS_PKG.set_material(srv('ECG'), mat('ELEC'), 10);      NOONA_HIS_PKG.set_material(srv('CT-ABD'), mat('CONT'), 1);
  NOONA_HIS_PKG.set_material(srv('PROC-SUT'), mat('SUTK'), 1);
  say('مواد المعامل والأشعة: 12 مادة بأرصدة في مستودعات الأقسام ومربوطة بالفحوص');

  -- الأطباء وساعات العمل
  dr('IM1') := doctor('د. خالد العتيبي', 'IM', 'CONSULTANT', 'باطنة وغدد صماء', 'CON-CS', 30);   hours(dr('IM1'), '09:00', '13:00', 20);
  dr('IM2') := doctor('د. سارة القحطاني', 'IM', 'SPECIALIST', 'باطنة', 'CON-SP', 25);           hours(dr('IM2'), '16:00', '21:00', 20);
  dr('PED') := doctor('د. فهد الشمري', 'PED', 'SPECIALIST', 'أطفال', 'CON-SP', 25);              hours(dr('PED'), '09:00', '14:00', 15);
  dr('OBG') := doctor('د. نورة الدوسري', 'OBG', 'CONSULTANT', 'نساء وولادة', 'CON-CS', 30);      hours(dr('OBG'), '10:00', '14:00', 20, '1,2,3,4');
  dr('ORTH') := doctor('د. ماجد الحربي', 'ORTH', 'CONSULTANT', 'جراحة العظام', 'CON-CS', 30);   hours(dr('ORTH'), '16:00', '20:00', 20, '1,3,5');
  dr('DERM') := doctor('د. ريم السبيعي', 'DERM', 'SPECIALIST', 'جلدية', 'CON-SP', 25);           hours(dr('DERM'), '09:00', '12:00', 15, '2,4');
  dr('ENT') := doctor('د. عمر الزهراني', 'ENT', 'SPECIALIST', 'أنف وأذن وحنجرة', 'CON-SP', 25); hours(dr('ENT'), '17:00', '21:00', 20, '1,2,3');
  dr('DENT') := doctor('د. هند المطيري', 'DENT', 'DENTIST', 'أسنان', 'DENT-EX', 35);             hours(dr('DENT'), '09:00', '17:00', 30);
  dr('ER') := doctor('د. سلطان الغامدي', 'ER', 'GP', 'طب طوارئ', 'ER-VISIT', 15);                hours(dr('ER'), '08:00', '20:00', 15, '1,2,3,4,5,6,7');
  dr('RAD') := doctor('د. ليلى الرشيد', 'RCT', 'RADIOLOGIST', 'أشعة تشخيصية', NULL, 20);
  say('الأطباء: 10 بساعات عمل صباحية ومسائية والطوارئ طوال الأسبوع');

  -- التأمين والجهات المتعاقدة
  l_ins1 := NOONA_HIS_PKG.save_payer('{"code":"DEMO-INS1","name":"شركة الرعاية المتحدة للتأمين","type":"INSURANCE","discount":10,"claim_days":60,'
            || '"contract":"UC-2026-118","from":"' || TO_CHAR(ADD_MONTHS(SYSDATE, -3), 'YYYY-MM-DD') || '","to":"' || TO_CHAR(ADD_MONTHS(SYSDATE, 9), 'YYYY-MM-DD')
            || '","phone":"920001234"}');
  pl('VIP') := NOONA_HIS_PKG.save_plan(NULL, l_ins1, 'VIP', 'كبار الشخصيات', 0, NULL, 5000);
  pl('A') := NOONA_HIS_PKG.save_plan(NULL, l_ins1, 'A', 'الفئة أ', 10, 75, 1500, 'DENTAL');
  pl('B') := NOONA_HIS_PKG.save_plan(NULL, l_ins1, 'B', 'الفئة ب', 20, 100, 800, 'DENTAL,PHYSIOTHERAPY');
  NOONA_HIS_PKG.set_payer_price(l_ins1, srv('CON-CS'), 250);
  NOONA_HIS_PKG.set_payer_price(l_ins1, srv('LAB-CBC'), 50);
  NOONA_HIS_PKG.set_payer_price(l_ins1, srv('MRI-KNEE'), 1350, 'Y', 'Y');
  l_ins2 := NOONA_HIS_PKG.save_payer('{"code":"DEMO-INS2","name":"الصحة الأولى للتأمين التعاوني","type":"INSURANCE","discount":15,"claim_days":45,'
            || '"contract":"SF-77","phone":"920005678"}');
  pl('S1') := NOONA_HIS_PKG.save_plan(NULL, l_ins2, 'GOLD', 'الذهبية', 10, 50, 1000);
  l_corp := NOONA_HIS_PKG.save_payer('{"code":"DEMO-CORP","name":"شركة الأفق للمقاولات - التأمين الطبي للموظفين","type":"CORPORATE","discount":5,"claim_days":30}');
  pl('CORP') := NOONA_HIS_PKG.save_plan(NULL, l_corp, 'STAFF', 'موظفو الشركة', 0, NULL, 2000, 'DENTAL');
  say('الجهات: شركتا تأمين بفئات VIP وأ وب والذهبية وأسعار عقود، وشركة متعاقدة لموظفيها');

  -- المرضى
  pt('P1') := patient('عبدالرحمن محمد السالم', 'M', '1978-03-12', 'SA', '1023456781', '0551200001', 'A', 'بنسلين', 'سكري النوع الثاني');
  pt('P2') := patient('منيرة سعد العنزي', 'F', '1990-07-22', 'SA', '1034567892', '0551200002', 'B');
  pt('P3') := patient('أحمد علي حسن', 'M', '1985-11-02', 'EG', '2345678903', '0551200003', 'S1');
  pt('P4') := patient('فاطمة يوسف الأحمد', 'F', '2016-01-15', 'SA', '1045678904', '0551200004', 'VIP');
  pt('P5') := patient('جون سميث', 'M', '1980-05-05', 'GB', '2456789015', '0551200005');
  pt('P6') := patient('ناصر فهد القرني', 'M', '1965-09-30', 'SA', '1056789016', '0551200006', NULL, NULL, 'ضغط مرتفع');
  pt('P7') := patient('ريتا فرنانديز', 'F', '1992-02-18', 'PH', '2567890127', '0551200007', 'CORP');
  pt('P8') := patient('سلمان عبدالله الحربي', 'M', '1999-12-01', 'SA', '1067890128', '0551200008', 'CORP');
  pt('P9') := patient('هيفاء خالد النمر', 'F', '1988-04-09', 'SA', '1078901239', '0551200009', 'A');
  pt('P10') := patient('محمد إقبال', 'M', '1975-08-25', 'PK', '2678901230', '0551200010');
  pt('P11') := patient('لمى ماجد العمري', 'F', '2019-06-11', 'SA', '1089012341', '0551200011', 'S1');
  pt('P12') := patient('إبراهيم صالح الدوسري', 'M', '1958-10-17', 'SA', '1090123452', '0551200012', 'VIP', 'أسبرين');
  pt('P13') := patient('سعاد عمر بخيت', 'F', '1983-03-03', 'SD', '2789012343', '0551200013', 'B');
  pt('P14') := patient('تركي سعود المالكي', 'M', '2001-07-07', 'SA', '1001234564', '0551200014');
  say('المرضى: 14 (مواطنون ومقيمون، مؤمنون ونقديون ومتعاقدون)');

  -- زيارات الأيام الخمسة السابقة (طلبات ونتائج وفواتير)
  past_visit('P1', 'IM1', 5, 9, 'LAB-FBS LAB-HBA1C LAB-LIPID', 'CASH', 'سكري النوع الثاني غير منتظم', 'E11.65');
  past_visit('P2', 'IM2', 5, 17, 'LAB-CBC LAB-TSH LAB-VITD', 'MADA', 'نقص فيتامين د', 'E55.9');
  past_visit('P3', 'IM1', 4, 10, 'XR-CHEST LAB-CBC', 'MADA', 'التهاب شعبي حاد', 'J20.9');
  past_visit('P4', 'PED', 4, 11, 'LAB-CBC LAB-UR', 'CASH', 'التهاب المسالك البولية', 'N39.0');
  past_visit('P5', 'ORTH', 4, 18, 'XR-LIMB', 'CARD', 'التواء الكاحل', 'S93.4');
  past_visit('P6', 'IM1', 3, 9, 'ECG ECHO LAB-LIPID', 'CASH', 'ارتفاع ضغط الدم الأساسي', 'I10');
  past_visit('P7', 'OBG', 3, 12, 'US-PREG LAB-CBC', 'CASH', 'متابعة حمل طبيعي', 'Z34.0');
  past_visit('P8', 'ORTH', 2, 17, 'MRI-KNEE', 'CASH', 'تمزق الغضروف الهلالي', 'S83.2');
  past_visit('P9', 'IM2', 2, 18, 'US-ABD LAB-LIPID', 'MADA', 'كبد دهني', 'K76.0');
  past_visit('P10', 'ER', 1, 21, 'PROC-SUT NURS-INJ', 'CASH', 'جرح قطعي في اليد', 'S61.4');
  past_visit('P12', 'IM1', 1, 10, 'ECG LAB-HBA1C', 'CASH', 'سكري ومتابعة قلب', 'E11.9');
  past_visit('P13', 'DERM', 1, 9, 'LAB-CBC', 'MADA', 'التهاب الجلد التماسي', 'L25.9');
  say('زيارات سابقة: 12 زيارة بطلبات ونتائج وفواتير وصرف مواد الأقسام');

  -- اليوم: زيارات مفتوحة وطلبات بانتظار الموافقة أو التنفيذ
  l_v := NOONA_HIS_PKG.open_visit('{"patient":' || pt('P11') || ',"doctor":' || dr('PED') || ',"complaint":"حرارة وسعال منذ يومين"}');
  l_x := NOONA_HIS_PKG.add_order(l_v, srv('LAB-CBC'));
  l_o := NOONA_HIS_PKG.add_order(l_v, srv('XR-CHEST'));
  l_inv := NOONA_HIS_PKG.create_invoice('{"visit":' || l_v || ',"method":"MADA","ref":"88123"}');
  l_lines := NOONA_HIS_PKG.collect_sample(l_x);
  l_v := NOONA_HIS_PKG.open_visit('{"patient":' || pt('P2') || ',"doctor":' || dr('ORTH') || ',"complaint":"ألم أسفل الظهر مزمن"}');
  l_o := NOONA_HIS_PKG.add_order(l_v, srv('MRI-SPINE'));        -- بانتظار موافقة التأمين
  l_o := NOONA_HIS_PKG.add_order(l_v, srv('PT-SES'), 6);         -- غير مغطاة للفئة ب
  l_v := NOONA_HIS_PKG.open_visit('{"patient":' || pt('P14') || ',"dept":' || dep('ER') || ',"doctor":' || dr('ER') || ',"type":"EMERGENCY",'
         || '"complaint":"ألم في البطن"}');
  l_o := NOONA_HIS_PKG.add_order(l_v, srv('US-ABD'));
  l_o := NOONA_HIS_PKG.add_order(l_v, srv('LAB-CBC'));
  NOONA_HIS_PKG.start_order(l_o);
  -- مواعيد اليوم والغد
  FOR a IN (SELECT 'P6' p, 'IM1' d, 0 dd, '10:20' t FROM dual UNION ALL SELECT 'P9', 'IM2', 0, '17:00' FROM dual
            UNION ALL SELECT 'P3', 'ENT', 0, '18:00' FROM dual UNION ALL SELECT 'P12', 'IM1', 1, '09:40' FROM dual
            UNION ALL SELECT 'P7', 'OBG', 1, '11:00' FROM dual UNION ALL SELECT 'P5', 'DENT', 1, '10:00' FROM dual
            UNION ALL SELECT 'P13', 'DERM', 2, '09:30' FROM dual UNION ALL SELECT 'P1', 'IM1', 3, '09:00' FROM dual) LOOP
    BEGIN
      l_x := NOONA_HIS_PKG.book('{"patient":' || pt(a.p) || ',"doctor":' || dr(a.d) || ',"date":"' || TO_CHAR(TRUNC(SYSDATE) + a.dd, 'YYYY-MM-DD')
             || '","time":"' || a.t || '","channel":"PHONE"}');
    EXCEPTION WHEN OTHERS THEN NULL;   -- يوم خارج دوام الطبيب (مثل الجمعة) لا يمنع بقية البيانات
    END;
  END LOOP;
  say('اليوم: ثلاث زيارات مفتوحة (عينة مسحوبة، رنين بانتظار الموافقة، طوارئ تحت التنفيذ) ومواعيد اليوم والأيام القادمة');

  -- تحصيل جزئي من شركة التأمين
  SELECT MIN(id) INTO l_x FROM csh_bank_account WHERE company_id = l_co AND status_code = 'ACTIVE';
  IF l_x IS NOT NULL AND NOONA_SAL_PKG.customer_balance(NOONA_HIS_PKG.payer_account(l_ins1)) > 500 THEN
    l_n := NOONA_SAL_PKG.receive('{"cust":' || NOONA_HIS_PKG.payer_account(l_ins1) || ',"amount":500,"method":"BANK_APP","place":"BANK:' || l_x
           || '","ref":"UC-PAY-001","notes":"دفعة من مطالبات شركة الرعاية المتحدة"}');
    say('تحصيل 500 من مطالبات شركة الرعاية المتحدة بتحويل بنكي');
  END IF;

  COMMIT;
  say('');
  say('تم تحميل بيانات المستشفى التجريبية. افتح «المستشفيات والمراكز الطبية».');
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  RAISE;
END;
/
EXIT
