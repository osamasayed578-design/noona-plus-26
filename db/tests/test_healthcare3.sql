-- =============================================================================
-- NOONA PLUS ERP | اختبار المستشفى - المرحلة الثالثة: الربط الإلكتروني (الأهلية، الموافقات، المطالبات، الوصفات)، الصرف الاختياري
--                  من الصيدلية، الفرز والتمريض وإعطاء الأدوية، التقارير الطبية، الملف الطبي، عمولات الأطباء
--                  (بحساب NOONA_APP - يتراجع عن كل التغييرات)
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_healthcare3.sql
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
  l_r    VARCHAR2(100);
  l_c    CLOB;
  l_ch   NUMBER;
  l_erx  NUMBER;
  l_pay  NUMBER;
  l_plan NUMBER;
  l_pi   NUMBER;
  l_px   NUMBER;
  l_pc   NUMBER;
  l_v    NUMBER;
  l_v2   NUMBER;
  l_o    NUMBER;
  l_o2   NUMBER;
  l_o3   NUMBER;
  l_inv  NUMBER;
  l_bt   NUMBER;
  l_med  NUMBER;
  l_wh   NUMBER;
  l_rx   NUMBER;
  l_ln   NUMBER;
  l_adm  NUMBER;
  l_bed  NUMBER;
  l_dr   NUMBER;
  l_ct   NUMBER;
  l_j    NUMBER;
  l_m    NUMBER;

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
  FUNCTION rxs(p_rx NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT status_code INTO l FROM his_prescription WHERE id = p_rx; RETURN l;
  END rxs;
  FUNCTION last_msg(p_type VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) INTO l FROM his_link_message WHERE msg_type = p_type AND company_id = NOONA_HIS_PKG.company; RETURN l;
  END last_msg;
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
  -- قنوات الوصفات القائمة (بيانات تجريبية) لا تؤثر على الاختبار
  UPDATE his_integration SET status_code = 'INACTIVE' WHERE company_id = NOONA_HIS_PKG.company AND kind = 'ERX';

  -- ======================================================== قناة الربط وأسرارها
  l_ch := NOONA_HIS_LINK_PKG.save_integration('{"code":"GW' || l_sfx || '","name":"بوابة اختبار","kind":"INSURANCE","mode":"SIMULATOR",'
          || '"auth":"BEARER","secret":"tok-' || l_sfx || '","provider":"PRV-100"}');
  SELECT secret_enc INTO l_s FROM his_integration WHERE id = l_ch;
  ok('channel secret stored encrypted', l_s IS NOT NULL AND INSTR(l_s, 'tok-') = 0 AND NOONA_HIS_LINK_PKG.has_secret(l_ch) = 'Y');
  l_x := NOONA_HIS_LINK_PKG.save_integration('{"id":' || l_ch || ',"code":"GW' || l_sfx || '","name":"بوابة اختبار","kind":"INSURANCE","mode":"SIMULATOR",'
          || '"auth":"BEARER","provider":"PRV-100"}');
  SELECT COUNT(*) INTO l_n FROM his_integration WHERE id = l_ch AND secret_enc = l_s;
  ok('empty secret keeps the stored one', l_n = 1);
  BEGIN l_x := NOONA_HIS_LINK_PKG.save_integration('{"code":"RX' || l_sfx || '","name":"x","mode":"REST","url":"ftp://x"}'); ok('REST needs a URL', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('REST needs a URL', 'NOONA-HIS-201', SQLERRM); END;
  ok('connection test', NOONA_HIS_LINK_PKG.test_connection(l_ch) LIKE 'مقبولة%', NOONA_HIS_LINK_PKG.test_connection(l_ch));

  l_pay := NOONA_HIS_PKG.save_payer('{"code":"LP' || l_sfx || '","name":"تأمين ربط ' || l_sfx || '","type":"INSURANCE","contract":"L-' || l_sfx || '"}');
  l_plan := NOONA_HIS_PKG.save_plan(NULL, l_pay, 'A', 'أ', 0);
  NOONA_HIS_LINK_PKG.set_payer_link(l_pay, l_ch, 'INS-77');
  ok('payer linked to the channel', NOONA_HIS_LINK_PKG.payer_channel(l_pay) = l_ch);
  NOONA_HIS_PKG.set_payer_price(l_pay, srv('MRI-KNEE'), 1350, 'Y', 'Y');
  NOONA_HIS_PKG.set_payer_price(l_pay, srv('SURG-MIN'), 8000, 'Y', 'Y');
  NOONA_HIS_PKG.set_payer_price(l_pay, srv('SURG-CS'), 25000, 'Y', 'Y');

  -- ======================================================== الأهلية
  l_pi := NOONA_HIS_PKG.save_patient('{"name":"مؤمن ربط ' || l_sfx || '","name_en":"Linked Member ' || l_sfx || '","gender":"M","birth":"1980-05-05",'
          || '"nationality":"SA","id_no":"7' || l_sfx || '","plan":' || l_plan || ',"member":"MB-' || l_sfx || '","ins_expiry":"'
          || TO_CHAR(ADD_MONTHS(SYSDATE, 6), 'YYYY-MM-DD') || '"}');
  l_v := NOONA_HIS_PKG.open_visit('{"patient":' || l_pi || ',"dept":' || dep('ORTH') || '}');
  l_r := NOONA_HIS_LINK_PKG.check_eligibility(l_v);
  SELECT eligibility_status || '/' || eligibility_ref INTO l_s FROM his_visit WHERE id = l_v;
  ok('eligibility confirmed and stored on the visit', l_r = 'ELIGIBLE' AND l_s LIKE 'ELIGIBLE/ELG-LM-%', l_r || ' ' || l_s);
  l_m := last_msg('ELIGIBILITY');
  SELECT request_body INTO l_c FROM his_link_message WHERE id = l_m;
  ok('eligibility request carries member, payer code and provider', JSON_VALUE(l_c, '$.coverage.member') = 'MB-' || l_sfx
     AND JSON_VALUE(l_c, '$.payer') = 'INS-77' AND JSON_VALUE(l_c, '$.provider') = 'PRV-100' AND JSON_VALUE(l_c, '$.patient.name_en') LIKE 'Linked Member%');
  l_px := NOONA_HIS_PKG.save_patient('{"name":"غير مؤهل ' || l_sfx || '","gender":"F","nationality":"SA","id_no":"8' || l_sfx || '","plan":' || l_plan
          || ',"member":"X-' || l_sfx || '"}');
  l_v2 := NOONA_HIS_PKG.open_visit('{"patient":' || l_px || ',"dept":' || dep('ORTH') || '}');
  ok('inactive member not eligible', NOONA_HIS_LINK_PKG.check_eligibility(l_v2) = 'NOT_ELIGIBLE');
  UPDATE his_patient SET member_no = 'MB2-' || l_sfx, insurance_expiry = TRUNC(SYSDATE) - 1 WHERE id = l_px;
  ok('expired policy not eligible', NOONA_HIS_LINK_PKG.check_eligibility(l_v2) = 'NOT_ELIGIBLE');

  -- ======================================================== الموافقات المسبقة
  l_o := NOONA_HIS_PKG.add_order(l_v, srv('MRI-KNEE'));
  ok('MRI needs approval', ost(l_o) = 'APPROVAL_PENDING', ost(l_o));
  l_r := NOONA_HIS_LINK_PKG.request_preauth(l_o);
  SELECT approval_no || '/' || preauth_status INTO l_s FROM his_order WHERE id = l_o;
  ok('pre-authorization approved electronically', l_r = 'APPROVED' AND ost(l_o) = 'ORDERED' AND l_s LIKE 'SIM-LM-%/APPROVED', l_r || ' ' || l_s);
  l_o2 := NOONA_HIS_PKG.add_order(l_v, srv('SURG-MIN'));
  l_r := NOONA_HIS_LINK_PKG.request_preauth(l_o2);
  ok('large request pending review', l_r = 'PENDING' AND ost(l_o2) = 'APPROVAL_PENDING', l_r);
  ok('pending approval followed up', NOONA_HIS_LINK_PKG.poll_preauth(l_o2) = 'APPROVED' AND ost(l_o2) = 'ORDERED');
  l_o3 := NOONA_HIS_PKG.add_order(l_v, srv('SURG-CS'));
  l_r := NOONA_HIS_LINK_PKG.request_preauth(l_o3);
  SELECT covered || '/' || preauth_status INTO l_s FROM his_order WHERE id = l_o3;
  ok('rejected request turns the service to cash', l_r = 'REJECTED' AND l_s = 'N/REJECTED' AND ost(l_o3) = 'ORDERED', l_s);
  NOONA_HIS_PKG.cancel_order(l_o3, 'test');
  -- التأمين اختياري: تحويل الزيارة إلى نقدي ثم إعادتها للتأمين
  l_v2 := NOONA_HIS_PKG.open_visit('{"patient":' || l_pi || ',"dept":' || dep('ORTH') || ',"bill_to":"CASH"}');
  l_o3 := NOONA_HIS_PKG.add_order(l_v2, srv('MRI-KNEE'));
  SELECT v.bill_to || '/' || o.covered || '/' || o.status_code INTO l_s FROM his_visit v JOIN his_order o ON o.visit_id = v.id WHERE o.id = l_o3;
  ok('insured patient treated as cash on request', l_s = 'CASH/N/ORDERED', l_s);
  NOONA_HIS_PKG.set_billing(l_v2, 'PAYER');
  SELECT v.bill_to || '/' || o.covered || '/' || o.status_code || '/' || unit_price INTO l_s FROM his_visit v JOIN his_order o ON o.visit_id = v.id WHERE o.id = l_o3;
  ok('switched to insurance: contract price and approval', l_s = 'PAYER/Y/APPROVAL_PENDING/1350', l_s);
  NOONA_HIS_PKG.set_billing(l_v2, 'CASH');
  SELECT v.bill_to || '/' || o.covered || '/' || o.status_code || '/' || payer_net INTO l_s FROM his_visit v JOIN his_order o ON o.visit_id = v.id WHERE o.id = l_o3;
  ok('switched back to cash: no approval, all on patient', l_s = 'CASH/N/ORDERED/0', l_s);
  BEGIN NOONA_HIS_PKG.set_billing(NOONA_HIS_PKG.open_visit('{"patient":' || l_px || ',"dept":' || dep('ORTH') || '}'), 'PAYER'); NULL;
  EXCEPTION WHEN OTHERS THEN NULL; END;
  BEGIN l_r := NOONA_HIS_LINK_PKG.request_preauth(l_o); ok('approved order not re-requested', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('approved order not re-requested', 'NOONA-HIS-063', SQLERRM); END;

  -- ======================================================== المطالبات الإلكترونية
  NOONA_HIS_PKG.update_visit('{"id":' || l_v || ',"diagnosis":"Medial meniscus tear","icd10":"S83.2"}');
  l_inv := NOONA_HIS_PKG.create_invoice('{"visit":' || l_v || '}');
  l_bt := NOONA_HIS_CLAIM_PKG.create_batch(l_pay, TRUNC(SYSDATE), TRUNC(SYSDATE));
  l_r := NOONA_HIS_LINK_PKG.send_claim(l_bt);
  SELECT status_code || '/' || reference_no INTO l_s FROM his_claim_batch WHERE id = l_bt;
  ok('claim batch sent and submitted with the payer reference', l_r = 'SENT' AND l_s LIKE 'SUBMITTED/SC-LM-%', l_r || ' ' || l_s);
  l_m := last_msg('CLAIM');
  SELECT request_body INTO l_c FROM his_link_message WHERE id = l_m;
  ok('claim message carries the e-claim batch', JSON_VALUE(l_c, '$.batch.total') IS NOT NULL AND INSTR(l_c, 'Magnetic') + INSTR(l_c, 'MRI') > 0
     AND INSTR(l_c, 'S83.2') > 0, DBMS_LOB.SUBSTR(l_c, 200, 1));
  l_r := NOONA_HIS_LINK_PKG.poll_claim(l_bt);
  SELECT b.status_code || '/' || b.rejected_amount INTO l_s FROM his_claim_batch b WHERE b.id = l_bt;
  SELECT ROUND(payer_total * 0.1, 2) INTO l_x FROM his_invoice WHERE id = l_inv;
  ok('adjudication applied automatically (90% of an invoice above 2000)', l_r = 'ADJUDICATED' AND l_s = 'PARTIAL/' || TO_CHAR(l_x), l_r || ' ' || l_s);
  SELECT j.id INTO l_j FROM gl_journal j JOIN his_claim_batch b ON b.accounting_event_id = j.accounting_event_id WHERE b.id = l_bt;
  ok('rejection posted from the adjudication', jl(l_j, '4129', 'D') > 0);

  -- ======================================================== تعثر الاتصال والإعادة
  UPDATE his_integration SET link_mode = 'REST', base_url = 'http://127.0.0.1:9/noona', timeout_sec = 5 WHERE id = l_ch;
  l_v2 := NOONA_HIS_PKG.open_visit('{"patient":' || l_pi || ',"dept":' || dep('IM') || '}');
  l_r := NOONA_HIS_LINK_PKG.check_eligibility(l_v2);
  l_m := last_msg('ELIGIBILITY');
  SELECT status_code || '/' || attempts INTO l_s FROM his_link_message WHERE id = l_m;
  ok('unreachable service logged as an error without failing', l_r = 'ERROR' AND l_s = 'ERROR/1', l_r || ' ' || l_s);
  SELECT COUNT(*) INTO l_n FROM his_integration WHERE id = l_ch AND last_error IS NOT NULL;
  ok('channel keeps the last error', l_n = 1);
  UPDATE his_integration SET link_mode = 'EMAIL', email = 'claims@example.com' WHERE id = l_ch;
  ok('e-mail mode only from the application', NOONA_HIS_LINK_PKG.check_eligibility(l_v2) = 'ERROR');
  UPDATE his_integration SET link_mode = 'SIMULATOR' WHERE id = l_ch;
  ok('failed message retried', NOONA_HIS_LINK_PKG.retry(l_m) = 'ELIGIBLE');
  l_c := NOONA_HIS_LINK_PKG.message_html(l_m);
  ok('message view shows request and response', INSTR(l_c, 'Request') > 0 AND INSTR(l_c, 'Response') > 0);
  ok('simulator pending review', JSON_VALUE(NOONA_HIS_LINK_PKG.simulate('PREAUTH', '{"order":{"gross":9000}}'), '$.status') = 'PENDING');

  -- ======================================================== الوصفة الإلكترونية والصرف الاختياري
  l_erx := NOONA_HIS_LINK_PKG.save_integration('{"code":"ER' || l_sfx || '","name":"منصة الوصفات","kind":"ERX","mode":"SIMULATOR"}');
  ok('active e-prescription channel', NOONA_HIS_LINK_PKG.erx_channel = l_erx);
  l_med := NOONA_INV_PKG.save_item('{"name":"دواء ربط ' || l_sfx || '","nameEn":"Cetirizine 10 mg Tab ' || l_sfx || '","type":"STOCK","price":11.5,"incl":"Y","sell":"Y"}');
  SELECT warehouse_id INTO l_wh FROM his_department WHERE id = NOONA_HIS_CARE_PKG.default_pharmacy;
  l_n := NOONA_INV_PKG.save_stock_doc('{"type":"OPENING","date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '","wh":' || l_wh || ',"action":"POST",'
         || '"lines":[{"i":' || l_med || ',"q":100,"c":3}]}');
  l_pc := NOONA_HIS_PKG.save_patient('{"name":"نقدي وصفة ' || l_sfx || '","name_en":"Cash Rx ' || l_sfx || '","gender":"F","birth":"1990-01-01","nationality":"SA","id_no":"9' || l_sfx || '"}');
  l_v := NOONA_HIS_PKG.open_visit('{"patient":' || l_pc || ',"dept":' || dep('IM') || '}');
  NOONA_HIS_PKG.update_visit('{"id":' || l_v || ',"diagnosis":"Allergic rhinitis","icd10":"J30.4"}');
  l_rx := NOONA_HIS_CARE_PKG.prescribe('{"visit":' || l_v || ',"lines":[{"i":' || l_med || ',"q":10,"dose":"10 mg","freq":"OD","days":10}]}');
  SELECT erx_status || '/' || erx_no || '/' || TO_CHAR(expires_on - TRUNC(SYSDATE)) INTO l_s FROM his_prescription WHERE id = l_rx;
  ok('prescription registered on the e-prescription platform, valid 30 days', l_s LIKE 'ACCEPTED/ERX%/30', l_s);
  NOONA_HIS_PKG.close_visit(l_v);
  ok('visit closes without dispensing', NOONA_HIS_PKG.is_open(l_v) = 'N' AND rxs(l_rx) = 'ACTIVE');
  NOONA_HIS_CARE_PKG.bill_prescription(l_rx);
  SELECT o.visit_id, l.order_id INTO l_v2, l_o FROM his_prescription_line l JOIN his_order o ON o.id = l.order_id WHERE l.prescription_id = l_rx;
  SELECT COUNT(*) INTO l_n FROM his_visit WHERE id = l_v2 AND department_id = NOONA_HIS_CARE_PKG.default_pharmacy AND status_code = 'OPEN';
  ok('later dispensing billed on a pharmacy visit', l_v2 <> l_v AND l_n = 1);
  -- المريض لم يسدد: إقفال زيارة الصيدلية يلغي الطلب ويبقي الوصفة سارية
  NOONA_HIS_PKG.close_visit(l_v2);
  SELECT COUNT(*) INTO l_n FROM his_prescription_line WHERE prescription_id = l_rx AND order_id IS NULL;
  ok('unpaid medicine released at closure', ost(l_o) = 'CANCELLED' AND l_n = 1 AND rxs(l_rx) = 'ACTIVE');
  NOONA_HIS_CARE_PKG.bill_prescription(l_rx);
  SELECT l.order_id, o.visit_id INTO l_o, l_v2 FROM his_prescription_line l JOIN his_order o ON o.id = l.order_id WHERE l.prescription_id = l_rx;
  l_inv := NOONA_HIS_PKG.create_invoice('{"visit":' || l_v2 || ',"method":"CASH"}');
  BEGIN NOONA_HIS_CARE_PKG.close_prescription(l_rx, 'Patient left'); ok('paid medicine must be delivered', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('paid medicine must be delivered', 'NOONA-HIS-122', SQLERRM); END;
  NOONA_HIS_CARE_PKG.deliver_prescription(l_rx);
  ok('delivered after payment', rxs(l_rx) = 'DISPENSED' AND NOONA_INV_PKG.on_hand(l_med, l_wh) = 90);
  l_c := NOONA_HIS_CARE_PKG.rx_html(l_rx);
  ok('printable English prescription', INSTR(l_c, 'Prescription') > 0 AND INSTR(l_c, 'Cetirizine') > 0 AND INSTR(l_c, 'e-Prescription ERX') > 0
     AND INSTR(l_c, 'Allergic rhinitis') > 0);
  -- وصفة تصرف خارجياً
  l_v := NOONA_HIS_PKG.open_visit('{"patient":' || l_pc || ',"dept":' || dep('IM') || '}');
  l_rx := NOONA_HIS_CARE_PKG.prescribe('{"visit":' || l_v || ',"lines":[{"i":' || l_med || ',"q":5}]}');
  NOONA_HIS_CARE_PKG.bill_prescription(l_rx);
  BEGIN NOONA_HIS_CARE_PKG.close_prescription(l_rx, NULL); ok('closing needs a reason', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('closing needs a reason', 'NOONA-HIS-123', SQLERRM); END;
  NOONA_HIS_CARE_PKG.close_prescription(l_rx, 'Dispensed at an outside pharmacy');
  l_x := NOONA_HIS_CARE_PKG.med_service(l_med);
  SELECT COUNT(*) INTO l_n FROM his_order o WHERE o.visit_id = l_v AND o.service_id = l_x AND o.status_code = 'CANCELLED';
  ok('external dispensing closes the prescription and cancels the unpaid charge', rxs(l_rx) = 'EXTERNAL' AND l_n = 1 AND NOONA_HIS_PKG.unbilled_total(l_v) = 0);
  -- انتهاء الصلاحية
  l_rx := NOONA_HIS_CARE_PKG.prescribe('{"visit":' || l_v || ',"valid_days":3,"lines":[{"i":' || l_med || ',"q":5}]}');
  UPDATE his_prescription SET expires_on = TRUNC(SYSDATE) - 1 WHERE id = l_rx;
  BEGIN NOONA_HIS_CARE_PKG.bill_prescription(l_rx); ok('expired prescription not billed', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('expired prescription not billed', 'NOONA-HIS-121', SQLERRM); END;
  ok('expired prescriptions closed', NOONA_HIS_CARE_PKG.expire_prescriptions >= 1 AND rxs(l_rx) = 'EXPIRED');
  l_rx := NOONA_HIS_CARE_PKG.prescribe('{"visit":' || l_v || ',"lines":[{"i":' || l_med || ',"q":2}]}');
  NOONA_HIS_CARE_PKG.cancel_prescription(l_rx);
  SELECT erx_status INTO l_s FROM his_prescription WHERE id = l_rx;
  ok('cancelled prescription withdrawn from the platform', l_s = 'CANCELLED' AND rxs(l_rx) = 'CANCELLED', l_s);

  -- ======================================================== الطوارئ والتمريض
  l_v := NOONA_HIS_PKG.open_visit('{"patient":' || l_pc || ',"dept":' || dep('ER') || ',"type":"EMERGENCY","complaint":"Chest pain for 2 hours"}');
  BEGIN NOONA_HIS_CLIN_PKG.set_triage(l_v, '7'); ok('triage level 1-5', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('triage level 1-5', 'NOONA-HIS-220', SQLERRM); END;
  NOONA_HIS_CLIN_PKG.set_triage(l_v, '2');
  l_c := NOONA_HIS_CLIN_PKG.er_board_html;
  ok('ER board shows the triaged patient', INSTR(l_c, '2 - Emergent') > 0 AND INSTR(l_c, 'Chest pain') > 0);
  l_x := NOONA_HIS_CLIN_PKG.record_vitals('{"visit":' || l_v || ',"bp":"150/95","pulse":104,"temp":37.2,"spo2":95,"pain":7}');
  SELECT vitals INTO l_s FROM his_visit WHERE id = l_v;
  ok('vital signs summarized on the visit', l_s = 'BP 150/95, T 37.2, HR 104, SpO2 95%, Pain 7/10', l_s);
  BEGIN l_x := NOONA_HIS_CLIN_PKG.record_vitals('{"visit":' || l_v || ',"bp":"150-95"}'); ok('blood pressure format', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('blood pressure format', 'NOONA-HIS-221', SQLERRM); END;
  BEGIN l_x := NOONA_HIS_CLIN_PKG.record_vitals('{"visit":' || l_v || ',"spo2":130}'); ok('implausible reading rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('implausible reading rejected', 'NOONA-HIS-222', SQLERRM); END;
  ok('vitals chart', INSTR(NOONA_HIS_CLIN_PKG.vitals_html(l_v), '150/95') > 0);
  l_x := NOONA_HIS_CLIN_PKG.add_note(l_v, 'NURSING', 'ECG done, aspirin given as ordered.');
  ok('nursing note recorded', INSTR(NOONA_HIS_CLIN_PKG.notes_html(l_v), 'aspirin given') > 0);
  l_rx := NOONA_HIS_CARE_PKG.prescribe('{"visit":' || l_v || ',"lines":[{"i":' || l_med || ',"q":3,"dose":"10 mg","freq":"OD"}]}');
  SELECT id INTO l_ln FROM his_prescription_line WHERE prescription_id = l_rx;
  l_x := NOONA_HIS_CLIN_PKG.give_medication('{"line":' || l_ln || ',"route":"ORAL"}');
  BEGIN l_x := NOONA_HIS_CLIN_PKG.give_medication('{"line":' || l_ln || ',"outcome":"HELD"}'); ok('held dose needs a reason', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('held dose needs a reason', 'NOONA-HIS-228', SQLERRM); END;
  l_x := NOONA_HIS_CLIN_PKG.give_medication('{"line":' || l_ln || ',"outcome":"HELD","notes":"Patient asleep"}');
  l_c := NOONA_HIS_CLIN_PKG.mar_html(l_v);
  ok('medication administration record', INSTR(l_c, 'Cetirizine') > 0 AND INSTR(l_c, 'HELD ORAL') > 0, DBMS_LOB.SUBSTR(l_c, 300, 1));
  l_v2 := NOONA_HIS_PKG.open_visit('{"patient":' || l_pi || ',"dept":' || dep('IM') || '}');
  l_rx := NOONA_HIS_CARE_PKG.prescribe('{"visit":' || l_v2 || ',"lines":[{"i":' || l_med || ',"q":1}]}');
  SELECT id INTO l_ln FROM his_prescription_line WHERE prescription_id = l_rx;
  BEGIN l_x := NOONA_HIS_CLIN_PKG.give_medication('{"line":' || l_ln || '}'); ok('MAR only for inpatient/emergency', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('MAR only for inpatient/emergency', 'NOONA-HIS-226', SQLERRM); END;

  -- ======================================================== التقارير الطبية والملف الطبي
  NOONA_HIS_PKG.update_visit('{"id":' || l_v || ',"diagnosis":"Unstable angina","icd10":"I20.0"}');
  SELECT MIN(id) INTO l_dr FROM his_doctor WHERE company_id = NOONA_HIS_PKG.company;
  IF l_dr IS NULL THEN
    l_dr := NOONA_HIS_PKG.save_doctor('{"name":"د. اختبار","dept":' || dep('IM') || ',"title":"GP"}');
  END IF;
  l_ct := NOONA_HIS_CLIN_PKG.issue_certificate('{"visit":' || l_v || ',"type":"SICK_LEAVE","from":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '","to":"'
          || TO_CHAR(SYSDATE + 2, 'YYYY-MM-DD') || '","doctor":' || l_dr || '}');
  SELECT days || '/' || LENGTH(verify_code) || '/' || CASE WHEN body LIKE '%sick leave for 3 day(s)%' AND body LIKE '%Unstable angina (I20.0)%' THEN 'Y' END
    INTO l_s FROM his_certificate WHERE id = l_ct;
  ok('sick leave certificate in English with verification code', l_s = '3/10/Y', l_s);
  l_c := NOONA_HIS_CLIN_PKG.certificate_html(l_ct);
  ok('certificate print', INSTR(l_c, 'Sick Leave') > 0 AND INSTR(l_c, 'Verification code') > 0 AND INSTR(l_c, 'Cash Rx') > 0);
  BEGIN l_x := NOONA_HIS_CLIN_PKG.issue_certificate('{"visit":' || l_v || ',"type":"REFERRAL","doctor":' || l_dr || '}'); ok('referral needs a destination', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('referral needs a destination', 'NOONA-HIS-234', SQLERRM); END;
  NOONA_HIS_CLIN_PKG.cancel_certificate(l_ct, 'Issued in error');
  SELECT status_code INTO l_s FROM his_certificate WHERE id = l_ct;
  ok('certificate cancelled', l_s = 'CANCELLED' AND INSTR(NOONA_HIS_CLIN_PKG.certificate_html(l_ct), 'CANCELLED') > 0);
  l_c := NOONA_HIS_CLIN_PKG.patient_history_html(l_pc);
  ok('patient record timeline', INSTR(l_c, 'Unstable angina') > 0 AND INSTR(l_c, 'Allergic rhinitis') > 0 AND INSTR(l_c, 'Cetirizine') > 0);

  -- ======================================================== عمولات الأطباء
  l_dr := NOONA_HIS_PKG.save_doctor('{"name":"د. عمولة ' || l_sfx || '","dept":' || dep('IM') || ',"title":"SPECIALIST","commission":20}');
  l_v := NOONA_HIS_PKG.open_visit('{"patient":' || l_pc || ',"dept":' || dep('IM') || '}');
  l_o := NOONA_HIS_PKG.add_order(l_v, srv('LAB-CBC'), 2, l_dr);
  l_inv := NOONA_HIS_PKG.create_invoice('{"visit":' || l_v || ',"method":"CASH"}');
  SELECT patient_net + payer_net INTO l_x FROM his_order WHERE id = l_o;
  ok('commission preview', INSTR(NOONA_HIS_CLIN_PKG.commission_preview_html(TRUNC(SYSDATE), TRUNC(SYSDATE)), 'د. عمولة ' || l_sfx) > 0);
  l_n := NOONA_HIS_CLIN_PKG.settle_commissions(TRUNC(SYSDATE), TRUNC(SYSDATE), l_dr);
  SELECT id, amount INTO l_m, l_n FROM his_commission WHERE doctor_id = l_dr;
  ok('commission = 20% of the doctor''s billed services', l_n = ROUND(l_x * 0.2, 2), l_n || ' vs ' || l_x);
  SELECT j.id INTO l_j FROM gl_journal j JOIN his_commission c ON c.accounting_event_id = j.accounting_event_id WHERE c.id = l_m;
  ok('accrual journal Dr 5220 Cr 2111', jl(l_j, '5220', 'D') = l_n AND jl(l_j, '2111', 'C') = l_n);
  BEGIN l_x := NOONA_HIS_CLIN_PKG.settle_commissions(TRUNC(SYSDATE), TRUNC(SYSDATE), l_dr); ok('services settled once', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('services settled once', 'NOONA-HIS-241', SQLERRM); END;
  BEGIN NOONA_HIS_PKG.cancel_invoice(l_inv, 'test'); ok('settled invoice not cancelled', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('settled invoice not cancelled', 'NOONA-HIS-077', SQLERRM); END;
  NOONA_HIS_CLIN_PKG.cancel_commission(l_m, 'Wrong rate');
  SELECT COUNT(*) INTO l_n FROM his_order WHERE commission_id = l_m;
  SELECT status_code INTO l_s FROM his_commission WHERE id = l_m;
  ok('settlement cancelled and services released', l_n = 0 AND l_s = 'CANCELLED');

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
