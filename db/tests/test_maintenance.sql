-- =============================================================================
-- NOONA PLUS ERP | اختبار صيانة الأصول وتمديد العمر وصيانة أسطول النقل بحساب NOONA_APP - يتراجع في النهاية
--   صيانة كمصروف أو رأسمالية مع تمديد العمر، العكس، خطط الصيانة الدورية للأصول، برامج صيانة الأسطول بالكيلومتر والأيام،
--   أوامر الصيانة وبنودها وإقفالها وترحيلها، العربة المستأجرة، الإلغاء، تقرير التكلفة
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_maintenance.sql
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
  l_sfx  VARCHAR2(4) := TO_CHAR(MOD(TO_NUMBER(TO_CHAR(SYSTIMESTAMP, 'SSFF3')), 9000) + 1000);
  l_v NUMBER; l_r NUMBER; l_asset NUMBER; l_m NUMBER; l_m2 NUMBER; l_pl NUMBER; l_fp NUMBER;
  l_o NUMBER; l_o2 NUMBER; l_o3 NUMBER; l_x NUMBER; l_n NUMBER; l_sup NUMBER; l_box NUMBER;
  l_cost NUMBER; l_life NUMBER; l_s VARCHAR2(4000); l_h CLOB;
  l_wh NUMBER; l_oil NUMBER; l_flt NUMBER; l_o4 NUMBER; l_wip NUMBER; l_b1 NUMBER; l_b2 NUMBER;
  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE rejects(p_name VARCHAR2, p_code VARCHAR2, p_sql VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
    ok(p_name, FALSE, 'accepted');
  EXCEPTION WHEN OTHERS THEN
    ok(p_name, INSTR(SQLERRM, p_code) > 0, SUBSTR(SQLERRM, 1, 200));
  END rejects;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_n := NOONA_FA_PKG.quick_setup;
  l_n := NOONA_TRN_PKG.quick_setup;
  SELECT MIN(s.party_id) INTO l_sup FROM ap_supplier s;
  ok('a supplier exists for workshop invoices', l_sup IS NOT NULL);

  -- ---------------------------------------------------------------- صيانة الأصول (المالية)
  l_v := NOONA_TRN_PKG.save_vehicle('{"plate":"ص ي ' || l_sfx || '","type":"TRUCK","make":"Scania","model":"R450","capacityTons":28,'
        || '"odometer":50000,"ownership":"OWNED","purchaseCost":300000,"funding":"OPENING"}');
  SELECT asset_id INTO l_asset FROM trn_vehicle WHERE id = l_v;
  SELECT cost, useful_life_months INTO l_cost, l_life FROM fa_asset_book WHERE asset_id = l_asset;
  ok('truck asset ready', l_asset IS NOT NULL AND l_cost = 300000, l_cost);

  l_m := NOONA_FA_PKG.record_maintenance('{"asset":' || l_asset || ',"maint_type":"CORRECTIVE","treatment":"EXPENSE",'
        || '"description":"إصلاح كمبروسر التكييف","amount":2000,"vat":300,"funding":"PAYABLE","party":' || l_sup || '}');
  SELECT COUNT(*) INTO l_n FROM fa_maintenance m JOIN ace_accounting_event e ON e.id = m.accounting_event_id
    JOIN gl_journal_line jl ON jl.journal_id = e.journal_id JOIN gl_account a ON a.id = jl.account_id
   WHERE m.id = l_m AND a.account_code = '5205' AND jl.debit_amount = 2000;
  ok('expense maintenance: Dr 5205 maintenance expense', l_n = 1);
  SELECT cost INTO l_x FROM fa_asset_book WHERE asset_id = l_asset;
  ok('expense maintenance does not change asset cost', l_x = 300000);
  rejects('life extension only with capitalized maintenance', 'NOONA-FA-062',
    'DECLARE x NUMBER; BEGIN x := NOONA_FA_PKG.record_maintenance(''{"asset":' || l_asset
    || ',"treatment":"EXPENSE","description":"x","amount":10,"life_extension":12,"funding":"PAYABLE","party":' || l_sup || '}''); END;');
  rejects('capitalized maintenance needs an asset', 'NOONA-FA-061',
    'DECLARE x NUMBER; BEGIN x := NOONA_FA_PKG.record_maintenance(''{"treatment":"CAPITALIZE","description":"x","amount":10,'
    || '"funding":"PAYABLE","party":' || l_sup || '}''); END;');
  rejects('description required', 'NOONA-FA-065',
    'DECLARE x NUMBER; BEGIN x := NOONA_FA_PKG.record_maintenance(''{"asset":' || l_asset || ',"amount":10}''); END;');

  l_m2 := NOONA_FA_PKG.record_maintenance('{"asset":' || l_asset || ',"maint_type":"OVERHAUL","treatment":"CAPITALIZE",'
        || '"description":"عمرة المحرك وناقل الحركة","amount":45000,"vat":6750,"funding":"PAYABLE","party":' || l_sup
        || ',"life_extension":24}');
  SELECT cost, useful_life_months INTO l_x, l_n FROM fa_asset_book WHERE asset_id = l_asset;
  ok('overhaul capitalized: asset cost +45,000', l_x = 345000, l_x);
  ok('overhaul extends useful life by 24 months', l_n = l_life + 24, l_n || ' vs ' || l_life);
  SELECT COUNT(*) INTO l_n FROM fa_maintenance m JOIN fa_transaction t ON t.id = m.fa_transaction_id
   WHERE m.id = l_m2 AND t.txn_type = 'ADDITION' AND t.status_code = 'POSTED';
  ok('capital addition transaction posted', l_n = 1);

  l_x := NOONA_FA_PKG.extend_life(l_asset, 12, TRUNC(SYSDATE), 'تقرير فني بصلاحية الهيكل');
  SELECT useful_life_months INTO l_n FROM fa_asset_book WHERE asset_id = l_asset;
  ok('direct life extension +12 months', l_n = l_life + 36, l_n);
  rejects('extension months must be positive', 'NOONA-FA-060',
    'DECLARE x NUMBER; BEGIN x := NOONA_FA_PKG.extend_life(' || l_asset || ', 0, NULL, ''x''); END;');

  l_x := NOONA_FA_PKG.reverse_maintenance(l_m, 'قيد بالخطأ');
  SELECT status_code INTO l_s FROM fa_maintenance WHERE id = l_m;
  ok('expense maintenance reversed', l_s = 'REVERSED' AND l_x IS NOT NULL);
  rejects('capitalized maintenance not reversible here', 'NOONA-FA-069',
    'DECLARE x NUMBER; BEGIN x := NOONA_FA_PKG.reverse_maintenance(' || l_m2 || ', ''x''); END;');

  l_fp := NOONA_FA_PKG.save_maint_plan(NULL, l_asset, 'فحص دوري شامل', 6, TRUNC(SYSDATE) - 2, 1500);
  ok('preventive plan due shows as overdue', DBMS_LOB.INSTR(NOONA_FA_PKG.due_maintenance_html(30), 'فحص دوري شامل') > 0);
  l_x := NOONA_FA_PKG.record_maintenance('{"asset":' || l_asset || ',"plan":' || l_fp || ',"maint_type":"PREVENTIVE",'
        || '"description":"فحص دوري","amount":1400,"funding":"PAYABLE","party":' || l_sup || '}');
  SELECT COUNT(*) INTO l_n FROM fa_maint_plan WHERE id = l_fp AND last_done_date = TRUNC(SYSDATE) AND next_due_date = ADD_MONTHS(TRUNC(SYSDATE), 6);
  ok('doing the plan moves next due by 6 months', l_n = 1);
  l_h := NOONA_FA_PKG.maintenance_html(l_asset);
  ok('asset maintenance history renders', DBMS_LOB.INSTR(l_h, 'عمرة المحرك') > 0 AND DBMS_LOB.INSTR(l_h, 'معكوسة') > 0);

  -- ---------------------------------------------------------------- صيانة الأسطول (النقل)
  l_pl := NOONA_TRN_PKG.save_maint_plan('{"service":"تغيير زيت وفلاتر ' || l_sfx || '","vehicle":' || l_v || ',"everyKm":10000,"everyDays":90,"cost":900}');
  rejects('program needs km or days', 'NOONA-TRN-101',
    'DECLARE x NUMBER; BEGIN x := NOONA_TRN_PKG.save_maint_plan(''{"service":"x"}''); END;');
  ok('never-done program is due', DBMS_LOB.INSTR(NOONA_TRN_PKG.maint_due_html, 'تغيير زيت وفلاتر ' || l_sfx) > 0);

  l_o := NOONA_TRN_PKG.open_maint('{"vehicle":' || l_v || ',"plan":' || l_pl || ',"workshop":"EXTERNAL","vendor":' || l_sup || ',"odometer":50500}');
  SELECT status_code INTO l_s FROM trn_vehicle WHERE id = l_v;
  ok('vehicle enters maintenance', l_s = 'MAINTENANCE');
  SELECT maint_type || ':' || description INTO l_s FROM trn_maint_order WHERE id = l_o;
  ok('preventive type and description from program', l_s LIKE 'PREVENTIVE:تغيير زيت%', l_s);
  rejects('one open order per vehicle', 'NOONA-TRN-104',
    'DECLARE x NUMBER; BEGIN x := NOONA_TRN_PKG.open_maint(''{"vehicle":' || l_v || ',"description":"x"}''); END;');
  rejects('external workshop needs vendor', 'NOONA-TRN-108',
    'DECLARE x NUMBER; BEGIN x := NOONA_TRN_PKG.open_maint(''{"vehicle":' || l_v || ',"description":"x","workshop":"EXTERNAL"}''); END;');
  l_x := NOONA_TRN_PKG.add_maint_line(l_o, 'OIL', 'زيت محرك 15W40', 30, 25);
  l_x := NOONA_TRN_PKG.add_maint_line(l_o, 'PART', 'فلتر زيت', 2, 75);
  l_x := NOONA_TRN_PKG.add_maint_line(l_o, 'LABOR', 'أجور فني', 1, 200);
  l_r := NOONA_TRN_PKG.add_maint_line(l_o, 'OTHER', 'بند خاطئ', 1, 999);
  NOONA_TRN_PKG.remove_maint_line(l_r);
  SELECT parts_cost || '/' || labor_cost || '/' || total_cost || '/' || status_code INTO l_s FROM trn_maint_order WHERE id = l_o;
  ok('order totals: parts 900, labor 200, total 1100', l_s = '900/200/1100/IN_PROGRESS', l_s);
  rejects('exit odometer cannot be below entry', 'NOONA-TRN-115',
    'BEGIN NOONA_TRN_PKG.complete_maint(' || l_o || ', ''{"odometer":40000}''); END;');
  NOONA_TRN_PKG.complete_maint(l_o, '{"odometer":50520,"vat":165,"downtimeHours":5}');
  SELECT o.status_code || '/' || m.treatment || '/' || m.amount || '/' || m.source_module || '/' || o.downtime_hours INTO l_s
    FROM trn_maint_order o JOIN fa_maintenance m ON m.id = o.fa_maintenance_id WHERE o.id = l_o;
  ok('order completed and posted as maintenance expense', l_s = 'COMPLETED/EXPENSE/1100/TRN/5', l_s);
  SELECT status_code || '/' || odometer_km INTO l_s FROM trn_vehicle WHERE id = l_v;
  ok('vehicle available with updated odometer', l_s = 'AVAILABLE/50520', l_s);
  ok('program no longer due after service', DBMS_LOB.INSTR(NOONA_TRN_PKG.maint_due_html, 'تغيير زيت وفلاتر ' || l_sfx) = 0);
  rejects('closed order cannot change', 'NOONA-TRN-110',
    'DECLARE x NUMBER; BEGIN x := NOONA_TRN_PKG.add_maint_line(' || l_o || ', ''PART'', ''x'', 1, 1); END;');

  UPDATE trn_vehicle SET odometer_km = 59800 WHERE id = l_v;
  ok('program due again near 10,000 km', DBMS_LOB.INSTR(NOONA_TRN_PKG.maint_due_html, 'تغيير زيت وفلاتر ' || l_sfx) > 0);

  -- عمرة رأسمالية تمدد عمر الشاحنة
  SELECT cost, useful_life_months INTO l_cost, l_life FROM fa_asset_book WHERE asset_id = l_asset;
  l_o2 := NOONA_TRN_PKG.open_maint('{"vehicle":' || l_v || ',"type":"OVERHAUL","workshop":"EXTERNAL","vendor":' || l_sup
        || ',"description":"عمرة كاملة للمحرك"}');
  l_x := NOONA_TRN_PKG.add_maint_line(l_o2, 'PART', 'طقم عمرة محرك', 1, 38000);
  l_x := NOONA_TRN_PKG.add_maint_line(l_o2, 'LABOR', 'أجور العمرة', 1, 7000);
  NOONA_TRN_PKG.complete_maint(l_o2, '{"treatment":"CAPITALIZE","lifeExtension":36,"vat":6750}');
  SELECT cost, useful_life_months INTO l_x, l_n FROM fa_asset_book WHERE asset_id = l_asset;
  ok('truck overhaul added to asset cost', l_x = l_cost + 45000, l_x);
  ok('truck useful life extended 36 months', l_n = l_life + 36, l_n);

  -- عربة مستأجرة: مصروف فقط
  l_r := NOONA_TRN_PKG.save_vehicle('{"plate":"م س ' || l_sfx || '","type":"VAN","capacityTons":2,"ownership":"RENTED"}');
  l_o3 := NOONA_TRN_PKG.open_maint('{"vehicle":' || l_r || ',"description":"تغيير إطارين","type":"TIRES","workshop":"EXTERNAL","vendor":' || l_sup || '}');
  l_x := NOONA_TRN_PKG.add_maint_line(l_o3, 'TIRE', 'إطار', 2, 600);
  rejects('rented vehicle cannot capitalize', 'NOONA-TRN-117',
    'BEGIN NOONA_TRN_PKG.complete_maint(' || l_o3 || ', ''{"treatment":"CAPITALIZE"}''); END;');
  NOONA_TRN_PKG.complete_maint(l_o3, '{}');
  SELECT COUNT(*) INTO l_n FROM trn_maint_order o JOIN fa_maintenance m ON m.id = o.fa_maintenance_id
   WHERE o.id = l_o3 AND m.asset_id IS NULL AND m.amount = 1200;
  ok('rented vehicle maintenance posted as expense without asset', l_n = 1);

  -- إلغاء أمر يعيد حالة العربة
  l_o3 := NOONA_TRN_PKG.open_maint('{"vehicle":' || l_r || ',"description":"فحص"}');
  NOONA_TRN_PKG.cancel_maint(l_o3, 'لم تحتج');
  SELECT status_code INTO l_s FROM trn_vehicle WHERE id = l_r;
  ok('cancel returns vehicle to available', l_s = 'AVAILABLE');

  -- ---------------------------------------------------------------- ورشة داخلية تصرف من المخزون
  l_n := NOONA_INV_PKG.quick_setup;
  l_wh := NOONA_INV_PKG.create_warehouse('WS' || l_sfx, 'مستودع الورشة ' || l_sfx, 'MAIN');
  l_oil := NOONA_INV_PKG.save_item('{"name":"زيت محرك ديزل 15W40 ' || l_sfx || '","code":"MO' || l_sfx || '","price":30}');
  l_flt := NOONA_INV_PKG.save_item('{"name":"فلتر زيت شاحنة ' || l_sfx || '","code":"MF' || l_sfx || '","price":90}');
  l_n := NOONA_INV_PKG.save_stock_doc('{"id":null,"type":"OPENING","date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '","wh":' || l_wh
        || ',"action":"POST","lines":[{"i":' || l_oil || ',"q":200,"c":22},{"i":' || l_flt || ',"q":20,"c":60}]}');
  ok('workshop stock ready', NOONA_INV_PKG.on_hand(l_oil, l_wh) = 200 AND NOONA_INV_PKG.on_hand(l_flt, l_wh) = 20);
  l_wip := NOONA_INV_PKG.maint_wip_account;
  ok('maintenance WIP account 1116 exists', l_wip IS NOT NULL);
  SELECT NVL(SUM(debit_amount - credit_amount), 0) INTO l_b1 FROM gl_journal_line WHERE account_id = l_wip;

  l_o4 := NOONA_TRN_PKG.open_maint('{"vehicle":' || l_v || ',"type":"PREVENTIVE","workshop":"INTERNAL","warehouse":' || l_wh
        || ',"description":"تغيير زيت وفلتر بالورشة الداخلية"}');
  l_x := NOONA_TRN_PKG.add_maint_line(l_o4, 'OIL', NULL, 30, NULL, l_oil);
  l_x := NOONA_TRN_PKG.add_maint_line(l_o4, 'PART', NULL, 2, NULL, l_flt);
  l_r := NOONA_TRN_PKG.add_maint_line(l_o4, 'PART', NULL, 1, NULL, l_flt);
  ok('oil issued from workshop stock', NOONA_INV_PKG.on_hand(l_oil, l_wh) = 170);
  ok('filters issued from workshop stock', NOONA_INV_PKG.on_hand(l_flt, l_wh) = 17);
  SELECT COUNT(*) INTO l_n FROM trn_maint_line WHERE order_id = l_o4 AND from_stock = 'Y' AND inv_txn_id IS NOT NULL;
  ok('stock lines linked to inventory movements', l_n = 3);
  SELECT amount INTO l_x FROM trn_maint_line WHERE order_id = l_o4 AND item_id = l_oil;
  ok('oil costed at weighted average (30 x 22 = 660)', l_x = 660, l_x);
  SELECT NVL(SUM(debit_amount - credit_amount), 0) INTO l_b2 FROM gl_journal_line WHERE account_id = l_wip;
  ok('issue posted to maintenance WIP (660 + 180)', l_b2 - l_b1 = 840, l_b2 - l_b1);
  NOONA_TRN_PKG.remove_maint_line(l_r);
  ok('unused filter returned to stock', NOONA_INV_PKG.on_hand(l_flt, l_wh) = 18);
  SELECT NVL(SUM(debit_amount - credit_amount), 0) INTO l_b2 FROM gl_journal_line WHERE account_id = l_wip;
  ok('return reverses WIP', l_b2 - l_b1 = 780, l_b2 - l_b1);
  SELECT stock_cost || '/' || total_cost INTO l_s FROM trn_maint_order WHERE id = l_o4;
  ok('order stock cost 780 of total 780', l_s = '780/780', l_s);
  NOONA_TRN_PKG.complete_maint(l_o4, '{}');
  SELECT NVL(SUM(debit_amount - credit_amount), 0) INTO l_b2 FROM gl_journal_line WHERE account_id = l_wip;
  ok('completion clears maintenance WIP', l_b2 = l_b1, l_b2 - l_b1);
  SELECT m.stock_amount || '/' || m.amount || '/' || m.treatment INTO l_s FROM trn_maint_order o JOIN fa_maintenance m ON m.id = o.fa_maintenance_id WHERE o.id = l_o4;
  ok('posted as maintenance expense from stock', l_s = '780/780/EXPENSE', l_s);

  -- عمرة داخلية رأسمالية بمواد من المخزون + عمالة خارجية
  SELECT cost INTO l_cost FROM fa_asset_book WHERE asset_id = l_asset;
  l_o4 := NOONA_TRN_PKG.open_maint('{"vehicle":' || l_v || ',"type":"OVERHAUL","workshop":"INTERNAL","warehouse":' || l_wh
        || ',"description":"عمرة بالورشة الداخلية"}');
  l_x := NOONA_TRN_PKG.add_maint_line(l_o4, 'OIL', NULL, 40, NULL, l_oil);
  l_x := NOONA_TRN_PKG.add_maint_line(l_o4, 'LABOR', 'فني عمرة متعاقد', 1, 3000);
  NOONA_TRN_PKG.complete_maint(l_o4, '{"treatment":"CAPITALIZE","lifeExtension":12,"funding":"PAYABLE","vat":450,"vendor":' || l_sup || '}');
  SELECT cost INTO l_x FROM fa_asset_book WHERE asset_id = l_asset;
  ok('capitalized: stock 880 + labor 3000 added to asset', l_x = l_cost + 3880, l_x - l_cost);
  SELECT NVL(SUM(debit_amount - credit_amount), 0) INTO l_b2 FROM gl_journal_line WHERE account_id = l_wip;
  ok('WIP cleared after capitalization', l_b2 = l_b1, l_b2 - l_b1);

  -- إلغاء أمر يعيد القطع للمخزون
  l_o4 := NOONA_TRN_PKG.open_maint('{"vehicle":' || l_v || ',"workshop":"INTERNAL","warehouse":' || l_wh || ',"description":"فحص"}');
  l_x := NOONA_TRN_PKG.add_maint_line(l_o4, 'OIL', NULL, 5, NULL, l_oil);
  NOONA_TRN_PKG.cancel_maint(l_o4, 'أجلت');
  ok('cancel returns issued oil', NOONA_INV_PKG.on_hand(l_oil, l_wh) = 130, NOONA_INV_PKG.on_hand(l_oil, l_wh));

  -- ---------------------------------------------------------------- عمر الاستبدال والتقارير
  NOONA_TRN_PKG.set_part_life(l_oil, 10000, 180);
  SELECT odometer_km INTO l_n FROM trn_vehicle WHERE id = l_v;
  l_o4 := NOONA_TRN_PKG.open_maint('{"vehicle":' || l_v || ',"workshop":"INTERNAL","warehouse":' || l_wh || ',"description":"تغيير زيت دوري"}');
  l_x := NOONA_TRN_PKG.add_maint_line(l_o4, 'OIL', NULL, 30, NULL, l_oil);
  l_r := NOONA_TRN_PKG.add_maint_line(l_o4, 'TIRE', 'بطارية 200 أمبير', 1, 900, NULL, NULL, 730);
  SELECT life_km || '/' || life_days INTO l_s FROM trn_maint_line WHERE id = l_x;
  ok('oil line takes item replacement life (10000 km / 180 days)', l_s = '10000/180', l_s);
  NOONA_TRN_PKG.complete_maint(l_o4, '{"odometer":' || (l_n + 100) || ',"funding":"PAYABLE","vendor":' || l_sup || '}');
  SELECT next_due_km || '/' || TO_CHAR(next_due_date, 'YYYY-MM-DD') INTO l_s FROM trn_maint_line WHERE id = l_x;
  ok('next oil change from exit odometer and date', l_s = (l_n + 10100) || '/' || TO_CHAR(TRUNC(SYSDATE) + 180, 'YYYY-MM-DD'), l_s);
  SELECT TO_CHAR(next_due_date, 'YYYY-MM-DD') INTO l_s FROM trn_maint_line WHERE id = l_r;
  ok('battery replacement date by life days (730)', l_s = TO_CHAR(TRUNC(SYSDATE) + 730, 'YYYY-MM-DD'), l_s);
  l_h := NOONA_TRN_PKG.maint_due_html;
  ok('fresh oil not due yet', DBMS_LOB.INSTR(l_h, 'قطع حان استبدالها') = 0 OR DBMS_LOB.INSTR(l_h, 'زيت محرك ديزل 15W40 ' || l_sfx) = 0);
  UPDATE trn_vehicle SET odometer_km = l_n + 9500 WHERE id = l_v;
  l_h := NOONA_TRN_PKG.maint_due_html;
  ok('oil due for replacement near its km life', DBMS_LOB.INSTR(l_h, 'زيت محرك ديزل 15W40 ' || l_sfx) > 0);
  -- استبدال ثان: يظهر العمر الفعلي للقطعة السابقة
  l_o4 := NOONA_TRN_PKG.open_maint('{"vehicle":' || l_v || ',"workshop":"INTERNAL","warehouse":' || l_wh || ',"description":"تغيير زيت"}');
  l_x := NOONA_TRN_PKG.add_maint_line(l_o4, 'OIL', NULL, 30, NULL, l_oil);
  NOONA_TRN_PKG.complete_maint(l_o4, '{}');
  ok('replaced oil no longer due', DBMS_LOB.INSTR(NOONA_TRN_PKG.maint_due_html, 'زيت محرك ديزل 15W40 ' || l_sfx) = 0);
  l_h := NOONA_TRN_PKG.parts_report_html(TRUNC(SYSDATE) - 1, TRUNC(SYSDATE), l_v);
  ok('parts report lists vehicle spare parts with totals', DBMS_LOB.INSTR(l_h, 'زيت محرك ديزل') > 0 AND DBMS_LOB.INSTR(l_h, 'إجمالي ص ي ' || l_sfx) > 0);
  ok('parts report shows actual life of previous part', DBMS_LOB.INSTR(l_h, '9400 كم') > 0 OR DBMS_LOB.INSTR(l_h, '9,400 كم') > 0);
  l_h := NOONA_TRN_PKG.vehicle_perf_html(TRUNC(SYSDATE) - 1, TRUNC(SYSDATE), l_v);
  ok('vehicle performance report', DBMS_LOB.INSTR(l_h, 'ص ي ' || l_sfx) > 0 AND DBMS_LOB.INSTR(l_h, 'التكلفة/كم') > 0);
  l_h := NOONA_TRN_PKG.driver_perf_html(ADD_MONTHS(TRUNC(SYSDATE), -12), TRUNC(SYSDATE));
  ok('driver performance report renders', l_h IS NOT NULL);

  l_h := NOONA_TRN_PKG.maint_cost_html(TRUNC(SYSDATE) - 1);
  ok('fleet maintenance cost report', DBMS_LOB.INSTR(l_h, 'ص ي ' || l_sfx) > 0 AND DBMS_LOB.INSTR(l_h, 'التكلفة/كم') > 0);
  ok('order page renders', DBMS_LOB.INSTR(NOONA_TRN_PKG.maint_order_html(l_o2), 'رأسمالية') > 0);

  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || (g_fail + 1) || ' failed');
END;
/
EXIT
