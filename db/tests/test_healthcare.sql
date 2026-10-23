-- =============================================================================
-- NOONA PLUS ERP | اختبار المستشفيات والمراكز الطبية بحساب NOONA_APP - يتراجع عن كل التغييرات في النهاية
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_healthcare.sql
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
  l_d1   DATE := TRUNC(SYSDATE) + 1;
  l_wd   NUMBER;
  l_im   NUMBER;
  l_chem NUMBER;
  l_hem  NUMBER;
  l_doc  NUMBER;
  l_ins  NUMBER;
  l_gold NUMBER;
  l_corp NUMBER;
  l_cplan NUMBER;
  l_p1   NUMBER;
  l_p2   NUMBER;
  l_p3   NUMBER;
  l_ap   NUMBER;
  l_v1   NUMBER;
  l_v2   NUMBER;
  l_o1   NUMBER;
  l_o2   NUMBER;
  l_o3   NUMBER;
  l_ct   NUMBER;
  l_inv1 NUMBER;
  l_inv2 NUMBER;
  l_inv3 NUMBER;
  l_reag NUMBER;
  l_j    NUMBER;
  l_rc   NUMBER;

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
  FUNCTION shr(p_o NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(200);
  BEGIN
    SELECT TO_CHAR(patient_net) || '/' || TO_CHAR(payer_net) || '/' || TO_CHAR(patient_vat + payer_vat) INTO l FROM his_order WHERE id = p_o; RETURN l;
  END shr;
  FUNCTION jl(p_j NUMBER, p_code VARCHAR2, p_side VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(CASE p_side WHEN 'D' THEN l.debit_amount ELSE l.credit_amount END), 0) INTO l
      FROM gl_journal_line l JOIN gl_account a ON a.id = l.account_id WHERE l.journal_id = p_j AND a.account_code = p_code;
    RETURN l;
  END jl;
  FUNCTION inv_journal(p_inv NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(j.id) INTO l FROM gl_journal j JOIN his_invoice i ON i.accounting_event_id = j.accounting_event_id WHERE i.id = p_inv; RETURN l;
  END inv_journal;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));

  -- التجهيز والأقسام
  l_n := NOONA_HIS_PKG.seed_catalog;
  ok('hospital ready after setup', NOONA_HIS_PKG.is_ready = 'Y');
  SELECT COUNT(*) INTO l_n FROM his_department WHERE company_id = NOONA_HIS_PKG.company AND dept_type = 'LAB';
  ok('five separate labs', l_n >= 5, l_n);
  l_chem := dep('LCHEM'); l_hem := dep('LHEM'); l_im := dep('IM');
  SELECT COUNT(DISTINCT warehouse_id) INTO l_n FROM his_department WHERE id IN (l_chem, l_hem) AND warehouse_id IS NOT NULL;
  ok('each lab has its own warehouse', l_n = 2, l_n);
  SELECT COUNT(*) INTO l_n FROM his_department WHERE id = l_im AND cost_center_id IS NOT NULL AND warehouse_id IS NULL;
  ok('clinic has a cost center and no store', l_n = 1);
  SELECT COUNT(*) INTO l_n FROM his_service WHERE company_id = NOONA_HIS_PKG.company AND modality IN ('CT', 'MRI', 'ULTRASOUND', 'XRAY', 'ECG', 'ECHO');
  ok('radiology and cardio services with modalities', l_n >= 10, l_n);
  ok('catalog seeding is idempotent', NOONA_HIS_PKG.seed_catalog = 0);
  BEGIN l_n := NOONA_HIS_PKG.save_department(NULL, 'LCHEM', 'مكرر', 'LAB'); ok('duplicate department code rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('duplicate department code rejected', 'NOONA-HIS-011', SQLERRM); END;
  BEGIN l_n := NOONA_HIS_PKG.save_service('{"code":"X' || l_sfx || '","name":"x","type":"LAB","price":-1}'); ok('negative price rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('negative price rejected', 'NOONA-HIS-013', SQLERRM); END;

  -- مواد المعمل: كاشف بمستودع معمل الكيمياء
  l_reag := NOONA_INV_PKG.save_item('{"name":"كاشف سكر اختبار ' || l_sfx || '","type":"STOCK","sell":"N"}');
  SELECT warehouse_id INTO l_x FROM his_department WHERE id = l_chem;
  l_n := NOONA_INV_PKG.save_stock_doc('{"type":"OPENING","date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '","wh":' || l_x || ',"action":"POST",'
         || '"lines":[{"i":' || l_reag || ',"q":20,"c":4}]}');
  -- مواد سابقة مربوطة بالفحص (بيانات التجربة) ترفع ضمن الاختبار ثم تعود بالتراجع
  l_o3 := srv('LAB-FBS');
  FOR m IN (SELECT item_id FROM his_service_material WHERE service_id = l_o3) LOOP
    NOONA_HIS_PKG.set_material(l_o3, m.item_id, 0);
  END LOOP;
  NOONA_HIS_PKG.set_material(srv('LAB-FBS'), l_reag, 0.5);
  l_x := srv('LAB-FBS');
  SELECT COUNT(*) INTO l_n FROM his_service_material WHERE service_id = l_x;
  ok('lab material linked to the test', l_n = 1);

  -- الطبيب وساعات العمل
  l_doc := NOONA_HIS_PKG.save_doctor('{"name":"د. سامي اختبار ' || l_sfx || '","dept":' || l_im || ',"title":"SPECIALIST","specialty":"باطنة",'
           || '"license":"SCFHS-' || l_sfx || '","consult_service":' || srv('CON-SP') || ',"commission":30}');
  l_wd := NOONA_HIS_PKG.weekday_of(l_d1);
  ok('weekday independent of territory', NOONA_HIS_PKG.weekday_of(DATE '2026-10-25') = 1 AND NOONA_HIS_PKG.weekday_of(DATE '2026-10-24') = 7);
  NOONA_HIS_PKG.set_schedule(l_doc, l_wd, '09:00', '12:00', 30, 'غرفة 5');
  BEGIN NOONA_HIS_PKG.set_schedule(l_doc, l_wd, '11:00', '13:00', 30); ok('overlapping hours rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('overlapping hours rejected', 'NOONA-HIS-020', SQLERRM); END;
  NOONA_HIS_PKG.set_schedule(l_doc, l_wd, '16:00', '18:00', 30);
  l_s := NOONA_HIS_PKG.free_slots(l_doc, l_d1);
  ok('free slots from both periods', l_s LIKE '["09:00","09:30",%' AND INSTR(l_s, '"17:30"') > 0 AND INSTR(l_s, '"12:00"') = 0, l_s);

  -- شركات التأمين والجهات المتعاقدة
  l_ins := NOONA_HIS_PKG.save_payer('{"code":"INS' || l_sfx || '","name":"تأمين اختبار ' || l_sfx || '","type":"INSURANCE","discount":10,"claim_days":45}');
  SELECT COUNT(*) INTO l_n FROM his_payer y JOIN ar_customer_account a ON a.id = y.customer_account_id JOIN gl_account g ON g.id = a.receivable_account_id
   WHERE y.id = l_ins AND g.account_code = '1114';
  ok('payer gets a receivable account on 1114', l_n = 1);
  l_gold := NOONA_HIS_PKG.save_plan(NULL, l_ins, 'GOLD', 'الفئة الذهبية', 20, 50, 1000, 'DENTAL');
  NOONA_HIS_PKG.set_payer_price(l_ins, srv('LAB-CBC'), 50);
  l_corp := NOONA_HIS_PKG.save_payer('{"code":"CO' || l_sfx || '","name":"شركة متعاقدة ' || l_sfx || '","type":"CORPORATE"}');
  l_cplan := NOONA_HIS_PKG.save_plan(NULL, l_corp, 'STAFF', 'موظفو الشركة', 0);
  BEGIN l_n := NOONA_HIS_PKG.save_plan(NULL, l_ins, 'X', 'x', 120); ok('patient share over 100 rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('patient share over 100 rejected', 'NOONA-HIS-025', SQLERRM); END;

  -- المرضى
  l_p1 := NOONA_HIS_PKG.save_patient('{"name":"محمد المؤمن ' || l_sfx || '","gender":"M","birth":"1985-05-01","id_type":"NATIONAL_ID","id_no":"1' || l_sfx
          || '","nationality":"SA","mobile":"0551' || l_sfx || '","plan":' || l_gold || ',"member":"M-' || l_sfx || '","ins_expiry":"'
          || TO_CHAR(SYSDATE + 200, 'YYYY-MM-DD') || '","allergies":"بنسلين"}');
  SELECT COUNT(*) INTO l_n FROM his_patient WHERE id = l_p1 AND mrn LIKE 'MRN%';
  ok('patient registered with MRN', l_n = 1);
  BEGIN l_n := NOONA_HIS_PKG.save_patient('{"name":"مكرر","gender":"M","id_no":"1' || l_sfx || '"}'); ok('duplicate ID rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('duplicate ID rejected', 'NOONA-HIS-033', SQLERRM); END;
  BEGIN l_n := NOONA_HIS_PKG.save_patient('{"name":"بلا عضوية","gender":"F","plan":' || l_gold || '}'); ok('member number required', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('member number required', 'NOONA-HIS-034', SQLERRM); END;
  l_p2 := NOONA_HIS_PKG.save_patient('{"name":"جون مقيم ' || l_sfx || '","gender":"M","id_type":"IQAMA","id_no":"2' || l_sfx || '","nationality":"GB"}');
  l_c := NOONA_HIS_PKG.find_patients_json('0551' || l_sfx);
  ok('patient search by mobile', INSTR(l_c, 'محمد المؤمن') > 0);

  -- الحجز
  l_ap := NOONA_HIS_PKG.book('{"patient":' || l_p1 || ',"doctor":' || l_doc || ',"date":"' || TO_CHAR(l_d1, 'YYYY-MM-DD') || '","time":"09:30"}');
  ok('appointment booked with end time', l_ap IS NOT NULL);
  SELECT end_time, department_id INTO l_s, l_n FROM his_appointment WHERE id = l_ap;
  ok('end time and clinic from the doctor', l_s = '10:00' AND l_n = l_im, l_s);
  ok('booked slot no longer free', INSTR(NOONA_HIS_PKG.free_slots(l_doc, l_d1), '"09:30"') = 0);
  BEGIN l_n := NOONA_HIS_PKG.book('{"patient":' || l_p2 || ',"doctor":' || l_doc || ',"date":"' || TO_CHAR(l_d1, 'YYYY-MM-DD') || '","time":"09:30"}');
    ok('double booking rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('double booking rejected', 'NOONA-HIS-043', SQLERRM); END;
  BEGIN l_n := NOONA_HIS_PKG.book('{"patient":' || l_p2 || ',"doctor":' || l_doc || ',"date":"' || TO_CHAR(l_d1, 'YYYY-MM-DD') || '","time":"13:00"}');
    ok('outside working hours rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('outside working hours rejected', 'NOONA-HIS-042', SQLERRM); END;
  l_n := NOONA_HIS_PKG.book('{"patient":' || l_p2 || ',"doctor":' || l_doc || ',"date":"' || TO_CHAR(l_d1, 'YYYY-MM-DD') || '","time":"10:00"}');
  NOONA_HIS_PKG.mark_no_show(l_n);
  ok('no-show frees the slot', INSTR(NOONA_HIS_PKG.free_slots(l_doc, l_d1), '"10:00"') > 0);

  -- الزيارة المؤمنة: الكشف بسعر العقد وحصة المريض 20% بحد أعلى 50 للزيارة
  l_v1 := NOONA_HIS_PKG.arrive(l_ap);
  SELECT status_code INTO l_s FROM his_appointment WHERE id = l_ap;
  ok('arrival opens the visit', l_s = 'ARRIVED' AND l_v1 IS NOT NULL);
  SELECT MIN(id) INTO l_o1 FROM his_order WHERE visit_id = l_v1;
  ok('consultation added (200 less 10% = 180; 36 patient, 144 insurer, VAT 0 for citizen)', shr(l_o1) = '36/144/0', shr(l_o1));
  l_o2 := NOONA_HIS_PKG.add_order(l_v1, srv('LAB-CBC'));
  ok('contract price 50 for CBC', shr(l_o2) = '10/40/0', shr(l_o2));
  l_o3 := NOONA_HIS_PKG.add_order(l_v1, srv('LAB-LIPID'));
  ok('patient share capped at 50 per visit', shr(l_o3) = '4/104/0', shr(l_o3));
  l_ct := NOONA_HIS_PKG.add_order(l_v1, srv('CT-BRAIN'));
  ok('CT needs insurance approval', ost(l_ct) = 'APPROVAL_PENDING');
  l_n := NOONA_HIS_PKG.add_order(l_v1, srv('DENT-EX'));
  SELECT covered INTO l_s FROM his_order WHERE id = l_n;
  ok('excluded type is cash on the patient', l_s = 'N' AND shr(l_n) = '150/0/0', shr(l_n));
  NOONA_HIS_PKG.cancel_order(l_n, 'لا يرغب');
  BEGIN NOONA_HIS_PKG.start_order(l_o2); ok('outpatient service unpaid cannot start', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('outpatient service unpaid cannot start', 'NOONA-HIS-066', SQLERRM); END;

  -- الفاتورة الأولى: المريض يدفع بمدى، والباقي مطالبة على التأمين
  l_inv1 := NOONA_HIS_PKG.create_invoice('{"visit":' || l_v1 || ',"method":"MADA","ref":"4455"}');
  SELECT patient_total || '/' || payer_total || '/' || paid_amount || '/' || claim_status INTO l_s FROM his_invoice WHERE id = l_inv1;
  ok('invoice splits patient and insurer', l_s = '50/288/50/PENDING', l_s);
  ok('pending approval stays unbilled', NOONA_HIS_PKG.unbilled_total(l_v1, 'PAYER') = 0 AND ost(l_ct) = 'APPROVAL_PENDING');
  l_j := inv_journal(l_inv1);
  ok('journal: insurer receivable and revenues by type', jl(l_j, '1114', 'D') = 288 AND jl(l_j, '4120', 'C') = 180 AND jl(l_j, '4121', 'C') = 158,
     jl(l_j, '1114', 'D') || ' ' || jl(l_j, '4120', 'C') || ' ' || jl(l_j, '4121', 'C'));
  SELECT COUNT(*) INTO l_n FROM ar_open_item WHERE source_entity_type = 'HIS_INVOICE' AND source_entity_id = l_inv1 AND original_amount = 288;
  ok('claim open item on the insurer', l_n = 1);
  NOONA_HIS_PKG.start_order(l_o2);
  ok('paid service starts', ost(l_o2) = 'IN_PROGRESS');
  -- الموافقة
  BEGIN NOONA_HIS_PKG.set_approval(l_ct, NULL); ok('approval number required', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('approval number required', 'NOONA-HIS-064', SQLERRM); END;
  NOONA_HIS_PKG.set_approval(l_ct, 'APR-' || l_sfx);
  ok('approved CT: patient cap reached, insurer pays all', ost(l_ct) = 'ORDERED' AND shr(l_ct) = '0/810/0', shr(l_ct));
  l_inv2 := NOONA_HIS_PKG.create_invoice('{"visit":' || l_v1 || '}');
  SELECT patient_total || '/' || payer_total INTO l_s FROM his_invoice WHERE id = l_inv2;
  ok('second invoice is claim only', l_s = '0/810', l_s);
  NOONA_HIS_PKG.update_visit('{"id":' || l_v1 || ',"diagnosis":"ارتفاع ضغط الدم","icd10":"I10","vitals":"BP 150/95"}');
  NOONA_HIS_PKG.close_visit(l_v1);
  SELECT status_code INTO l_s FROM his_visit WHERE id = l_v1;
  ok('visit closed after full billing', l_s = 'CLOSED');

  -- مريض نقدي غير سعودي: ضريبة 15% ومواد المعمل
  l_v2 := NOONA_HIS_PKG.open_visit('{"patient":' || l_p2 || ',"dept":' || l_chem || ',"type":"OUTPATIENT"}');
  l_o1 := NOONA_HIS_PKG.add_order(l_v2, srv('LAB-FBS'));
  ok('cash non-citizen: VAT 15%', shr(l_o1) = '30/0/4.5', shr(l_o1));
  BEGIN NOONA_HIS_PKG.close_visit(l_v2); ok('unbilled visit cannot close', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('unbilled visit cannot close', 'NOONA-HIS-065', SQLERRM); END;
  l_inv3 := NOONA_HIS_PKG.create_invoice('{"visit":' || l_v2 || ',"method":"CASH"}');
  l_j := inv_journal(l_inv3);
  ok('cash invoice journal with VAT', jl(l_j, '1101', 'D') = 34.5 AND jl(l_j, '2104', 'C') = 4.5 AND jl(l_j, '4121', 'C') = 30,
     jl(l_j, '1101', 'D') || ' ' || jl(l_j, '2104', 'C'));
  l_s := NOONA_HIS_PKG.collect_sample(l_o1);
  ok('sample number issued', l_s LIKE 'S%' AND ost(l_o1) = 'IN_PROGRESS', l_s);
  SELECT warehouse_id INTO l_x FROM his_department WHERE id = l_chem;
  NOONA_HIS_PKG.complete_order(l_o1, 'Glucose (fasting): 132 mg/dL', 'ABNORMAL');
  ok('lab material consumed from the lab store', NOONA_INV_PKG.on_hand(l_reag, l_x) = 19.5, NOONA_INV_PKG.on_hand(l_reag, l_x));
  SELECT material_cost, status_code INTO l_n, l_s FROM his_order WHERE id = l_o1;
  ok('material cost on the order', l_n = 2 AND l_s = 'COMPLETED', l_n || ' ' || l_s);
  ok('result report in English', INSTR(NOONA_HIS_PKG.result_html(l_o1), '132 mg/dL') > 0 AND INSTR(NOONA_HIS_PKG.result_html(l_o1), 'Abnormal') > 0);
  BEGIN NOONA_HIS_PKG.cancel_invoice(l_inv3, 'خطأ'); ok('invoice of a performed service cannot be cancelled', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('invoice of a performed service cannot be cancelled', 'NOONA-HIS-075', SQLERRM); END;

  -- جهة متعاقدة 100% والتأمين المنتهي
  l_p3 := NOONA_HIS_PKG.save_patient('{"name":"موظف شركة ' || l_sfx || '","gender":"F","nationality":"SA","plan":' || l_cplan || ',"member":"E-' || l_sfx || '"}');
  l_x := NOONA_HIS_PKG.open_visit('{"patient":' || l_p3 || ',"doctor":' || l_doc || '}');
  SELECT MIN(id) INTO l_o1 FROM his_order WHERE visit_id = l_x;
  ok('corporate covers fully', shr(l_o1) = '0/200/0', shr(l_o1));
  UPDATE his_patient SET insurance_expiry = TRUNC(SYSDATE) - 1 WHERE id = l_p1;
  l_n := NOONA_HIS_PKG.open_visit('{"patient":' || l_p1 || ',"dept":' || l_hem || ',"bill_to":"PAYER"}');
  l_o2 := NOONA_HIS_PKG.add_order(l_n, srv('LAB-ESR'));
  ok('expired insurance falls back to cash price', shr(l_o2) = '40/0/0', shr(l_o2));
  -- على حساب المريض ثم التحصيل
  l_inv1 := NOONA_HIS_PKG.create_invoice('{"visit":' || l_n || ',"method":"CREDIT"}');
  SELECT customer_account_id INTO l_x FROM his_patient WHERE id = l_p1;
  ok('patient account opened with the balance', NOONA_SAL_PKG.customer_balance(l_x) = 40, NOONA_SAL_PKG.customer_balance(l_x));
  SELECT MIN(id) INTO l_rc FROM csh_cash_box WHERE company_id = NOONA_HIS_PKG.company AND status_code = 'ACTIVE';
  l_rc := NOONA_SAL_PKG.receive('{"cust":' || l_x || ',"amount":40,"place":"BOX:' || l_rc || '"}');
  ok('patient balance collected', NOONA_SAL_PKG.customer_balance(l_x) = 0);
  -- تحصيل مطالبة التأمين
  SELECT MIN(id) INTO l_rc FROM csh_bank_account WHERE company_id = NOONA_HIS_PKG.company AND status_code = 'ACTIVE';
  l_rc := NOONA_SAL_PKG.receive('{"cust":' || NOONA_HIS_PKG.payer_account(l_ins) || ',"amount":1000,"method":"BANK_APP","place":"BANK:' || l_rc || '"}');
  ok('insurer claims collected oldest first', NOONA_SAL_PKG.customer_balance(NOONA_HIS_PKG.payer_account(l_ins)) = 98,
     NOONA_SAL_PKG.customer_balance(NOONA_HIS_PKG.payer_account(l_ins)));
  l_c := NOONA_HIS_PKG.claims_html(l_ins, TRUNC(SYSDATE), TRUNC(SYSDATE));
  ok('claims statement with approvals', INSTR(l_c, 'APR-' || l_sfx) > 0 AND INSTR(l_c, 'M-' || l_sfx) > 0 AND INSTR(l_c, '1,098.00') > 0);

  -- إلغاء فاتورة لم تنفذ خدماتها
  l_x := NOONA_HIS_PKG.open_visit('{"patient":' || l_p2 || ',"dept":' || dep('RXR') || '}');
  l_o1 := NOONA_HIS_PKG.add_order(l_x, srv('XR-CHEST'));
  l_inv2 := NOONA_HIS_PKG.create_invoice('{"visit":' || l_x || ',"method":"CASH"}');
  BEGIN NOONA_HIS_PKG.cancel_invoice(l_inv2, NULL); ok('cancel needs reason', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('cancel needs reason', 'NOONA-HIS-074', SQLERRM); END;
  NOONA_HIS_PKG.cancel_invoice(l_inv2, 'تغيير الطبيب للطلب');
  SELECT COUNT(*) INTO l_n FROM his_order WHERE id = l_o1 AND invoice_id IS NULL;
  SELECT COUNT(*) INTO l_rc FROM gl_journal j JOIN ace_accounting_event e ON e.id = j.accounting_event_id
   WHERE e.source_entity_type = 'HIS_INVOICE' AND e.source_entity_id = l_inv2;
  ok('cancelled invoice reversed and services unbilled', l_n = 1 AND l_rc = 2, l_n || ' ' || l_rc);
  NOONA_HIS_PKG.cancel_order(l_o1, 'إلغاء');
  NOONA_HIS_PKG.close_visit(l_x);

  -- العرض والتقارير
  ok('summary', DBMS_LOB.GETLENGTH(NOONA_HIS_PKG.summary_html) > 300);
  l_c := NOONA_HIS_PKG.visit_html(l_v1);
  ok('visit card with allergy and diagnosis', INSTR(l_c, 'بنسلين') > 0 AND INSTR(l_c, 'I10') > 0 AND INSTR(l_c, 'APR-' || l_sfx) > 0);
  l_c := NOONA_HIS_PKG.invoice_html(l_inv3);
  ok('tax invoice print', INSTR(l_c, 'فاتورة ضريبية') > 0 AND INSTR(l_c, '34.50') > 0);
  l_c := NOONA_HIS_PKG.day_board_html(l_d1, l_im);
  ok('day board of doctors and appointments', INSTR(l_c, 'د. سامي اختبار') > 0 AND INSTR(l_c, '09:30') > 0);
  l_c := NOONA_HIS_PKG.revenue_html(TRUNC(SYSDATE), TRUNC(SYSDATE));
  ok('revenue by department, payer and doctor', INSTR(l_c, 'معمل الكيمياء الحيوية') > 0 AND INSTR(l_c, 'تأمين اختبار') > 0 AND INSTR(l_c, 'د. سامي') > 0);
  ok('labels', NOONA_HIS_PKG.modality_label('MRI') = 'رنين مغناطيسي' AND NOONA_HIS_PKG.dept_type_label('LAB') = 'معمل');

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
