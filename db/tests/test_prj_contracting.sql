-- =============================================================================
-- NOONA PLUS ERP | اختبار محاسبة عقود المقاولات (NOONA_PRJ_CTR_PKG وتعديلات المستخلص):
--   غرامات التأخير بسقفها، المواد المشونة بالموقع، الاعتراف بالإيراد حسب نسبة الإنجاز وأصول العقود ومخصص الخسارة،
--   المستخلص الختامي والحساب الختامي، المعدات، خطابات الضمان بغطائها (بحساب NOONA_APP - يتراجع عن كل التغييرات)
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_prj_contracting.sql
-- =============================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE
DECLARE
  g_pass PLS_INTEGER := 0;
  g_fail PLS_INTEGER := 0;
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'MISSFF3');
  l_n NUMBER; l_x NUMBER; l_s VARCHAR2(4000); l_c CLOB;
  l_cust NUMBER; l_sup NUMBER; l_box NUMBER; l_prj NUMBER; l_w NUMBER; l_ct NUMBER; l_b NUMBER; l_cl NUMBER; l_run NUMBER;
  l_eq NUMBER; l_g NUMBER; l_g2 NUMBER; l_bank NUMBER; l_party NUMBER;
  r   prj_progress_claim%ROWTYPE;
  rr  prj_revenue_run%ROWTYPE;
  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END); END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION claim(p_id NUMBER) RETURN prj_progress_claim%ROWTYPE IS
    l prj_progress_claim%ROWTYPE;
  BEGIN SELECT * INTO l FROM prj_progress_claim WHERE id = p_id; RETURN l; END claim;
  -- مجموع مدين حساب في قيد حدث محاسبي
  FUNCTION acc_amt(p_event NUMBER, p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(l.debit_amount - l.credit_amount), 0) INTO l FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
     WHERE j.accounting_event_id = p_event AND l.account_id = NOONA_INV_PKG.acc_id(p_code);
    RETURN l;
  END acc_amt;
  FUNCTION jacc(p_journal NUMBER, p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(debit_amount - credit_amount), 0) INTO l FROM gl_journal_line WHERE journal_id = p_journal AND account_id = NOONA_INV_PKG.acc_id(p_code);
    RETURN l;
  END jacc;
  PROCEDURE fund(p_amt NUMBER) IS
    l_fc NUMBER; l_fr NUMBER;
  BEGIN
    l_fc := NOONA_SAL_PKG.save_customer('{"name":"ممول مقاولات ' || l_sfx || '","term":"NET0"}');
    l_fr := NOONA_SAL_PKG.receive('{"cust":' || l_fc || ',"amount":' || p_amt || ',"place":"BOX:' || l_box || '","method":"CASH"}');
  END fund;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_n := NOONA_PRJ_PKG.setup_accounts;
  ok('contracting accounts ready', l_n = 19 AND NOONA_INV_PKG.acc_id('1142') IS NOT NULL AND NOONA_INV_PKG.acc_id('2143') IS NOT NULL
     AND NOONA_INV_PKG.acc_id('1145') IS NOT NULL AND NOONA_INV_PKG.acc_id('4131') IS NOT NULL, l_n);
  l_cust := NOONA_SAL_PKG.save_customer('{"name":"مالك مقاولات ' || l_sfx || '","person":"N","tax":"300000000000003","term":"NET30"}');
  l_sup := NOONA_PUR_PKG.save_supplier('{"name":"مقاول باطن ' || l_sfx || '","person":"N","type":"SERVICES","term":"NET30"}');
  l_box := NOONA_CSH_PKG.create_cash_box('CB' || SUBSTR(l_sfx, 1, 6), 'صندوق مقاولات اختبار');
  fund(2000000);

  -- ======================================================== المشروع بطريقة نسبة الإنجاز والعقد بغرامة يومية
  BEGIN l_x := NOONA_PRJ_PKG.save_project('{"name":"x","method":"WHATEVER"}'); ok('invalid revenue method rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('invalid revenue method rejected', 'NOONA-PRJ-006', SQLERRM); END;
  l_prj := NOONA_PRJ_PKG.save_project('{"code":"K' || l_sfx || '","name":"برج سكني اختبار","type":"CONSTRUCTION","customer":' || l_cust
           || ',"method":"COST_TO_COST","eac":800000,"start":"' || TO_CHAR(SYSDATE - 60, 'YYYY-MM-DD') || '"}');
  SELECT revenue_method, estimated_total_cost INTO l_s, l_x FROM prj_project WHERE id = l_prj;
  ok('project saved with cost-to-cost method and estimated cost', l_s = 'COST_TO_COST' AND l_x = 800000, l_s || ' ' || l_x);
  l_w := NOONA_PRJ_PKG.save_wbs('{"project":' || l_prj || ',"code":"01","name":"الأعمال الإنشائية","weight":100}');
  BEGIN l_x := NOONA_PRJ_PKG.save_contract('{"project":' || l_prj || ',"type":"MAIN_CONTRACT","penalty":-5}'); ok('negative daily penalty rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('negative daily penalty rejected', 'NOONA-PRJ-110', SQLERRM); END;
  l_ct := NOONA_PRJ_PKG.save_contract('{"project":' || l_prj || ',"type":"MAIN_CONTRACT","no":"KC-' || l_sfx || '","ret":10,"penalty":1000,"penCap":5,'
          || '"start":"' || TO_CHAR(SYSDATE - 60, 'YYYY-MM-DD') || '","end":"' || TO_CHAR(SYSDATE + 120, 'YYYY-MM-DD') || '","dlp":12}');
  l_n := NOONA_PRJ_PKG.save_boq(l_ct, '[{"code":"1","d":"أعمال خرسانية","q":1000,"r":1000,"w":' || l_w || '}]');
  NOONA_PRJ_PKG.activate_contract(l_ct);
  SELECT id INTO l_b FROM prj_boq_item WHERE contract_id = l_ct;
  l_x := NOONA_PRJ_PKG.post_expense('{"project":' || l_prj || ',"wbs":' || l_w || ',"type":"MATERIAL","amount":400000,"place":"BOX:' || l_box
         || '","desc":"حديد وخرسانة"}');

  -- ======================================================== مستخلص بغرامة تأخير ومواد مشونة
  l_cl := NOONA_PRJ_PKG.new_claim(l_ct);
  BEGIN NOONA_PRJ_PKG.save_claim('{"id":' || l_cl || ',"mos":-1}'); ok('negative materials on site rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('negative materials on site rejected', 'NOONA-PRJ-111', SQLERRM); END;
  NOONA_PRJ_PKG.save_claim('{"id":' || l_cl || ',"penaltyDays":10,"mos":50000,"lines":[{"b":' || l_b || ',"q":300}]}');
  r := claim(l_cl);
  ok('penalty = 10 days x 1,000 and materials on site added',
     r.penalty_amount = 10000 AND r.mos_to_date = 50000 AND r.current_gross = 300000 AND r.retention_amount = 30000, r.penalty_amount || ' ' || r.mos_to_date);
  ok('tax on (works + materials - penalty) and net payable', r.tax_amount = 51000 AND r.net_payable = 361000, r.tax_amount || ' ' || r.net_payable);
  NOONA_PRJ_PKG.approve_claim(l_cl);
  r := claim(l_cl);
  ok('penalty posted to its contra-revenue account', acc_amt(r.accounting_event_id, '4131') = 10000, acc_amt(r.accounting_event_id, '4131'));
  ok('materials on site billed as a liability not revenue', acc_amt(r.accounting_event_id, '2142') = -50000
     AND acc_amt(r.accounting_event_id, '4130') = -300000, acc_amt(r.accounting_event_id, '2142') || ' ' || acc_amt(r.accounting_event_id, '4130'));
  ok('claim print shows penalty and materials', DBMS_LOB.INSTR(NOONA_PRJ_PKG.claim_print(l_cl), 'غرامة تأخير') > 0
     AND DBMS_LOB.INSTR(NOONA_PRJ_PKG.claim_print(l_cl), 'مواد مشونة بالموقع') > 0);

  -- ======================================================== الاعتراف بالإيراد حسب نسبة الإنجاز
  l_c := NOONA_PRJ_CTR_PKG.preview_json(l_prj, TRUNC(SYSDATE));
  ok('preview: 50% complete, revenue 495,000 vs billed 290,000', JSON_VALUE(l_c, '$.poc') = 50 AND JSON_VALUE(l_c, '$.revenueToDate') = 495000
     AND JSON_VALUE(l_c, '$.billedToDate') = 290000 AND JSON_VALUE(l_c, '$.contractAsset') = 205000, DBMS_LOB.SUBSTR(l_c, 400));
  l_run := NOONA_PRJ_CTR_PKG.run_revenue(l_prj, TRUNC(SYSDATE));
  SELECT * INTO rr FROM prj_revenue_run WHERE id = l_run;
  ok('revenue run posts the unbilled revenue as a contract asset', jacc(rr.gl_journal_id, '1142') = 205000 AND jacc(rr.gl_journal_id, '4132') = -205000,
     jacc(rr.gl_journal_id, '1142') || ' ' || jacc(rr.gl_journal_id, '4132'));
  BEGIN l_x := NOONA_PRJ_CTR_PKG.run_revenue(l_prj, TRUNC(SYSDATE)); ok('same period cannot run twice', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('same period cannot run twice', 'NOONA-PRJ-123', SQLERRM); END;
  NOONA_PRJ_CTR_PKG.reverse_run(l_run, 'تحديث التكلفة المتوقعة');
  -- تقدير جديد: التكلفة المتوقعة 1,000,000 > قيمة العقد بعد الغرامات (990,000): عقد خاسر
  l_run := NOONA_PRJ_CTR_PKG.run_revenue(l_prj, TRUNC(SYSDATE), 1000000);
  SELECT * INTO rr FROM prj_revenue_run WHERE id = l_run;
  ok('re-run at 40%: revenue 396,000, contract asset 106,000', rr.poc_pct = 40 AND rr.revenue_to_date = 396000 AND rr.contract_asset = 106000,
     rr.poc_pct || ' ' || rr.revenue_to_date || ' ' || rr.contract_asset);
  ok('loss-making contract: remaining loss 6,000 provided at once', rr.expected_loss = 10000 AND rr.loss_provision = 6000
     AND jacc(rr.gl_journal_id, '5151') = 6000 AND jacc(rr.gl_journal_id, '2143') = -6000, rr.expected_loss || ' ' || rr.loss_provision);
  l_c := NOONA_PRJ_CTR_PKG.wip_html(TRUNC(SYSDATE));
  ok('WIP schedule lists the project', DBMS_LOB.INSTR(l_c, 'K' || l_sfx) > 0 AND DBMS_LOB.INSTR(l_c, 'أصول العقود') > 0);
  ok('forecast card warns of the loss', DBMS_LOB.INSTR(NOONA_PRJ_CTR_PKG.forecast_html(l_prj), 'عقد خاسر') > 0);

  -- ======================================================== المستخلص الختامي: سقف الغرامات واسترداد المواد المشونة
  l_cl := NOONA_PRJ_PKG.new_claim(l_ct);
  ok('materials on site carried from the previous claim', claim(l_cl).mos_previous = 50000);
  BEGIN NOONA_PRJ_PKG.save_claim('{"id":' || l_cl || ',"final":"Y"}'); ok('final claim cannot keep materials on site', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('final claim cannot keep materials on site', 'NOONA-PRJ-113', SQLERRM); END;
  NOONA_PRJ_PKG.save_claim('{"id":' || l_cl || ',"penaltyDays":60,"mos":0,"final":"Y","lines":[{"b":' || l_b || ',"q":1000}]}');
  r := claim(l_cl);
  ok('penalty capped at 5% of the contract (40,000 left of 50,000)', r.penalty_amount = 40000, r.penalty_amount);
  ok('final claim: materials recovered and net payable', r.current_gross = 700000 AND r.tax_amount = 91500 AND r.net_payable = 631500,
     r.current_gross || ' ' || r.tax_amount || ' ' || r.net_payable);
  NOONA_PRJ_PKG.approve_claim(l_cl);
  SELECT status_code INTO l_s FROM prj_contract WHERE id = l_ct;
  ok('final claim completes the contract', l_s = 'COMPLETED', l_s);
  BEGIN l_x := NOONA_PRJ_PKG.new_claim(l_ct); ok('no progress claims after the final claim', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('no progress claims after the final claim', 'NOONA-PRJ-080', SQLERRM); END;
  l_x := NOONA_PRJ_PKG.new_claim(l_ct, 'RETENTION_RELEASE');
  ok('retention release still allowed after completion', claim(l_x).current_gross = 100000, claim(l_x).current_gross);
  NOONA_PRJ_PKG.cancel_claim(l_x, NULL);
  l_c := NOONA_PRJ_CTR_PKG.final_account_html(l_ct);
  ok('final account: claims 1,000,000, penalties 50,000, retention held 100,000', DBMS_LOB.INSTR(l_c, 'المستخلص الختامي') > 0
     AND DBMS_LOB.INSTR(l_c, '1,000,000.00') > 0 AND DBMS_LOB.INSTR(l_c, '(50,000.00)') > 0 AND DBMS_LOB.INSTR(l_c, '100,000.00') > 0);

  -- ======================================================== المعدات
  BEGIN l_x := NOONA_PRJ_CTR_PKG.save_equipment('{"code":"EX' || l_sfx || '","name":"حفار","rate":0}'); ok('equipment needs an hourly rate', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('equipment needs an hourly rate', 'NOONA-PRJ-131', SQLERRM); END;
  l_eq := NOONA_PRJ_CTR_PKG.save_equipment('{"code":"EX' || l_sfx || '","name":"حفار كاتربيلر","type":"حفار","ownership":"OWNED","rate":250}');
  l_x := NOONA_PRJ_CTR_PKG.log_usage('{"equipment":' || l_eq || ',"project":' || l_prj || ',"wbs":' || l_w || ',"hours":8}');
  l_x := NOONA_PRJ_CTR_PKG.log_usage('{"equipment":' || l_eq || ',"project":' || l_prj || ',"hours":4,"rate":300}');
  ok('equipment usage posted to the project', NOONA_PRJ_CTR_PKG.post_usage(l_prj) = 2);
  SELECT NVL(SUM(amount), 0) INTO l_x FROM prj_cost_line WHERE project_id = l_prj AND cost_type = 'EQUIPMENT' AND status_code = 'POSTED';
  ok('equipment cost = hours x rate (8x250 + 4x300)', l_x = 3200, l_x);
  SELECT COUNT(*) INTO l_n FROM gl_journal_line WHERE account_id = NOONA_INV_PKG.acc_id('5158') AND credit_amount = 2000;
  ok('equipment applied account credited', l_n >= 1);
  ok('equipment utilisation report', DBMS_LOB.INSTR(NOONA_PRJ_CTR_PKG.equipment_html(TRUNC(SYSDATE) - 1, TRUNC(SYSDATE)), 'EX' || l_sfx) > 0);

  -- ======================================================== خطابات الضمان
  SELECT MIN(id) INTO l_bank FROM ref_bank;
  SELECT party_id INTO l_party FROM ar_customer WHERE id = (SELECT customer_id FROM ar_customer_account WHERE id = l_cust);
  BEGIN l_x := NOONA_PRJ_CTR_PKG.save_guarantee('{"no":"LG' || l_sfx || '","type":"PERFORMANCE","amount":100000,"bank":' || l_bank
                                               || ',"issue":"2026-05-01","expiry":"2026-04-01"}'); ok('expiry before issue rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('expiry before issue rejected', 'NOONA-PRJ-144', SQLERRM); END;
  l_g := NOONA_PRJ_CTR_PKG.save_guarantee('{"no":"LG' || l_sfx || '","type":"PERFORMANCE","direction":"ISSUED_BY_US","contract":' || l_ct
         || ',"bank":' || l_bank || ',"beneficiary":' || l_party || ',"amount":100000,"margin":10000,"issue":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD')
         || '","expiry":"' || TO_CHAR(SYSDATE + 20, 'YYYY-MM-DD') || '"}');
  l_x := NOONA_CSH_PKG.balance(l_box, NULL);
  NOONA_PRJ_CTR_PKG.guarantee_action(l_g, 'ISSUE', p_place => 'BOX:' || l_box);
  SELECT status_code, margin_journal_id INTO l_s, l_n FROM prj_guarantee WHERE id = l_g;
  ok('issued with cash margin set aside', l_s = 'ACTIVE' AND jacc(l_n, '1145') = 10000 AND NOONA_CSH_PKG.balance(l_box, NULL) = l_x - 10000,
     l_s || ' ' || jacc(l_n, '1145'));
  ok('expiring within 30 days is flagged', NOONA_PRJ_CTR_PKG.expiring_count(30) >= 1
     AND DBMS_LOB.INSTR(NOONA_PRJ_CTR_PKG.guarantees_html(30), 'LG' || l_sfx) > 0);
  NOONA_PRJ_CTR_PKG.guarantee_action(l_g, 'EXTEND', p_expiry => TRUNC(SYSDATE) + 400, p_reason => 'فترة الضمان');
  BEGIN NOONA_PRJ_CTR_PKG.guarantee_action(l_g, 'REDUCE', p_amount => 5000); ok('cannot reduce below the margin', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('cannot reduce below the margin', 'NOONA-PRJ-153', SQLERRM); END;
  NOONA_PRJ_CTR_PKG.guarantee_action(l_g, 'REDUCE', p_amount => 80000, p_reason => 'بعد الاستلام الابتدائي');
  l_n := NOONA_CSH_PKG.balance(l_box, NULL);
  NOONA_PRJ_CTR_PKG.guarantee_action(l_g, 'RELEASE', p_place => 'BOX:' || l_box);
  SELECT status_code, amount INTO l_s, l_x FROM prj_guarantee WHERE id = l_g;
  ok('extended, reduced, then released with the margin back', l_s = 'RELEASED' AND l_x = 80000 AND NOONA_CSH_PKG.balance(l_box, NULL) = l_n + 10000,
     l_s || ' ' || l_x || ' ' || (NOONA_CSH_PKG.balance(l_box, NULL) - l_n));
  -- خطاب صادر منا بغطاء يسيله المالك: يعود الغطاء ويخصم كامل المبلغ خسارة
  l_g := NOONA_PRJ_CTR_PKG.save_guarantee('{"no":"LGB' || l_sfx || '","type":"BID","contract":' || l_ct || ',"bank":' || l_bank
         || ',"beneficiary":' || l_party || ',"amount":30000,"margin":3000,"issue":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD')
         || '","expiry":"' || TO_CHAR(SYSDATE + 60, 'YYYY-MM-DD') || '"}');
  l_n := NOONA_CSH_PKG.balance(l_box, NULL);
  NOONA_PRJ_CTR_PKG.guarantee_action(l_g, 'ISSUE', p_place => 'BOX:' || l_box);
  NOONA_PRJ_CTR_PKG.guarantee_action(l_g, 'LIQUIDATE', p_place => 'BOX:' || l_box, p_reason => 'عدم توقيع العقد');
  SELECT COUNT(*) INTO l_x FROM gl_journal_line WHERE account_id = NOONA_INV_PKG.acc_id('5153') AND debit_amount = 30000;
  ok('issued guarantee liquidated: full amount out, loss booked', NOONA_CSH_PKG.balance(l_box, NULL) = l_n - 30000 AND l_x >= 1,
     (NOONA_CSH_PKG.balance(l_box, NULL) - l_n) || ' ' || l_x);
  -- خطاب وارد من مقاول باطن يسيل لصالحنا
  l_g2 := NOONA_PRJ_CTR_PKG.save_guarantee('{"no":"LGR' || l_sfx || '","type":"ADVANCE_PAYMENT","direction":"RECEIVED_FROM_PARTY","project":' || l_prj
          || ',"bank":' || l_bank || ',"amount":25000,"issue":"' || TO_CHAR(SYSDATE - 10, 'YYYY-MM-DD') || '","expiry":"' || TO_CHAR(SYSDATE + 90, 'YYYY-MM-DD') || '"}');
  NOONA_PRJ_CTR_PKG.guarantee_action(l_g2, 'ISSUE');
  l_x := NOONA_CSH_PKG.balance(l_box, NULL);
  NOONA_PRJ_CTR_PKG.guarantee_action(l_g2, 'LIQUIDATE', p_place => 'BOX:' || l_box, p_reason => 'إخلال المقاول');
  ok('received guarantee liquidated: cash in as income', NOONA_CSH_PKG.balance(l_box, NULL) = l_x + 25000, NOONA_CSH_PKG.balance(l_box, NULL) - l_x);

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
  IF g_fail > 0 THEN RAISE_APPLICATION_ERROR(-20999, g_fail || ' test(s) failed'); END IF;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
