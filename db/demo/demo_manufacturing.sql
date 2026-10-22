-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية للتصنيع (بعد بيانات التجارة demo_trade_data.sql وبعد التحديث 17)
-- تشغل بحساب NOONA_APP ولا تكرر (تكتشف مركز العمل DEMO-BLOW):
--   sqlplus NOONA_APP@//host:1521/PDB @demo/demo_manufacturing.sql ADMIN
-- المحتوى: مركزا عمل بمعدلاتهما، أصناف تغليف ورجيع، إصدار جديد لقائمة مواد العبوة (ملصق + منتج ثانوي)،
-- مسار تصنيع بنقطة جودة، منتج كرتونة 24 عبوة (قائمة مكونها مصنع ومسار)، أمر مقفل بفحص جودة وانحرافات،
-- أمر كرتون مقفل، أمر قيد التنفيذ (رصيد تحت التشغيل)، أمر مخطط، وحد طلب للخامة يظهر في تخطيط الاحتياجات.
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE
COLUMN 1 NEW_VALUE 1 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
DEFINE ADMIN_USER = '&1'

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/

DECLARE
  c_admin  CONSTANT VARCHAR2(128) := NVL(UPPER(TRIM('&ADMIN_USER')), 'ADMIN');
  TYPE t_map IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
  it       t_map;
  l_co     NUMBER;
  l_n      NUMBER;
  l_y0     DATE;
  l_wh     NUMBER;
  l_cc     NUMBER;
  l_blow   NUMBER;
  l_pack   NUMBER;
  l_bom    NUMBER;
  l_o1     NUMBER;
  l_o2     NUMBER;
  l_o3     NUMBER;
  l_out    NUMBER;
  l_op     NUMBER;
  l_rules  SYS.ODCINUMBERLIST;
  PROCEDURE say(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
  FUNCTION dt(p_days NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(GREATEST(l_y0, TRUNC(SYSDATE) - p_days), 'YYYY-MM-DD');
  END dt;
  FUNCTION catid(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM inv_item_category WHERE code = p_code; RETURN l;
  END catid;
  FUNCTION code(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM inv_item WHERE item_code = p_code; RETURN l;
  END code;
  FUNCTION op(p_order NUMBER, p_seq NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM mfg_order_operation WHERE order_id = p_order AND operation_seq = p_seq; RETURN l;
  END op;
BEGIN
  NOONA_APEX_PKG.cleanup_request;
  NOONA_APEX_PKG.post_auth(c_admin, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  SELECT COUNT(*) INTO l_n FROM mfg_work_center WHERE company_id = l_co AND code = 'DEMO-BLOW';
  IF l_n > 0 THEN
    say('بيانات التصنيع التجريبية محملة سابقاً - لم يضف شيء.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;
  it('BTL') := code('DEMO-BTL-1L'); it('RES') := code('DEMO-RES-PET'); it('CAP') := code('DEMO-CAP-38');
  IF it('BTL') IS NULL OR it('RES') IS NULL OR it('CAP') IS NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'حمل بيانات التجارة التجريبية أولاً (demo_trade_data.sql): أصناف العبوة والخامات غير موجودة');
  END IF;
  SELECT id BULK COLLECT INTO l_rules FROM dms_archive_rule WHERE is_active = 'Y';
  UPDATE dms_archive_rule SET is_active = 'N' WHERE is_active = 'Y';
  SELECT MIN(p.start_date) INTO l_y0 FROM gl_period p JOIN gl_fiscal_year y ON y.id = p.fiscal_year_id
   WHERE y.company_id = l_co AND TRUNC(SYSDATE) BETWEEN y.start_date AND y.end_date;
  l_y0 := NVL(l_y0, TRUNC(SYSDATE, 'YYYY'));
  l_n := NOONA_MFG_PKG.quick_setup;
  l_wh := NOONA_INV_PKG.default_warehouse;
  SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY DECODE(code, 'CC-600', 0, 'CC-500', 1, 2), id) INTO l_cc FROM gl_cost_center WHERE company_id = l_co;

  -- ====================================================== مراكز العمل
  l_blow := NOONA_MFG_PKG.save_work_center('{"code":"DEMO-BLOW","name":"خط نفخ العبوات","cap":16,"labor":45,"machine":60,"overhead":25,"cc":'
                                           || NVL(TO_CHAR(l_cc), 'null') || '}');
  l_pack := NOONA_MFG_PKG.save_work_center('{"code":"DEMO-PACK","name":"التعبئة والفحص","cap":8,"labor":30,"machine":5,"overhead":15,"cc":'
                                           || NVL(TO_CHAR(l_cc), 'null') || '}');
  say('مراكز العمل: خط النفخ والتعبئة');

  -- ====================================================== الأصناف والأرصدة
  it('LBL') := NOONA_INV_PKG.save_item('{"name":"ملصق عبوة 1 لتر","code":"DEMO-LBL-1L","cat":' || catid('RAW') || ',"type":"RAW_MATERIAL","sell":"N"}');
  it('CTN') := NOONA_INV_PKG.save_item('{"name":"كرتونة تعبئة 24 عبوة","code":"DEMO-CTN-24","cat":' || catid('RAW') || ',"type":"RAW_MATERIAL","sell":"N"}');
  it('RGR') := NOONA_INV_PKG.save_item('{"name":"رجيع بلاستيك (منتج ثانوي)","code":"DEMO-RGR-PET","cat":' || catid('RAW') || ',"type":"RAW_MATERIAL"}');
  it('PK24') := NOONA_INV_PKG.save_item('{"name":"كرتونة عبوات 24 × 1 لتر","code":"DEMO-PK24-1L","cat":' || catid('FG') || ',"type":"FINISHED_GOOD",'
             || '"price":14,"incl":"Y","barcodes":["6281000099124"]}');
  -- حد الطلب للخامة الرئيسية ليظهر في تخطيط الاحتياجات
  l_n := NOONA_INV_PKG.save_stock_doc('{"type":"OPENING","date":"' || dt(20) || '","wh":' || l_wh || ',"action":"POST","lines":['
       || '{"i":' || it('LBL') || ',"q":20000,"c":0.03},{"i":' || it('CTN') || ',"q":400,"c":1.2},{"i":' || it('RGR') || ',"q":10,"c":2}]}');
  UPDATE inv_item_company SET min_qty = 5000, max_qty = 8000 WHERE company_id = l_co AND item_id = it('RES');
  say('أصناف التغليف والرجيع وأرصدتها');

  -- ====================================================== قوائم المواد والمسارات
  l_bom := NOONA_MFG_PKG.save_bom('{"item":' || it('BTL') || ',"name":"عبوة 1 لتر بملصق","base":1000,"action":"PUBLISH","lines":['
         || '{"i":' || it('RES') || ',"q":45,"s":3,"op":10},{"i":' || it('CAP') || ',"q":1000,"s":1,"op":20},{"i":' || it('LBL') || ',"q":1000,"s":2,"op":20},'
         || '{"i":' || it('RGR') || ',"q":1.2,"co":"Y"}]}');
  l_n := NOONA_MFG_PKG.save_routing('{"item":' || it('BTL') || ',"name":"نفخ وتغليف العبوة","action":"PUBLISH","ops":['
       || '{"seq":10,"wc":' || l_blow || ',"d":"نفخ العبوات","setup":45,"run":0.15},'
       || '{"seq":20,"wc":' || l_pack || ',"d":"تركيب الغطاء والملصق والفحص","setup":10,"run":0.05,"qc":"Y"}]}');
  l_n := NOONA_MFG_PKG.save_bom('{"item":' || it('PK24') || ',"name":"كرتونة 24 عبوة","base":1,"action":"PUBLISH","lines":['
       || '{"i":' || it('BTL') || ',"q":24,"op":10},{"i":' || it('CTN') || ',"q":1,"op":10}]}');
  l_n := NOONA_MFG_PKG.save_routing('{"item":' || it('PK24') || ',"name":"تعبئة الكراتين","action":"PUBLISH","ops":['
       || '{"seq":10,"wc":' || l_pack || ',"d":"تعبئة وتغليف الكرتون","setup":10,"run":1.5}]}');
  say('قوائم المواد ومسارات التصنيع (إصدار جديد للعبوة بملصق ومنتج ثانوي)');

  -- ====================================================== أمر 1: عبوات بفحص جودة ثم إقفال بالانحرافات
  l_o1 := NOONA_MFG_PKG.save_order('{"item":' || it('BTL') || ',"qty":2000,"date":"' || dt(6) || '","start":"' || dt(6) || '","end":"' || dt(4)
        || '","priority":"HIGH","lot":"BTL-0002","action":"RELEASE","notes":"تشغيلة طلبية مصنع العصائر"}');
  l_n := NOONA_MFG_PKG.issue_materials('{"order":' || l_o1 || ',"date":"' || dt(6) || '"}');
  l_n := NOONA_MFG_PKG.report_operation('{"op":' || op(l_o1, 10) || ',"date":"' || dt(5) || '","setup":50,"run":330,"good":2000,"scrap":15,"down":20,"done":"Y"}');
  l_n := NOONA_MFG_PKG.report_operation('{"op":' || op(l_o1, 20) || ',"date":"' || dt(5) || '","setup":10,"run":95,"good":2000,"done":"Y"}');
  l_out := NOONA_MFG_PKG.report_output('{"order":' || l_o1 || ',"qty":2000,"date":"' || dt(5) || '","key":"DEMO-O1"}');
  l_n := NOONA_MFG_PKG.inspect_output('{"output":' || l_out || ',"passed":1980,"failed":20,"date":"' || dt(4)
       || '","notes":"تشوه في عنق 20 عبوة","results":{"weight_g":28.4,"leak_test":"OK"}}');
  SELECT MIN(id) INTO l_op FROM mfg_order_material WHERE order_id = l_o1 AND item_id = it('LBL');
  l_n := NOONA_MFG_PKG.return_materials('{"order":' || l_o1 || ',"date":"' || dt(4) || '","lines":[{"m":' || l_op || ',"q":15}]}');
  l_n := NOONA_MFG_PKG.close_order(l_o1, TO_DATE(dt(4), 'YYYY-MM-DD'));
  say('أمر 1: 2000 عبوة، صرف وتشغيل وفحص جودة (1980 مقبول)، إرجاع ملصقات، إقفال بالانحرافات');

  -- ====================================================== أمر 2: كراتين من العبوات (مكون مصنع)
  l_o2 := NOONA_MFG_PKG.save_order('{"item":' || it('PK24') || ',"qty":50,"date":"' || dt(3) || '","action":"RELEASE"}');
  l_n := NOONA_MFG_PKG.issue_materials('{"order":' || l_o2 || ',"date":"' || dt(3) || '"}');
  l_n := NOONA_MFG_PKG.report_operation('{"op":' || op(l_o2, 10) || ',"date":"' || dt(3) || '","setup":10,"run":80,"good":50,"done":"Y"}');
  l_out := NOONA_MFG_PKG.report_output('{"order":' || l_o2 || ',"qty":50,"date":"' || dt(3) || '","key":"DEMO-O2"}');
  l_n := NOONA_MFG_PKG.close_order(l_o2, TO_DATE(dt(2), 'YYYY-MM-DD'));
  say('أمر 2: 50 كرتونة من العبوات المصنعة، مقفل');

  -- ====================================================== أمر 3: قيد التنفيذ، أمر 4: مخطط
  l_o3 := NOONA_MFG_PKG.save_order('{"item":' || it('BTL') || ',"qty":1500,"date":"' || dt(1) || '","start":"' || dt(1) || '","end":"'
        || TO_CHAR(TRUNC(SYSDATE) + 2, 'YYYY-MM-DD') || '","priority":"URGENT","lot":"BTL-0003","action":"RELEASE"}');
  l_n := NOONA_MFG_PKG.issue_materials('{"order":' || l_o3 || ',"date":"' || dt(1) || '"}');
  l_n := NOONA_MFG_PKG.report_operation('{"op":' || op(l_o3, 10) || ',"date":"' || dt(0) || '","setup":45,"run":120,"good":800}');
  l_n := NOONA_MFG_PKG.save_order('{"item":' || it('PK24') || ',"qty":30,"date":"' || dt(0) || '","start":"' || TO_CHAR(TRUNC(SYSDATE) + 3, 'YYYY-MM-DD')
       || '","action":"APPROVE"}');
  say('أمر 3: 1500 عبوة قيد التنفيذ (رصيد تحت التشغيل)، أمر 4: 30 كرتونة معتمد');

  FORALL i IN 1 .. l_rules.COUNT
    UPDATE dms_archive_rule SET is_active = 'Y' WHERE id = l_rules(i);
  COMMIT;
  say('');
  say('تم تحميل بيانات التصنيع التجريبية بنجاح. الإنتاج تحت التشغيل: ' || NOONA_MFG_PKG.wip_balance(l_o3));
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  RAISE;
END;
/
EXIT
