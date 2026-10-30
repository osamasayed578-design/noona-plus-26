-- =============================================================================
-- NOONA PLUS ERP | اختبار المستشفى - المرحلة الثانية: المعامل التفصيلية، القوالب، الصيدلية، التنويم، العمليات، العلاج الطبيعي،
--                  الأجهزة، المطالبات (بحساب NOONA_APP - يتراجع عن كل التغييرات)
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_healthcare2.sql
-- =============================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/

DECLARE
  g_pass PLS_INTEGER := 0;
  g_fail PLS_INTEGER := 0;
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'MISSFF3');
  l_n    NUMBER;
  l_x    NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_pf   NUMBER;
  l_pm   NUMBER;
  l_pi   NUMBER;
  l_v    NUMBER;
  l_v2   NUMBER;
  l_o    NUMBER;
  l_inv  NUMBER;
  l_med  NUMBER;
  l_rx   NUMBER;
  l_wh   NUMBER;
  l_adm  NUMBER;
  l_b1   NUMBER;
  l_b2   NUMBER;
  l_sg   NUMBER;
  l_pl   NUMBER;
  l_dev  NUMBER;
  l_pay  NUMBER;
  l_plan NUMBER;
  l_bt   NUMBER;
  l_inv2 NUMBER;
  l_j    NUMBER;
  l_dr   NUMBER;

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION srv(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM his_service WHERE code = p_code AND company_id = NOONA_HIS_PKG.company; RETURN l;
  END srv;
  FUNCTION dep(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM his_department WHERE code = p_code AND company_id = NOONA_HIS_PKG.company; RETURN l;
  END dep;
  FUNCTION ost(p_o NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT status_code INTO l FROM his_order WHERE id = p_o; RETURN l;
  END ost;
  FUNCTION pid(p_json CLOB, p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(p) INTO l FROM JSON_TABLE(p_json, '$[*]' COLUMNS (p NUMBER PATH '$.p', code VARCHAR2(30) PATH '$.code')) WHERE code = p_code;
    RETURN l;
  END pid;
  FUNCTION jl(p_j NUMBER, p_code VARCHAR2, p_side VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(CASE p_side WHEN 'D' THEN l.debit_amount ELSE l.credit_amount END), 0) INTO l
      FROM gl_journal_line l JOIN gl_account a ON a.id = l.account_id WHERE l.journal_id = p_j AND a.account_code = p_code;
    RETURN l;
  END jl;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_n := NOONA_HIS_PKG.seed_catalog;
  l_n := NOONA_HIS_CARE_PKG.seed_defaults;
  SELECT COUNT(*) INTO l_n FROM his_lab_param WHERE company_id = NOONA_HIS_PKG.company;
  ok('lab parameters seeded', l_n >= 24, l_n);
  SELECT COUNT(*) INTO l_n FROM his_report_template WHERE company_id = NOONA_HIS_PKG.company AND code LIKE 'TPL-%';
  ok('radiology templates seeded', l_n >= 6, l_n);
  SELECT COUNT(*) INTO l_n FROM his_bed WHERE company_id = NOONA_HIS_PKG.company;
  ok('ward beds available', l_n >= 8, l_n);
  ok('clinical names in English', NOONA_HIS_PKG.service_name(srv('LAB-CBC')) = 'Complete Blood Count (CBC)'
     AND NOONA_HIS_PKG.service_name(srv('US-ABD')) = 'Ultrasound Abdomen' AND NOONA_HIS_PKG.service_name(srv('CON-SP')) = 'كشف أخصائي',
     NOONA_HIS_PKG.service_name(srv('LAB-CBC')));

  -- ======================================================== المعامل: معدلات حسب الجنس والتقييم الآلي
  l_pf := NOONA_HIS_PKG.save_patient('{"name":"مريضة اختبار ' || l_sfx || '","name_en":"Test Patient ' || l_sfx || '","gender":"F","birth":"1994-01-01",'
          || '"nationality":"SA","id_no":"3' || l_sfx || '"}');
  l_v := NOONA_HIS_PKG.open_visit('{"patient":' || l_pf || ',"dept":' || dep('LHEM') || '}');
  l_o := NOONA_HIS_PKG.add_order(l_v, srv('LAB-CBC'));
  l_inv := NOONA_HIS_PKG.create_invoice('{"visit":' || l_v || ',"method":"CASH"}');
  l_c := NOONA_HIS_CARE_PKG.lab_params_json(l_o);
  ok('female ranges selected for HB', INSTR(l_c, '"code":"HB"') > 0 AND INSTR(l_c, '"low":12') > 0 AND INSTR(l_c, '"low":13.5') = 0, DBMS_LOB.SUBSTR(l_c, 300, 1));
  ok('parameter names in English', INSTR(l_c, 'Hemoglobin') > 0);
  BEGIN NOONA_HIS_CARE_PKG.save_lab_results(l_o, '[{"p":-1,"v":1}]'); ok('foreign parameter rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('foreign parameter rejected', 'NOONA-HIS-102', SQLERRM); END;
  NOONA_HIS_CARE_PKG.save_lab_results(l_o, '[{"p":' || pid(l_c, 'HB') || ',"v":6.5},{"p":' || pid(l_c, 'WBC') || ',"v":12.4},{"p":' || pid(l_c, 'PLT')
                                      || ',"v":250}]', 'N');
  SELECT COUNT(*) INTO l_n FROM his_lab_result WHERE order_id = l_o;
  ok('results saved without completing', l_n = 3 AND ost(l_o) = 'IN_PROGRESS', l_n || ' ' || ost(l_o));
  SELECT LISTAGG(p.code || '=' || r.flag, ',') WITHIN GROUP (ORDER BY p.code) INTO l_s FROM his_lab_result r JOIN his_lab_param p ON p.id = r.param_id
   WHERE r.order_id = l_o;
  ok('automatic flags (critical low Hb, high WBC, normal PLT)', l_s = 'HB=LL,PLT=N,WBC=H', l_s);
  NOONA_HIS_CARE_PKG.save_lab_results(l_o, '[]', 'Y', NULL, 'Repeat sample recommended');
  SELECT result_flag INTO l_s FROM his_order WHERE id = l_o;
  ok('completed as critical', ost(l_o) = 'COMPLETED' AND l_s = 'CRITICAL', l_s);
  l_c := NOONA_HIS_PKG.result_html(l_o);
  ok('English lab report', INSTR(l_c, 'Laboratory Report') > 0 AND INSTR(l_c, 'Hemoglobin') > 0 AND INSTR(l_c, 'LL (critical)') > 0
     AND INSTR(l_c, 'dir="ltr"') > 0 AND INSTR(l_c, 'Test Patient') > 0);
  -- قالب التقرير
  l_o := NOONA_HIS_PKG.add_order(l_v, srv('XR-CHEST'));
  ok('X-ray template by modality', NOONA_HIS_CARE_PKG.template_for(l_o) IS NOT NULL);
  -- قالب خاص بالخدمة يتقدم على قوالب نوع الفحص مهما تعددت
  INSERT INTO his_report_template (company_id, code, name_ar, modality, service_id, body, is_active)
  SELECT o.company_id, 'TT' || l_sfx, 'قالب خدمة', s.modality, o.service_id, 'Service specific findings', 'Y'
    FROM his_order o JOIN his_service s ON s.id = o.service_id WHERE o.id = l_o;
  ok('service template wins over modality templates', NOONA_HIS_CARE_PKG.template_for(l_o) = 'Service specific findings');
  NOONA_HIS_PKG.cancel_order(l_o, 'test');

  -- ======================================================== الصيدلية الداخلية
  l_med := NOONA_INV_PKG.save_item('{"name":"باراسيتامول 500 اختبار ' || l_sfx || '","nameEn":"Paracetamol 500mg Tab ' || l_sfx || '","type":"STOCK",'
           || '"price":11.5,"incl":"Y","sell":"Y"}');
  SELECT warehouse_id INTO l_wh FROM his_department WHERE id = NOONA_HIS_CARE_PKG.default_pharmacy;
  l_n := NOONA_INV_PKG.save_stock_doc('{"type":"OPENING","date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '","wh":' || l_wh || ',"action":"POST",'
         || '"lines":[{"i":' || l_med || ',"q":100,"c":4}]}');
  l_v2 := NOONA_HIS_PKG.open_visit('{"patient":' || l_pf || ',"dept":' || dep('IM') || '}');
  l_rx := NOONA_HIS_CARE_PKG.prescribe('{"visit":' || l_v2 || ',"lines":[{"i":' || l_med || ',"q":10,"dose":"500 mg","freq":"TID","days":3,'
          || '"instr":"After meals"}]}');
  ok('prescription created', l_rx IS NOT NULL);
  SELECT COUNT(*) INTO l_n FROM his_service WHERE item_id = l_med AND service_type = 'MEDICATION' AND name_en LIKE 'Paracetamol%' AND price = 10;
  ok('medicine billable service in English at net price', l_n = 1);
  NOONA_HIS_CARE_PKG.bill_prescription(l_rx);
  SELECT order_id INTO l_o FROM his_prescription_line WHERE prescription_id = l_rx;
  ok('medicine order 10 x 10 + VAT 0 for citizen', ost(l_o) = 'ORDERED' AND NOONA_HIS_PKG.unbilled_total(l_v2, 'PATIENT') = 100,
     NOONA_HIS_PKG.unbilled_total(l_v2, 'PATIENT'));
  BEGIN NOONA_HIS_CARE_PKG.deliver_prescription(l_rx); ok('unpaid medicine not delivered', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('unpaid medicine not delivered', 'NOONA-HIS-066', SQLERRM); END;
  l_inv := NOONA_HIS_PKG.create_invoice('{"visit":' || l_v2 || ',"method":"CASH"}');
  NOONA_HIS_CARE_PKG.deliver_prescription(l_rx);
  SELECT status_code INTO l_s FROM his_prescription WHERE id = l_rx;
  ok('delivered from the pharmacy store', l_s = 'DISPENSED' AND NOONA_INV_PKG.on_hand(l_med, l_wh) = 90, l_s || ' ' || NOONA_INV_PKG.on_hand(l_med, l_wh));
  SELECT material_cost INTO l_n FROM his_order WHERE id = l_o;
  ok('medicine cost on the order', l_n = 40, l_n);

  -- ======================================================== التنويم
  SELECT MIN(id), MAX(id) INTO l_b1, l_b2 FROM (SELECT id FROM his_bed WHERE company_id = NOONA_HIS_PKG.company AND status_code = 'AVAILABLE'
                                                 ORDER BY bed_no) WHERE ROWNUM <= 2;
  l_pm := NOONA_HIS_PKG.save_patient('{"name":"مريض تنويم ' || l_sfx || '","gender":"M","nationality":"EG","id_no":"4' || l_sfx || '"}');
  l_adm := NOONA_HIS_CARE_PKG.admit('{"patient":' || l_pm || ',"bed":' || l_b1 || ',"reason":"Pneumonia"}');
  SELECT status_code INTO l_s FROM his_bed WHERE id = l_b1;
  ok('admitted and bed occupied', l_adm IS NOT NULL AND l_s = 'OCCUPIED');
  BEGIN l_n := NOONA_HIS_CARE_PKG.admit('{"patient":' || l_pf || ',"bed":' || l_b1 || '}'); ok('occupied bed refused', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('occupied bed refused', 'NOONA-HIS-123', SQLERRM); END;
  SELECT visit_id INTO l_v FROM his_admission WHERE id = l_adm;
  UPDATE his_admission SET admit_at = SYSTIMESTAMP - INTERVAL '3' DAY, charged_to = TRUNC(SYSDATE) - 4 WHERE id = l_adm;
  l_n := NOONA_HIS_CARE_PKG.charge_beds(TRUNC(SYSDATE), l_adm);
  ok('bed days charged up to today', l_n = 4, l_n);
  ok('second run charges nothing', NOONA_HIS_CARE_PKG.charge_beds(TRUNC(SYSDATE), l_adm) = 0);
  l_x := srv('BED-DAY');
  SELECT SUM(quantity), MAX(vat_rate) INTO l_n, l_x FROM his_order WHERE visit_id = l_v AND service_id = l_x;
  ok('bed-day order with VAT for non-citizen', l_n = 4 AND l_x = 15, l_n || ' ' || l_x);
  NOONA_HIS_CARE_PKG.transfer_bed(l_adm, l_b2, 'Isolation not needed');
  SELECT status_code INTO l_s FROM his_bed WHERE id = l_b1;
  ok('transfer frees the old bed for cleaning', l_s = 'CLEANING');
  BEGIN NOONA_HIS_CARE_PKG.discharge(l_adm, 'HOME', NULL); ok('discharge summary required', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('discharge summary required', 'NOONA-HIS-129', SQLERRM); END;

  -- ======================================================== العمليات (للمنوم: تنفذ ثم تفوتر)
  -- جراح وغرفة خاصة بالاختبار حتى لا تتعارض مع عمليات البيانات التجريبية
  l_dr := NOONA_HIS_PKG.save_doctor('{"name":"د. جراح اختبار ' || l_sfx || '","dept":' || dep('OR') || ',"title":"SURGEON"}');
  l_sg := NOONA_HIS_CARE_PKG.schedule_surgery('{"visit":' || l_v || ',"service":' || srv('SURG-MIN') || ',"theater":"T' || l_sfx || '","surgeon":' || l_dr
          || ',"anesthesia":"LOCAL","start":"' || TO_CHAR(SYSDATE + 1, 'YYYY-MM-DD') || ' 10:00","duration":60}');
  BEGIN l_n := NOONA_HIS_CARE_PKG.schedule_surgery('{"visit":' || l_v || ',"service":' || srv('PROC-SUT') || ',"theater":"T' || l_sfx || '","surgeon":' || l_dr
          || ',"start":"' || TO_CHAR(SYSDATE + 1, 'YYYY-MM-DD') || ' 10:30","duration":30}'); ok('theater conflict refused', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('theater conflict refused', 'NOONA-HIS-133', SQLERRM); END;
  ok('OR board shows the surgery', INSTR(NOONA_HIS_CARE_PKG.or_board_html(SYSDATE + 1), 'Minor Surgery') > 0);
  NOONA_HIS_CARE_PKG.start_surgery(l_sg);
  BEGIN NOONA_HIS_CARE_PKG.finish_surgery(l_sg, NULL); ok('operative notes required', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('operative notes required', 'NOONA-HIS-136', SQLERRM); END;
  NOONA_HIS_CARE_PKG.finish_surgery(l_sg, 'Excision of sebaceous cyst under local anesthesia. No complications.');
  SELECT s.status_code || '/' || o.status_code INTO l_s FROM his_surgery s JOIN his_order o ON o.id = s.order_id WHERE s.id = l_sg;
  ok('surgery done and order completed', l_s = 'DONE/COMPLETED', l_s);
  NOONA_HIS_CARE_PKG.discharge(l_adm, 'HOME', 'Improved. Discharged on oral antibiotics.');
  SELECT a.status_code || '/' || b.status_code INTO l_s FROM his_admission a JOIN his_bed b ON b.id = l_b2 WHERE a.id = l_adm;
  ok('discharged, bed to cleaning', l_s = 'DISCHARGED/CLEANING', l_s);
  NOONA_HIS_CARE_PKG.set_bed_status(l_b2, 'AVAILABLE');
  ok('bed board renders', INSTR(NOONA_HIS_CARE_PKG.bed_board_html, 'nn-his-bed') > 0);
  l_inv := NOONA_HIS_PKG.create_invoice('{"visit":' || l_v || ',"method":"CASH"}');
  ok('inpatient bill after discharge', l_inv IS NOT NULL AND NOONA_HIS_PKG.unbilled_total(l_v, 'PATIENT') = 0);

  -- ======================================================== العلاج الطبيعي
  l_v2 := NOONA_HIS_PKG.open_visit('{"patient":' || l_pf || ',"dept":' || dep('PT') || '}');
  l_pl := NOONA_HIS_CARE_PKG.create_plan('{"visit":' || l_v2 || ',"service":' || srv('PT-SES') || ',"sessions":3,"frequency":"3/week",'
          || '"goals":"Improve knee range of motion"}');
  BEGIN l_n := NOONA_HIS_CARE_PKG.record_session(l_pl, NULL, 'x'); ok('unpaid plan session refused', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('unpaid plan session refused', 'NOONA-HIS-066', SQLERRM); END;
  l_inv := NOONA_HIS_PKG.create_invoice('{"visit":' || l_v2 || ',"method":"MADA"}');
  SELECT patient_total INTO l_n FROM his_invoice WHERE id = l_inv;
  ok('plan billed for all sessions', l_n = 540, l_n);
  l_n := NOONA_HIS_CARE_PKG.record_session(l_pl, NULL, 'ROM 90 deg');
  l_n := NOONA_HIS_CARE_PKG.record_session(l_pl, NULL, 'ROM 105 deg');
  SELECT status_code INTO l_s FROM his_therapy_plan WHERE id = l_pl;
  ok('plan in progress after 2 sessions', l_s = 'ACTIVE', l_s);
  l_n := NOONA_HIS_CARE_PKG.record_session(l_pl, NULL, 'ROM 120 deg, discharged from therapy');
  SELECT p.status_code || '/' || o.status_code INTO l_s FROM his_therapy_plan p JOIN his_order o ON o.id = p.order_id WHERE p.id = l_pl;
  ok('plan completed with the last session', l_s = 'COMPLETED/COMPLETED', l_s);

  -- ======================================================== الأجهزة
  l_dev := NOONA_HIS_CARE_PKG.save_device('{"code":"DV' || l_sfx || '","name":"CT Scanner","dept":' || dep('RCT') || ',"modality":"CT",'
           || '"manufacturer":"GE","serial":"SN-' || l_sfx || '","installed":"' || TO_CHAR(SYSDATE - 100, 'YYYY-MM-DD') || '","cal_days":180}');
  SELECT next_calibration INTO l_x FROM (SELECT next_calibration - TRUNC(SYSDATE) next_calibration FROM his_device WHERE id = l_dev);
  ok('next calibration from installation', l_x = 80, l_x);
  NOONA_HIS_CARE_PKG.log_device(l_dev, 'BREAKDOWN', SYSDATE, NULL, NULL, 'Tube failure');
  SELECT status_code INTO l_s FROM his_device WHERE id = l_dev;
  ok('breakdown takes the device out of service', l_s = 'OUT_OF_SERVICE');
  NOONA_HIS_CARE_PKG.log_device(l_dev, 'CALIBRATION', SYSDATE, 'GE Service', 3500, 'Annual calibration');
  SELECT status_code || '/' || TO_CHAR(next_calibration - TRUNC(SYSDATE)) INTO l_s FROM his_device WHERE id = l_dev;
  NOONA_HIS_CARE_PKG.log_device(l_dev, 'RETURN_TO_SERVICE', SYSDATE, NULL, NULL, NULL);
  SELECT l_s || '/' || status_code INTO l_s FROM his_device WHERE id = l_dev;
  ok('calibration resets the due date; back in service', l_s = 'OUT_OF_SERVICE/180/IN_SERVICE', l_s);

  -- ======================================================== المطالبات
  l_pay := NOONA_HIS_PKG.save_payer('{"code":"CI' || l_sfx || '","name":"تأمين مطالبات ' || l_sfx || '","type":"INSURANCE","contract":"C-' || l_sfx || '"}');
  l_plan := NOONA_HIS_PKG.save_plan(NULL, l_pay, 'A', 'أ', 0);
  l_pi := NOONA_HIS_PKG.save_patient('{"name":"مؤمن مطالبات ' || l_sfx || '","gender":"M","nationality":"SA","id_no":"5' || l_sfx || '","plan":' || l_plan
          || ',"member":"MB-' || l_sfx || '"}');
  l_v := NOONA_HIS_PKG.open_visit('{"patient":' || l_pi || ',"dept":' || dep('RUS') || '}');
  l_o := NOONA_HIS_PKG.add_order(l_v, srv('US-ABD'));
  NOONA_HIS_PKG.update_visit('{"id":' || l_v || ',"diagnosis":"Abdominal pain","icd10":"R10.4"}');
  l_inv := NOONA_HIS_PKG.create_invoice('{"visit":' || l_v || '}');
  l_v2 := NOONA_HIS_PKG.open_visit('{"patient":' || l_pi || ',"dept":' || dep('LCHEM') || '}');
  l_o := NOONA_HIS_PKG.add_order(l_v2, srv('LAB-LIPID'));
  l_inv2 := NOONA_HIS_PKG.create_invoice('{"visit":' || l_v2 || '}');
  l_bt := NOONA_HIS_CLAIM_PKG.create_batch(l_pay, TRUNC(SYSDATE), TRUNC(SYSDATE));
  SELECT claimed_amount, status_code INTO l_n, l_s FROM his_claim_batch WHERE id = l_bt;
  ok('claim batch with two invoices', l_n = 420 AND l_s = 'DRAFT', l_n || ' ' || l_s);
  BEGIN l_x := NOONA_HIS_CLAIM_PKG.create_batch(l_pay, TRUNC(SYSDATE), TRUNC(SYSDATE)); ok('invoices not claimed twice', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('invoices not claimed twice', 'NOONA-HIS-162', SQLERRM); END;
  l_c := NOONA_HIS_CLAIM_PKG.batch_json(l_bt);
  ok('e-claim JSON with member, ICD-10 and English items', JSON_VALUE(l_c, '$.total') = '420' AND INSTR(l_c, '"member":"MB-' || l_sfx) > 0
     AND INSTR(l_c, '"icd10":"R10.4"') > 0 AND INSTR(l_c, 'Ultrasound Abdomen') > 0, DBMS_LOB.SUBSTR(l_c, 200, 1));
  BEGIN NOONA_HIS_CLAIM_PKG.record_response(l_bt, NULL); ok('response needs submission', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('response needs submission', 'NOONA-HIS-164', SQLERRM); END;
  NOONA_HIS_CLAIM_PKG.submit_batch(l_bt, 'SUB-' || l_sfx);
  SELECT claim_status INTO l_s FROM his_invoice WHERE id = l_inv;
  ok('invoices marked submitted', l_s = 'SUBMITTED');
  BEGIN NOONA_HIS_CLAIM_PKG.record_response(l_bt, '[{"inv":' || l_inv2 || ',"approved":60}]'); ok('rejection reason required', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('rejection reason required', 'NOONA-HIS-166', SQLERRM); END;
  NOONA_HIS_CLAIM_PKG.record_response(l_bt, '[{"inv":' || l_inv2 || ',"approved":60,"reason":"Not medically justified"}]');
  SELECT approved_amount || '/' || rejected_amount || '/' || status_code INTO l_s FROM his_claim_batch WHERE id = l_bt;
  ok('partial approval recorded', l_s = '360/60/PARTIAL', l_s);
  SELECT j.id INTO l_j FROM gl_journal j JOIN his_claim_batch b ON b.accounting_event_id = j.accounting_event_id WHERE b.id = l_bt;
  ok('rejection journal Dr 4129 Cr 1114', jl(l_j, '4129', 'D') = 60 AND jl(l_j, '1114', 'C') = 60);
  ok('insurer balance reduced by the rejection', NOONA_SAL_PKG.customer_balance(NOONA_HIS_PKG.payer_account(l_pay)) = 360,
     NOONA_SAL_PKG.customer_balance(NOONA_HIS_PKG.payer_account(l_pay)));
  BEGIN NOONA_HIS_CLAIM_PKG.cancel_batch(l_bt); ok('answered batch cannot be cancelled', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('answered batch cannot be cancelled', 'NOONA-HIS-168', SQLERRM); END;
  SELECT MIN(id) INTO l_x FROM csh_bank_account WHERE company_id = NOONA_HIS_PKG.company AND status_code = 'ACTIVE';
  l_n := NOONA_SAL_PKG.receive('{"cust":' || NOONA_HIS_PKG.payer_account(l_pay) || ',"amount":360,"method":"BANK_APP","place":"BANK:' || l_x || '"}');
  NOONA_HIS_CLAIM_PKG.refresh_batch(l_bt);
  SELECT status_code INTO l_s FROM his_claim_batch WHERE id = l_bt;
  ok('batch settled after payment', l_s = 'SETTLED' AND NOONA_SAL_PKG.customer_balance(NOONA_HIS_PKG.payer_account(l_pay)) = 0, l_s);
  l_c := NOONA_HIS_CLAIM_PKG.batch_html(l_bt);
  ok('batch statement with rejection reason', INSTR(l_c, 'Not medically justified') > 0 AND INSTR(l_c, '420.00') > 0);

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
