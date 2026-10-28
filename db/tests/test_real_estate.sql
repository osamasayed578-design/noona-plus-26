-- =============================================================================
-- NOONA PLUS ERP | اختبار التطوير العقاري وبيع الوحدات وإدارة الأملاك:
--   قوائم الأسعار وخطط السداد، الحجز بعربون وإلغاؤه بالمصادرة، العقد وجدول أقساطه، التوقيع وتطبيق العربون، فوترة الأقساط وتحصيلها،
--   عمولة الوسيط وأهليتها وسدادها، رسملة تكاليف التطوير، التسليم والاعتراف بالإيراد والتكلفة، الإفراغ، الفسخ؛
--   عقود الإيجار وجدولها والزيادة السنوية، الفوترة والتحصيل والتأخير، التأمين واستلامه وتسويته، التجديد والإنهاء والانتهاء،
--   العدادات وفوترة الاستهلاك، اتفاقية إدارة أملاك الغير وكشف المالك وتحويله (بحساب NOONA_APP - يتراجع عن كل التغييرات)
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_real_estate.sql
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
  l_bal  NUMBER;
  l_prop NUMBER;
  l_u1   NUMBER; l_u2 NUMBER; l_u3 NUMBER; l_u4 NUMBER; l_u5 NUMBER;
  l_pl   NUMBER;
  l_plan NUMBER;
  l_buyer NUMBER;
  l_broker NUMBER;
  l_r1   NUMBER; l_r2 NUMBER; l_r3 NUMBER;
  l_ct   NUMBER; l_ct2 NUMBER; l_ct3 NUMBER;
  l_inv  NUMBER;
  l_com  NUMBER;
  l_prj  NUMBER;
  l_ho   NUMBER;
  l_cust NUMBER;
  l_lp   NUMBER;
  l_lu1  NUMBER; l_lu2 NUMBER; l_lu3 NUMBER; l_lu4 NUMBER;
  l_agr  NUMBER;
  l_ls1  NUMBER; l_ls2 NUMBER; l_ls3 NUMBER; l_ls4 NUMBER; l_ren NUMBER;
  l_dep  NUMBER;
  l_met  NUMBER;
  l_st   NUMBER;
  l_start DATE := ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -2);
  c      re_sale_contract%ROWTYPE;

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION ctr(p_id NUMBER) RETURN re_sale_contract%ROWTYPE IS
    l re_sale_contract%ROWTYPE;
  BEGIN SELECT * INTO l FROM re_sale_contract WHERE id = p_id; RETURN l; END ctr;
  FUNCTION ustat(p_id NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN SELECT status_code INTO l FROM re_unit WHERE id = p_id; RETURN l; END ustat;
  -- حسابات قيد حدث: كود:مدين/دائن مرتبة
  FUNCTION jl(p_event NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT LISTAGG(code || ':' || dr || '/' || cr, ' ') WITHIN GROUP (ORDER BY code) INTO l FROM (
      SELECT a.account_code code, SUM(l.debit_amount) dr, SUM(l.credit_amount) cr FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
        JOIN gl_account a ON a.id = l.account_id WHERE j.accounting_event_id = p_event GROUP BY a.account_code);
    RETURN l;
  END jl;
  FUNCTION ev(p_entity VARCHAR2, p_id NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) INTO l FROM ace_accounting_event WHERE source_entity_type = p_entity AND source_entity_id = p_id AND reversal_of_event_id IS NULL
       AND status_code = 'POSTED';
    RETURN l;
  END ev;
  FUNCTION inv_acc(p_inv NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(a.account_code) INTO l FROM sal_invoice_line s JOIN gl_account a ON a.id = s.revenue_account_id WHERE s.invoice_id = p_inv;
    RETURN l;
  END inv_acc;
  PROCEDURE pay(p_inv NUMBER, p_amt NUMBER) IS
    l_id NUMBER;
    l_cu NUMBER;
    l_oi NUMBER;
  BEGIN
    SELECT customer_account_id INTO l_cu FROM sal_invoice WHERE id = p_inv;
    SELECT MIN(id) INTO l_oi FROM ar_open_item WHERE source_entity_type = 'SAL_INVOICE' AND source_entity_id = p_inv;
    l_id := NOONA_SAL_PKG.receive('{"cust":' || l_cu || ',"date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '","amount":' || p_amt || ',"place":"BOX:' || l_box
                                  || '","method":"CASH","alloc":[{"inv":' || l_oi || ',"a":' || p_amt || '}]}');
  END pay;
  -- تمويل صندوق الاختبار (الصرف فوق الرصيد ممنوع): مقبوضات مقدمة من عميل
  PROCEDURE fund(p_amt NUMBER) IS
    l_fc NUMBER;
    l_fr NUMBER;
  BEGIN
    l_fc := NOONA_SAL_PKG.save_customer('{"name":"ممول صندوق اختبار ' || l_sfx || '-' || p_amt || '","term":"NET0"}');
    l_fr := NOONA_SAL_PKG.receive('{"cust":' || l_fc || ',"amount":' || p_amt || ',"place":"BOX:' || l_box || '","method":"CASH"}');
  END fund;
BEGIN
  NOONA_APEX_PKG.cleanup_request;
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  UPDATE dms_archive_rule SET is_active = 'N';
  UPDATE loc_einvoice_profile SET status_code = 'SUSPENDED' WHERE company_id = NOONA_RES_PKG.company;
  l_box := NOONA_CSH_PKG.create_cash_box('RB' || SUBSTR(l_sfx, 1, 6), 'صندوق عقارات اختبار');
  fund(2000000);
  l_n := NOONA_RES_PKG.setup_accounts + NOONA_PRP_PKG.setup_accounts;
  ok('real estate accounts ready', NOONA_INV_PKG.acc_id('2150') IS NOT NULL AND NOONA_INV_PKG.acc_id('4140') IS NOT NULL AND NOONA_INV_PKG.acc_id('1150') IS NOT NULL
     AND NOONA_INV_PKG.acc_id('4150') IS NOT NULL AND NOONA_INV_PKG.acc_id('2153') IS NOT NULL AND NOONA_INV_PKG.acc_id('2154') IS NOT NULL);

  -- ======================================================== المشروع والوحدات
  l_prop := NOONA_RE_PKG.setup_wizard('{"name_ar":"أبراج اختبار ' || l_sfx || '","type":"TOWER","buildings":[{"code":"T","name":"البرج","floors":2}],'
            || '"units":{"per_floor":3,"unit_type":"APARTMENT","usage_type":"SALE","bedrooms":3,"area":120,"price":600000}}');
  SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY code), MAX(id) KEEP (DENSE_RANK LAST ORDER BY code) INTO l_u1, l_u5 FROM re_unit WHERE property_id = l_prop;
  SELECT id INTO l_u2 FROM re_unit WHERE property_id = l_prop AND code = '102';
  SELECT id INTO l_u3 FROM re_unit WHERE property_id = l_prop AND code = '103';
  SELECT id INTO l_u4 FROM re_unit WHERE property_id = l_prop AND code = '201';
  UPDATE re_unit SET unit_type = 'SHOP' WHERE id = l_u4;
  SELECT COUNT(*) INTO l_n FROM re_unit WHERE property_id = l_prop AND usage_type = 'SALE';
  ok('6 units for sale', l_n = 6, l_n);

  -- ======================================================== الأسعار وخطط السداد
  BEGIN l_n := NOONA_RES_PKG.save_price_list('{"property":' || l_prop || ',"name":"x","lines":[{"unit":' || l_u1 || ',"price":100,"min":200}]}');
    ok('min above price rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('min above price rejected', 'NOONA-RES-012', SQLERRM); END;
  l_pl := NOONA_RES_PKG.save_price_list('{"property":' || l_prop || ',"name":"قائمة الإطلاق","lines":[{"unit":' || l_u1 || ',"price":650000,"min":620000},'
          || '{"unit":' || l_u2 || ',"price":640000},{"unit":' || l_u3 || ',"price":630000},{"unit":' || l_u4 || ',"price":900000}]}');
  ok('draft list does not change prices', NOONA_RES_PKG.unit_price(l_u1) = 600000, NOONA_RES_PKG.unit_price(l_u1));
  NOONA_RES_PKG.activate_price_list(l_pl);
  SELECT list_price INTO l_n FROM re_unit WHERE id = l_u1;
  ok('active list prices units', NOONA_RES_PKG.unit_price(l_u1) = 650000 AND l_n = 650000 AND NOONA_RES_PKG.unit_min_price(l_u1) = 620000);
  SELECT price_per_sqm INTO l_n FROM re_price_list_line WHERE price_list_id = l_pl AND unit_id = l_u1;
  ok('price per sqm computed', ROUND(l_n, 2) = ROUND(650000 / 120, 2), l_n);
  BEGIN l_n := NOONA_RES_PKG.save_plan('{"name":"x","down":70,"handover":40}'); ok('plan over 100% rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('plan over 100% rejected', 'NOONA-RES-016', SQLERRM); END;
  l_plan := NOONA_RES_PKG.save_plan('{"name":"10% مقدم و4 أقساط ربع سنوية و20% عند التسليم","property":' || l_prop || ',"down":10,"count":4,"freq":"QUARTERLY","handover":20}');
  SELECT COUNT(*), SUM(due_pct), MAX(offset_months) INTO l_n, l_x, l_bal FROM re_payment_plan_line WHERE payment_plan_id = l_plan;
  ok('plan lines: down + 4 quarterly + handover = 100%', l_n = 6 AND l_x = 100 AND l_bal = 12, l_n || '/' || l_x || '/' || l_bal);

  -- ======================================================== الحجز
  l_bal := NOONA_CSH_PKG.balance(l_box, NULL);
  l_r1 := NOONA_RES_PKG.reserve('{"unit":' || l_u1 || ',"buyerName":"مشتري اختبار ' || l_sfx || '","phone":"0551112233","deposit":20000,"place":"BOX:' || l_box || '","days":10}');
  SELECT buyer_party_id INTO l_buyer FROM re_reservation WHERE id = l_r1;
  ok('reservation active, unit reserved', ustat(l_u1) = 'RESERVED');
  ok('deposit journal: Dr box, Cr 2151', jl(ev('RE_RESERVATION', l_r1)) LIKE '%2151:0/20000%', jl(ev('RE_RESERVATION', l_r1)));
  ok('deposit in cash box', NOONA_CSH_PKG.balance(l_box, NULL) = l_bal + 20000);
  BEGIN l_n := NOONA_RES_PKG.reserve('{"unit":' || l_u1 || ',"buyer":' || l_buyer || '}'); ok('reserved unit cannot be reserved again', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('reserved unit cannot be reserved again', 'NOONA-RES-020', SQLERRM); END;
  BEGIN l_n := NOONA_RES_PKG.reserve('{"unit":' || l_u2 || ',"buyer":' || l_buyer || ',"deposit":5000}'); ok('deposit needs a place', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('deposit needs a place', 'NOONA-RES-026', SQLERRM); END;
  -- إلغاء مع مصادرة جزء
  l_r2 := NOONA_RES_PKG.reserve('{"unit":' || l_u3 || ',"buyer":' || l_buyer || ',"deposit":10000,"place":"BOX:' || l_box || '"}');
  l_bal := NOONA_CSH_PKG.balance(l_box, NULL);
  NOONA_RES_PKG.cancel_reservation(l_r2, 'تراجع المشتري', 3000);
  SELECT status_code || '|' || refund_amount INTO l_s FROM re_reservation WHERE id = l_r2;
  ok('cancelled with refund 7000', l_s = 'REFUNDED|7000' AND ustat(l_u3) = 'AVAILABLE', l_s);
  ok('forfeit 3000 to income 4141', jl(ev('RE_RESERVATION', l_r2)) LIKE '%4141:0/3000%', jl(ev('RE_RESERVATION', l_r2)));
  ok('cash box refunded 7000', NOONA_CSH_PKG.balance(l_box, NULL) = l_bal - 7000, NOONA_CSH_PKG.balance(l_box, NULL) - l_bal);
  -- انتهاء الحجز
  l_r3 := NOONA_RES_PKG.reserve('{"unit":' || l_u3 || ',"buyer":' || l_buyer || '}');
  UPDATE re_reservation SET expires_at = SYSTIMESTAMP - 1 WHERE id = l_r3;
  ok('expired reservations released', NOONA_RES_PKG.expire_reservations >= 1 AND ustat(l_u3) = 'AVAILABLE');

  -- ======================================================== العقد
  l_broker := NOONA_PTY_PKG.create_party('PERSON', 'وسيط عقاري اختبار ' || l_sfx, 'BROKER');
  l_ct := NOONA_RES_PKG.create_contract('{"reservation":' || l_r1 || ',"plan":' || l_plan || ',"date":"' || l_d || '","handover":"'
          || TO_CHAR(ADD_MONTHS(SYSDATE, 12), 'YYYY-MM-DD') || '","broker":' || l_broker || ',"commission":2,"eligible":20}');
  c := ctr(l_ct);
  ok('contract from reservation: price, residential VAT exempt', c.sale_price = 650000 AND c.tax_amount = 0 AND c.total_amount = 650000 AND c.status_code = 'DRAFT',
     c.sale_price || '/' || c.tax_amount);
  SELECT status_code INTO l_s FROM re_reservation WHERE id = l_r1;
  ok('reservation converted', l_s = 'CONVERTED');
  SELECT COUNT(*), SUM(amount) INTO l_n, l_x FROM re_sale_installment WHERE contract_id = l_ct;
  ok('6 installments summing the price', l_n = 6 AND l_x = 650000, l_n || '/' || l_x);
  SELECT amount INTO l_x FROM re_sale_installment WHERE contract_id = l_ct AND installment_no = 1;
  ok('down payment 10%', l_x = 65000, l_x);
  SELECT commission_amount INTO l_x FROM re_broker_commission WHERE contract_id = l_ct;
  ok('commission 2% of net price', l_x = 13000, l_x);
  NOONA_RES_PKG.sign_contract(l_ct, TRUNC(SYSDATE), 'SAKANI-' || l_sfx);
  c := ctr(l_ct);
  ok('signed and registered, unit sold', c.status_code = 'REGISTERED' AND ustat(l_u1) = 'SOLD', c.status_code);
  SELECT sales_invoice_id INTO l_inv FROM re_sale_installment WHERE contract_id = l_ct AND installment_no = 1;
  ok('down payment invoiced on advances account 2150', l_inv IS NOT NULL AND inv_acc(l_inv) = '2150', inv_acc(l_inv));
  ok('deposit applied: collected 20000', NOONA_RES_PKG.collected(l_ct) = 20000, NOONA_RES_PKG.collected(l_ct));
  ok('deposit applied journal: Dr 2151, Cr AR', jl(ev('RE_DEPOSIT_APPLIED', l_ct)) LIKE '%2151:20000/0%', jl(ev('RE_DEPOSIT_APPLIED', l_ct)));
  SELECT id INTO l_com FROM re_broker_commission WHERE contract_id = l_ct;
  ok('commission accrued: Dr 5161, Cr 2152', jl(ev('RE_BROKER_COMMISSION', l_com)) = '2152:0/13000 5161:13000/0', jl(ev('RE_BROKER_COMMISSION', l_com)));
  pay(l_inv, 45000);
  NOONA_RES_PKG.refresh_installments(l_ct);
  SELECT status_code INTO l_s FROM re_sale_installment WHERE contract_id = l_ct AND installment_no = 1;
  ok('down payment paid', l_s = 'PAID' AND NOONA_RES_PKG.collected(l_ct) = 65000, l_s || ' ' || NOONA_RES_PKG.collected(l_ct));
  BEGIN NOONA_RES_PKG.approve_commission(l_com); ok('commission waits for 20% collection', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('commission waits for 20% collection', 'NOONA-RES-070', SQLERRM); END;
  ok('nothing else due today', NOONA_RES_PKG.bill_installments(l_ct) = 0);
  UPDATE re_sale_installment SET due_date = TRUNC(SYSDATE) - 1 WHERE contract_id = l_ct AND installment_no = 2;
  ok('due installment billed', NOONA_RES_PKG.bill_installments(l_ct) = 1);
  SELECT sales_invoice_id, amount INTO l_inv, l_x FROM re_sale_installment WHERE contract_id = l_ct AND installment_no = 2;
  pay(l_inv, l_x);
  NOONA_RES_PKG.refresh_installments(l_ct);
  SELECT status_code INTO l_s FROM re_broker_commission WHERE id = l_com;
  ok('commission eligible after 20% collected', l_s = 'ELIGIBLE', l_s || ' collected ' || NOONA_RES_PKG.collected(l_ct));
  NOONA_RES_PKG.approve_commission(l_com);
  BEGIN NOONA_RES_PKG.pay_commission(l_com, NULL); ok('commission payment needs a place', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('commission payment needs a place', 'NOONA-RES-072', SQLERRM); END;
  NOONA_RES_PKG.pay_commission(l_com, 'BOX:' || l_box);
  ok('commission paid: Dr 2152, Cr box', jl(ev('RE_COMMISSION_PAYMENT', l_com)) LIKE '%2152:13000/0%');

  -- ======================================================== رسملة التكاليف والتسليم
  BEGIN l_n := NOONA_RES_PKG.capitalize_costs(l_prop); ok('capitalization needs a development project', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('capitalization needs a development project', 'NOONA-RES-080', SQLERRM); END;
  l_prj := NOONA_PRJ_PKG.save_project('{"name":"تطوير أبراج اختبار","type":"REAL_ESTATE_DEVELOPMENT","property":' || l_prop || '}');
  l_n := NOONA_PRJ_PKG.post_expense('{"project":' || l_prj || ',"type":"OTHER","amount":300000,"place":"BOX:' || l_box || '","desc":"أعمال الهيكل"}');
  l_x := NOONA_RES_PKG.capitalize_costs(l_prop, 'UNIT_COUNT');
  ok('development cost capitalized: Dr 1150, Cr 5150', jl(ev('RE_COST_ALLOCATION', l_x)) = '1150:300000/0 5150:0/300000', jl(ev('RE_COST_ALLOCATION', l_x)));
  ok('unit cost by unit count', NOONA_RES_PKG.unit_cost(l_u1) = 50000, NOONA_RES_PKG.unit_cost(l_u1));
  BEGIN l_n := NOONA_RES_PKG.capitalize_costs(l_prop); ok('no double capitalization', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('no double capitalization', 'NOONA-RES-083', SQLERRM); END;
  l_ho := NOONA_RES_PKG.schedule_handover(l_ct, TRUNC(SYSDATE));
  NOONA_RES_PKG.save_snags(l_ho, '[{"item":"تشقق دهان غرفة النوم","status":"OPEN"},{"item":"مفتاح كهرباء المطبخ","status":"FIXED"}]');
  BEGIN NOONA_RES_PKG.complete_handover(l_ho, TRUNC(SYSDATE)); ok('open snags block handover', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('open snags block handover', 'NOONA-RES-062', SQLERRM); END;
  NOONA_RES_PKG.save_snags(l_ho, '[{"item":"تشقق دهان غرفة النوم","status":"FIXED"},{"item":"مفتاح كهرباء المطبخ","status":"FIXED"}]');
  NOONA_RES_PKG.complete_handover(l_ho, TRUNC(SYSDATE), 3, 'سلمت المفاتيح');
  c := ctr(l_ct);
  ok('handed over, revenue recognized', c.status_code = 'HANDED_OVER' AND c.revenue_recognized = 'Y' AND ustat(l_u1) = 'HANDED_OVER' AND c.unit_cost = 50000);
  l_s := jl(ev('RE_HANDOVER', l_ho));
  ok('revenue and cost journal: Dr 2150/Cr 4140 billed net, Dr 5160/Cr 1150 unit cost',
     l_s = '1150:0/50000 2150:' || (65000 + 113750) || '/0 4140:0/' || (65000 + 113750) || ' 5160:50000/0', l_s);
  ok('handover installment now due and billed to revenue', NOONA_RES_PKG.bill_installments(l_ct) = 1);
  SELECT sales_invoice_id INTO l_inv FROM re_sale_installment WHERE contract_id = l_ct AND label = 'دفعة التسليم';
  ok('post-handover billing credits 4140', inv_acc(l_inv) = '4140', inv_acc(l_inv));
  BEGIN l_n := NOONA_RES_PKG.transfer_title(l_ct, '{"deed":"D-' || l_sfx || '"}'); ok('title needs full payment', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('title needs full payment', 'NOONA-RES-066', SQLERRM); END;
  l_n := NOONA_RES_PKG.transfer_title(l_ct, '{"deed":"D-' || l_sfx || '","ref":"MOJ-1","fees":0,"financed":"Y"}');
  SELECT owner_party_id || '|' || title_deed_no INTO l_s FROM re_unit WHERE id = l_u1;
  ok('title transferred to buyer', l_s = l_buyer || '|D-' || l_sfx AND ctr(l_ct).status_code = 'TITLE_TRANSFERRED', l_s);
  SELECT COUNT(*) INTO l_n FROM re_unit_ownership WHERE unit_id = l_u1 AND owner_party_id = l_buyer AND effective_to IS NULL;
  ok('ownership history recorded', l_n = 1);

  -- ======================================================== الضريبة والفسخ
  l_ct2 := NOONA_RES_PKG.create_contract('{"unit":' || l_u4 || ',"buyer":' || l_buyer || ',"plan":' || l_plan || ',"date":"' || l_d || '"}');
  c := ctr(l_ct2);
  ok('commercial unit taxed 15%', c.tax_amount = 135000 AND c.total_amount = 1035000, c.tax_amount);
  NOONA_RES_PKG.sign_contract(l_ct2);
  SELECT sales_invoice_id INTO l_inv FROM re_sale_installment WHERE contract_id = l_ct2 AND installment_no = 1;
  SELECT tax_amount INTO l_x FROM sal_invoice WHERE id = l_inv;
  ok('down payment invoice carries VAT', l_x = 13500, l_x);
  SELECT COUNT(*) INTO l_n FROM noona_v_tax_register WHERE source_type = 'SAL_INVOICE' AND source_id = l_inv AND tax_amount = 13500;
  ok('installment VAT in the tax register', l_n = 1);
  pay(l_inv, 103500);
  l_bal := NOONA_CSH_PKG.balance(l_box, NULL);
  BEGIN NOONA_RES_PKG.terminate_contract(l_ct2, 'تعثر', 100000, 'BOX:' || l_box); ok('forfeit above collected rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('forfeit above collected rejected', 'NOONA-RES-050', SQLERRM); END;
  NOONA_RES_PKG.terminate_contract(l_ct2, 'تعثر المشتري', 20000, 'BOX:' || l_box);
  c := ctr(l_ct2);
  ok('terminated: forfeit 20000, refund 70000, unit available', c.status_code = 'TERMINATED' AND c.forfeited_amount = 20000 AND c.refunded_amount = 70000
     AND ustat(l_u4) = 'AVAILABLE', c.forfeited_amount || '/' || c.refunded_amount);
  ok('termination journal', jl(c.termination_event_id) LIKE '%2150:90000/0 4141:0/20000%', jl(c.termination_event_id));
  ok('refund paid from box', NOONA_CSH_PKG.balance(l_box, NULL) = l_bal - 70000);
  SELECT COUNT(*) INTO l_n FROM re_sale_installment WHERE contract_id = l_ct2 AND status_code = 'CANCELLED';
  ok('unbilled installments cancelled', l_n = 5, l_n);
  -- فسخ عقد غير مسدد: إشعار دائن لفاتورة القسط
  l_ct3 := NOONA_RES_PKG.create_contract('{"unit":' || l_u2 || ',"buyer":' || l_buyer || ',"date":"' || l_d || '"}');
  NOONA_RES_PKG.sign_contract(l_ct3);
  SELECT sales_invoice_id INTO l_inv FROM re_sale_installment WHERE contract_id = l_ct3;
  NOONA_RES_PKG.terminate_contract(l_ct3, 'لم يسدد', 0);
  SELECT COUNT(*) INTO l_n FROM sal_invoice WHERE original_invoice_id = l_inv AND doc_type = 'CREDIT_NOTE';
  ok('unpaid installment credited on termination', l_n = 1 AND ctr(l_ct3).status_code = 'TERMINATED');
  SELECT NVL(SUM(open_amount), 0) INTO l_x FROM ar_open_item WHERE source_entity_type = 'SAL_INVOICE' AND source_entity_id = l_inv;
  ok('customer balance cleared', l_x = 0, l_x);

  -- ======================================================== شاشات البيع
  ok('sales dashboard', DBMS_LOB.INSTR(NOONA_RES_PKG.summary_html, 'وحدات متاحة للبيع') > 0);
  ok('availability grid', DBMS_LOB.INSTR(NOONA_RES_PKG.availability_html(l_prop, '#ID#'), 'nn-res-unit is-available') > 0);
  ok('contract card', DBMS_LOB.INSTR(NOONA_RES_PKG.contract_html(l_ct), 'جدول الأقساط') > 0 AND DBMS_LOB.INSTR(NOONA_RES_PKG.contract_html(l_ct), 'D-' || l_sfx) > 0);
  ok('collections, commissions, handovers, reports', NOONA_RES_PKG.collections_html(TRUNC(SYSDATE) - 30, TRUNC(SYSDATE) + 400) IS NOT NULL
     AND DBMS_LOB.INSTR(NOONA_RES_PKG.commissions_html, 'مسدد') > 0 AND DBMS_LOB.INSTR(NOONA_RES_PKG.handovers_html, 'مسلم') > 0
     AND DBMS_LOB.INSTR(NOONA_RES_PKG.sales_report_html(TRUNC(SYSDATE) - 1, TRUNC(SYSDATE)), 'قيمة المبيعات') > 0
     AND NOONA_RES_PKG.plans_html IS NOT NULL AND NOONA_RES_PKG.price_lists_html IS NOT NULL AND NOONA_RES_PKG.allocations_html IS NOT NULL);

  -- ======================================================== الإيجارات
  l_lp := NOONA_RE_PKG.setup_wizard('{"name_ar":"عمارة إيجار اختبار ' || l_sfx || '","type":"BUILDING","buildings":[{"code":"B","floors":2}],'
          || '"units":{"per_floor":2,"unit_type":"APARTMENT","usage_type":"LEASE","bedrooms":2,"area":90}}');
  SELECT id INTO l_lu1 FROM re_unit WHERE property_id = l_lp AND code = '101';
  SELECT id INTO l_lu2 FROM re_unit WHERE property_id = l_lp AND code = '102';
  SELECT id INTO l_lu3 FROM re_unit WHERE property_id = l_lp AND code = '201';
  SELECT id INTO l_lu4 FROM re_unit WHERE property_id = l_lp AND code = '202';
  l_agr := NOONA_PRP_PKG.save_agreement('{"ownerName":"مالك العمارة ' || l_sfx || '","property":' || l_lp || ',"feeType":"PCT_OF_COLLECTION","feePct":10,'
           || '"from":"' || TO_CHAR(ADD_MONTHS(SYSDATE, -12), 'YYYY-MM-DD') || '"}');
  SELECT management_mode INTO l_s FROM re_property WHERE id = l_lp;
  ok('managed property agreement', l_s = 'MANAGED_FOR_OWNER');
  BEGIN l_n := NOONA_PRP_PKG.save_lease('{"property":' || l_lp || ',"units":[' || l_lu1 || '],"tenantName":"x","start":"2026-05-01","end":"2026-04-01","rent":1}');
    ok('lease dates validated', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('lease dates validated', 'NOONA-PRP-021', SQLERRM); END;
  l_ls1 := NOONA_PRP_PKG.save_lease('{"type":"RESIDENTIAL","property":' || l_lp || ',"units":[' || l_lu1 || '],"tenantName":"مستأجر اختبار ' || l_sfx
           || '","phone":"0559998877","start":"' || TO_CHAR(l_start, 'YYYY-MM-DD') || '","end":"' || TO_CHAR(ADD_MONTHS(l_start, 12) - 1, 'YYYY-MM-DD')
           || '","rent":60000,"freq":"MONTHLY","deposit":5000,"grace":5,"charges":[{"type":"SERVICE_CHARGE","amount":200,"freq":"MONTHLY"}]}');
  SELECT management_agreement_id INTO l_x FROM prp_lease WHERE id = l_ls1;
  ok('lease linked to the management agreement', l_x = l_agr);
  NOONA_PRP_PKG.activate_lease(l_ls1, 'EJAR-' || l_sfx);
  SELECT COUNT(*), SUM(amount) INTO l_n, l_x FROM prp_rent_schedule WHERE lease_id = l_ls1;
  ok('schedule: 12 rent + 12 service rows', l_n = 24 AND l_x = 60000 + 2400, l_n || '/' || l_x);
  ok('unit leased', ustat(l_lu1) = 'LEASED');
  BEGIN l_n := NOONA_PRP_PKG.save_lease('{"property":' || l_lp || ',"units":[' || l_lu1 || '],"tenantName":"آخر","start":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD')
                                        || '","end":"' || TO_CHAR(SYSDATE + 100, 'YYYY-MM-DD') || '","rent":1000}');
    ok('overlapping lease rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('overlapping lease rejected', 'NOONA-PRP-029', SQLERRM); END;
  l_n := NOONA_PRP_PKG.bill_rent(l_ls1);
  ok('3 monthly invoices billed in advance', l_n = 3, l_n);
  SELECT MIN(sales_invoice_id) INTO l_inv FROM prp_rent_schedule WHERE lease_id = l_ls1 AND due_date = l_start;
  SELECT total_amount, tax_amount INTO l_x, l_n FROM sal_invoice WHERE id = l_inv;
  ok('invoice: rent 5000 + service 200, residential exempt', l_x = 5200 AND l_n = 0, l_x || '/' || l_n);
  SELECT LISTAGG(a.account_code, ',') WITHIN GROUP (ORDER BY a.account_code) INTO l_s FROM sal_invoice_line s JOIN gl_account a ON a.id = s.revenue_account_id
   WHERE s.invoice_id = l_inv;
  ok('managed rent to owner payable 2154, service to 4151', l_s = '2154,4151', l_s);
  pay(l_inv, 5200);
  NOONA_PRP_PKG.refresh_schedule(l_ls1);
  SELECT COUNT(CASE WHEN status_code = 'PAID' THEN 1 END), COUNT(CASE WHEN status_code = 'OVERDUE' THEN 1 END) INTO l_n, l_x
    FROM prp_rent_schedule WHERE lease_id = l_ls1 AND sales_invoice_id IS NOT NULL;
  ok('first month paid, the next past grace overdue', l_n = 2 AND l_x >= 2, l_n || '/' || l_x);
  ok('overdue list', DBMS_LOB.INSTR(NOONA_PRP_PKG.overdue_html, 'مستأجر اختبار') > 0);
  l_bal := NOONA_CSH_PKG.balance(l_box, NULL);
  l_dep := NOONA_PRP_PKG.receive_deposit(l_ls1, 'BOX:' || l_box);
  ok('deposit received: Dr box, Cr 2153', jl(ev('PRP_SECURITY_DEPOSIT', l_dep)) LIKE '%2153:0/5000%' AND NOONA_CSH_PKG.balance(l_box, NULL) = l_bal + 5000);
  BEGIN l_n := NOONA_PRP_PKG.receive_deposit(l_ls1, 'BOX:' || l_box); ok('deposit once', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('deposit once', 'NOONA-PRP-042', SQLERRM); END;
  -- الزيادة السنوية (عقد سنتين سنوي)
  l_ls2 := NOONA_PRP_PKG.save_lease('{"type":"COMMERCIAL","property":' || l_lp || ',"units":[' || l_lu2 || '],"tenantName":"شركة مستأجرة ' || l_sfx
           || '","start":"' || TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-DD') || '","end":"' || TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE), 24) - 1, 'YYYY-MM-DD')
           || '","rent":50000,"freq":"ANNUAL","escalation":10}');
  NOONA_PRP_PKG.activate_lease(l_ls2);
  SELECT LISTAGG(amount || ':' || tax_amount, ',') WITHIN GROUP (ORDER BY due_date) INTO l_s FROM prp_rent_schedule WHERE lease_id = l_ls2;
  ok('annual rent with 10% escalation, commercial VAT 15%', l_s = '50000:7500,55000:8250', l_s);
  -- التجديد
  l_ren := NOONA_PRP_PKG.renew_lease(l_ls1, ADD_MONTHS(l_start, 24) - 1, 63000);
  ok('renewal draft created, current pending', NOONA_PRP_PKG.lease_status(l_ren) = 'DRAFT' AND NOONA_PRP_PKG.lease_status(l_ls1) = 'RENEWAL_PENDING');
  SELECT TO_CHAR(start_date, 'YYYY-MM-DD') INTO l_s FROM prp_lease WHERE id = l_ren;
  ok('renewal starts after current end', l_s = TO_CHAR(ADD_MONTHS(l_start, 12), 'YYYY-MM-DD'), l_s);
  NOONA_PRP_PKG.activate_lease(l_ren);
  ok('activating renewal marks previous renewed', NOONA_PRP_PKG.lease_status(l_ls1) = 'RENEWED');
  BEGIN l_n := NOONA_PRP_PKG.renew_lease(l_ls1, ADD_MONTHS(l_start, 36)); ok('no second renewal', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('no second renewal', INSTR(SQLERRM, 'NOONA-PRP-05') > 0, SQLERRM); END;
  -- الإنهاء وتسوية التأمين
  l_ls3 := NOONA_PRP_PKG.save_lease('{"type":"RESIDENTIAL","property":' || l_lp || ',"units":[' || l_lu3 || '],"tenantName":"مستأجر مغادر ' || l_sfx
           || '","start":"' || TO_CHAR(l_start, 'YYYY-MM-DD') || '","end":"' || TO_CHAR(ADD_MONTHS(l_start, 12) - 1, 'YYYY-MM-DD')
           || '","rent":36000,"freq":"QUARTERLY","deposit":3000}');
  NOONA_PRP_PKG.activate_lease(l_ls3);
  l_dep := NOONA_PRP_PKG.receive_deposit(l_ls3, 'BOX:' || l_box);
  BEGIN NOONA_PRP_PKG.settle_deposit(l_ls3, NULL); ok('deposit settled after lease ends only', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('deposit settled after lease ends only', 'NOONA-PRP-047', SQLERRM); END;
  NOONA_PRP_PKG.terminate_lease(l_ls3, TRUNC(SYSDATE), 'إخلاء مبكر');
  SELECT COUNT(*) INTO l_n FROM prp_rent_schedule WHERE lease_id = l_ls3 AND status_code = 'CANCELLED';
  ok('future periods cancelled, unit available', l_n >= 2 AND ustat(l_lu3) = 'AVAILABLE' AND NOONA_PRP_PKG.lease_status(l_ls3) = 'TERMINATED', l_n);
  l_bal := NOONA_CSH_PKG.balance(l_box, NULL);
  NOONA_PRP_PKG.settle_deposit(l_ls3, '[{"reason":"دهان وتنظيف","amount":1000}]', 'BOX:' || l_box);
  SELECT status_code || '|' || deducted_amount || '|' || refunded_amount INTO l_s FROM prp_security_deposit WHERE id = l_dep;
  ok('deposit: 1000 deducted, 2000 refunded', l_s = 'PARTIALLY_REFUNDED|1000|2000' AND NOONA_CSH_PKG.balance(l_box, NULL) = l_bal - 2000, l_s);
  ok('deposit settlement journal', jl(ev('PRP_DEPOSIT_SETTLEMENT', l_dep)) LIKE '%2153:3000/0 4153:0/1000%', jl(ev('PRP_DEPOSIT_SETTLEMENT', l_dep)));
  -- الانتهاء
  l_ls4 := NOONA_PRP_PKG.save_lease('{"type":"RESIDENTIAL","property":' || l_lp || ',"units":[' || l_lu4 || '],"tenantName":"مستأجر سابق ' || l_sfx
           || '","start":"' || TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE), -13), 'YYYY-MM-DD') || '","end":"' || TO_CHAR(TRUNC(SYSDATE) - 31, 'YYYY-MM-DD')
           || '","rent":24000,"freq":"ANNUAL"}');
  NOONA_PRP_PKG.activate_lease(l_ls4);
  ok('ended leases expire and release units', NOONA_PRP_PKG.expire_leases >= 1 AND NOONA_PRP_PKG.lease_status(l_ls4) = 'EXPIRED' AND ustat(l_lu4) = 'AVAILABLE');
  -- العدادات
  l_met := NOONA_PRP_PKG.save_meter('{"unit":' || l_lu2 || ',"type":"ELECTRICITY","no":"E-' || l_sfx || '","rate":0.18}');
  l_n := NOONA_PRP_PKG.add_reading(l_met, TRUNC(SYSDATE) - 30, 1000);
  l_n := NOONA_PRP_PKG.add_reading(l_met, TRUNC(SYSDATE), 1500);
  BEGIN l_n := NOONA_PRP_PKG.add_reading(l_met, TRUNC(SYSDATE) + 1, 1400); ok('reading cannot go back', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('reading cannot go back', 'NOONA-PRP-062', SQLERRM); END;
  ok('consumption billed to the lease', NOONA_PRP_PKG.bill_readings >= 1);
  SELECT amount INTO l_x FROM prp_rent_schedule WHERE lease_id = l_ls2 AND charge_id IS NULL;
  ok('500 units x 0.18 = 90', l_x = 90, l_x);
  -- كشف المالك
  l_st := NOONA_PRP_PKG.owner_statement(l_agr, l_start, TRUNC(SYSDATE));
  SELECT collections || '|' || management_fee || '|' || net_to_owner INTO l_s FROM prp_owner_statement WHERE id = l_st;
  ok('owner statement: collected rent 5000, fee 10%', l_s = '5000|500|4500', l_s);
  BEGIN l_n := NOONA_PRP_PKG.owner_statement(l_agr, l_start, TRUNC(SYSDATE)); ok('no overlapping statements', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('no overlapping statements', 'NOONA-PRP-071', SQLERRM); END;
  NOONA_PRP_PKG.approve_statement(l_st);
  ok('fee journal: Dr 2154, Cr 4152', jl(ev('PRP_OWNER_STATEMENT', l_st)) = '2154:500/0 4152:0/500', jl(ev('PRP_OWNER_STATEMENT', l_st)));
  NOONA_PRP_PKG.remit_statement(l_st, 'BOX:' || l_box);
  ok('owner remitted: Dr 2154 net', NOONA_PRP_PKG.statement_status(l_st) = 'REMITTED' AND jl(ev('PRP_OWNER_REMITTANCE', l_st)) LIKE '%2154:4500/0%');
  -- شاشات الإيجار
  ok('leasing dashboard', DBMS_LOB.INSTR(NOONA_PRP_PKG.summary_html, 'نسبة الإشغال') > 0);
  ok('lease card and schedule', DBMS_LOB.INSTR(NOONA_PRP_PKG.lease_html(l_ls1), 'جدول الاستحقاقات') > 0 AND DBMS_LOB.INSTR(NOONA_PRP_PKG.lease_html(l_ls1), 'جدد بالعقد') > 0);
  ok('rent roll, occupancy, expiring, agreements, statements, meters', DBMS_LOB.INSTR(NOONA_PRP_PKG.rent_roll_html(l_lp), 'مؤجرة') > 0
     AND DBMS_LOB.INSTR(NOONA_PRP_PKG.occupancy_html, 'عمارة إيجار اختبار') > 0 AND NOONA_PRP_PKG.expiring_html(400) IS NOT NULL
     AND DBMS_LOB.INSTR(NOONA_PRP_PKG.agreements_html, '10% من المحصل') > 0 AND DBMS_LOB.INSTR(NOONA_PRP_PKG.statement_html(l_st), 'الصافي المستحق للمالك') > 0
     AND DBMS_LOB.INSTR(NOONA_PRP_PKG.meters_html, 'E-' || l_sfx) > 0 AND NOONA_PRP_PKG.statements_html IS NOT NULL
     AND DBMS_LOB.INSTR(NOONA_PRP_PKG.leases_html('OPEN'), 'شركة مستأجرة') > 0);

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
