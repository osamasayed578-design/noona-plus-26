-- =============================================================================
-- NOONA PLUS ERP | اختبار التصنيع: مراكز العمل، قوائم المواد بإصداراتها (متعددة المستويات، وهمية، بدائل، منتج مشترك)،
--                  مسارات التصنيع، التكلفة المعيارية المجمعة، دورة أمر الإنتاج كاملة وقيودها، فحص الجودة، الإقفال
--                  والانحرافات، الإيقاف والإلغاء، منع التكرار، تخطيط الاحتياجات، التقارير - بحساب NOONA_APP
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_manufacturing.sql
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

-- التجهيز يحفظ (حسابات التصنيع والترقيم)
BEGIN
  NOONA_APEX_PKG.cleanup_request;
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  DBMS_OUTPUT.PUT_LINE('setup rows: ' || NOONA_MFG_PKG.quick_setup);
  COMMIT;
  NOONA_APEX_PKG.cleanup_request;
END;
/

DECLARE
  g_pass PLS_INTEGER := 0;
  g_fail PLS_INTEGER := 0;
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'HH24MISSFF3');
  l_d    VARCHAR2(10) := TO_CHAR(SYSDATE, 'YYYY-MM-DD');
  l_n    NUMBER;
  l_x    NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_wh   NUMBER;
  l_wc1  NUMBER; l_wc2 NUMBER;
  l_a    NUMBER; l_b NUMBER; l_b2 NUMBER; l_pk NUMBER; l_co NUMBER; l_sa NUMBER; l_ph NUMBER; l_fg NUMBER;
  l_bom  NUMBER; l_bom2 NUMBER; l_sab NUMBER; l_phb NUMBER; l_rt NUMBER;
  l_o    NUMBER; l_o2 NUMBER; l_o3 NUMBER;
  l_op10 NUMBER; l_op20 NUMBER;
  l_out  NUMBER; l_out2 NUMBER;
  l_t    NUMBER;
  l_j    NUMBER;

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
  FUNCTION mat(p_order NUMBER, p_item NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM mfg_order_material WHERE order_id = p_order AND item_id = p_item; RETURN l;
  END mat;
  FUNCTION req(p_order NUMBER, p_item NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT SUM(required_qty) INTO l FROM mfg_order_material WHERE order_id = p_order AND item_id = p_item; RETURN l;
  END req;
  FUNCTION st(p_order NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT status_code INTO l FROM mfg_production_order WHERE id = p_order; RETURN l;
  END st;
  -- سطور قيد المصدر: رمز:مدين/دائن مرتبة
  FUNCTION jlj(p_j NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT LISTAGG(a.account_code || ':' || l.debit_amount || '/' || l.credit_amount, ' ') WITHIN GROUP (ORDER BY a.account_code, l.debit_amount)
      INTO l FROM gl_journal_line l JOIN gl_account a ON a.id = l.account_id WHERE l.journal_id = p_j;
    RETURN l;
  END jlj;
  FUNCTION jl(p_type VARCHAR2, p_id NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT LISTAGG(a.account_code || ':' || l.debit_amount || '/' || l.credit_amount, ' ') WITHIN GROUP (ORDER BY a.account_code, l.debit_amount)
      INTO l
      FROM ace_accounting_event e JOIN gl_journal j ON j.accounting_event_id = e.id JOIN gl_journal_line l ON l.journal_id = j.id
      JOIN gl_account a ON a.id = l.account_id
     WHERE e.source_entity_type = p_type AND e.source_entity_id = p_id;
    RETURN l;
  END jl;
  -- رصيد حساب في قيود أمر الإنتاج (كل مصادره)
  FUNCTION order_gl(p_order NUMBER, p_acc VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(l.debit_amount - l.credit_amount), 0) INTO l
      FROM ace_accounting_event e JOIN gl_journal j ON j.accounting_event_id = e.id JOIN gl_journal_line l ON l.journal_id = j.id
      JOIN gl_account a ON a.id = l.account_id
     WHERE a.account_code = p_acc
       AND (e.source_entity_type, e.source_entity_id) IN (SELECT DISTINCT source_entity_type, source_entity_id FROM mfg_wip_cost WHERE order_id = p_order);
    RETURN l;
  END order_gl;
BEGIN
  NOONA_APEX_PKG.cleanup_request;
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  UPDATE dms_archive_rule SET is_active = 'N';
  l_wh := NOONA_INV_PKG.default_warehouse;

  -- ======================================================== التجهيز ومراكز العمل
  ok('manufacturing ready after quick setup', NOONA_MFG_PKG.is_ready = 'Y');
  SELECT COUNT(*) INTO l_n FROM gl_account WHERE coa_id = NOONA_GL_PKG.primary_coa AND account_code IN ('1110', '5103', '5104', '5105');
  ok('WIP, absorbed labor/overhead and variance accounts', l_n = 4, l_n);
  SELECT allow_manual_posting INTO l_s FROM gl_account WHERE coa_id = NOONA_GL_PKG.primary_coa AND account_code = '1110';
  ok('WIP is a control account (no manual journals)', l_s = 'N', l_s);
  l_wc1 := NOONA_MFG_PKG.save_work_center('{"code":"WCA' || l_sfx || '","name":"خط القص اختبار","cap":8,"labor":60,"machine":30,"overhead":30}');
  l_wc2 := NOONA_MFG_PKG.save_work_center('{"code":"WCB' || l_sfx || '","name":"خط التعبئة اختبار","cap":8,"labor":30,"machine":0,"overhead":30}');
  ok('work centers saved', l_wc1 IS NOT NULL AND INSTR(NOONA_MFG_PKG.work_center_json(l_wc1), '"labor":60') > 0);
  BEGIN
    l_n := NOONA_MFG_PKG.save_work_center('{"code":"WCA' || l_sfx || '","name":"مكرر"}');
    ok('duplicate work center code rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('duplicate work center code rejected', 'NOONA-MFG-005', SQLERRM); END;

  -- ======================================================== الأصناف والأرصدة
  l_a  := item('{"name":"ألواح ألمنيوم اختبار ' || l_sfx || '","type":"RAW_MATERIAL","cat":' || cat('RAW') || ',"sell":"N","min":200,"max":300}');
  l_b  := item('{"name":"براغي اختبار ' || l_sfx || '","type":"RAW_MATERIAL","cat":' || cat('RAW') || ',"sell":"N"}');
  l_b2 := item('{"name":"براغي بديلة اختبار ' || l_sfx || '","type":"RAW_MATERIAL","cat":' || cat('RAW') || ',"sell":"N"}');
  l_pk := item('{"name":"كرتون تغليف اختبار ' || l_sfx || '","type":"RAW_MATERIAL","cat":' || cat('RAW') || ',"sell":"N"}');
  l_co := item('{"name":"قصاصات ألمنيوم اختبار ' || l_sfx || '","type":"RAW_MATERIAL","cat":' || cat('RAW') || '}');
  l_sa := item('{"name":"هيكل نصف مصنع اختبار ' || l_sfx || '","type":"FINISHED_GOOD","cat":' || cat('FG') || '}');
  l_ph := item('{"name":"طقم تغليف وهمي اختبار ' || l_sfx || '","type":"FINISHED_GOOD","cat":' || cat('FG') || '}');
  l_fg := item('{"name":"خزانة معدنية اختبار ' || l_sfx || '","type":"FINISHED_GOOD","cat":' || cat('FG') || ',"tracking":"LOT","price":150}');
  l_n := NOONA_INV_PKG.save_stock_doc('{"type":"OPENING","date":"' || l_d || '","wh":' || l_wh || ',"action":"POST","lines":['
       || '{"i":' || l_a || ',"q":100,"c":10},{"i":' || l_b || ',"q":12,"c":5},{"i":' || l_b2 || ',"q":30,"c":6},{"i":' || l_pk || ',"q":50,"c":1},'
       || '{"i":' || l_co || ',"q":1,"c":2},{"i":' || l_sa || ',"q":20,"c":20}]}');
  ok('opening stock for components', NOONA_INV_PKG.on_hand(l_a, l_wh) = 100 AND NOONA_INV_PKG.avg_cost(l_sa) = 20);

  -- ======================================================== قوائم المواد
  l_sab := NOONA_MFG_PKG.save_bom('{"item":' || l_sa || ',"base":1,"action":"PUBLISH","lines":[{"i":' || l_a || ',"q":2}]}');
  l_phb := NOONA_MFG_PKG.save_bom('{"item":' || l_ph || ',"type":"PHANTOM","base":1,"action":"PUBLISH","lines":[{"i":' || l_pk || ',"q":1}]}');
  l_bom := NOONA_MFG_PKG.save_bom('{"item":' || l_fg || ',"base":1,"lines":['
         || '{"i":' || l_sa || ',"q":1,"op":10},{"i":' || l_a || ',"q":1,"s":5,"op":10},'
         || '{"i":' || l_b || ',"q":2,"op":10,"subs":[{"i":' || l_b2 || ',"f":1}]},{"i":' || l_ph || ',"q":1,"op":20},'
         || '{"i":' || l_co || ',"q":0.1,"co":"Y"}]}');
  SELECT status_code || '|' || version_no || '|' || is_default INTO l_s FROM mfg_bom WHERE id = l_bom;
  ok('BOM saved as draft version 1', l_s = 'DRAFT|1|N', l_s);
  BEGIN
    l_n := NOONA_MFG_PKG.save_bom('{"item":' || l_fg || ',"lines":[{"i":' || l_fg || ',"q":1}]}');
    ok('item cannot be its own component', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('item cannot be its own component', 'NOONA-MFG-015', SQLERRM); END;
  NOONA_MFG_PKG.publish_bom(l_bom);
  ok('published BOM is the default', NOONA_MFG_PKG.default_bom(l_fg) = l_bom);
  BEGIN
    -- الهيكل يحتوي المنتج التام الذي يحتوي الهيكل: دورة
    l_n := NOONA_MFG_PKG.save_bom('{"id":' || l_sab || ',"lines":[{"i":' || l_a || ',"q":2},{"i":' || l_fg || ',"q":1}]}');
    ok('circular multi-level BOM rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('circular multi-level BOM rejected', 'NOONA-MFG-017', SQLERRM); END;
  l_c := NOONA_MFG_PKG.bom_doc_json(NULL, l_fg);
  ok('BOM document with substitutes and co-product', INSTR(l_c, '"co":"Y"') > 0 AND INSTR(l_c, '"subs":[{"i":' || l_b2) > 0
     AND INSTR(l_c, '"mk":"Y"') > 0, SUBSTR(l_c, 1, 200));

  -- ======================================================== المسار والتكلفة المعيارية
  l_rt := NOONA_MFG_PKG.save_routing('{"item":' || l_fg || ',"action":"PUBLISH","ops":['
        || '{"seq":10,"wc":' || l_wc1 || ',"d":"قص وتجميع","setup":30,"run":6},'
        || '{"seq":20,"wc":' || l_wc2 || ',"d":"تعبئة وفحص","setup":0,"run":3,"qc":"Y"}]}');
  ok('routing published', NOONA_MFG_PKG.default_routing(l_fg) = l_rt);
  BEGIN
    l_n := NOONA_MFG_PKG.save_routing('{"item":' || l_fg || ',"ops":[{"seq":10,"wc":' || l_wc1 || ',"d":"أ"},{"seq":10,"wc":' || l_wc2 || ',"d":"ب"}]}');
    ok('duplicate operation sequence rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('duplicate operation sequence rejected', 'NOONA-MFG-033', SQLERRM); END;
  -- الخامات: هيكل 20 + ألمنيوم 10.5 + براغي 10 + تغليف وهمي 1 - قصاصات 0.2 = 41.3
  -- العمليات لكمية 10: عملية 10 = (30/10+6) دقيقة × 2 ريال = 18 (عمالة 9، آلات 4.5، تحميل 4.5)، عملية 20 = 3 دقائق × 1 = 3 (عمالة 1.5، تحميل 1.5)
  l_c := NOONA_MFG_PKG.std_cost_json(l_fg, 10);
  ok('rolled-up standard cost by element', INSTR(l_c, '"mat":41.3,') > 0 AND INSTR(l_c, '"lab":10.5,') > 0 AND INSTR(l_c, '"mac":4.5,') > 0
     AND INSTR(l_c, '"ovh":6,') > 0 AND INSTR(l_c, '"total":62.3}') > 0, l_c);

  -- ======================================================== أمر الإنتاج: التخطيط والاعتماد والإطلاق
  l_o := NOONA_MFG_PKG.save_order('{"item":' || l_fg || ',"qty":10,"date":"' || l_d || '","priority":"HIGH","lot":"L' || l_sfx || '"}');
  ok('order planned with document number', st(l_o) = 'PLANNED' AND NOONA_MFG_PKG.order_json(l_o) LIKE '%"no":"MO-%');
  ok('requirements exploded (phantom replaced by its components, scrap applied)',
     req(l_o, l_sa) = 10 AND req(l_o, l_a) = 10.5 AND req(l_o, l_b) = 20 AND req(l_o, l_pk) = 10 AND mat(l_o, l_ph) IS NULL
     AND mat(l_o, l_co) IS NULL);
  SELECT COUNT(*), MAX(requires_qc), MAX(std_unit_cost), MAX(estimated_cost) INTO l_n, l_s, l_x, l_j
    FROM mfg_order_operation p JOIN mfg_production_order o ON o.id = p.order_id WHERE o.id = l_o;
  ok('operations from routing, QC required, standard cost frozen', l_n = 2 AND l_s = 'Y' AND l_x = 62.3 AND l_j = 623, l_n || ' ' || l_s || ' ' || l_x || ' ' || l_j);
  BEGIN
    l_n := NOONA_MFG_PKG.issue_materials('{"order":' || l_o || '}');
    ok('cannot issue before release', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('cannot issue before release', 'NOONA-MFG-041', SQLERRM); END;
  l_n := NOONA_MFG_PKG.save_order('{"id":' || l_o || ',"qty":10,"date":"' || l_d || '","priority":"URGENT","lot":"L' || l_sfx || '","action":"RELEASE"}');
  ok('order approved and released', st(l_o) = 'RELEASED');
  ok('BOM in use after release', NOONA_MFG_PKG.bom_in_use(l_bom) = 'Y');
  BEGIN
    l_n := NOONA_MFG_PKG.save_bom('{"id":' || l_bom || ',"lines":[{"i":' || l_a || ',"q":3}]}');
    ok('BOM in use cannot be edited', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('BOM in use cannot be edited', 'NOONA-MFG-011', SQLERRM); END;
  l_bom2 := NOONA_MFG_PKG.new_bom_version(l_bom);
  SELECT version_no || '|' || status_code || '|' || (SELECT COUNT(*) FROM mfg_bom_line WHERE bom_id = l_bom2) INTO l_s FROM mfg_bom WHERE id = l_bom2;
  ok('new BOM version copies lines as draft', l_s = '2|DRAFT|5', l_s);
  BEGIN
    l_n := NOONA_MFG_PKG.save_order('{"id":' || l_o || ',"qty":5}');
    ok('released order cannot be edited', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('released order cannot be edited', 'NOONA-MFG-042', SQLERRM); END;
  BEGIN
    l_n := NOONA_MFG_PKG.report_output('{"order":' || l_o || ',"qty":1}');
    ok('output requires reported operations', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('output requires reported operations', 'NOONA-MFG-081', SQLERRM); END;

  -- ======================================================== صرف الخامات والبديل والإرجاع
  l_t := NOONA_MFG_PKG.issue_materials('{"order":' || l_o || ',"date":"' || l_d || '","lines":[{"m":' || mat(l_o, l_sa) || ',"q":10},{"m":'
       || mat(l_o, l_a) || ',"q":10.5},{"m":' || mat(l_o, l_pk) || ',"q":10},{"m":' || mat(l_o, l_b) || ',"q":12}]}');
  ok('materials issued from stock', NOONA_INV_PKG.on_hand(l_a, l_wh) = 89.5 AND NOONA_INV_PKG.on_hand(l_b, l_wh) = 0 AND st(l_o) = 'IN_PROGRESS');
  ok('issue journal: WIP debit, inventory credit', jl('INV_TRANSACTION', l_t) = '1105:0/375 1110:375/0', jl('INV_TRANSACTION', l_t));
  BEGIN
    l_n := NOONA_MFG_PKG.issue_materials('{"order":' || l_o || '}');
    ok('issue blocked by insufficient stock', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('issue blocked by insufficient stock', 'NOONA-INV-025', SQLERRM); END;
  BEGIN
    NOONA_MFG_PKG.substitute_material(mat(l_o, l_b), l_pk);
    ok('only approved substitutes', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('only approved substitutes', 'NOONA-MFG-066', SQLERRM); END;
  NOONA_MFG_PKG.substitute_material(mat(l_o, l_b), l_b2);
  ok('remaining requirement moved to the substitute', req(l_o, l_b) = 12 AND req(l_o, l_b2) = 8);
  l_t := NOONA_MFG_PKG.issue_materials('{"order":' || l_o || ',"date":"' || l_d || '"}');
  ok('issue all remaining (substitute at its own cost)', NOONA_INV_PKG.on_hand(l_b2, l_wh) = 22 AND jl('INV_TRANSACTION', l_t) = '1105:0/48 1110:48/0',
     jl('INV_TRANSACTION', l_t));
  BEGIN
    l_n := NOONA_MFG_PKG.return_materials('{"order":' || l_o || ',"lines":[{"m":' || mat(l_o, l_a) || ',"q":11}]}');
    ok('return limited to the net issued quantity', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('return limited to the net issued quantity', 'NOONA-MFG-062', SQLERRM); END;
  l_t := NOONA_MFG_PKG.return_materials('{"order":' || l_o || ',"date":"' || l_d || '","lines":[{"m":' || mat(l_o, l_a) || ',"q":0.5}]}');
  ok('excess material returned at issue cost', NOONA_INV_PKG.on_hand(l_a, l_wh) = 90 AND jl('INV_TRANSACTION', l_t) = '1105:5/0 1110:0/5',
     jl('INV_TRANSACTION', l_t));
  ok('WIP material charge = issues - returns', NOONA_MFG_PKG.wip_balance(l_o, 'MATERIAL') = 418, NOONA_MFG_PKG.wip_balance(l_o, 'MATERIAL'));

  -- ======================================================== تقارير العمليات
  SELECT id INTO l_op10 FROM mfg_order_operation WHERE order_id = l_o AND operation_seq = 10;
  SELECT id INTO l_op20 FROM mfg_order_operation WHERE order_id = l_o AND operation_seq = 20;
  BEGIN
    l_n := NOONA_MFG_PKG.report_operation('{"op":' || l_op20 || ',"run":10,"good":5}');
    ok('operation cannot exceed the previous operation', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('operation cannot exceed the previous operation', 'NOONA-MFG-074', SQLERRM); END;
  l_x := NOONA_MFG_PKG.report_operation('{"op":' || l_op10 || ',"date":"' || l_d || '","setup":30,"run":66,"good":10,"down":15,"done":"Y"}');
  ok('operation absorbs labor, machine and overhead at work center rates', jl('MFG_WIP_COST', l_x) = '1110:192/0 5103:0/96 5104:0/96',
     jl('MFG_WIP_COST', l_x));
  l_x := NOONA_MFG_PKG.report_operation('{"op":' || l_op20 || ',"date":"' || l_d || '","run":30,"good":10,"done":"Y"}');
  ok('second operation absorbed', jl('MFG_WIP_COST', l_x) = '1110:30/0 5103:0/15 5104:0/15', jl('MFG_WIP_COST', l_x));
  SELECT status_code || '|' || actual_minutes || '|' || downtime_minutes INTO l_s FROM mfg_order_operation WHERE id = l_op10;
  ok('operation completed with actual and downtime minutes', l_s = 'COMPLETED|96|15', l_s);

  -- ======================================================== الإنتاج وفحص الجودة
  l_out := NOONA_MFG_PKG.report_output('{"order":' || l_o || ',"qty":10,"date":"' || l_d || '","key":"K1"}');
  SELECT status_code INTO l_s FROM mfg_order_output WHERE id = l_out;
  ok('output waits for quality (not in stock yet)', NOONA_INV_PKG.on_hand(l_fg, l_wh) = 0 AND l_s = 'PENDING_QUALITY', l_s);
  ok('resubmitting the same output key does not duplicate', NOONA_MFG_PKG.report_output('{"order":' || l_o || ',"qty":10,"key":"K1"}') = l_out);
  BEGIN
    NOONA_MFG_PKG.complete_order(l_o);
    ok('cannot complete with pending inspection', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('cannot complete with pending inspection', 'NOONA-MFG-085', SQLERRM); END;
  BEGIN
    l_n := NOONA_MFG_PKG.inspect_output('{"output":' || l_out || ',"passed":9,"failed":2}');
    ok('inspection quantities must match', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('inspection quantities must match', 'NOONA-MFG-084', SQLERRM); END;
  l_x := NOONA_MFG_PKG.inspect_output('{"output":' || l_out || ',"passed":9,"failed":1,"date":"' || l_d || '","notes":"خدش في الباب",'
       || '"results":{"thickness":1.2}}');
  SELECT COUNT(*) INTO l_n FROM inv_lot WHERE item_id = l_fg AND lot_no = 'L' || l_sfx;
  ok('accepted output enters stock at standard cost with lot', NOONA_INV_PKG.on_hand(l_fg, l_wh) = 9 AND NOONA_INV_PKG.avg_cost(l_fg) = 62.3
     AND l_n = 1, NOONA_INV_PKG.avg_cost(l_fg) || ' lots=' || l_n);
  ok('co-product received in proportion', NOONA_INV_PKG.on_hand(l_co, l_wh) = 1.9);
  ok('inspection journal: stock, scrap expense, WIP relief', jl('MFG_QUALITY_INSPECTION', l_x) = '1105:562.5/0 1110:0/624.8 5213:62.3/0',
     jl('MFG_QUALITY_INSPECTION', l_x));
  SELECT o.completed_qty || '|' || o.scrapped_qty || '|' || o.status_code || '|' || q.status_code INTO l_s
    FROM mfg_production_order o JOIN mfg_quality_inspection q ON q.order_id = o.id WHERE o.id = l_o;
  ok('order partially completed, inspection conditional', l_s = '9|1|PARTIALLY_COMPLETED|CONDITIONAL', l_s);
  ok('WIP balance before close', NOONA_MFG_PKG.wip_balance(l_o) = 15.2, NOONA_MFG_PKG.wip_balance(l_o));

  SELECT MAX(standard_cost) INTO l_x FROM inv_item_company WHERE item_id = l_fg AND company_id = NOONA_MFG_PKG.company;
  ok('release updates the standard cost on the item card', l_x = 62.3, l_x);

  -- ======================================================== الإقفال بالتكلفة الفعلية (الانحراف على المخزون) ثم التراجع
  SAVEPOINT pre_close;
  NOONA_MFG_PKG.save_settings('INVENTORY', 'Y');
  ok('variance treatment setting saved', NOONA_MFG_PKG.variance_treatment = 'INVENTORY');
  l_j := NOONA_MFG_PKG.close_order(l_o, TRUNC(SYSDATE));
  ok('inventory mode: variance of stock still on hand goes to inventory', jlj(l_j) = '1105:15.2/0 1110:0/15.2', jlj(l_j));
  ok('inventory mode: average cost absorbs the variance (62.3 + 15.2 / 9)', ROUND(NOONA_INV_PKG.avg_cost(l_fg), 4) = ROUND(62.3 + 15.2 / 9, 4),
     NOONA_INV_PKG.avg_cost(l_fg));
  ROLLBACK TO pre_close;
  BEGIN
    NOONA_MFG_PKG.save_settings('ACTUAL', 'Y');
    ok('invalid variance treatment rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('invalid variance treatment rejected', 'NOONA-MFG-090', SQLERRM); END;

  -- ======================================================== الإقفال والانحرافات
  l_j := NOONA_MFG_PKG.close_order(l_o, TRUNC(SYSDATE));
  ok('close posts the variance and clears WIP', st(l_o) = 'CLOSED' AND NOONA_MFG_PKG.wip_balance(l_o) = 0
     AND jl('MFG_PRODUCTION_ORDER', l_o) = '1110:0/15.2 5105:15.2/0', jl('MFG_PRODUCTION_ORDER', l_o));
  ok('WIP account nets to zero across the order journals', order_gl(l_o, '1110') = 0, order_gl(l_o, '1110'));
  SELECT LISTAGG(variance_type || ':' || variance_amount, ' ') WITHIN GROUP (ORDER BY variance_type) INTO l_s FROM mfg_variance WHERE order_id = l_o;
  ok('variance analysis (substitute price, usage, labor efficiency, overhead)',
     l_s = 'LABOR_EFFICIENCY:6 MATERIAL_PRICE:8 MATERIAL_USAGE:-4.8 OVERHEAD:3 OVERHEAD:3', l_s);
  SELECT actual_cost INTO l_x FROM mfg_production_order WHERE id = l_o;
  ok('actual cost recorded', l_x = 640, l_x);
  BEGIN
    l_n := NOONA_MFG_PKG.close_order(l_o);
    ok('closed order cannot be closed again', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('closed order cannot be closed again', 'NOONA-MFG-086', SQLERRM); END;
  l_c := NOONA_MFG_PKG.order_json(l_o);
  ok('order document shows journals and WIP', INSTR(l_c, '"journals":[{') > 0 AND INSTR(l_c, '"wip":[{') > 0 AND INSTR(l_c, '"status":"CLOSED"') > 0);

  -- ======================================================== أمر بلا مسار ومنع التكرار
  l_o2 := NOONA_MFG_PKG.save_order('{"item":' || l_sa || ',"qty":2,"action":"RELEASE"}');
  l_t := NOONA_MFG_PKG.issue_materials('{"order":' || l_o2 || '}');
  l_out2 := NOONA_MFG_PKG.report_output('{"order":' || l_o2 || ',"qty":2,"key":"SA1"}');
  l_n := NOONA_MFG_PKG.report_output('{"order":' || l_o2 || ',"qty":2,"key":"SA1"}');
  ok('order without routing posts output directly, once per key', l_n = l_out2 AND NOONA_INV_PKG.on_hand(l_sa, l_wh) = 12
     AND st(l_o2) = 'COMPLETED' AND jl('MFG_ORDER_OUTPUT', l_out2) = '1105:40/0 1110:0/40', jl('MFG_ORDER_OUTPUT', l_out2));
  l_j := NOONA_MFG_PKG.close_order(l_o2);
  ok('order without variance closes without a journal', st(l_o2) = 'CLOSED' AND l_j IS NULL);

  -- ======================================================== الإيقاف والإلغاء
  l_o3 := NOONA_MFG_PKG.save_order('{"item":' || l_fg || ',"qty":3,"action":"RELEASE"}');
  BEGIN
    NOONA_MFG_PKG.hold_order(l_o3, NULL);
    ok('hold needs a reason', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('hold needs a reason', 'NOONA-MFG-053', SQLERRM); END;
  NOONA_MFG_PKG.hold_order(l_o3, 'انتظار خامات');
  ok('order on hold', st(l_o3) = 'ON_HOLD');
  NOONA_MFG_PKG.resume_order(l_o3);
  ok('resumed to released', st(l_o3) = 'RELEASED');
  l_t := NOONA_MFG_PKG.issue_materials('{"order":' || l_o3 || ',"lines":[{"m":' || mat(l_o3, l_a) || ',"q":1}]}');
  BEGIN
    NOONA_MFG_PKG.cancel_order(l_o3, 'إلغاء');
    ok('order with costs cannot be cancelled', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('order with costs cannot be cancelled', 'NOONA-MFG-055', SQLERRM); END;
  l_n := NOONA_MFG_PKG.save_order('{"item":' || l_fg || ',"qty":1}');
  NOONA_MFG_PKG.cancel_order(l_n, 'لم يعد مطلوباً');
  ok('planned order cancelled', st(l_n) = 'CANCELLED');

  -- ======================================================== تخطيط الاحتياجات
  l_c := NOONA_MFG_PKG.mrp_json('Y');
  ok('MRP suggests buying raw material below its minimum', INSTR(l_c, '{"i":' || l_a || ',') > 0 AND INSTR(l_c, '"t":"BUY"') > 0, SUBSTR(l_c, 1, 300));
  l_c := NOONA_MFG_PKG.mrp_execute('{"date":"' || l_d || '","lines":[{"i":' || l_fg || ',"q":2,"t":"MAKE"},{"i":' || l_a || ',"q":50,"t":"BUY"}]}');
  ok('MRP creates planned orders and a draft purchase requisition', INSTR(l_c, '"orders":1') > 0 AND INSTR(l_c, '"reqNo":"PR-') > 0, l_c);

  -- ======================================================== التقارير
  ok('cost sheet', INSTR(NOONA_MFG_PKG.order_cost_sheet(l_o), 'تحليل الانحرافات') > 0);
  ok('job card', INSTR(NOONA_MFG_PKG.order_print(l_o), 'مراحل التشغيل') > 0);
  ok('orders register', INSTR(NOONA_MFG_PKG.orders_register(TRUNC(SYSDATE) - 1, TRUNC(SYSDATE)), 'سجل أوامر الإنتاج') > 0);
  l_c := NOONA_MFG_PKG.wip_report;
  ok('WIP report reconciles with the ledger', INSTR(l_c, 'مطابق للأوامر') > 0, SUBSTR(l_c, -400));
  ok('variance report', INSTR(NOONA_MFG_PKG.variance_report(TRUNC(SYSDATE) - 1, TRUNC(SYSDATE)), 'انحرافات تكاليف الإنتاج') > 0);
  ok('material usage', INSTR(NOONA_MFG_PKG.material_usage(TRUNC(SYSDATE) - 1, TRUNC(SYSDATE)), 'ألواح ألمنيوم اختبار') > 0);
  ok('production summary', INSTR(NOONA_MFG_PKG.production_summary(TRUNC(SYSDATE) - 1, TRUNC(SYSDATE)), 'خزانة معدنية اختبار') > 0);
  ok('work center utilization', INSTR(NOONA_MFG_PKG.wc_utilization(TRUNC(SYSDATE) - 1, TRUNC(SYSDATE)), 'خط القص اختبار') > 0);
  ok('capacity load', INSTR(NOONA_MFG_PKG.capacity_load(TRUNC(SYSDATE), 7), 'أحمال مراكز العمل') > 0);
  ok('BOM tree', INSTR(NOONA_MFG_PKG.bom_tree(l_fg, 10), 'هيكل نصف مصنع اختبار') > 0);
  ok('where used', INSTR(NOONA_MFG_PKG.where_used(l_a), 'خزانة معدنية اختبار') > 0);
  ok('MRP report', INSTR(NOONA_MFG_PKG.mrp_report, 'تخطيط احتياجات المواد') > 0);
  ok('quality report', INSTR(NOONA_MFG_PKG.quality_report(TRUNC(SYSDATE) - 1, TRUNC(SYSDATE)), 'خدش في الباب') > 0);
  ok('dashboard KPIs', INSTR(NOONA_MFG_PKG.mfg_summary, 'الإنتاج تحت التشغيل') > 0);
  ok('lists for screens', INSTR(NOONA_MFG_PKG.lists_json('wcs,products,whs,ccs'), '"products":[') > 0);
  l_c := NOONA_FIN_RPT_PKG.controls(TRUNC(SYSDATE));
  ok('finance controls include WIP reconciliation', INSTR(l_c, 'الإنتاج تحت التشغيل') > 0);

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
