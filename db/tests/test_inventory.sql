-- =============================================================================
-- NOONA PLUS ERP | اختبار المخزون وسلسلة الإمداد (الأصناف بملفاتها، الباركود، قطع الغيار، الأدوية والدفعات،
--                  مستندات المخزون وقيودها، المتوسط المرجح، التحويل، قائمة المواد والإنتاج، التقارير) بحساب NOONA_APP
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_inventory.sql
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

-- التجهيز يحفظ (بيانات أساسية للشركة)
BEGIN
  NOONA_APEX_PKG.cleanup_request;
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  DBMS_OUTPUT.PUT_LINE('setup rows: ' || NOONA_INV_PKG.quick_setup);
  COMMIT;
  NOONA_APEX_PKG.cleanup_request;
END;
/

DECLARE
  g_pass PLS_INTEGER := 0;
  g_fail PLS_INTEGER := 0;
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'HH24MISSFF3');
  l_n    NUMBER;
  l_gen  NUMBER;     -- صنف عام
  l_ph   NUMBER;     -- دواء
  l_ap   NUMBER;     -- قطعة غيار
  l_ap2  NUMBER;     -- قطعة بديلة
  l_raw  NUMBER;     -- خامة
  l_fg   NUMBER;     -- منتج مصنع
  l_srv  NUMBER;     -- خدمة
  l_wh   NUMBER;
  l_wh2  NUMBER;
  l_cc   NUMBER;
  l_t    NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_d    VARCHAR2(10) := TO_CHAR(SYSDATE, 'YYYY-MM-DD');
  l_bar  VARCHAR2(30) := '62' || LPAD(SUBSTR(l_sfx, 1, 9), 11, '0');

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION item(p_json VARCHAR2) RETURN NUMBER IS BEGIN RETURN NOONA_INV_PKG.save_item(p_json); END;
  FUNCTION cat(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM inv_item_category WHERE code = p_code; RETURN l;
  END cat;
  FUNCTION doc(p_type VARCHAR2, p_lines VARCHAR2, p_extra VARCHAR2 DEFAULT NULL, p_action VARCHAR2 DEFAULT 'POST') RETURN NUMBER IS
  BEGIN
    RETURN NOONA_INV_PKG.save_stock_doc('{"id":null,"type":"' || p_type || '","date":"' || l_d || '","wh":' || l_wh || p_extra
      || ',"action":"' || p_action || '","lines":[' || p_lines || ']}');
  END doc;
  -- سطور قيد المستند: رمز:مدين/دائن مرتبة
  FUNCTION jl(p_entity NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT LISTAGG(a.account_code || ':' || l.debit_amount || '/' || l.credit_amount, ' ') WITHIN GROUP (ORDER BY a.account_code, l.debit_amount)
      INTO l
      FROM ace_accounting_event e JOIN gl_journal j ON j.accounting_event_id = e.id JOIN gl_journal_line l ON l.journal_id = j.id
      JOIN gl_account a ON a.id = l.account_id
     WHERE e.source_entity_type = 'INV_TRANSACTION' AND e.source_entity_id = p_entity;
    RETURN l;
  END jl;
  FUNCTION jtype(p_entity NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(100);
  BEGIN
    SELECT MAX(j.journal_category) INTO l FROM ace_accounting_event e JOIN gl_journal j ON j.accounting_event_id = e.id
     WHERE e.source_entity_type = 'INV_TRANSACTION' AND e.source_entity_id = p_entity;
    RETURN l;
  END jtype;
BEGIN
  NOONA_APEX_PKG.cleanup_request;
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  UPDATE dms_archive_rule SET is_active = 'N';

  -- التجهيز
  ok('inventory ready after quick setup', NOONA_INV_PKG.is_ready = 'Y');
  ok('quick setup is idempotent', NOONA_INV_PKG.quick_setup = 0);
  SELECT COUNT(*) INTO l_n FROM inv_item_category WHERE code IN ('GEN', 'AUTO', 'PHARMA', 'RAW', 'FG', 'SRV') AND inventory_account_id IS NOT NULL;
  ok('default categories with accounts (goods, spare parts, pharma, raw, finished, services)', l_n = 6, l_n);
  SELECT COUNT(*) INTO l_n FROM loc_tax_account WHERE company_id = NOONA_INV_PKG.company;
  ok('VAT accounts linked to the company', l_n >= 4, l_n);
  ok('VAT 15% rate', NOONA_INV_PKG.tax_rate(NOONA_INV_PKG.tax_id('VAT15')) = 15);
  ok('purchase VAT goes to input tax 1107', NOONA_INV_PKG.tax_account(NOONA_INV_PKG.tax_id('VAT15'), 'PURCHASE') = NOONA_INV_PKG.acc_id('1107'));
  l_wh := NOONA_INV_PKG.create_warehouse('WT' || SUBSTR(l_sfx, 1, 6), 'مستودع اختبار', 'MAIN');
  l_wh2 := NOONA_INV_PKG.create_warehouse('WS' || SUBSTR(l_sfx, 1, 6), 'مستودع الفرع', 'STORE');
  SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY DECODE(code, 'CC-100', 0, 1), id) INTO l_cc
    FROM gl_cost_center WHERE company_id = NOONA_INV_PKG.company;
  IF l_cc IS NULL THEN
    INSERT INTO gl_cost_center (company_id, code, name_ar)
    VALUES (NOONA_INV_PKG.company, 'TCC' || SUBSTR(l_sfx, 1, 6), 'مركز اختبار') RETURNING id INTO l_cc;
  END IF;

  -- الأصناف
  l_gen := item('{"name":"زيت محرك 5W30 اختبار","code":"OIL' || l_sfx || '","cat":' || cat('GEN') || ',"price":45,"incl":"Y",'
             || '"min":20,"max":60,"barcodes":["' || l_bar || '","X' || l_sfx || '"]}');
  SELECT item_no INTO l_s FROM inv_item WHERE id = l_gen;
  ok('item number generated', l_s LIKE 'ITM-%', l_s);
  ok('item found by barcode', NOONA_INV_PKG.item_by_barcode(l_bar) = l_gen);
  ok('item found by item code', NOONA_INV_PKG.item_by_barcode('OIL' || l_sfx) = l_gen);
  l_c := NOONA_INV_PKG.find_items(l_bar);
  ok('POS search by barcode returns price and tax', INSTR(l_c, '"id":' || l_gen || ',') > 0 AND INSTR(l_c, '"t":15') > 0
     AND INSTR(l_c, '"inc":"Y"') > 0, SUBSTR(l_c, 1, 300));
  BEGIN
    l_n := item('{"name":"صنف مكرر","barcodes":["' || l_bar || '"]}');
    ok('duplicate barcode rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('duplicate barcode rejected', 'NOONA-INV-013', SQLERRM); END;

  l_ph := item('{"name":"باراسيتامول 500 مجم اختبار","cat":' || cat('PHARMA') || ',"generic":"Paracetamol","strength":"500mg",'
            || '"form":"TABLET","rx":"N","reg":"SFDA-' || l_sfx || '","price":12}');
  SELECT tracking_mode || '|' || track_expiry || '|' || product_profile INTO l_s FROM inv_item WHERE id = l_ph;
  ok('pharma item tracked by lot and expiry', l_s = 'LOT|Y|PHARMA', l_s);
  l_c := NOONA_INV_PKG.find_items('paracetamol');
  ok('search by generic name', INSTR(l_c, '"id":' || l_ph || ',') > 0);

  l_ap2 := item('{"name":"فلتر زيت بديل اختبار","cat":' || cat('AUTO') || ',"mpn":"ALT-' || l_sfx || '","brand":"Bosch","price":30}');
  l_ap := item('{"name":"فلتر زيت تويوتا اختبار","cat":' || cat('AUTO') || ',"mpn":"90915-' || l_sfx || '","brand":"Toyota",'
            || '"mfr":"Toyota Genuine","price":55,"fitment":[{"make":"Toyota","model":"Camry","from":2012,"to":2020,"engine":"2.5L"},'
            || '{"make":"Toyota","model":"Corolla","from":2014,"to":2022}],"alternates":[{"no":"ALT-' || l_sfx || '","type":"OEM_EQUIVALENT"}]}');
  ok('spare part found by OEM number', NOONA_INV_PKG.item_by_barcode('90915-' || l_sfx) IS NULL
     AND INSTR(NOONA_INV_PKG.find_items('90915-' || l_sfx), '"id":' || l_ap || ',') > 0);
  l_c := NOONA_INV_PKG.item_json(l_ap);
  ok('item JSON carries fitment and alternates', INSTR(l_c, '"model":"Camry"') > 0 AND INSTR(l_c, '"type":"OEM_EQUIVALENT"') > 0);
  l_c := NOONA_INV_PKG.fitment_search('toyota', 'camry', 2015);
  ok('fitment search by vehicle and year', INSTR(l_c, '90915-' || l_sfx) > 0 AND INSTR(l_c, 'ALT-') = 0);
  l_c := NOONA_INV_PKG.fitment_search('toyota', 'camry', 2025);
  ok('fitment search excludes other years', INSTR(l_c, '90915-' || l_sfx) = 0);

  l_raw := item('{"name":"حبيبات بلاستيك خام اختبار","type":"RAW_MATERIAL","cat":' || cat('RAW') || ',"sell":"N"}');
  l_fg := item('{"name":"علبة بلاستيك مصنعة اختبار","type":"FINISHED_GOOD","cat":' || cat('FG') || ',"price":20}');
  l_srv := item('{"name":"خدمة تركيب اختبار","type":"SERVICE","cat":' || cat('SRV') || ',"price":50}');
  ok('service is not stocked', NOONA_INV_PKG.is_stocked(l_srv) = 'N' AND NOONA_INV_PKG.is_stocked(l_gen) = 'Y');
  ok('raw material hidden from sales search', INSTR(NOONA_INV_PKG.find_items('حبيبات بلاستيك خام اختبار'), '"id":' || l_raw || ',') = 0
     AND INSTR(NOONA_INV_PKG.find_items('حبيبات بلاستيك خام اختبار', NULL, 20, 'PURCHASE'), '"id":' || l_raw || ',') > 0);

  -- رصيد افتتاحي: مدين المخزون 1105 / دائن الأرصدة الافتتاحية 3105، قيد من نوع «حركة مخزون»
  l_t := doc('OPENING', '{"i":' || l_gen || ',"q":10,"c":20},{"i":' || l_raw || ',"q":100,"c":2}');
  ok('opening stock posted', NOONA_INV_PKG.on_hand(l_gen, l_wh) = 10 AND NOONA_INV_PKG.avg_cost(l_gen) = 20);
  ok('opening journal Dr inventory / Cr opening balances', jl(l_t) = '1105:400/0 3105:0/400', jl(l_t));
  ok('opening journal typed INVENTORY', jtype(l_t) = 'INVENTORY', jtype(l_t));
  SELECT doc_no || '|' || status_code INTO l_s FROM inv_transaction WHERE id = l_t;
  ok('stock document numbered and posted', l_s LIKE 'IT-%|POSTED', l_s);
  BEGIN
    l_n := NOONA_INV_PKG.save_stock_doc('{"id":' || l_t || ',"type":"OPENING","lines":[]}');
    ok('posted stock document is locked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('posted stock document is locked', 'NOONA-INV-033', SQLERRM); END;

  -- الأدوية: الدفعة والصلاحية إلزامية
  BEGIN
    l_n := doc('OPENING', '{"i":' || l_ph || ',"q":50,"c":5}');
    ok('pharma opening requires lot', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('pharma opening requires lot', 'NOONA-INV-022', SQLERRM); END;
  l_t := doc('OPENING', '{"i":' || l_ph || ',"q":50,"c":5,"lot":"B1' || l_sfx || '","exp":"' || TO_CHAR(SYSDATE + 200, 'YYYY-MM-DD') || '"},'
          || '{"i":' || l_ph || ',"q":8,"c":5,"lot":"B0' || l_sfx || '","exp":"' || TO_CHAR(SYSDATE - 5, 'YYYY-MM-DD') || '"},'
          || '{"i":' || l_ph || ',"q":20,"c":5,"lot":"B2' || l_sfx || '","exp":"' || TO_CHAR(SYSDATE + 40, 'YYYY-MM-DD') || '"}');
  SELECT COUNT(*) INTO l_n FROM inv_onhand o JOIN inv_lot l ON l.id = o.lot_id WHERE o.item_id = l_ph AND o.warehouse_id = l_wh AND o.on_hand_qty > 0;
  ok('pharma stock held per lot', l_n = 3 AND NOONA_INV_PKG.on_hand(l_ph, l_wh) = 78, l_n);
  l_c := NOONA_INV_PKG.expiry_report(90, l_wh);
  ok('expiry report shows expired and near-expiry lots', INSTR(l_c, 'B0' || l_sfx) > 0 AND INSTR(l_c, 'منتهية') > 0
     AND INSTR(l_c, 'B2' || l_sfx) > 0 AND INSTR(l_c, 'B1' || l_sfx) = 0);
  -- إتلاف الدفعة المنتهية: مدين عجز وتلف المخزون 5213
  l_t := doc('SCRAP', '{"i":' || l_ph || ',"q":8,"lot":"B0' || l_sfx || '"}', ',"reason":"EXPIRED"');
  ok('expired lot scrapped', NOONA_INV_PKG.on_hand(l_ph, l_wh) = 70);
  ok('scrap journal Dr 5213 / Cr inventory', jl(l_t) = '1105:0/40 5213:40/0', jl(l_t));

  -- تسوية بالزيادة تعيد حساب المتوسط المرجح
  l_t := doc('ADJ_IN', '{"i":' || l_gen || ',"q":5,"c":26}', ',"reason":"COUNT"');
  ok('weighted average after adjustment in', NOONA_INV_PKG.avg_cost(l_gen) = 22, NOONA_INV_PKG.avg_cost(l_gen));
  ok('adjustment-in journal Cr inventory gains 4203', jl(l_t) = '1105:130/0 4203:0/130', jl(l_t));
  BEGIN
    l_n := doc('ADJ_OUT', '{"i":' || l_gen || ',"q":2}');
    ok('adjustment needs a reason', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('adjustment needs a reason', 'NOONA-INV-032', SQLERRM); END;
  l_t := doc('ADJ_OUT', '{"i":' || l_gen || ',"q":2}', ',"reason":"SHORTAGE"');
  ok('shortage at weighted average cost', jl(l_t) = '1105:0/44 5213:44/0', jl(l_t));
  BEGIN
    l_n := doc('ADJ_OUT', '{"i":' || l_gen || ',"q":500}', ',"reason":"SHORTAGE"');
    ok('negative stock prevented', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('negative stock prevented', 'NOONA-INV-025', SQLERRM); END;

  -- صرف لمركز تكلفة: مدين حساب مصروف الصنف بمركز التكلفة
  BEGIN
    l_n := doc('CONSUMPTION', '{"i":' || l_gen || ',"q":1}');
    ok('consumption needs a cost center', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('consumption needs a cost center', 'NOONA-INV-034', SQLERRM); END;
  l_t := doc('CONSUMPTION', '{"i":' || l_gen || ',"q":1}', ',"cc":' || l_cc);
  SELECT COUNT(*) INTO l_n FROM ace_accounting_event e JOIN gl_journal j ON j.accounting_event_id = e.id
    JOIN gl_journal_line l ON l.journal_id = j.id
   WHERE e.source_entity_type = 'INV_TRANSACTION' AND e.source_entity_id = l_t AND l.debit_amount = 22 AND l.cost_center_id = l_cc;
  ok('consumption charged to the cost center', l_n = 1, jl(l_t));

  -- التحويل بين المستودعات بلا قيد
  l_t := doc('TRANSFER_OUT', '{"i":' || l_gen || ',"q":3}', ',"toWh":' || l_wh2);
  ok('transfer moves stock between warehouses', NOONA_INV_PKG.on_hand(l_gen, l_wh) = 9 AND NOONA_INV_PKG.on_hand(l_gen, l_wh2) = 3
     AND NOONA_INV_PKG.on_hand(l_gen) = 12);
  ok('transfer keeps the average cost and posts no journal', NOONA_INV_PKG.avg_cost(l_gen) = 22 AND jl(l_t) IS NULL);
  BEGIN
    l_n := doc('TRANSFER_OUT', '{"i":' || l_gen || ',"q":1}', ',"toWh":' || l_wh);
    ok('transfer to the same warehouse rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('transfer to the same warehouse rejected', 'NOONA-INV-031', SQLERRM); END;
  BEGIN
    l_n := doc('ADJ_IN', '{"i":' || l_srv || ',"q":1,"c":5}', ',"reason":"X"');
    ok('services cannot be stocked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('services cannot be stocked', 'NOONA-INV-035', SQLERRM); END;

  -- مسودة ثم ترحيل وإلغاء
  l_t := doc('ADJ_IN', '{"i":' || l_gen || ',"q":1,"c":22}', ',"reason":"COUNT"', 'SAVE');
  ok('draft has no stock effect', NOONA_INV_PKG.on_hand(l_gen, l_wh) = 9 AND INSTR(NOONA_INV_PKG.stock_doc_json(l_t), '"status":"DRAFT"') > 0);
  NOONA_INV_PKG.cancel_stock_doc(l_t);
  SELECT status_code INTO l_s FROM inv_transaction WHERE id = l_t;
  ok('draft cancelled', l_s = 'CANCELLED', l_s);

  -- التصنيع: 4 وحدات خام لكل منتج + 5% هالك
  l_n := NOONA_INV_PKG.save_bom(l_fg, '[{"i":' || l_raw || ',"q":4,"s":5}]');
  ok('bill of materials saved', INSTR(NOONA_INV_PKG.bom_json(l_fg), '"q":4') > 0);
  BEGIN
    l_n := NOONA_INV_PKG.save_bom(l_fg, '[{"i":' || l_fg || ',"q":1}]');
    ok('item cannot be its own component', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('item cannot be its own component', 'NOONA-INV-040', SQLERRM); END;
  l_t := NOONA_INV_PKG.produce(l_fg, 5, l_wh, TRUNC(SYSDATE), 'تشغيلة اختبار');
  ok('production consumes raw materials with scrap', NOONA_INV_PKG.on_hand(l_raw, l_wh) = 79);
  ok('finished goods received at material cost', NOONA_INV_PKG.on_hand(l_fg, l_wh) = 5 AND NOONA_INV_PKG.avg_cost(l_fg) = 8.4,
     NOONA_INV_PKG.avg_cost(l_fg));
  ok('production journal typed MANUFACTURING', jtype(l_t) = 'MANUFACTURING', jtype(l_t) || ' ' || jl(l_t));
  BEGIN
    l_n := NOONA_INV_PKG.produce(l_fg, 1000, l_wh, TRUNC(SYSDATE));
    ok('production limited by raw stock', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('production limited by raw stock', 'NOONA-INV-025', SQLERRM); END;

  -- التقارير
  l_c := NOONA_INV_PKG.stock_balance(l_wh);
  ok('stock balance report', INSTR(l_c, 'زيت محرك 5W30 اختبار') > 0 AND INSTR(l_c, 'خدمة تركيب') = 0);
  l_c := NOONA_INV_PKG.item_card(l_gen, TRUNC(SYSDATE) - 1, TRUNC(SYSDATE));
  ok('item card shows movements and running balance', INSTR(l_c, 'تسوية بالزيادة') > 0 AND INSTR(l_c, 'تحويل وارد') > 0 AND INSTR(l_c, '>12<') > 0);
  l_c := NOONA_INV_PKG.reorder_report;
  ok('reorder report lists items under minimum', INSTR(l_c, 'زيت محرك 5W30 اختبار') > 0);
  l_c := NOONA_INV_PKG.inv_summary;
  ok('inventory summary KPIs', INSTR(l_c, 'قيمة المخزون') > 0);

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
