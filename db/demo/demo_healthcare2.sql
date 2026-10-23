-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية للمرحلة الثانية من المستشفى (بعد التحديث 26 وبعد demo_healthcare.sql) - تشغل بحساب NOONA_APP
-- ولا تكرر (تكتشف الجهاز ذا الرمز DEMO-CT1):
--   sqlplus NOONA_APP@//host:1521/PDB @demo/demo_healthcare2.sql ADMIN
-- المحتوى:
--   * مكونات التحاليل بالمعدلات الطبيعية والحرجة، قوالب تقارير الأشعة والقلب بالإنجليزية، وأسرة الأجنحة
--   * أدوية الصيدلية الداخلية بأسماء إنجليزية وأرصدة، ووصفة مصروفة وأخرى بانتظار الصرف
--   * مريضان منومان (أحدهما بعملية مجدولة غداً)، خطة علاج طبيعي بجلسات، أجهزة طبية بسجل معايرة
--   * دفعة مطالبات لشركة الرعاية المتحدة مرسلة
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
  l_wh    NUMBER;
  l_rx    NUMBER;
  l_adm   NUMBER;
  l_dr    NUMBER;
  l_ins1  NUMBER;
  l_s     VARCHAR2(4000);
  TYPE t_map IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
  med     t_map;

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
  FUNCTION pat(p_id_no VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM his_patient WHERE company_id = l_co AND id_no = p_id_no; RETURN l;
  END pat;
  FUNCTION doc(p_name VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM his_doctor WHERE company_id = l_co AND name_ar = p_name; RETURN l;
  END doc;
  -- دواء بسعر بيع شامل الضريبة ورصيد في مستودع الصيدلية
  PROCEDURE medicine(p_key VARCHAR2, p_ar VARCHAR2, p_en VARCHAR2, p_price NUMBER, p_qty NUMBER, p_cost NUMBER) IS
  BEGIN
    med(p_key) := NOONA_INV_PKG.save_item('{"name":"' || p_ar || '","nameEn":"' || p_en || '","type":"STOCK","price":' || p_price
                  || ',"incl":"Y","sell":"Y"}');
    l_x := NOONA_INV_PKG.save_stock_doc('{"type":"OPENING","date":"' || TO_CHAR(SYSDATE - 10, 'YYYY-MM-DD') || '","wh":' || l_wh
           || ',"action":"POST","desc":"رصيد افتتاحي ' || p_ar || '","lines":[{"i":' || med(p_key) || ',"q":' || p_qty || ',"c":' || p_cost || '}]}');
  END medicine;
BEGIN
  NOONA_APEX_PKG.post_auth(c_admin, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  SELECT COUNT(*) INTO l_n FROM his_payer WHERE company_id = l_co AND code = 'DEMO-INS1';
  IF l_n = 0 THEN
    say('شغل demo_healthcare.sql أولاً.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;
  SELECT COUNT(*) INTO l_n FROM his_device WHERE company_id = l_co AND code = 'DEMO-CT1';
  IF l_n > 0 THEN
    say('بيانات المرحلة الثانية محملة سابقاً لهذه الشركة؛ لم يضف شيء.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;
  SELECT id INTO l_ins1 FROM his_payer WHERE company_id = l_co AND code = 'DEMO-INS1';

  l_n := NOONA_HIS_CARE_PKG.seed_defaults;
  say('مكونات التحاليل وقوالب التقارير والأسرة: ' || l_n);

  -- الصيدلية الداخلية
  SELECT warehouse_id INTO l_wh FROM his_department WHERE id = NOONA_HIS_CARE_PKG.default_pharmacy;
  medicine('PARA', 'باراسيتامول 500 ملغ أقراص', 'Paracetamol 500 mg Tablet', 8.05, 400, 3);
  medicine('AMOX', 'أموكسيسيلين 500 ملغ كبسول', 'Amoxicillin 500 mg Capsule', 23, 200, 9);
  medicine('IBU', 'إيبوبروفين 400 ملغ أقراص', 'Ibuprofen 400 mg Tablet', 11.5, 300, 4);
  medicine('OMEP', 'أوميبرازول 20 ملغ كبسول', 'Omeprazole 20 mg Capsule', 17.25, 150, 6);
  medicine('MET', 'ميتفورمين 500 ملغ أقراص', 'Metformin 500 mg Tablet', 9.2, 300, 3.5);
  medicine('CEF', 'سيفترياكسون 1 جم حقن', 'Ceftriaxone 1 g Injection', 34.5, 120, 14);
  medicine('NS', 'محلول ملحي 0.9% 500 مل', 'Normal Saline 0.9% 500 mL', 11.5, 250, 4);
  say('الصيدلية: 7 أدوية بأسماء إنجليزية وأرصدة في مستودع الصيدلية');

  -- وصفة لمريض سكري: فوترة وتحصيل ثم صرف
  l_v := NOONA_HIS_PKG.open_visit('{"patient":' || pat('1023456781') || ',"dept":' || dep('IM') || ',"doctor":' || doc('د. خالد العتيبي')
         || ',"complaint":"Follow-up of type 2 diabetes, polyuria"}');
  NOONA_HIS_PKG.update_visit('{"id":' || l_v || ',"vitals":"BP 130/84, T 36.8, HR 82, SpO2 98%, Wt 92 kg","complaint":"Follow-up of type 2 diabetes, polyuria",'
         || '"diagnosis":"Type 2 diabetes mellitus without complications","icd10":"E11.9","notes":"Continue metformin, diet counselling, HbA1c in 3 months"}');
  l_rx := NOONA_HIS_CARE_PKG.prescribe('{"visit":' || l_v || ',"lines":[{"i":' || med('MET') || ',"q":60,"dose":"500 mg","freq":"BID","days":30,'
          || '"instr":"With meals"},{"i":' || med('OMEP') || ',"q":14,"dose":"20 mg","freq":"OD","days":14,"instr":"Before breakfast"}]}');
  NOONA_HIS_CARE_PKG.bill_prescription(l_rx);
  l_x := NOONA_HIS_PKG.create_invoice('{"visit":' || l_v || ',"method":"CASH"}');
  NOONA_HIS_CARE_PKG.deliver_prescription(l_rx);
  -- وصفة بانتظار الفوترة والصرف
  l_v := NOONA_HIS_PKG.open_visit('{"patient":' || pat('2456789015') || ',"dept":' || dep('ENT') || ',"doctor":' || doc('د. عمر الزهراني')
         || ',"complaint":"Sore throat and fever for 3 days"}');
  NOONA_HIS_PKG.update_visit('{"id":' || l_v || ',"vitals":"BP 118/76, T 38.4, HR 96","diagnosis":"Acute tonsillitis","icd10":"J03.9",'
         || '"notes":"Oral antibiotics and antipyretics, review in 1 week"}');
  l_rx := NOONA_HIS_CARE_PKG.prescribe('{"visit":' || l_v || ',"lines":[{"i":' || med('AMOX') || ',"q":21,"dose":"500 mg","freq":"TID","days":7},'
          || '{"i":' || med('PARA') || ',"q":20,"dose":"1 g","freq":"QID PRN","days":5,"instr":"For fever"}]}');
  say('وصفتان: مصروفة ومسددة، وأخرى بانتظار الصيدلية');

  -- التنويم: مريضان منومان منذ يومين، أحدهما بعملية مجدولة غداً
  SELECT MIN(id) INTO l_x FROM his_bed WHERE company_id = l_co AND status_code = 'AVAILABLE';
  l_adm := NOONA_HIS_CARE_PKG.admit('{"patient":' || pat('1056789016') || ',"bed":' || l_x || ',"doctor":' || doc('د. خالد العتيبي')
           || ',"reason":"Community-acquired pneumonia, hypoxia"}');
  UPDATE his_admission SET admit_at = SYSTIMESTAMP - INTERVAL '2' DAY WHERE id = l_adm;
  SELECT visit_id INTO l_v FROM his_admission WHERE id = l_adm;
  NOONA_HIS_PKG.update_visit('{"id":' || l_v || ',"vitals":"BP 135/85, T 38.9, HR 104, RR 24, SpO2 91%","diagnosis":"Community-acquired pneumonia",'
         || '"icd10":"J18.9","notes":"IV ceftriaxone, oxygen therapy, chest X-ray"}');
  l_o := NOONA_HIS_PKG.add_order(l_v, srv('XR-CHEST'));
  NOONA_HIS_PKG.complete_order(l_o, 'Findings: Right lower lobe consolidation with air bronchograms. No pleural effusion.' || CHR(10)
       || 'Impression: Right lower lobe pneumonia.', 'ABNORMAL');
  l_rx := NOONA_HIS_CARE_PKG.prescribe('{"visit":' || l_v || ',"lines":[{"i":' || med('CEF') || ',"q":5,"dose":"1 g","freq":"OD IV","days":5},'
          || '{"i":' || med('NS') || ',"q":6,"dose":"500 mL","freq":"BID IV","days":3}]}');
  NOONA_HIS_CARE_PKG.bill_prescription(l_rx);
  NOONA_HIS_CARE_PKG.deliver_prescription(l_rx);

  SELECT MIN(id) INTO l_x FROM his_bed WHERE company_id = l_co AND status_code = 'AVAILABLE';
  l_dr := doc('د. ماجد الحربي');
  l_adm := NOONA_HIS_CARE_PKG.admit('{"patient":' || pat('1067890128') || ',"bed":' || l_x || ',"doctor":' || l_dr
           || ',"approval":"UC-ADM-2201","reason":"Acute appendicitis for laparoscopic appendectomy"}');
  UPDATE his_admission SET admit_at = SYSTIMESTAMP - INTERVAL '1' DAY WHERE id = l_adm;
  SELECT visit_id INTO l_v FROM his_admission WHERE id = l_adm;
  NOONA_HIS_PKG.update_visit('{"id":' || l_v || ',"diagnosis":"Acute appendicitis","icd10":"K35.80"}');
  l_n := NOONA_HIS_CARE_PKG.schedule_surgery('{"visit":' || l_v || ',"service":' || srv('SURG-APP') || ',"theater":"OR1","surgeon":' || l_dr
         || ',"anesthetist":' || NVL(TO_CHAR(doc('د. ليلى الرشيد')), 'null') || ',"anesthesia":"SPINAL","start":"'
         || TO_CHAR(SYSDATE + 1, 'YYYY-MM-DD') || ' 09:00","duration":120}');
  l_n := NOONA_HIS_CARE_PKG.charge_beds;
  say('التنويم: مريضان (التهاب رئوي، واستئصال زائدة بالمنظار مجدولة غداً)، وأيام السرير مرحلة: ' || l_n);

  -- العلاج الطبيعي: خطة 6 جلسات مسددة، نفذت منها جلستان
  l_v := NOONA_HIS_PKG.open_visit('{"patient":' || pat('2345678903') || ',"dept":' || dep('PT') || ',"complaint":"Low back pain"}');
  l_x := NOONA_HIS_CARE_PKG.create_plan('{"visit":' || l_v || ',"service":' || srv('PT-SES') || ',"sessions":6,"frequency":"3/week",'
         || '"goals":"Reduce pain, improve lumbar flexibility and core strength"}');
  l_n := NOONA_HIS_PKG.create_invoice('{"visit":' || l_v || ',"method":"MADA"}');
  l_n := NOONA_HIS_CARE_PKG.record_session(l_x, NULL, 'Hot packs, TENS, McKenzie exercises. Pain 7/10.');
  l_n := NOONA_HIS_CARE_PKG.record_session(l_x, NULL, 'Core stabilisation. Pain 5/10.');
  say('العلاج الطبيعي: خطة 6 جلسات نفذت منها جلستان');

  -- الأجهزة الطبية
  l_x := NOONA_HIS_CARE_PKG.save_device('{"code":"DEMO-CT1","name":"CT Scanner 128-slice","dept":' || dep('RCT') || ',"modality":"CT",'
         || '"manufacturer":"Siemens","model":"SOMATOM go.Top","serial":"CT-778812","installed":"' || TO_CHAR(ADD_MONTHS(SYSDATE, -14), 'YYYY-MM-DD')
         || '","warranty":"' || TO_CHAR(ADD_MONTHS(SYSDATE, 10), 'YYYY-MM-DD') || '","cal_days":180}');
  NOONA_HIS_CARE_PKG.log_device(l_x, 'CALIBRATION', TRUNC(SYSDATE) - 170, 'Siemens Healthineers', 4500, 'Semi-annual calibration and QA phantom');
  l_x := NOONA_HIS_CARE_PKG.save_device('{"code":"DEMO-MRI1","name":"MRI 1.5T","dept":' || dep('RMRI') || ',"modality":"MRI",'
         || '"manufacturer":"GE","model":"SIGNA Explorer","serial":"MR-55120","installed":"' || TO_CHAR(ADD_MONTHS(SYSDATE, -30), 'YYYY-MM-DD')
         || '","cal_days":365}');
  NOONA_HIS_CARE_PKG.log_device(l_x, 'PREVENTIVE', TRUNC(SYSDATE) - 40, 'GE Healthcare', 6000, 'Annual PM, helium level 92%');
  NOONA_HIS_CARE_PKG.log_device(l_x, 'CALIBRATION', TRUNC(SYSDATE) - 40, 'GE Healthcare', 0, 'Coil calibration');
  l_x := NOONA_HIS_CARE_PKG.save_device('{"code":"DEMO-US1","name":"Ultrasound Logiq P9","dept":' || dep('RUS') || ',"modality":"ULTRASOUND",'
         || '"manufacturer":"GE","serial":"US-90211","installed":"' || TO_CHAR(ADD_MONTHS(SYSDATE, -8), 'YYYY-MM-DD') || '","cal_days":365}');
  l_x := NOONA_HIS_CARE_PKG.save_device('{"code":"DEMO-HEM1","name":"Hematology Analyzer XN-550","dept":' || dep('LHEM')
         || ',"manufacturer":"Sysmex","serial":"XN-31004","installed":"' || TO_CHAR(ADD_MONTHS(SYSDATE, -6), 'YYYY-MM-DD') || '","cal_days":90}');
  NOONA_HIS_CARE_PKG.log_device(l_x, 'BREAKDOWN', TRUNC(SYSDATE), NULL, NULL, 'Aspiration probe error');
  say('الأجهزة: 4 بسجل معايرة وصيانة (أحدها خارج الخدمة، وآخر معايرته مستحقة قريباً)');

  -- دفعة مطالبات شركة الرعاية المتحدة
  BEGIN
    l_x := NOONA_HIS_CLAIM_PKG.create_batch(l_ins1, TRUNC(SYSDATE) - 7, TRUNC(SYSDATE));
    NOONA_HIS_CLAIM_PKG.submit_batch(l_x, 'UC-SUB-' || TO_CHAR(SYSDATE, 'YYMMDD'));
    say('دفعة مطالبات مرسلة لشركة الرعاية المتحدة');
  EXCEPTION WHEN OTHERS THEN
    say('لا توجد فواتير لمطالبة الشركة: ' || SQLERRM);
  END;

  COMMIT;
  say('');
  say('تم تحميل بيانات المرحلة الثانية للمستشفى.');
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  RAISE;
END;
/
EXIT
