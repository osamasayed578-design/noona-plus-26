-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية متكاملة للمالية والمخزون والمشتريات والمبيعات ونقاط البيع
-- تشغل مرة واحدة بحساب NOONA_APP بعد التحديث 16 (تكتشف إن كانت محملة سابقاً فلا تكرر):
--   sqlplus NOONA_APP@//host:1521/PDB @demo/demo_trade_data.sql ADMIN
-- المعامل الأول: اسم مستخدم مسؤول المؤسسة (الافتراضي ADMIN). ينشئ مستخدماً معتمداً DEMO_APPROVER
-- لاعتماد السندات والقيود (فصل المهام)، بلا كلمة مرور؛ يمكن إيقافه من إدارة المستخدمين.
-- المحتوى: تمويل الصندوق والبنك، قيود يدوية بأنواعها، مستودعان، 16 صنفاً (قطع غيار، أدوية بدفعات، بضائع،
-- خامات ومنتج مصنع بقائمة مواد، خدمة)، أرصدة افتتاحية، 4 موردين، أوامر وفواتير شراء آجلة ونقدية ومرتجع وسداد،
-- 4 عملاء + العميل العام، فواتير بيع آجلة ونقدية ومرتجع وتحصيل، تسويات وإتلاف وصرف لمركز تكلفة وتحويل وإنتاج،
-- ووردية نقطة بيع بمبيعات بطرق سداد مختلفة ومرتجع وإقفال.
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
  c_admin   CONSTANT VARCHAR2(100) := NVL(TRIM('&ADMIN_USER'), 'ADMIN');
  l_co      NUMBER;
  l_n       NUMBER;
  l_x       NUMBER;
  l_mem     NUMBER;
  l_role    NUMBER;
  l_box     NUMBER;
  l_bank    NUMBER;
  l_wh      NUMBER;
  l_wh2     NUMBER;
  l_cc_adm  NUMBER;
  l_cc_sal  NUMBER;
  l_y0      DATE;
  l_c       CLOB;
  l_r       CLOB;
  l_sh      NUMBER;
  l_term    NUMBER;
  l_sale    NUMBER;
  l_inv     NUMBER;
  l_po      NUMBER;
  l_line    NUMBER;
  l_sid     NUMBER;
  l_kg      NUMBER;
  l_ccs     VARCHAR2(30);
  l_cca     VARCHAR2(30);
  TYPE t_list IS TABLE OF NUMBER;
  l_rules   t_list;
  TYPE t_ids IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
  it  t_ids;          -- الأصناف بالرمز
  sup t_ids;          -- الموردون
  cus t_ids;          -- العملاء
  cat t_ids;          -- الفئات

  PROCEDURE say(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
  PROCEDURE login(p_user VARCHAR2) IS
  BEGIN
    NOONA_APEX_PKG.cleanup_request;
    NOONA_APEX_PKG.post_auth(p_user, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  END login;
  -- تاريخ قبل n يوماً، لا يسبق بداية السنة المالية الحالية
  FUNCTION dt(p_days NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(GREATEST(l_y0, TRUNC(SYSDATE) - p_days), 'YYYY-MM-DD');
  END dt;
  FUNCTION catid(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM inv_item_category WHERE code = p_code; RETURN l;
  END catid;
  PROCEDURE item(p_key VARCHAR2, p_json VARCHAR2) IS
  BEGIN
    it(p_key) := NOONA_INV_PKG.save_item(p_json);
  END item;
  FUNCTION voucher(p_type VARCHAR2, p_box NUMBER, p_bank NUMBER, p_party VARCHAR2, p_desc VARCHAR2, p_acc VARCHAR2, p_amt NUMBER,
                   p_days NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    l := NOONA_CSH_PKG.save_voucher(NULL, p_type, TO_DATE(dt(p_days), 'YYYY-MM-DD'), p_box, p_bank, NULL, p_party, p_desc, 'DEMO',
                                    '[{"a":"' || p_acc || '","m":' || p_amt || '}]');
    NOONA_CSH_PKG.submit_voucher(l);
    RETURN l;
  END voucher;
  FUNCTION journal(p_type VARCHAR2, p_days NUMBER, p_desc VARCHAR2, p_ref VARCHAR2, p_lines VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN NOONA_GL_PKG.save_journal_doc('{"id":null,"type":"' || p_type || '","date":"' || dt(p_days) || '","desc":"' || p_desc
      || '","ref":' || CASE WHEN p_ref IS NULL THEN 'null' ELSE '"' || p_ref || '"' END || ',"action":"SUBMIT","lines":[' || p_lines || ']}');
  END journal;
  FUNCTION pos_sale(p_key VARCHAR2, p_cust NUMBER, p_lines VARCHAR2, p_pays VARCHAR2, p_rx VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
  BEGIN
    l_r := NOONA_POS_PKG.sale('{"key":"' || p_key || '","shift":' || l_sh || ',"cust":' || NVL(TO_CHAR(p_cust), 'null')
           || ',"rx":' || CASE WHEN p_rx IS NULL THEN 'null' ELSE '"' || p_rx || '"' END || ',"lines":[' || p_lines || '],"pays":[' || p_pays || ']}');
    RETURN TO_NUMBER(JSON_VALUE(l_r, '$.id'));
  END pos_sale;
  FUNCTION total_of(p_sale NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT total_amount INTO l FROM pos_sale WHERE id = p_sale; RETURN l;
  END total_of;
BEGIN
  login(c_admin);
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  SELECT COUNT(*) INTO l_n FROM inv_item WHERE item_code = 'DEMO-OIL-01';
  IF l_n > 0 THEN
    say('البيانات التجريبية محملة سابقاً لهذه المؤسسة - لم يضف شيء.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;

  -- ====================================================== التجهيز
  IF NOONA_GL_PKG.primary_ledger IS NULL THEN l_n := NOONA_GL_PKG.quick_setup; END IF;
  l_box := NOONA_CSH_PKG.quick_setup;
  l_n := NOONA_CSH_PKG.seed_defaults;
  l_n := NOONA_PUR_PKG.quick_setup;
  l_n := NOONA_POS_PKG.quick_setup;
  -- قواعد الأرشفة الإلزامية تعلق أثناء التحميل فقط ثم تعاد كما كانت (المستندات التجريبية بلا مرفقات)
  SELECT id BULK COLLECT INTO l_rules FROM dms_archive_rule WHERE is_active = 'Y';
  UPDATE dms_archive_rule SET is_active = 'N' WHERE is_active = 'Y';
  SELECT MIN(id) INTO l_kg FROM inv_uom WHERE code = 'KG';
  SELECT MIN(p.start_date) INTO l_y0 FROM gl_period p JOIN gl_fiscal_year y ON y.id = p.fiscal_year_id
   WHERE y.company_id = l_co AND TRUNC(SYSDATE) BETWEEN y.start_date AND y.end_date;
  l_y0 := NVL(l_y0, TRUNC(SYSDATE, 'YYYY'));
  SELECT MIN(id) INTO l_box FROM csh_cash_box WHERE company_id = l_co AND status_code = 'ACTIVE' AND box_type = 'MAIN';
  SELECT MIN(id) INTO l_bank FROM csh_bank_account WHERE company_id = l_co AND status_code = 'ACTIVE';
  SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY DECODE(code, 'CC-100', 0, 1), id) INTO l_cc_adm FROM gl_cost_center WHERE company_id = l_co;
  SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY DECODE(code, 'CC-600', 0, 'CC-500', 1, 2), id) INTO l_cc_sal FROM gl_cost_center WHERE company_id = l_co;
  l_ccs := NVL(TO_CHAR(l_cc_sal), 'null');
  l_cca := NVL(TO_CHAR(l_cc_adm), 'null');
  l_wh := NOONA_INV_PKG.default_warehouse;
  SELECT MIN(id) INTO l_wh2 FROM inv_warehouse WHERE company_id = l_co AND code = 'WH-02';
  IF l_wh2 IS NULL THEN l_wh2 := NOONA_INV_PKG.create_warehouse('WH-02', 'معرض الفرع', 'STORE', l_cc_sal); END IF;
  say('التجهيز: صندوق ' || l_box || ' بنك ' || l_bank || ' مستودعان ' || l_wh || '/' || l_wh2);

  -- مستخدم معتمد للسندات والقيود (فصل المهام)
  SELECT MIN(m.id) INTO l_mem FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id WHERE u.username = 'DEMO_APPROVER';
  IF l_mem IS NULL THEN
    l_mem := NOONA_SEC_ADMIN_PKG.create_user('DEMO_APPROVER', 'المعتمد المالي (تجريبي)', 'demo.approver@noona.local', l_co);
    l_role := NOONA_SEC_ADMIN_PKG.create_role('DEMO_APPROVER', 'معتمد مالي (تجريبي)');
    l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'GL', 'VIEW,APPROVE,POST,REVERSE');
    l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'CSH', 'VIEW,APPROVE,POST');
    l_n := NOONA_SEC_ADMIN_PKG.grant_role(l_mem, l_role, NULL, 'بيانات تجريبية');
  END IF;

  -- ====================================================== التمويل والقيود اليدوية
  DECLARE
    v1 NUMBER; v2 NUMBER; v3 NUMBER; j1 NUMBER; j2 NUMBER; j3 NUMBER;
  BEGIN
    v1 := voucher('RECEIPT', l_box, NULL, 'الشركاء', 'إيداع رأس المال نقداً في الصندوق الرئيسي', '3101', 60000, 60);
    v2 := voucher('RECEIPT', NULL, l_bank, 'الشركاء', 'إيداع رأس المال في الحساب البنكي', '3101', 250000, 60);
    v3 := voucher('EXPENSE', l_box, NULL, 'مؤسسة الصيانة', 'صيانة مكيفات المعرض', '5205', 1200, 20);
    j1 := journal('ACCRUAL', 15, 'استحقاق فاتورة الكهرباء لم ترد بعد', NULL, '{"a":"5203","d":1850},{"a":"2103","c":1850}');
    j2 := journal('ADJUSTMENT', 10, 'تسوية: تحميل القرطاسية على الدعاية والإعلان', NULL, '{"a":"5208","d":400},{"a":"5207","c":400}');
    j3 := journal('RECLASS', 5, 'إعادة تبويب مصروف صيانة إلى رسوم حكومية', 'JV-DEMO-01', '{"a":"5209","d":300},{"a":"5205","c":300}');
    login('DEMO_APPROVER');
    NOONA_CSH_PKG.approve_voucher(v1); NOONA_CSH_PKG.approve_voucher(v2); NOONA_CSH_PKG.approve_voucher(v3);
    NOONA_GL_PKG.approve_journal(j1); NOONA_GL_PKG.approve_journal(j2); NOONA_GL_PKG.approve_journal(j3);
    login(c_admin);
  END;
  say('التمويل: صندوق ' || NOONA_CSH_PKG.balance(l_box, NULL) || ' / بنك ' || NOONA_CSH_PKG.balance(NULL, l_bank));

  -- ====================================================== الأصناف
  item('OIL', '{"name":"زيت محرك 5W-30 تخليقي 4 لتر","code":"DEMO-OIL-01","cat":' || catid('AUTO') || ',"type":"SPARE_PART","brand":"Mobil 1",'
       || '"mpn":"M1-5W30-4L","price":185,"incl":"Y","minPrice":160,"min":20,"max":120,"reorder":40,"barcodes":["6281001000011"]}');
  item('FLT', '{"name":"فلتر زيت تويوتا كامري","code":"DEMO-FLT-01","cat":' || catid('AUTO') || ',"type":"SPARE_PART","brand":"Toyota",'
       || '"mfr":"Toyota Genuine Parts","mpn":"90915-YZZE1","price":38,"incl":"Y","min":30,"max":150,"barcodes":["6281001000028"],'
       || '"fitment":[{"make":"Toyota","model":"Camry","from":2012,"to":2023,"engine":"2.5L"},{"make":"Toyota","model":"Corolla","from":2014,"to":2022}]}');
  item('FLT2', '{"name":"فلتر زيت بديل (Bosch)","code":"DEMO-FLT-02","cat":' || catid('AUTO') || ',"type":"SPARE_PART","brand":"Bosch",'
       || '"mpn":"F026407157","price":25,"incl":"Y","barcodes":["6281001000035"],"alternates":[{"no":"DEMO-FLT-01","type":"OEM_EQUIVALENT"}],'
       || '"fitment":[{"make":"Toyota","model":"Camry","from":2012,"to":2023}]}');
  item('BRK', '{"name":"فحمات فرامل أمامية هيونداي النترا","code":"DEMO-BRK-01","cat":' || catid('AUTO') || ',"type":"SPARE_PART","brand":"Hyundai Mobis",'
       || '"mpn":"58101-F2A00","price":240,"incl":"Y","minPrice":210,"barcodes":["6281001000042"],'
       || '"fitment":[{"make":"Hyundai","model":"Elantra","from":2016,"to":2020,"engine":"2.0L"}]}');
  item('BAT', '{"name":"بطارية سيارة 70 أمبير","code":"DEMO-BAT-70","cat":' || catid('AUTO') || ',"type":"SPARE_PART","brand":"Varta",'
       || '"price":420,"incl":"Y","minPrice":380,"min":5,"barcodes":["6281001000059"]}');
  item('SPK', '{"name":"شمعات احتراق NGK (طقم 4)","code":"DEMO-SPK-01","cat":' || catid('AUTO') || ',"type":"SPARE_PART","brand":"NGK",'
       || '"mpn":"ILKAR7B11","price":160,"incl":"Y","barcodes":["6281001000066"]}');
  item('PAR', '{"name":"باراسيتامول 500 مجم 24 قرص","code":"DEMO-PAR-500","cat":' || catid('PHARMA') || ',"generic":"Paracetamol","strength":"500mg",'
       || '"form":"TABLET","rx":"N","reg":"SFDA-DEMO-0001","price":9.5,"incl":"Y","min":50,"barcodes":["6281001000073"]}');
  item('AMX', '{"name":"أموكسيسيلين 500 مجم 20 كبسولة","code":"DEMO-AMX-500","cat":' || catid('PHARMA') || ',"generic":"Amoxicillin","strength":"500mg",'
       || '"form":"CAPSULE","rx":"Y","reg":"SFDA-DEMO-0002","price":24,"incl":"Y","barcodes":["6281001000080"]}');
  item('VTC', '{"name":"فيتامين سي 1000 مجم فوار","code":"DEMO-VTC-1000","cat":' || catid('PHARMA') || ',"generic":"Ascorbic Acid","strength":"1000mg",'
       || '"form":"OTHER","rx":"N","price":18,"incl":"Y","barcodes":["6281001000097"]}');
  item('CGH', '{"name":"شراب كحة للأطفال 100 مل","code":"DEMO-CGH-100","cat":' || catid('PHARMA') || ',"generic":"Dextromethorphan","strength":"15mg/5ml",'
       || '"form":"SYRUP","rx":"N","price":22,"incl":"Y","barcodes":["6281001000103"]}');
  item('WTR', '{"name":"مياه شرب 330 مل (كرتون 40)","code":"DEMO-WTR-40","cat":' || catid('GEN') || ',"price":19,"incl":"Y","min":30,"barcodes":["6281001000110"]}');
  item('TIS', '{"name":"مناديل ورقية 200 منديل","code":"DEMO-TIS-200","cat":' || catid('GEN') || ',"price":6.5,"incl":"Y","barcodes":["6281001000127"]}');
  item('RES', '{"name":"حبيبات بلاستيك PET خام","code":"DEMO-RES-PET","cat":' || catid('RAW') || ',"type":"RAW_MATERIAL","sell":"N",'
       || '"uom":' || NVL(TO_CHAR(l_kg), 'null') || ',"min":200}');
  item('CAP', '{"name":"غطاء بلاستيك 38 مم","code":"DEMO-CAP-38","cat":' || catid('RAW') || ',"type":"RAW_MATERIAL","sell":"N"}');
  item('BTL', '{"name":"عبوة بلاستيك 1 لتر (منتج المصنع)","code":"DEMO-BTL-1L","cat":' || catid('FG') || ',"type":"FINISHED_GOOD",'
       || '"price":1.75,"incl":"Y","barcodes":["6281001000134"]}');
  item('SRV', '{"name":"خدمة تغيير زيت وفلتر","code":"DEMO-SRV-OIL","cat":' || catid('SRV') || ',"type":"SERVICE","price":50,"incl":"Y"}');
  say('الأصناف: ' || it.COUNT);

  -- ====================================================== الأرصدة الافتتاحية للمخزون
  l_n := NOONA_INV_PKG.save_stock_doc('{"type":"OPENING","date":"' || dt(58) || '","wh":' || l_wh || ',"action":"POST","lines":['
     || '{"i":' || it('OIL') || ',"q":60,"c":120},{"i":' || it('FLT') || ',"q":80,"c":19},{"i":' || it('FLT2') || ',"q":60,"c":12},'
     || '{"i":' || it('BRK') || ',"q":25,"c":150},{"i":' || it('BAT') || ',"q":12,"c":290},{"i":' || it('SPK') || ',"q":30,"c":95},'
     || '{"i":' || it('PAR') || ',"q":200,"c":4.2,"lot":"PAR-2401","exp":"' || TO_CHAR(SYSDATE + 420, 'YYYY-MM-DD') || '"},'
     || '{"i":' || it('PAR') || ',"q":40,"c":4.2,"lot":"PAR-2312","exp":"' || TO_CHAR(SYSDATE + 25, 'YYYY-MM-DD') || '"},'
     || '{"i":' || it('AMX') || ',"q":80,"c":11,"lot":"AMX-2402","exp":"' || TO_CHAR(SYSDATE + 300, 'YYYY-MM-DD') || '"},'
     || '{"i":' || it('VTC') || ',"q":60,"c":9,"lot":"VTC-2403","exp":"' || TO_CHAR(SYSDATE + 500, 'YYYY-MM-DD') || '"},'
     || '{"i":' || it('CGH') || ',"q":30,"c":10,"lot":"CGH-2301","exp":"' || TO_CHAR(SYSDATE - 10, 'YYYY-MM-DD') || '"},'
     || '{"i":' || it('CGH') || ',"q":50,"c":10,"lot":"CGH-2405","exp":"' || TO_CHAR(SYSDATE + 360, 'YYYY-MM-DD') || '"},'
     || '{"i":' || it('WTR') || ',"q":100,"c":11},{"i":' || it('TIS') || ',"q":150,"c":3.2},'
     || '{"i":' || it('RES') || ',"q":1500,"c":5.5},{"i":' || it('CAP') || ',"q":5000,"c":0.08}]}');
  say('الرصيد الافتتاحي للمخزون مرحل');

  -- ====================================================== الموردون
  sup('AUTO') := NOONA_PUR_PKG.save_supplier('{"name":"شركة قطع الغيار المتحدة","nameEn":"United Auto Parts Co.","tax":"310000000000013","cr":"1010000001",'
       || '"phone":"0112000001","email":"sales@uap.example","address":"الرياض - حي السلي","term":"NET30","type":"GOODS"}');
  sup('PHARMA') := NOONA_PUR_PKG.save_supplier('{"name":"مستودع الدواء الوطني","nameEn":"National Pharma Warehouse","tax":"310000000000023","cr":"1010000002",'
       || '"phone":"0112000002","address":"الرياض - المنطقة الصناعية الثانية","term":"NET60","type":"GOODS"}');
  sup('PLAST') := NOONA_PUR_PKG.save_supplier('{"name":"مصنع البلاستيك الحديث","tax":"310000000000033","cr":"2050000003","phone":"0138000003",'
       || '"address":"الدمام - المدينة الصناعية","term":"NET30","type":"GOODS"}');
  sup('SERV') := NOONA_PUR_PKG.save_supplier('{"name":"مؤسسة الخدمات اللوجستية","tax":"310000000000043","phone":"0550000004","term":"NET15","type":"SERVICES"}');

  -- ====================================================== المشتريات
  -- أمر شراء معتمد ثم فاتورة آجلة من الأمر (استلام جزئي)
  l_po := NOONA_PUR_PKG.save_order('{"sup":' || sup('AUTO') || ',"date":"' || dt(40) || '","action":"APPROVE","lines":['
          || '{"i":' || it('OIL') || ',"q":60,"p":118},{"i":' || it('BRK') || ',"q":20,"p":148},{"i":' || it('BAT') || ',"q":10,"p":285}]}');
  SELECT MIN(id) INTO l_line FROM pur_order_line WHERE order_id = l_po AND item_id = it('OIL');
  SELECT MIN(id) INTO l_x FROM pur_order_line WHERE order_id = l_po AND item_id = it('BRK');
  l_inv := NOONA_PUR_PKG.save_invoice('{"sup":' || sup('AUTO') || ',"date":"' || dt(35) || '","supInv":"UAP-55120","po":' || l_po
          || ',"mode":"CREDIT","action":"POST","lines":[{"i":' || it('OIL') || ',"q":60,"p":118,"pol":' || l_line || '},'
          || '{"i":' || it('BRK') || ',"q":12,"p":148,"pol":' || l_x || '},{"d":"أجور شحن","q":1,"p":250,"acc":"5299"}]}');
  -- مرتجع جزئي من الفاتورة
  SELECT MIN(id) INTO l_line FROM ap_invoice_line WHERE invoice_id = l_inv AND item_id = it('BRK');
  l_n := NOONA_PUR_PKG.post_return('{"inv":' || l_inv || ',"date":"' || dt(33) || '","reason":"عيب تصنيع في الكرتون","lines":[{"l":' || l_line || ',"q":2}]}');
  -- أدوية بدفعات (آجل 60 يوماً)
  l_n := NOONA_PUR_PKG.save_invoice('{"sup":' || sup('PHARMA') || ',"date":"' || dt(30) || '","supInv":"NPW-9081","mode":"CREDIT","action":"POST","lines":['
          || '{"i":' || it('AMX') || ',"q":120,"p":10.5,"lot":"AMX-2406","exp":"' || TO_CHAR(SYSDATE + 540, 'YYYY-MM-DD') || '"},'
          || '{"i":' || it('PAR') || ',"q":300,"p":4,"lot":"PAR-2406","exp":"' || TO_CHAR(SYSDATE + 600, 'YYYY-MM-DD') || '"},'
          || '{"i":' || it('VTC') || ',"q":60,"p":8.5,"disc":30,"lot":"VTC-2406","exp":"' || TO_CHAR(SYSDATE + 620, 'YYYY-MM-DD') || '"}]}');
  -- خامات للمصنع
  l_n := NOONA_PUR_PKG.save_invoice('{"sup":' || sup('PLAST') || ',"date":"' || dt(28) || '","supInv":"MPF-3310","mode":"CREDIT","action":"POST","lines":['
          || '{"i":' || it('RES') || ',"q":2000,"p":5.4},{"i":' || it('CAP') || ',"q":10000,"p":0.075}]}');
  -- فاتورة نقدية من الصندوق: بضاعة + خدمة نقل
  l_n := NOONA_PUR_PKG.save_invoice('{"sup":' || sup('SERV') || ',"date":"' || dt(22) || '","supInv":"LOG-771","mode":"CASH","place":"BOX:' || l_box
          || '","action":"POST","lines":[{"i":' || it('WTR') || ',"q":50,"p":10.5},{"d":"نقل وتحميل بضاعة","q":1,"p":350,"acc":"5299","cc":' || l_ccs || '}]}');
  -- سداد الموردين: بنك وصندوق
  l_n := NOONA_PUR_PKG.pay_supplier('{"sup":' || sup('AUTO') || ',"date":"' || dt(15) || '","amount":5000,"place":"BANK:' || l_bank
          || '","method":"BANK_APP","ref":"TRF-88231","notes":"دفعة من فاتورة UAP-55120"}');
  l_n := NOONA_PUR_PKG.pay_supplier('{"sup":' || sup('PLAST') || ',"date":"' || dt(12) || '","amount":3000,"place":"BOX:' || l_box || '","method":"CASH"}');
  say('المشتريات: أمر شراء، 4 فواتير، مرتجع، سدادان');

  -- ====================================================== العملاء
  cus('WALK') := NOONA_SAL_PKG.walk_in_customer;
  cus('GARAGE') := NOONA_SAL_PKG.save_customer('{"name":"ورشة النجم لصيانة السيارات","person":"N","tax":"310000000000053","cr":"1010000005",'
       || '"phone":"0500000005","address":"الرياض - الصناعية القديمة","term":"NET30","limit":25000}');
  cus('PHARM') := NOONA_SAL_PKG.save_customer('{"name":"صيدلية الشفاء","person":"N","tax":"310000000000063","phone":"0500000006","term":"NET30","limit":15000}');
  cus('FLEET') := NOONA_SAL_PKG.save_customer('{"name":"شركة النقل السريع (أسطول)","person":"N","tax":"310000000000073","phone":"0500000007","term":"NET60","limit":50000}');
  cus('PERSON') := NOONA_SAL_PKG.save_customer('{"name":"محمد عبدالله السالم","person":"Y","phone":"0500000008","term":"NET15","limit":2000}');

  -- ====================================================== المبيعات
  l_n := NOONA_SAL_PKG.save_invoice('{"cust":' || cus('GARAGE') || ',"date":"' || dt(25) || '","mode":"CREDIT","action":"POST","lines":['
          || '{"i":' || it('OIL') || ',"q":20},{"i":' || it('FLT') || ',"q":30},{"i":' || it('BRK') || ',"q":4,"disc":40}]}');
  l_inv := NOONA_SAL_PKG.save_invoice('{"cust":' || cus('FLEET') || ',"date":"' || dt(20) || '","mode":"CREDIT","cc":' || l_ccs || ',"action":"POST","lines":['
          || '{"i":' || it('BAT') || ',"q":6},{"i":' || it('OIL') || ',"q":15},{"i":' || it('SRV') || ',"q":15}]}');
  l_n := NOONA_SAL_PKG.save_invoice('{"cust":' || cus('PHARM') || ',"date":"' || dt(18) || '","mode":"CREDIT","action":"POST","lines":['
          || '{"i":' || it('PAR') || ',"q":100,"p":7.5},{"i":' || it('VTC') || ',"q":20,"p":14},{"i":' || it('CGH') || ',"q":10,"p":17}]}');
  l_n := NOONA_SAL_PKG.save_invoice('{"date":"' || dt(16) || '","mode":"CASH","place":"BOX:' || l_box || '","name":"عميل نقدي","rx":"RX-55021",'
          || '"action":"POST","lines":[{"i":' || it('AMX') || ',"q":2},{"i":' || it('PAR') || ',"q":3}]}');
  l_n := NOONA_SAL_PKG.save_invoice('{"cust":' || cus('PERSON') || ',"date":"' || dt(14) || '","mode":"CASH","place":"BANK:' || l_bank
          || '","action":"POST","lines":[{"i":' || it('SPK') || ',"q":1},{"i":' || it('SRV') || ',"q":1}]}');
  -- مرتجع من فاتورة الأسطول
  SELECT MIN(id) INTO l_line FROM sal_invoice_line WHERE invoice_id = l_inv AND item_id = it('BAT');
  l_n := NOONA_SAL_PKG.post_return('{"inv":' || l_inv || ',"date":"' || dt(12) || '","reason":"بطارية لا تناسب المركبة","lines":[{"l":' || l_line || ',"q":1}]}');
  -- التحصيل
  l_n := NOONA_SAL_PKG.receive('{"cust":' || cus('GARAGE') || ',"date":"' || dt(8) || '","amount":4000,"place":"BANK:' || l_bank
          || '","method":"BANK_APP","ref":"SARIE-44120"}');
  l_n := NOONA_SAL_PKG.receive('{"cust":' || cus('PHARM') || ',"date":"' || dt(6) || '","amount":500,"place":"BOX:' || l_box || '","method":"CASH"}');
  say('المبيعات: 5 فواتير، مرتجع، تحصيلان');

  -- ====================================================== حركات المخزون والإنتاج
  l_n := NOONA_INV_PKG.save_stock_doc('{"type":"SCRAP","date":"' || dt(10) || '","wh":' || l_wh || ',"reason":"EXPIRED","action":"POST","lines":['
          || '{"i":' || it('CGH') || ',"q":20,"lot":"CGH-2301"}]}');
  l_n := NOONA_INV_PKG.save_stock_doc('{"type":"ADJ_OUT","date":"' || dt(9) || '","wh":' || l_wh || ',"reason":"COUNT","action":"POST","lines":['
          || '{"i":' || it('TIS') || ',"q":5}]}');
  l_n := NOONA_INV_PKG.save_stock_doc('{"type":"ADJ_IN","date":"' || dt(9) || '","wh":' || l_wh || ',"reason":"COUNT","action":"POST","lines":['
          || '{"i":' || it('FLT2') || ',"q":3,"c":12}]}');
  l_n := NOONA_INV_PKG.save_stock_doc('{"type":"CONSUMPTION","date":"' || dt(7) || '","wh":' || l_wh || ',"cc":' || l_cca
          || ',"reason":"ضيافة الإدارة","action":"POST","lines":[{"i":' || it('WTR') || ',"q":5},{"i":' || it('TIS') || ',"q":10}]}');
  l_n := NOONA_INV_PKG.save_stock_doc('{"type":"TRANSFER_OUT","date":"' || dt(7) || '","wh":' || l_wh || ',"toWh":' || l_wh2
          || ',"reason":"تزويد معرض الفرع","action":"POST","lines":[{"i":' || it('OIL') || ',"q":10},{"i":' || it('FLT') || ',"q":15}]}');
  l_n := NOONA_INV_PKG.save_bom(it('BTL'), '[{"i":' || it('RES') || ',"q":0.045,"s":3},{"i":' || it('CAP') || ',"q":1,"s":1}]');
  l_n := NOONA_INV_PKG.produce(it('BTL'), 3000, l_wh, TO_DATE(dt(5), 'YYYY-MM-DD'), 'تشغيلة إنتاج تجريبية', 'BTL-0001');
  say('المخزون: إتلاف، عجز، زيادة، صرف لمركز تكلفة، تحويل، إنتاج 3000 عبوة');

  -- ====================================================== نقطة البيع (وردية اليوم)
  SELECT MIN(id) INTO l_term FROM pos_terminal WHERE company_id = l_co AND status_code = 'ACTIVE';
  FOR o IN (SELECT id FROM pos_shift WHERE terminal_id = l_term AND status_code = 'OPEN') LOOP
    l_n := NOONA_POS_PKG.close_shift(o.id, NOONA_POS_PKG.expected_cash(o.id));
  END LOOP;
  l_sh := NOONA_POS_PKG.open_shift(l_term, 300);
  l_sale := pos_sale('DEMO-1', NULL, '{"i":' || it('OIL') || ',"q":1},{"i":' || it('FLT') || ',"q":1}', '{"m":"CASH","a":250}');
  l_sid := l_sale;
  l_sale := pos_sale('DEMO-2', NULL, '{"i":' || it('WTR') || ',"q":2},{"i":' || it('TIS') || ',"q":3}', '{"m":"MADA","a":57.5,"ref":"MADA-1001"}');
  l_sale := pos_sale('DEMO-3', NULL, '{"i":' || it('BAT') || ',"q":1}', '{"m":"APPLE_PAY","a":420,"ref":"AP-77310"}');
  l_sale := pos_sale('DEMO-4', NULL, '{"i":' || it('PAR') || ',"q":2},{"i":' || it('VTC') || ',"q":1}', '{"m":"STC_PAY","a":37,"ref":"STC-5521"}');
  l_sale := pos_sale('DEMO-5', NULL, '{"i":' || it('AMX') || ',"q":1},{"i":' || it('CGH') || ',"q":1}', '{"m":"CASH","a":20},{"m":"BANK_APP","a":26,"ref":"BNK-201"}', 'RX-77812');
  l_sale := pos_sale('DEMO-6', cus('GARAGE'), '{"i":' || it('BRK') || ',"q":2},{"i":' || it('SPK') || ',"q":1}', '{"m":"CREDIT","a":640}');
  l_sale := pos_sale('DEMO-7', NULL, '{"i":' || it('BTL') || ',"q":200}', '{"m":"CASH","a":350}');
  -- مرتجع من الإيصال الأول
  SELECT MIN(id) INTO l_line FROM pos_sale_line WHERE sale_id = l_sid AND item_id = it('FLT');
  l_r := NOONA_POS_PKG.return_sale('{"key":"DEMO-R1","shift":' || l_sh || ',"orig":' || l_sid || ',"lines":[{"l":' || l_line || ',"q":1}]}');
  l_n := NOONA_POS_PKG.close_shift(l_sh, NOONA_POS_PKG.expected_cash(l_sh));
  say('نقطة البيع: 7 مبيعات بطرق سداد مختلفة، مرتجع، وإقفال الوردية');

  FORALL i IN 1 .. l_rules.COUNT
    UPDATE dms_archive_rule SET is_active = 'Y' WHERE id = l_rules(i);
  COMMIT;
  say('');
  say('تم تحميل البيانات التجريبية بنجاح.');
  say('الصندوق: ' || NOONA_CSH_PKG.balance(l_box, NULL) || ' | البنك: ' || NOONA_CSH_PKG.balance(NULL, l_bank));
  say('مستحق للموردين: ' || (NOONA_PUR_PKG.supplier_balance(sup('AUTO')) + NOONA_PUR_PKG.supplier_balance(sup('PHARMA'))
                              + NOONA_PUR_PKG.supplier_balance(sup('PLAST')) + NOONA_PUR_PKG.supplier_balance(sup('SERV'))));
  say('مستحق على العملاء: ' || (NOONA_SAL_PKG.customer_balance(cus('GARAGE')) + NOONA_SAL_PKG.customer_balance(cus('PHARM'))
                                 + NOONA_SAL_PKG.customer_balance(cus('FLEET')) + NOONA_SAL_PKG.customer_balance(cus('PERSON'))));
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  RAISE;
END;
/
EXIT
