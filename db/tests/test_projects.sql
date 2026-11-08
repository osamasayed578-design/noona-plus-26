-- =============================================================================
-- NOONA PLUS ERP | اختبار المشروعات والمقاولات: المشروع ومركز تكلفته، WBS ونسب الإنجاز، الموازنة، التكاليف الفعلية
--                  (مصروف، مواد من المخزون، ساعات عمل)، العقد وجدول الكميات، الدفعة المقدمة والمستخلصات والمحتجز،
--                  أمر التغيير، مقاول الباطن، التحصيل والسداد، الإلغاء، والتوزيع على الوحدات (بحساب NOONA_APP - يتراجع عن كل التغييرات)
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_projects.sql
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
  l_cust NUMBER;
  l_sup  NUMBER;
  l_box  NUMBER;
  l_prj  NUMBER;
  l_w1   NUMBER;
  l_w2   NUMBER;
  l_ct   NUMBER;
  l_sc   NUMBER;
  l_b1   NUMBER;
  l_b2   NUMBER;
  l_cl   NUMBER;
  l_cl2  NUMBER;
  l_adv  NUMBER;
  l_emp  NUMBER;
  l_item NUMBER;
  l_wh   NUMBER;
  l_vo   NUMBER;
  l_prop NUMBER;
  l_rp   NUMBER;
  r      prj_progress_claim%ROWTYPE;

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION claim(p_id NUMBER) RETURN prj_progress_claim%ROWTYPE IS
    l prj_progress_claim%ROWTYPE;
  BEGIN SELECT * INTO l FROM prj_progress_claim WHERE id = p_id; RETURN l; END claim;
  -- القيد متوازن ومجموع مدينه
  FUNCTION jdr(p_claim NUMBER) RETURN VARCHAR2 IS
    l_d NUMBER; l_k NUMBER;
  BEGIN
    SELECT SUM(l.debit_amount), SUM(l.credit_amount) INTO l_d, l_k FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
     WHERE j.accounting_event_id = (SELECT accounting_event_id FROM prj_progress_claim WHERE id = p_claim);
    RETURN l_d || '/' || l_k;
  END jdr;
  -- تمويل صندوق الاختبار (الصرف فوق الرصيد ممنوع): مقبوضات مقدمة من عميل
  PROCEDURE fund(p_amt NUMBER) IS
    l_fc NUMBER;
    l_fr NUMBER;
  BEGIN
    l_fc := NOONA_SAL_PKG.save_customer('{"name":"ممول صندوق اختبار ' || l_sfx || '-' || p_amt || '","term":"NET0"}');
    l_fr := NOONA_SAL_PKG.receive('{"cust":' || l_fc || ',"amount":' || p_amt || ',"place":"BOX:' || l_box || '","method":"CASH"}');
  END fund;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_n := NOONA_PRJ_PKG.setup_accounts;
  ok('project accounts ready', l_n = 19 AND NOONA_INV_PKG.acc_id('1140') IS NOT NULL AND NOONA_INV_PKG.acc_id('4130') IS NOT NULL);
  l_cust := NOONA_SAL_PKG.save_customer('{"name":"مالك اختبار ' || l_sfx || '","person":"N","tax":"300000000000003","term":"NET30"}');
  l_sup := NOONA_PUR_PKG.save_supplier('{"name":"مقاول باطن ' || l_sfx || '","person":"N","type":"SERVICES","term":"NET30"}');
  l_box := NOONA_CSH_PKG.create_cash_box('PB' || SUBSTR(l_sfx, 1, 6), 'صندوق مشروعات اختبار');
  fund(1000000);

  -- ======================================================== المشروع
  BEGIN l_x := NOONA_PRJ_PKG.save_project('{"name":"x","start":"2026-05-01","end":"2026-04-01"}'); ok('end before start rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('end before start rejected', 'NOONA-PRJ-003', SQLERRM); END;
  l_prj := NOONA_PRJ_PKG.save_project('{"code":"T' || l_sfx || '","name":"مبنى إداري اختبار","type":"CONSTRUCTION","customer":' || l_cust
           || ',"start":"' || TO_CHAR(SYSDATE - 30, 'YYYY-MM-DD') || '","end":"' || TO_CHAR(SYSDATE + 150, 'YYYY-MM-DD') || '"}');
  SELECT COUNT(*) INTO l_n FROM prj_project p JOIN gl_cost_center c ON c.id = p.cost_center_id WHERE p.id = l_prj AND c.code = 'T' || l_sfx;
  ok('project gets its own cost center', l_n = 1);
  SELECT COUNT(*) INTO l_n FROM prj_wbs WHERE project_id = l_prj AND code = 'GEN';
  ok('default general WBS item', l_n = 1);
  l_w1 := NOONA_PRJ_PKG.save_wbs('{"project":' || l_prj || ',"code":"01","name":"الهيكل الخرساني","weight":60}');
  l_w2 := NOONA_PRJ_PKG.save_wbs('{"project":' || l_prj || ',"code":"02","name":"التشطيبات","weight":40}');
  UPDATE prj_wbs SET status_code = 'CANCELLED' WHERE project_id = l_prj AND code = 'GEN';
  NOONA_PRJ_PKG.update_progress(l_w1, 50, 'صب الأسقف');
  NOONA_PRJ_PKG.update_progress(l_w2, 25);
  SELECT percent_complete, status_code INTO l_x, l_s FROM prj_project WHERE id = l_prj;
  ok('weighted project progress 40% and project activated', l_x = 40 AND l_s = 'ACTIVE', l_x || ' ' || l_s);
  UPDATE prj_wbs SET status_code = 'ACTIVE' WHERE project_id = l_prj AND code = 'GEN';
  BEGIN NOONA_PRJ_PKG.update_progress(l_w1, 120); ok('progress above 100 rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('progress above 100 rejected', 'NOONA-PRJ-015', SQLERRM); END;

  -- ======================================================== الموازنة والتكاليف
  l_x := NOONA_PRJ_PKG.save_budget(l_prj, '[{"w":' || l_w1 || ',"t":"MATERIAL","a":300000},{"w":' || l_w1 || ',"t":"LABOR","a":100000},'
         || '{"w":' || l_w2 || ',"t":"SUBCONTRACT","a":200000},{"t":"OTHER","a":20000}]');
  SELECT budget_amount INTO l_x FROM prj_project WHERE id = l_prj;
  ok('baseline budget total on project', l_x = 620000, l_x);
  l_x := NOONA_PRJ_PKG.save_budget(l_prj, '[{"w":' || l_w1 || ',"t":"MATERIAL","a":320000},{"t":"OTHER","a":20000}]', 'مراجعة');
  SELECT COUNT(*) INTO l_n FROM prj_budget WHERE project_id = l_prj AND is_baseline = 'Y';
  SELECT budget_amount INTO l_x FROM prj_project WHERE id = l_prj;
  ok('revised budget becomes the only baseline', l_n = 1 AND l_x = 340000, l_n || ' ' || l_x);
  l_x := NOONA_PRJ_PKG.post_expense('{"project":' || l_prj || ',"wbs":' || l_w1 || ',"type":"EQUIPMENT","amount":4500,"place":"BOX:' || l_box
         || '","desc":"إيجار رافعة","ref":"R-1"}');
  SELECT COUNT(*) INTO l_n FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN prj_project p ON p.cost_center_id = l.cost_center_id
   WHERE p.id = l_prj AND l.debit_amount = 4500 AND l.account_id = NOONA_INV_PKG.acc_id('5150');
  ok('direct expense posted to project cost with its cost center', l_n = 1, l_n);
  SELECT COUNT(*) INTO l_n FROM csh_transaction WHERE source_entity_type = 'PRJ_COST_LINE' AND source_entity_id = l_x;
  ok('expense appears in the cash book', l_n = 1);
  NOONA_PRJ_PKG.reverse_cost(l_x, 'خطأ في المبلغ');
  SELECT status_code INTO l_s FROM prj_cost_line WHERE id = l_x;
  ok('cost reversed', l_s = 'REVERSED');
  l_x := NOONA_PRJ_PKG.post_expense('{"project":' || l_prj || ',"wbs":' || l_w1 || ',"type":"EQUIPMENT","amount":4000,"place":"BOX:' || l_box
         || '","desc":"إيجار رافعة"}');
  BEGIN l_n := NOONA_PRJ_PKG.post_expense('{"project":' || l_prj || ',"type":"OTHER","amount":' || (NOONA_CSH_PKG.balance(l_box, NULL) + 1)
                                          || ',"place":"BOX:' || l_box || '","desc":"أكبر من رصيد الصندوق"}');
    ok('project expense cannot exceed the cash box balance', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('project expense cannot exceed the cash box balance', 'NOONA-CSH-040', SQLERRM); END;
  -- مواد من المخزون
  SELECT MIN(o.item_id) KEEP (DENSE_RANK FIRST ORDER BY o.on_hand_qty DESC), MIN(o.warehouse_id) KEEP (DENSE_RANK FIRST ORDER BY o.on_hand_qty DESC)
    INTO l_item, l_wh FROM inv_onhand o JOIN inv_item i ON i.id = o.item_id
   WHERE o.company_id = NOONA_PRJ_PKG.company AND o.on_hand_qty >= 5 AND i.item_type NOT IN ('SERVICE', 'NON_STOCK')
     AND NVL(i.requires_prescription, 'N') = 'N' AND o.lot_id IS NULL;
  IF l_item IS NOT NULL THEN
    l_n := NOONA_INV_PKG.on_hand(l_item, l_wh);
    l_x := NOONA_PRJ_PKG.issue_material('{"project":' || l_prj || ',"wbs":' || l_w1 || ',"wh":' || l_wh || ',"lines":[{"i":' || l_item || ',"q":2}]}');
    SELECT amount INTO l_s FROM prj_cost_line WHERE id = l_x;
    ok('material issued from stock to the project at cost', NOONA_INV_PKG.on_hand(l_item, l_wh) = l_n - 2 AND TO_NUMBER(l_s) > 0, l_s);
  ELSE
    ok('material issue (no stocked item in this database - skipped)', TRUE);
  END IF;
  SELECT MIN(e.id) INTO l_emp FROM hr_employee e JOIN hr_employment m ON m.employee_id = e.id WHERE m.company_id = NOONA_PRJ_PKG.company;
  IF l_emp IS NOT NULL THEN
    l_x := NOONA_PRJ_PKG.save_timesheet('{"employee":' || l_emp || ',"project":' || l_prj || ',"wbs":' || l_w1 || ',"hours":8,"rate":50}');
    l_x := NOONA_PRJ_PKG.save_timesheet('{"employee":' || l_emp || ',"project":' || l_prj || ',"wbs":' || l_w2 || ',"hours":4,"rate":50}');
    ok('timesheets posted as labor cost', NOONA_PRJ_PKG.post_timesheets(l_prj) = 2);
    SELECT NVL(SUM(amount), 0) INTO l_x FROM prj_cost_line WHERE project_id = l_prj AND cost_type = 'LABOR' AND status_code = 'POSTED';
    ok('labor cost = hours x rate', l_x = 600, l_x);
    BEGIN l_x := NOONA_PRJ_PKG.post_timesheets(l_prj); ok('nothing left to post', FALSE);
    EXCEPTION WHEN OTHERS THEN expect('nothing left to post', 'NOONA-PRJ-053', SQLERRM); END;
  END IF;
  l_c := NOONA_PRJ_PKG.budget_html(l_prj);
  ok('budget vs actual', DBMS_LOB.INSTR(l_c, 'معدات') > 0 AND DBMS_LOB.INSTR(l_c, 'بلا موازنة') > 0 AND DBMS_LOB.INSTR(l_c, '340,000.00') > 0);

  -- ======================================================== العقد الرئيسي وجدول الكميات
  l_ct := NOONA_PRJ_PKG.save_contract('{"project":' || l_prj || ',"type":"MAIN_CONTRACT","no":"MC-' || l_sfx || '","ret":10,"retCap":5,"adv":10,"advRec":20,'
          || '"start":"' || TO_CHAR(SYSDATE - 30, 'YYYY-MM-DD') || '","end":"' || TO_CHAR(SYSDATE + 150, 'YYYY-MM-DD') || '","dlp":12}');
  l_n := NOONA_PRJ_PKG.save_boq(l_ct, '[{"code":"1.1","d":"خرسانة مسلحة للأساسات","q":400,"r":1000,"w":' || l_w1 || '},'
         || '{"code":"1.2","d":"خرسانة مسلحة للأسقف","q":300,"r":1200,"w":' || l_w1 || '},{"code":"2.1","d":"لياسة داخلية","q":5000,"r":40,"w":' || l_w2 || '}]');
  SELECT original_value INTO l_x FROM prj_contract WHERE id = l_ct;
  ok('BOQ sets the contract value', l_n = 3 AND l_x = 960000, l_x);
  BEGIN l_x := NOONA_PRJ_PKG.new_claim(l_ct); ok('claims need an active contract', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('claims need an active contract', 'NOONA-PRJ-080', SQLERRM); END;
  NOONA_PRJ_PKG.activate_contract(l_ct);
  SELECT contract_value INTO l_x FROM prj_project WHERE id = l_prj;
  ok('active main contract sets the project contract value', l_x = 960000, l_x);
  SELECT id INTO l_b1 FROM prj_boq_item WHERE contract_id = l_ct AND item_code = '1.1';
  SELECT id INTO l_b2 FROM prj_boq_item WHERE contract_id = l_ct AND item_code = '1.2';

  -- ======================================================== الدفعة المقدمة
  l_adv := NOONA_PRJ_PKG.new_claim(l_ct, 'ADVANCE');
  r := claim(l_adv);
  ok('advance = 10% of contract + VAT', r.current_gross = 96000 AND r.tax_amount = 14400 AND r.net_payable = 110400, r.current_gross || ' ' || r.net_payable);
  NOONA_PRJ_PKG.approve_claim(l_adv);
  ok('advance posted balanced', jdr(l_adv) = '110400/110400', jdr(l_adv));
  ok('advance open', NOONA_PRJ_PKG.advance_open(l_ct) = 96000);
  BEGIN l_x := NOONA_PRJ_PKG.new_claim(l_ct, 'ADVANCE'); ok('one advance per contract', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('one advance per contract', 'NOONA-PRJ-083', SQLERRM); END;

  -- ======================================================== المستخلص الأول
  l_cl := NOONA_PRJ_PKG.new_claim(l_ct);
  BEGIN l_x := NOONA_PRJ_PKG.new_claim(l_ct); ok('one draft claim at a time', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('one draft claim at a time', 'NOONA-PRJ-082', SQLERRM); END;
  BEGIN NOONA_PRJ_PKG.save_claim('{"id":' || l_cl || ',"lines":[{"b":' || l_b1 || ',"q":450}]}'); ok('quantity above the contract rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('quantity above the contract rejected', 'NOONA-PRJ-089', SQLERRM); END;
  NOONA_PRJ_PKG.save_claim('{"id":' || l_cl || ',"lines":[{"b":' || l_b1 || ',"q":200},{"b":' || l_b2 || ',"q":50}]}');
  r := claim(l_cl);
  -- 200×1000 + 50×1200 = 260000؛ محتجز 10% = 26000؛ استرداد المقدم 20% = 52000؛ الضريبة 15% × (260000 - 52000) = 31200
  ok('claim 1 gross', r.current_gross = 260000 AND r.gross_to_date = 260000 AND r.previous_certified = 0, r.current_gross);
  ok('claim 1 retention 10%', r.retention_amount = 26000, r.retention_amount);
  ok('claim 1 advance recovery 20%', r.advance_recovery = 52000, r.advance_recovery);
  ok('claim 1 VAT after advance recovery', r.tax_amount = 31200, r.tax_amount);
  ok('claim 1 net', r.net_payable = 260000 - 26000 - 52000 + 31200, r.net_payable);
  NOONA_PRJ_PKG.approve_claim(l_cl);
  r := claim(l_cl);
  ok('claim approved with a number', r.status_code = 'APPROVED' AND r.doc_no LIKE 'IPC-%', r.doc_no);
  ok('claim 1 journal balanced', jdr(l_cl) = '291200/291200', jdr(l_cl));
  SELECT COUNT(*), MAX(open_amount) INTO l_n, l_x FROM ar_open_item WHERE source_entity_type = 'PRJ_PROGRESS_CLAIM' AND source_entity_id = l_cl;
  ok('customer open item for the net', l_n = 1 AND l_x = 213200, l_x);
  SELECT executed_qty INTO l_x FROM prj_boq_item WHERE id = l_b1;
  ok('executed quantity updated', l_x = 200);
  ok('retention held', NOONA_PRJ_PKG.retention_held(l_ct) = 26000);

  -- ======================================================== أمر التغيير والمستخلص الثاني
  l_vo := NOONA_PRJ_PKG.save_variation('{"contract":' || l_ct || ',"desc":"زيادة كميات الأسقف وبند عزل","days":20,'
          || '"lines":[{"b":' || l_b2 || ',"q":50},{"code":"3.1","d":"عزل مائي للسطح","q":800,"r":55}]}');
  NOONA_PRJ_PKG.approve_variation(l_vo);
  SELECT current_value INTO l_x FROM prj_contract WHERE id = l_ct;
  ok('variation raises the contract value', l_x = 960000 + 60000 + 44000, l_x);
  l_cl2 := NOONA_PRJ_PKG.new_claim(l_ct);
  l_c := NOONA_PRJ_PKG.claim_json(l_cl2);
  ok('claim 2 starts from previous quantities', JSON_VALUE(l_c, '$.lines[0].prev') = '200', JSON_VALUE(l_c, '$.lines[0].prev'));
  BEGIN NOONA_PRJ_PKG.save_claim('{"id":' || l_cl2 || ',"lines":[{"b":' || l_b1 || ',"q":150}]}'); ok('quantity below the certified rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('quantity below the certified rejected', 'NOONA-PRJ-088', SQLERRM); END;
  NOONA_PRJ_PKG.save_claim('{"id":' || l_cl2 || ',"other":1000,"lines":[{"b":' || l_b1 || ',"q":400},{"b":' || l_b2 || ',"q":350}]}');
  r := claim(l_cl2);
  -- تراكمي 400000 + 420000 = 820000؛ السابق 260000؛ الفترة 560000؛ المحتجز بسقف 5% من 1064000 = 53200 - 26000 = 27200
  ok('claim 2 cumulative and previous', r.gross_to_date = 820000 AND r.previous_certified = 260000 AND r.current_gross = 560000, r.gross_to_date);
  ok('claim 2 retention capped at 5% of contract', r.retention_amount = 27200, r.retention_amount);
  ok('claim 2 recovery limited to the remaining advance', r.advance_recovery = 44000, r.advance_recovery);
  NOONA_PRJ_PKG.approve_claim(l_cl2);
  ok('claim 2 journal balanced', SUBSTR(jdr(l_cl2), 1, INSTR(jdr(l_cl2), '/') - 1) = SUBSTR(jdr(l_cl2), INSTR(jdr(l_cl2), '/') + 1), jdr(l_cl2));
  ok('advance fully recovered', NOONA_PRJ_PKG.advance_open(l_ct) = 0);
  BEGIN NOONA_PRJ_PKG.cancel_claim(l_cl, 'x'); ok('only the latest claim is cancelled', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('only the latest claim is cancelled', 'NOONA-PRJ-095', SQLERRM); END;
  NOONA_PRJ_PKG.cancel_claim(l_cl2, 'خطأ في الكميات');
  SELECT executed_qty INTO l_x FROM prj_boq_item WHERE id = l_b1;
  SELECT COUNT(*) INTO l_n FROM ar_open_item WHERE source_entity_type = 'PRJ_PROGRESS_CLAIM' AND source_entity_id = l_cl2 AND status_code = 'CANCELLED';
  ok('cancelled claim restores quantities and cancels the open item', l_x = 200 AND l_n = 1, l_x || ' ' || l_n);
  ok('advance open again after cancelling', NOONA_PRJ_PKG.advance_open(l_ct) = 44000);

  -- ======================================================== التحصيل والإفراج عن المحتجز
  SELECT id INTO l_x FROM ar_open_item WHERE source_entity_type = 'PRJ_PROGRESS_CLAIM' AND source_entity_id = l_cl;
  l_x := NOONA_SAL_PKG.receive('{"cust":' || l_cust || ',"amount":213200,"place":"BOX:' || l_box || '","method":"CASH","alloc":[{"inv":' || l_x
         || ',"a":213200}]}');
  SELECT open_amount INTO l_x FROM ar_open_item WHERE source_entity_type = 'PRJ_PROGRESS_CLAIM' AND source_entity_id = l_cl;
  ok('claim collected through customer receipts', l_x = 0, l_x);
  BEGIN NOONA_PRJ_PKG.cancel_claim(l_cl, 'x'); ok('collected claim cannot be cancelled', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('collected claim cannot be cancelled', 'NOONA-PRJ-096', SQLERRM); END;
  l_rp := NOONA_PRJ_PKG.new_claim(l_ct, 'RETENTION_RELEASE');
  r := claim(l_rp);
  ok('retention release = held amount, no VAT', r.current_gross = 26000 AND r.tax_amount = 0 AND r.net_payable = 26000, r.net_payable);
  NOONA_PRJ_PKG.approve_claim(l_rp);
  ok('retention released', NOONA_PRJ_PKG.retention_held(l_ct) = 0);

  -- ======================================================== مقاول الباطن
  l_sc := NOONA_PRJ_PKG.save_contract('{"project":' || l_prj || ',"type":"SUBCONTRACT","supplier":' || l_sup || ',"ret":5,"value":100000}');
  l_n := NOONA_PRJ_PKG.save_boq(l_sc, '[{"code":"S1","d":"لياسة (مصنعية)","q":5000,"r":20,"w":' || l_w2 || '}]');
  NOONA_PRJ_PKG.activate_contract(l_sc);
  l_x := NOONA_PRJ_PKG.new_claim(l_sc);
  SELECT id INTO l_b1 FROM prj_boq_item WHERE contract_id = l_sc;
  NOONA_PRJ_PKG.save_claim('{"id":' || l_x || ',"lines":[{"b":' || l_b1 || ',"q":1000}]}');
  NOONA_PRJ_PKG.approve_claim(l_x);
  r := claim(l_x);
  ok('subcontractor claim: payable, retention 5%, input VAT', r.claim_direction = 'PAYABLE' AND r.doc_no LIKE 'SPC-%' AND r.retention_amount = 1000
     AND r.tax_amount = 3000 AND r.net_payable = 22000, r.net_payable);
  SELECT COUNT(*) INTO l_n FROM ap_open_item WHERE supplier_account_id = l_sup AND doc_no = r.doc_no AND open_amount = 22000;
  ok('supplier open item', l_n = 1);
  SELECT COUNT(*) INTO l_n FROM prj_cost_line WHERE project_id = l_prj AND cost_type = 'SUBCONTRACT' AND amount = 20000 AND source_entity_id = l_x;
  ok('subcontract cost on the project', l_n = 1);
  BEGIN l_s := NOONA_PRJ_PKG.save_boq(l_sc, '[]'); ok('used BOQ items cannot be deleted', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('used BOQ items cannot be deleted', 'NOONA-PRJ-063', SQLERRM); END;

  -- ======================================================== الشاشات والتقارير
  l_c := NOONA_PRJ_PKG.project_card_html(l_prj);
  ok('project card', DBMS_LOB.INSTR(l_c, 'مبنى إداري اختبار') > 0 AND DBMS_LOB.INSTR(l_c, '260,000.00') > 0 AND DBMS_LOB.INSTR(l_c, 'nn-prj-bar') > 0);
  ok('WBS tree', DBMS_LOB.INSTR(NOONA_PRJ_PKG.wbs_html(l_prj), 'الهيكل الخرساني') > 0);
  ok('contracts list', DBMS_LOB.INSTR(NOONA_PRJ_PKG.contracts_html(l_prj), 'MC-' || l_sfx) > 0);
  l_c := NOONA_PRJ_PKG.contract_html(l_ct);
  ok('contract BOQ with variation', DBMS_LOB.INSTR(l_c, 'عزل مائي للسطح') > 0 AND DBMS_LOB.INSTR(l_c, 'أوامر التغيير') > 0);
  l_c := NOONA_PRJ_PKG.claim_print(l_cl);
  ok('claim certificate', DBMS_LOB.INSTR(l_c, 'شهادة مستخلص أعمال') > 0 AND DBMS_LOB.INSTR(l_c, '213,200.00') > 0 AND DBMS_LOB.INSTR(l_c, 'استرداد الدفعة المقدمة') > 0);
  ok('claims list shows paid', DBMS_LOB.INSTR(NOONA_PRJ_PKG.claims_html(l_ct), 'مسدد') > 0);
  ok('portfolio', DBMS_LOB.INSTR(NOONA_PRJ_PKG.portfolio_html, 'T' || l_sfx) > 0);
  ok('claims register', DBMS_LOB.INSTR(NOONA_PRJ_PKG.claims_register_html(TRUNC(SYSDATE) - 1, TRUNC(SYSDATE)), 'IPC-') > 0);
  ok('retention report (subcontractor retention)', DBMS_LOB.INSTR(NOONA_PRJ_PKG.retention_html, 'لمقاول الباطن') > 0);
  ok('cost report', DBMS_LOB.INSTR(NOONA_PRJ_PKG.cost_report_html(TRUNC(SYSDATE) - 1, TRUNC(SYSDATE), l_prj), 'مقاولو باطن') > 0);
  ok('summary', DBMS_LOB.INSTR(NOONA_PRJ_PKG.summary_html, 'قيمة العقود') > 0);

  -- ======================================================== التطوير العقاري
  SELECT MIN(p.id) INTO l_prop FROM re_property p WHERE p.company_id = NOONA_PRJ_PKG.company AND p.project_id IS NULL
     AND EXISTS (SELECT 1 FROM re_unit u WHERE u.property_id = p.id AND NVL(u.net_area_sqm, u.gross_area_sqm) > 0);
  IF l_prop IS NOT NULL THEN
    l_x := NOONA_PRJ_PKG.save_project('{"name":"تطوير عقاري اختبار","type":"REAL_ESTATE_DEVELOPMENT","property":' || l_prop || '}');
    SELECT project_id INTO l_n FROM re_property WHERE id = l_prop;
    ok('development project linked to the property', l_n = l_x);
    l_n := NOONA_PRJ_PKG.post_expense('{"project":' || l_x || ',"type":"OTHER","amount":100000,"place":"BOX:' || l_box || '","desc":"رسوم ترخيص البناء"}');
    l_c := NOONA_PRJ_PKG.unit_costs_html(l_x, 'AREA');
    ok('development cost allocated to units by area', DBMS_LOB.INSTR(l_c, 'تكلفة المتر') > 0 AND DBMS_LOB.INSTR(l_c, '100,000.00') > 0);
    ok('allocation by unit count', DBMS_LOB.INSTR(NOONA_PRJ_PKG.unit_costs_html(l_x, 'UNIT_COUNT'), 'تكلفة الوحدة') > 0);
  ELSE
    ok('real estate allocation (no property with units - skipped)', TRUE);
  END IF;
  BEGIN l_x := NOONA_PRJ_PKG.save_project('{"name":"x","type":"REAL_ESTATE_DEVELOPMENT"}'); ok('development project needs a property', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('development project needs a property', 'NOONA-PRJ-004', SQLERRM); END;
  NOONA_PRJ_PKG.set_status(l_prj, 'CLOSED');
  BEGIN l_x := NOONA_PRJ_PKG.post_expense('{"project":' || l_prj || ',"amount":10,"place":"BOX:' || l_box || '","desc":"x"}'); ok('closed project rejects costs', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('closed project rejects costs', 'NOONA-PRJ-007', SQLERRM); END;

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
