-- =============================================================================
-- NOONA PLUS ERP | اختبار مراكز خدمة السيارات: الإعداد وكروت الخدمات وقطعها الافتراضية، المركبات واللوحات، البحث عن القطع
--                  (الاسم/الباركود/رقم القطعة/التوافق/البدائل)، أمر الإصلاح والفني ومدة العمل، الفاتورة الواحدة وصرف المخزون،
--                  التأمين وتحمل العميل، الحجوزات، والتقارير (بحساب NOONA_APP - يتراجع عن كل التغييرات)
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_auto_service.sql
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
  l_d    VARCHAR2(10) := TO_CHAR(SYSDATE, 'YYYY-MM-DD');
  l_n    NUMBER;
  l_x    NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_box  NUMBER;
  l_wh   NUMBER;
  l_cat  NUMBER;
  l_oil  NUMBER;
  l_flt  NUMBER;
  l_pad  NUMBER;
  l_pad2 NUMBER;
  l_svc1 NUMBER;
  l_svc2 NUMBER;
  l_tech NUMBER;
  l_ins  NUMBER;
  l_veh  NUMBER;
  l_veh2 NUMBER;
  l_job  NUMBER;
  l_job2 NUMBER;
  l_line NUMBER;
  l_inv  NUMBER;
  l_appt NUMBER;
  l_bay  NUMBER;
  l_onh  NUMBER;
  j      aut_job_card%ROWTYPE;

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION job(p_id NUMBER) RETURN aut_job_card%ROWTYPE IS
    l aut_job_card%ROWTYPE;
  BEGIN SELECT * INTO l FROM aut_job_card WHERE id = p_id; RETURN l; END job;
  FUNCTION cat(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN SELECT MIN(id) INTO l FROM inv_item_category WHERE code = p_code; RETURN l; END cat;
  FUNCTION line_of(p_job NUMBER, p_type VARCHAR2, p_ref NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM aut_job_line WHERE job_card_id = p_job AND line_type = p_type AND line_status <> 'CANCELLED'
       AND (p_ref IS NULL OR NVL(service_id, item_id) = p_ref);
    RETURN l;
  END line_of;
  FUNCTION jl(p_type VARCHAR2, p_entity NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT SUM(l.debit_amount) || '/' || SUM(l.credit_amount) INTO l
      FROM ace_accounting_event e JOIN gl_journal j ON j.accounting_event_id = e.id JOIN gl_journal_line l ON l.journal_id = j.id
     WHERE e.source_entity_type = p_type AND e.source_entity_id = p_entity AND e.reversal_of_event_id IS NULL;
    RETURN l;
  END jl;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  UPDATE dms_archive_rule SET is_active = 'N';

  -- ======================================================== الإعداد
  l_n := NOONA_AUT_PKG.quick_setup;
  ok('setup: revenue account 4160 and default bays', NOONA_INV_PKG.acc_id('4160') IS NOT NULL AND NOONA_AUT_PKG.is_ready = 'Y');
  SELECT MIN(id) INTO l_bay FROM aut_bay WHERE company_id = NOONA_AUT_PKG.company;
  l_box := NOONA_CSH_PKG.create_cash_box('AU' || SUBSTR(l_sfx, 1, 6), 'صندوق ورشة اختبار');
  l_wh := NOONA_AUT_PKG.default_warehouse;
  ok('default parts warehouse', l_wh IS NOT NULL);

  -- قطع الغيار: فلتر بباركود ورقم قطعة وتوافق، زيت، فحمات ولها بديل
  l_flt := NOONA_INV_PKG.save_item('{"name":"فلتر زيت تويوتا اختبار ' || l_sfx || '","cat":' || cat('AUTO') || ',"price":40,"brand":"Denso",'
           || '"mpn":"90915-YZ' || l_sfx || '","barcodes":["F' || l_sfx || '"],"fitment":[{"make":"Toyota","model":"Camry","from":2015,"to":2022}]}');
  l_oil := NOONA_INV_PKG.save_item('{"name":"زيت محرك 5W30 لتر اختبار ' || l_sfx || '","cat":' || cat('AUTO') || ',"price":30,"brand":"Mobil"}');
  l_pad2 := NOONA_INV_PKG.save_item('{"name":"فحمات فرامل تجاري اختبار ' || l_sfx || '","cat":' || cat('AUTO') || ',"price":120,"mpn":"BP2-' || l_sfx || '"}');
  l_pad := NOONA_INV_PKG.save_item('{"name":"فحمات فرامل أمامي أصلي اختبار ' || l_sfx || '","cat":' || cat('AUTO') || ',"price":200,"mpn":"BP1-' || l_sfx || '",'
           || '"fitment":[{"make":"Nissan","model":"Sunny"}],"alternates":[{"no":"BP2-' || l_sfx || '"}]}');
  l_n := NOONA_INV_PKG.save_stock_doc('{"type":"OPENING","date":"' || l_d || '","wh":' || l_wh || ',"action":"POST","lines":[{"i":' || l_flt || ',"q":10,"c":20},'
           || '{"i":' || l_oil || ',"q":40,"c":15},{"i":' || l_pad || ',"q":4,"c":110},{"i":' || l_pad2 || ',"q":6,"c":60}]}');
  ok('opening stock', NOONA_INV_PKG.on_hand(l_flt, l_wh) = 10 AND NOONA_INV_PKG.on_hand(l_oil, l_wh) = 40);

  -- الفئات والخدمات (الكروت) وقطعها الافتراضية
  l_cat := NOONA_AUT_PKG.save_category('{"code":"MECH' || SUBSTR(l_sfx, 1, 5) || '","name":"ميكانيكا اختبار","icon":"fa-cogs","color":"#1565c0"}');
  l_svc1 := NOONA_AUT_PKG.save_service('{"code":"OIL' || SUBSTR(l_sfx, 1, 6) || '","name":"تغيير زيت اختبار ' || l_sfx || '","cat":' || l_cat
            || ',"price":100,"minutes":30,"nextDays":90,"nextKm":5000,"parts":[{"item":' || l_flt || ',"qty":1},{"item":' || l_oil || ',"qty":4},'
            || '{"item":' || l_pad || ',"qty":1,"optional":"Y"}]}');
  l_svc2 := NOONA_AUT_PKG.save_service('{"code":"BRK' || SUBSTR(l_sfx, 1, 6) || '","name":"صيانة فرامل اختبار ' || l_sfx || '","cat":' || l_cat
            || ',"price":200,"minutes":60}');
  SELECT COUNT(*) INTO l_n FROM aut_service_part WHERE service_id = l_svc1;
  ok('service saved with default parts', l_n = 3);
  BEGIN l_x := NOONA_AUT_PKG.save_service('{"code":"BAD' || SUBSTR(l_sfx, 1, 6) || '","name":"خدمة سالبة","cat":' || l_cat || ',"price":-5}'); ok('negative service price rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('negative service price rejected', SQLERRM LIKE '%AUT-0%', SQLERRM); END;
  l_c := NOONA_AUT_PKG.boot_json;
  ok('boot json: service cards by category', DBMS_LOB.INSTR(l_c, '"id":' || l_svc1 || ',"name"') > 0 AND DBMS_LOB.INSTR(l_c, '"bays":[{') > 0);

  l_tech := NOONA_AUT_PKG.save_technician('{"code":"T' || SUBSTR(l_sfx, 1, 6) || '","name":"فني اختبار ' || l_sfx || '","specialty":"ميكانيكا","hourly":50,"commission":10}');
  l_ins := NOONA_AUT_PKG.save_insurer('{"code":"I' || SUBSTR(l_sfx, 1, 6) || '","name":"تأمين اختبار ' || l_sfx || '","laborDisc":10,"partsDisc":5,"deductible":100,"claimDays":45}');
  SELECT COUNT(*) INTO l_n FROM aut_insurer WHERE id = l_ins AND customer_account_id IS NOT NULL;
  ok('insurer gets a receivable account', l_n = 1);

  -- ======================================================== المركبات
  ok('plate key normalises spaces, dashes and Arabic digits', NOONA_AUT_PKG.plate_key('أ ب-ج ١٢٣٤') = NOONA_AUT_PKG.plate_key('أبج1234'));
  l_veh := NOONA_AUT_PKG.save_vehicle('{"plate":"ت س ' || SUBSTR(l_sfx, 1, 4) || '","make":"Toyota","model":"Camry","year":2019,"color":"أبيض",'
           || '"vin":"JT2BF22K1Y0' || SUBSTR(l_sfx, 1, 6) || '","ownerName":"مالك اختبار ' || l_sfx || '","ownerPhone":"056' || SUBSTR(l_sfx, 1, 7) || '","odometer":50000}');
  ok('vehicle found by plate ignoring spaces', NOONA_AUT_PKG.vehicle_by_plate('تس' || SUBSTR(l_sfx, 1, 4)) = l_veh);
  SELECT COUNT(*) INTO l_n FROM aut_vehicle WHERE id = l_veh AND customer_account_id IS NOT NULL;
  ok('owner customer account created', l_n = 1);
  BEGIN l_x := NOONA_AUT_PKG.save_vehicle('{"plate":"ت-س-' || SUBSTR(l_sfx, 1, 4) || '","make":"Kia"}'); ok('duplicate plate rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('duplicate plate rejected', SQLERRM LIKE '%AUT-02%', SQLERRM); END;
  ok('find vehicles by phone', INSTR(NOONA_AUT_PKG.find_vehicles_json('056' || SUBSTR(l_sfx, 1, 7)), '"id":' || l_veh) > 0);

  -- ======================================================== البحث عن القطع
  ok('parts search by barcode', JSON_VALUE(NOONA_AUT_PKG.search_parts_json('F' || l_sfx), '$[0].id') = l_flt);
  ok('parts search by part number without dash', JSON_VALUE(NOONA_AUT_PKG.search_parts_json('90915YZ' || l_sfx), '$[0].id') = l_flt);
  ok('parts search by name fragments in any order', INSTR(NOONA_AUT_PKG.search_parts_json('تويوتا فلتر ' || l_sfx), '"id":' || l_flt || ',') > 0);
  ok('parts search by brand', INSTR(NOONA_AUT_PKG.search_parts_json('mobil ' || l_sfx), '"id":' || l_oil || ',') > 0);
  l_c := NOONA_AUT_PKG.search_parts_json('BP1-' || l_sfx);
  ok('parts search returns alternates', INSTR(l_c, '"id":' || l_pad2 || ',') > 0 AND INSTR(l_c, '"alt":"Y"') > 0);

  -- ======================================================== أمر إصلاح نقدي
  l_job := NOONA_AUT_PKG.open_job('{"vehicle":' || l_veh || ',"odometer":51200,"fuel":"HALF","complaint":"تغيير زيت وصوت في الفرامل",'
           || '"promised":"' || TO_CHAR(SYSDATE + 1 / 24, 'YYYY-MM-DD HH24:MI') || '","services":[' || l_svc1 || ']}');
  j := job(l_job);
  ok('job card opened with number', j.doc_no LIKE 'JC-%' AND j.status_code = 'OPEN' AND j.customer_account_id IS NOT NULL, j.doc_no || ' ' || j.status_code);
  SELECT COUNT(*) INTO l_n FROM aut_job_line WHERE job_card_id = l_job AND line_type = 'PART' AND parent_line_id IS NOT NULL;
  ok('service card adds its mandatory parts only', l_n = 2);
  ok('job totals: service 100 + filter 40 + oil 4x30', j.services_amount = 100 AND j.parts_amount = 160, j.services_amount || '/' || j.parts_amount);
  ok('parts search flags fitment for the job vehicle', JSON_VALUE(NOONA_AUT_PKG.search_parts_json('F' || l_sfx, l_job), '$[0].fits') = 'Y');
  BEGIN l_x := NOONA_AUT_PKG.open_job('{"vehicle":' || l_veh || ',"odometer":51300}'); ok('one open job per vehicle', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('one open job per vehicle', 'AUT-042', SQLERRM); END;
  l_x := NOONA_AUT_PKG.add_part(l_job, l_pad2, 4);
  BEGIN l_n := NOONA_AUT_PKG.add_part(l_job, l_pad2, 3); ok('stock check counts parts already on the job', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('stock check counts parts already on the job', 'AUT-033', SQLERRM); END;
  NOONA_AUT_PKG.update_line('{"id":' || l_x || ',"qty":2}');
  SELECT quantity INTO l_n FROM aut_job_line WHERE id = l_x;
  ok('part quantity updated', l_n = 2);
  NOONA_AUT_PKG.remove_line(l_x);
  SELECT COUNT(*) INTO l_n FROM aut_job_line WHERE id = l_x;
  ok('part line removed', l_n = 0 AND job(l_job).parts_amount = 160);
  l_x := NOONA_AUT_PKG.add_line('{"job":' || l_job || ',"type":"SUBLET","desc":"خراطة هوبات خارجية","qty":1,"price":50}');
  ok('sublet line added', job(l_job).services_amount = 150, job(l_job).services_amount);
  l_line := line_of(l_job, 'SERVICE', l_svc1);
  BEGIN NOONA_AUT_PKG.line_action(l_line, 'START'); ok('technician required to start', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('technician required to start', 'AUT-039', SQLERRM); END;
  BEGIN NOONA_AUT_PKG.set_job_status(l_job, 'COMPLETED'); ok('cannot complete with pending services', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('cannot complete with pending services', SQLERRM LIKE '%AUT-04%', SQLERRM); END;
  NOONA_AUT_PKG.update_line('{"id":' || l_line || ',"tech":' || l_tech || '}');
  NOONA_AUT_PKG.line_action(l_line, 'START');
  ok('starting a line starts the job', job(l_job).status_code = 'IN_PROGRESS' AND job(l_job).started_at IS NOT NULL);
  NOONA_AUT_PKG.line_action(l_line, 'DONE');
  NOONA_AUT_PKG.update_line('{"id":' || l_line || ',"minutes":35}');
  SELECT line_status || '|' || work_minutes INTO l_s FROM aut_job_line WHERE id = l_line;
  ok('line done with technician and minutes', l_s = 'DONE|35', l_s);
  NOONA_AUT_PKG.update_line('{"id":' || l_x || ',"tech":' || l_tech || '}');
  NOONA_AUT_PKG.line_action(l_x, 'DONE');
  NOONA_AUT_PKG.update_job('{"id":' || l_job || ',"diagnosis":"تآكل الفحمات","recommendations":"تغيير الفحمات خلال شهر"}');
  ok('diagnosis saved', job(l_job).diagnosis = 'تآكل الفحمات');
  BEGIN l_n := NOONA_AUT_PKG.invoice_job(l_job); ok('only completed jobs are invoiced', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('only completed jobs are invoiced', 'AUT-050', SQLERRM); END;
  NOONA_AUT_PKG.set_job_status(l_job, 'COMPLETED');
  j := job(l_job);
  ok('completed: next service date and km computed', j.status_code = 'COMPLETED' AND j.next_service_date = TRUNC(SYSDATE) + 90 AND j.next_service_km = 56200,
     j.next_service_date || ' ' || j.next_service_km);
  l_c := NOONA_AUT_PKG.job_json(l_job);
  ok('job json: header, vehicle and lines', JSON_VALUE(l_c, '$.job.no') = j.doc_no AND JSON_VALUE(l_c, '$.vehicle.id') = l_veh
     AND JSON_EXISTS(l_c, '$.lines[3]'));
  l_onh := NOONA_INV_PKG.on_hand(l_oil, l_wh);
  l_inv := NOONA_AUT_PKG.invoice_job(l_job, '{"place":"BOX:' || l_box || '","method":"CASH"}');
  j := job(l_job);
  SELECT status_code || '|' || subtotal || '|' || total_amount INTO l_s FROM sal_invoice WHERE id = l_inv;
  ok('one invoice with services and parts', j.sales_invoice_id = l_inv AND j.status_code = 'INVOICED' AND l_s LIKE 'PAID|310|%', l_s);
  SELECT total_amount INTO l_n FROM sal_invoice WHERE id = l_inv;
  ok('invoice total equals job total', j.total_amount = l_n, j.total_amount || ' ' || l_s);
  SELECT COUNT(*) INTO l_n FROM sal_invoice_line WHERE invoice_id = l_inv;
  ok('invoice lines: service, sublet, two parts', l_n = 4, l_n);
  ok('parts issued from stock', NOONA_INV_PKG.on_hand(l_oil, l_wh) = l_onh - 4 AND NOONA_INV_PKG.on_hand(l_flt, l_wh) = 9);
  SELECT COUNT(*) INTO l_n FROM aut_job_line WHERE job_card_id = l_job AND line_type = 'PART' AND unit_cost > 0;
  ok('part cost captured for margin reports', l_n = 2);
  ok('cash box received the invoice', NOONA_CSH_PKG.balance(l_box, NULL) = j.total_amount);
  l_s := jl('SAL_INVOICE', l_inv);
  ok('balanced sales journal', REGEXP_SUBSTR(l_s, '^[^/]+') = REGEXP_SUBSTR(l_s, '[^/]+$'), l_s);
  BEGIN NOONA_AUT_PKG.update_line('{"id":' || l_line || ',"qty":2}'); ok('invoiced job is locked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('invoiced job is locked', 'AUT-031', SQLERRM); END;
  ok('printable job card', DBMS_LOB.INSTR(NOONA_AUT_PKG.job_print(l_job), j.doc_no) > 0);
  NOONA_AUT_PKG.deliver_job(l_job, 51210);
  SELECT odometer || '|' || TO_CHAR(next_service_date, 'YYYY-MM-DD') || '|' || next_service_km INTO l_s FROM aut_vehicle WHERE id = l_veh;
  ok('delivery updates the vehicle odometer and next service', job(l_job).status_code = 'DELIVERED' AND l_s = '51210|' || TO_CHAR(SYSDATE + 90, 'YYYY-MM-DD') || '|56200', l_s);
  ok('vehicle history shows the visit', DBMS_LOB.INSTR(NOONA_AUT_PKG.vehicle_html(l_veh), j.doc_no) > 0);
  BEGIN l_x := NOONA_AUT_PKG.open_job('{"vehicle":' || l_veh || ',"odometer":40000}'); ok('odometer cannot go back', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('odometer cannot go back', 'AUT-043', SQLERRM); END;

  -- ======================================================== أمر إصلاح على التأمين
  BEGIN l_x := NOONA_AUT_PKG.open_job('{"plate":"ن ج ' || SUBSTR(l_sfx, 1, 4) || '","make":"Nissan","payer":"INSURANCE","odometer":1000}'); ok('insurer required', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('insurer required', 'AUT-044', SQLERRM); END;
  l_job2 := NOONA_AUT_PKG.open_job('{"plate":"ن ج ' || SUBSTR(l_sfx, 1, 4) || '","make":"Nissan","model":"Sunny","year":2020,"ownerName":"عميل حادث ' || l_sfx
            || '","ownerPhone":"057' || SUBSTR(l_sfx, 1, 7) || '","payer":"INSURANCE","insurer":' || l_ins || ',"claim":"CLM-' || l_sfx || '",'
            || '"accident":"NJM-' || l_sfx || '","odometer":30000,"services":[' || l_svc2 || ']}');
  j := job(l_job2);
  l_veh2 := j.vehicle_id;
  ok('new plate creates the vehicle at check-in', NOONA_AUT_PKG.vehicle_by_plate('نج' || SUBSTR(l_sfx, 1, 4)) = l_veh2);
  ok('insurance job takes default deductible', j.payer_type = 'INSURANCE' AND j.deductible_amount = 100 AND j.claim_status = 'NOT_SUBMITTED',
     j.deductible_amount || ' ' || j.claim_status);
  l_x := NOONA_AUT_PKG.add_part(l_job2, l_pad, 1);
  j := job(l_job2);
  ok('insurer agreed discounts on labour (10%) and parts (5%)', j.services_amount = 180 AND j.parts_amount = 190, j.services_amount || '/' || j.parts_amount);
  ok('parts search flags non-fitting part for this vehicle', JSON_VALUE(NOONA_AUT_PKG.search_parts_json('F' || l_sfx, l_job2), '$[0].fits') = 'N');
  l_line := line_of(l_job2, 'SERVICE', l_svc2);
  NOONA_AUT_PKG.update_line('{"id":' || l_line || ',"tech":' || l_tech || '}');
  NOONA_AUT_PKG.line_action(l_line, 'START');
  NOONA_AUT_PKG.line_action(l_line, 'DONE');
  NOONA_AUT_PKG.set_claim('{"job":' || l_job2 || ',"claimStatus":"PARTIALLY_APPROVED","approved":300}');
  NOONA_AUT_PKG.set_job_status(l_job2, 'COMPLETED');
  l_inv := NOONA_AUT_PKG.invoice_job(l_job2);
  j := job(l_job2);
  SELECT MAX(subtotal) INTO l_n FROM sal_invoice WHERE id = j.insurer_invoice_id;
  ok('insurer invoiced approved amount less deductible', l_n = 200, l_n);
  SELECT MAX(subtotal) INTO l_n FROM sal_invoice WHERE id = j.sales_invoice_id;
  ok('customer invoiced the rest (deductible + not approved)', l_n = 170, l_n);
  SELECT COUNT(*) INTO l_n FROM sal_invoice i JOIN aut_insurer s ON s.customer_account_id = i.customer_account_id
   WHERE i.id = j.insurer_invoice_id AND s.id = l_ins AND i.payment_mode = 'CREDIT';
  ok('insurer invoice is on credit to the insurer account', l_n = 1);
  ok('claim submitted on invoicing', j.claim_status IN ('SUBMITTED', 'PARTIALLY_APPROVED'), j.claim_status);
  ok('claims list shows the claim', DBMS_LOB.INSTR(NOONA_AUT_PKG.claims_html(l_ins), 'CLM-' || l_sfx) > 0);
  NOONA_AUT_PKG.set_claim('{"job":' || l_job2 || ',"claimStatus":"PAID"}');
  ok('claim paid', job(l_job2).claim_status = 'PAID');
  BEGIN NOONA_AUT_PKG.set_claim('{"job":' || l_job2 || ',"approved":999}'); ok('approved amount locked after invoicing', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('approved amount locked after invoicing', 'AUT-056', SQLERRM); END;

  -- ======================================================== الحجوزات
  l_appt := NOONA_AUT_PKG.book('{"start":"' || TO_CHAR(TRUNC(SYSDATE) + 2 + 10 / 24, 'YYYY-MM-DD HH24:MI') || '","bay":' || l_bay || ',"plate":"ك ل ' || SUBSTR(l_sfx, 1, 4)
            || '","name":"عميل حجز","phone":"058' || SUBSTR(l_sfx, 1, 7) || '","services":[' || l_svc1 || ',' || l_svc2 || '],"source":"WHATSAPP"}');
  SELECT doc_no || '|' || ROUND((CAST(end_at AS DATE) - CAST(start_at AS DATE)) * 1440) INTO l_s FROM aut_appointment WHERE id = l_appt;
  ok('booking duration from service minutes', l_s LIKE 'BK-%|90', l_s);
  BEGIN l_x := NOONA_AUT_PKG.book('{"start":"' || TO_CHAR(TRUNC(SYSDATE) + 2 + 11 / 24, 'YYYY-MM-DD HH24:MI') || '","bay":' || l_bay || ',"plate":"X1","name":"x","minutes":30}');
    ok('bay overlap rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('bay overlap rejected', 'AUT-063', SQLERRM); END;
  ok('day appointments list', DBMS_LOB.INSTR(NOONA_AUT_PKG.appointments_html(TRUNC(SYSDATE) + 2), 'عميل حجز') > 0);
  NOONA_AUT_PKG.set_appointment_status(l_appt, 'CONFIRMED');
  l_x := NOONA_AUT_PKG.check_in(l_appt, '{"odometer":12000,"make":"Kia"}');
  SELECT status_code || '|' || job_card_id INTO l_s FROM aut_appointment WHERE id = l_appt;
  ok('check-in from booking opens the job with its services', l_s = 'ARRIVED|' || l_x AND line_of(l_x, 'SERVICE', l_svc2) IS NOT NULL, l_s);
  NOONA_AUT_PKG.set_job_status(l_x, 'CANCELLED', 'العميل اعتذر');
  ok('job cancelled with reason', job(l_x).status_code = 'CANCELLED');
  l_appt := NOONA_AUT_PKG.book('{"start":"' || TO_CHAR(SYSDATE + 5, 'YYYY-MM-DD') || ' 08:00","plate":"م ن ' || SUBSTR(l_sfx, 1, 4) || '","name":"متأخر","minutes":30}');
  UPDATE aut_appointment SET start_at = SYSTIMESTAMP - INTERVAL '4' HOUR, end_at = SYSTIMESTAMP - INTERVAL '3' HOUR WHERE id = l_appt;  -- موعد فات
  l_n := NOONA_AUT_PKG.mark_no_shows;
  SELECT status_code INTO l_s FROM aut_appointment WHERE id = l_appt;
  ok('late bookings marked no-show', l_s = 'NO_SHOW' AND l_n >= 1, l_s);

  -- ======================================================== اللوحات والتقارير
  ok('dashboard KPIs', DBMS_LOB.INSTR(NOONA_AUT_PKG.summary_html, 'nn-kpi') > 0);
  ok('workshop board', DBMS_LOB.INSTR(NOONA_AUT_PKG.board_html, 'nn-aut-col') > 0);
  l_c := NOONA_AUT_PKG.report_html('TOP_SERVICES', TRUNC(SYSDATE, 'MM'), SYSDATE);
  ok('most requested services', DBMS_LOB.INSTR(l_c, 'تغيير زيت اختبار ' || l_sfx) > 0);
  l_c := NOONA_AUT_PKG.report_html('TOP_PARTS', TRUNC(SYSDATE, 'YYYY'), SYSDATE);
  ok('best selling parts', DBMS_LOB.INSTR(l_c, 'زيت محرك 5W30 لتر اختبار ' || l_sfx) > 0);
  l_c := NOONA_AUT_PKG.report_html('SUMMARY', TRUNC(SYSDATE), SYSDATE);
  ok('operations summary (services + parts)', DBMS_LOB.INSTR(l_c, TO_CHAR(SYSDATE, 'YYYY-MM-DD')) > 0);
  ok('services report', DBMS_LOB.INSTR(NOONA_AUT_PKG.report_html('SERVICES', TRUNC(SYSDATE), SYSDATE), 'خراطة هوبات') > 0);
  ok('parts report', DBMS_LOB.INSTR(NOONA_AUT_PKG.report_html('PARTS', TRUNC(SYSDATE), SYSDATE), '90915-YZ') = 0
     AND DBMS_LOB.INSTR(NOONA_AUT_PKG.report_html('PARTS', TRUNC(SYSDATE), SYSDATE), 'فلتر زيت تويوتا اختبار ' || l_sfx) > 0);
  ok('technicians report', DBMS_LOB.INSTR(NOONA_AUT_PKG.report_html('TECHNICIANS', TRUNC(SYSDATE), SYSDATE), 'فني اختبار ' || l_sfx) > 0);
  ok('stay report', DBMS_LOB.INSTR(NOONA_AUT_PKG.report_html('STAY', TRUNC(SYSDATE), SYSDATE), job(l_job).doc_no) > 0);
  ok('insurance report', DBMS_LOB.INSTR(NOONA_AUT_PKG.report_html('INSURANCE', TRUNC(SYSDATE), SYSDATE), 'تأمين اختبار ' || l_sfx) > 0);
  ok('appointments report', DBMS_LOB.INSTR(NOONA_AUT_PKG.report_html('APPOINTMENTS', TRUNC(SYSDATE), SYSDATE + 3), 'واتساب') > 0);
  ok('due services report', DBMS_LOB.INSTR(NOONA_AUT_PKG.report_html('DUE', TRUNC(SYSDATE), SYSDATE + 100), 'خدمة دورية') > 0);
  ok('makes report', DBMS_LOB.INSTR(NOONA_AUT_PKG.report_html('MAKES', TRUNC(SYSDATE), SYSDATE), 'Nissan') > 0);
  ok('vehicles report', DBMS_LOB.INSTR(NOONA_AUT_PKG.report_html('VEHICLES', TRUNC(SYSDATE), SYSDATE), 'Camry') > 0);

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
