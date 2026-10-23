-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية للمطاعم والكافتريا (بعد التحديث 24) - تشغل بحساب NOONA_APP ولا تكرر
-- (تكتشف نقطة البيع ذات الرمز RST):
--   sqlplus NOONA_APP@//host:1521/PDB @demo/demo_restaurant.sql ADMIN
-- المحتوى:
--   * نقطة بيع «كاشير المطعم» بدرج نقدي مستقل
--   * ثلاث صالات: الرئيسية (10 طاولات)، الجلسات الخارجية (6)، العائلات (4 طاولات دائرية)
--   * قائمة طعام من 6 فئات و26 صنفاً بأسعار شاملة الضريبة، و27 مادة خام بأرصدة افتتاحية ووصفة لكل وجبة ومشروب محضر
--     (تصرف المكونات من المخزون عند السداد)، والمياه والمشروبات الغازية أصناف مخزنية
--   * ثلاثة عملاء آجلين بحدود ائتمان
--   * أسبوع من الطلبات المسددة (صالة، سفري، توصيل، آجل، مختلط) موزعة على الساعات، وتحصيل من عميل آجل، وإقفال الوردية بقيدها
--   * الوضع الحالي: طاولات مشغولة (في المطبخ، جاهزة، طبع الحساب)، طلب سفري وطلب توصيل مفتوحان
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

PROMPT ========== المواد الخام ووصفات قائمة الطعام (الخصم من المخزون)
DECLARE
  c_admin CONSTANT VARCHAR2(128) := NVL(UPPER(TRIM('&ADMIN_USER')), 'ADMIN');
  l_co    NUMBER;
  l_n     NUMBER;
  l_cat   NUMBER;
  l_kg    NUMBER;
  l_l     NUMBER;
  l_pcs   NUMBER;
  l_lines VARCHAR2(32767);
  l_cnt   PLS_INTEGER := 0;
  TYPE t_map IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
  g       t_map;
  m       t_map;

  PROCEDURE say(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
  -- صنف القائمة: الموجود بالاسم (من تحميل سابق) أو جديد
  PROCEDURE menu(p_key VARCHAR2, p_name VARCHAR2, p_price NUMBER, p_stock VARCHAR2 DEFAULT 'RECIPE') IS
    l NUMBER;
    l_t VARCHAR2(30);
  BEGIN
    SELECT MIN(i.id), MIN(i.item_type) INTO l, l_t FROM inv_item i JOIN inv_item_category c ON c.id = i.category_id
     WHERE i.name_ar = p_name AND (c.code = 'MENU' OR c.parent_category_id = (SELECT MIN(id) FROM inv_item_category WHERE code = 'MENU'));
    IF l IS NULL OR (p_stock = 'STOCK' AND l_t IN ('NON_STOCK', 'SERVICE')) THEN
      l := NOONA_RST_PKG.save_menu_item(l, p_name, l_cat, p_price, 'ACTIVE', p_stock);
    END IF;
    m(p_key) := l;
  END menu;
  PROCEDURE ing(p_key VARCHAR2, p_name VARCHAR2, p_uom NUMBER, p_cost NUMBER, p_qty NUMBER) IS
  BEGIN
    g(p_key) := NOONA_RST_PKG.save_ingredient(p_name, p_uom);
    l_lines := l_lines || CASE WHEN l_lines IS NOT NULL THEN ',' END || '{"i":' || g(p_key) || ',"q":' || p_qty || ',"c":' || p_cost || '}';
  END ing;
  -- «مفتاح:كمية مفتاح:كمية» لكل حصة
  PROCEDURE recipe(p_key VARCHAR2, p_parts VARCHAR2) IS
    l_part VARCHAR2(100);
    k PLS_INTEGER := 1;
  BEGIN
    LOOP
      l_part := REGEXP_SUBSTR(p_parts, '[^ ]+', 1, k);
      EXIT WHEN l_part IS NULL;
      NOONA_RST_PKG.recipe_set(m(p_key), g(SUBSTR(l_part, 1, INSTR(l_part, ':') - 1)),
                               TO_NUMBER(SUBSTR(l_part, INSTR(l_part, ':') + 1), '9999D9999', 'NLS_NUMERIC_CHARACTERS=''.,'''));
      k := k + 1;
    END LOOP;
    l_cnt := l_cnt + 1;
  END recipe;
BEGIN
  NOONA_APEX_PKG.post_auth(c_admin, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  SELECT COUNT(*) INTO l_n FROM inv_item i JOIN inv_item_category c ON c.id = i.category_id WHERE c.code = 'RST_ING' AND i.name_ar = 'أرز بسمتي';
  IF l_n > 0 THEN
    say('مكونات ووصفات المطعم التجريبية محملة سابقاً؛ لم يضف شيء.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;
  l_n := NOONA_RST_PKG.quick_setup;
  SELECT MIN(CASE WHEN code = 'KG' THEN id END), MIN(CASE WHEN code = 'L' THEN id END), MIN(CASE WHEN code = 'PCS' THEN id END)
    INTO l_kg, l_l, l_pcs FROM inv_uom;

  -- قائمة الطعام (الأسعار شاملة الضريبة)؛ المياه والمشروبات الغازية أصناف مخزنية تباع كما هي
  l_cat := NOONA_RST_PKG.menu_category('RM_HOT', 'مشروبات ساخنة');
  menu('ARCOF', 'قهوة عربية (دلة)', 25); menu('ESP', 'إسبريسو', 12); menu('LATTE', 'لاتيه', 17); menu('CAPP', 'كابتشينو', 17);
  menu('TEA', 'شاي بالنعناع', 8);
  l_cat := NOONA_RST_PKG.menu_category('RM_COLD', 'مشروبات باردة وعصائر');
  menu('ORJ', 'عصير برتقال طازج', 18); menu('LEMIN', 'ليمون بالنعناع', 16); menu('ICELAT', 'آيس لاتيه', 19);
  menu('WATER', 'مياه معدنية', 3, 'STOCK'); menu('SODA', 'مشروب غازي', 6, 'STOCK');
  l_cat := NOONA_RST_PKG.menu_category('RM_STRT', 'مقبلات وسلطات');
  menu('HUMUS', 'حمص بالطحينة', 14); menu('FATT', 'سلطة فتوش', 16); menu('FRIES', 'بطاطس مقلية', 12); menu('SAMB', 'سمبوسة (6 قطع)', 15);
  l_cat := NOONA_RST_PKG.menu_category('RM_MAIN', 'الوجبات الرئيسية');
  menu('KABSA', 'كبسة دجاج', 32); menu('MANDI', 'مندي لحم', 58); menu('GRILL', 'مشاوي مشكلة', 65); menu('PASTA', 'باستا ألفريدو', 36);
  l_cat := NOONA_RST_PKG.menu_category('RM_SAND', 'البرجر والسندويتشات');
  menu('BURG', 'برجر لحم كلاسيك', 29); menu('CHBURG', 'برجر دجاج مقرمش', 26); menu('SHAW', 'شاورما دجاج', 14); menu('CLUB', 'كلوب ساندويتش', 24);
  l_cat := NOONA_RST_PKG.menu_category('RM_DSRT', 'الحلويات');
  menu('KUN', 'كنافة بالقشطة', 22); menu('CAKE', 'تشيز كيك', 21); menu('UMALI', 'أم علي', 19); menu('ICE', 'آيس كريم (3 كرات)', 15);

  -- المواد الخام بأرصدة افتتاحية في المستودع الرئيسي (مستودع نقاط البيع)
  ing('RICE', 'أرز بسمتي', l_kg, 8, 100);          ing('CHICKEN', 'دجاج طازج', l_kg, 18, 80);
  ing('LAMB', 'لحم غنم', l_kg, 55, 40);             ing('BEEF', 'لحم بقري مفروم', l_kg, 42, 30);
  ing('BUN', 'خبز برجر', l_pcs, 1.2, 400);          ing('BREAD', 'خبز عربي', l_pcs, 0.5, 500);
  ing('POTATO', 'بطاطس مجمدة', l_kg, 9, 60);        ing('OIL', 'زيت قلي', l_l, 7, 40);
  ing('VEG', 'خضار مشكلة', l_kg, 6, 50);            ing('CHEESE', 'جبن شرائح', l_kg, 30, 15);
  ing('COFFEE', 'بن إسبريسو', l_kg, 90, 10);        ing('ARCOF', 'بن قهوة عربية بالهيل', l_kg, 120, 8);
  ing('MILK', 'حليب طازج', l_l, 6, 60);             ing('TEA', 'شاي', l_kg, 40, 5);
  ing('ORANGE', 'برتقال عصير', l_kg, 5, 80);        ing('LEMON', 'ليمون ونعناع', l_kg, 7, 30);
  ing('SUGAR', 'سكر', l_kg, 4, 40);                 ing('PASTA', 'معكرونة', l_kg, 7, 25);
  ing('CREAM', 'كريمة طبخ', l_l, 14, 20);           ing('CHICKP', 'حمص حب', l_kg, 9, 20);
  ing('TAHINI', 'طحينة', l_kg, 22, 10);             ing('KUNAFA', 'عجينة كنافة', l_kg, 18, 20);
  ing('QASHTA', 'قشطة', l_kg, 25, 15);              ing('CREAMCH', 'جبن كريمي', l_kg, 35, 10);
  ing('BISC', 'بسكويت', l_kg, 15, 10);              ing('ICE', 'آيس كريم', l_l, 20, 30);
  ing('SAMB', 'رقائق سمبوسة', l_pcs, 0.4, 600);
  l_n := NOONA_INV_PKG.save_stock_doc('{"type":"OPENING","date":"' || TO_CHAR(SYSDATE - 7, 'YYYY-MM-DD') || '","wh":'
         || NOONA_INV_PKG.default_warehouse || ',"action":"POST","desc":"رصيد افتتاحي لمواد المطبخ","lines":[' || l_lines || ']}');
  -- علب المشروبات والمياه
  l_n := NOONA_INV_PKG.save_stock_doc('{"type":"OPENING","date":"' || TO_CHAR(SYSDATE - 7, 'YYYY-MM-DD') || '","wh":'
         || NOONA_INV_PKG.default_warehouse || ',"action":"POST","desc":"رصيد افتتاحي للمشروبات المعلبة","lines":[{"i":' || m('WATER')
         || ',"q":240,"c":0.8},{"i":' || m('SODA') || ',"q":200,"c":2.2}]}');

  -- الوصفات: كمية كل مكون لكل حصة
  recipe('ARCOF', 'ARCOF:0.03');
  recipe('ESP', 'COFFEE:0.018');
  recipe('LATTE', 'COFFEE:0.018 MILK:0.2 SUGAR:0.01');
  recipe('CAPP', 'COFFEE:0.018 MILK:0.15');
  recipe('TEA', 'TEA:0.005 SUGAR:0.015 LEMON:0.005');
  recipe('ORJ', 'ORANGE:0.5');
  recipe('LEMIN', 'LEMON:0.12 SUGAR:0.03');
  recipe('ICELAT', 'COFFEE:0.018 MILK:0.2 SUGAR:0.015');
  recipe('HUMUS', 'CHICKP:0.12 TAHINI:0.04 OIL:0.01');
  recipe('FATT', 'VEG:0.25 BREAD:1 OIL:0.02');
  recipe('FRIES', 'POTATO:0.25 OIL:0.05');
  recipe('SAMB', 'SAMB:6 BEEF:0.1 OIL:0.06');
  recipe('KABSA', 'RICE:0.25 CHICKEN:0.45 OIL:0.03 VEG:0.05');
  recipe('MANDI', 'RICE:0.3 LAMB:0.4 OIL:0.03');
  recipe('GRILL', 'LAMB:0.25 CHICKEN:0.25 BREAD:2 VEG:0.1');
  recipe('PASTA', 'PASTA:0.15 CREAM:0.12 CHICKEN:0.1 CHEESE:0.03');
  recipe('BURG', 'BEEF:0.18 BUN:1 CHEESE:0.02 VEG:0.05 POTATO:0.15 OIL:0.04');
  recipe('CHBURG', 'CHICKEN:0.18 BUN:1 VEG:0.05 OIL:0.06');
  recipe('SHAW', 'CHICKEN:0.12 BREAD:1 VEG:0.03');
  recipe('CLUB', 'CHICKEN:0.1 BREAD:3 CHEESE:0.03 VEG:0.05');
  recipe('KUN', 'KUNAFA:0.15 QASHTA:0.08 SUGAR:0.05');
  recipe('CAKE', 'CREAMCH:0.08 BISC:0.03 SUGAR:0.02');
  recipe('UMALI', 'MILK:0.2 BREAD:1 SUGAR:0.03 QASHTA:0.03');
  recipe('ICE', 'ICE:0.2');
  COMMIT;
  say('المطبخ: 27 مادة خام بأرصدة افتتاحية، ' || l_cnt || ' وصفة تصرف مكوناتها عند البيع، والمياه والمشروبات الغازية أصناف مخزنية');
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  RAISE;
END;
/

PROMPT ========== الصالات والعملاء الآجلون وأسبوع من الطلبات
DECLARE
  c_admin CONSTANT VARCHAR2(128) := NVL(UPPER(TRIM('&ADMIN_USER')), 'ADMIN');
  l_co    NUMBER;
  l_n     NUMBER;
  l_box   NUMBER;
  l_bank  NUMBER;
  l_term  NUMBER;
  l_hall  NUMBER;
  l_out   NUMBER;
  l_fam   NUMBER;
  l_o     NUMBER;
  l_r     CLOB;
  l_sh    NUMBER;
  l_c1    NUMBER;
  l_c2    NUMBER;
  l_c3    NUMBER;
  l_k     PLS_INTEGER := 0;
  TYPE t_map IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
  it      t_map;
  TYPE t_list IS TABLE OF VARCHAR2(30);
  l_codes t_list := t_list();

  PROCEDURE say(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
  FUNCTION tbl(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM rst_table WHERE company_id = l_co AND code = p_code;
    RETURN l;
  END tbl;
  PROCEDURE item(p_key VARCHAR2, p_cat NUMBER, p_name VARCHAR2, p_price NUMBER) IS
  BEGIN
    SELECT MIN(i.id) INTO it(p_key) FROM inv_item i WHERE i.name_ar = p_name AND i.category_id = p_cat;   -- أنشئ مع وصفته في الجزء الأول
    IF it(p_key) IS NULL THEN
      it(p_key) := NOONA_RST_PKG.save_menu_item(NULL, p_name, p_cat, p_price);
    END IF;
    l_codes.EXTEND;
    l_codes(l_codes.COUNT) := p_key;
  END item;
  -- [{"i":..,"q":..}] من «مفتاح:كمية,مفتاح:كمية»
  FUNCTION lines(p VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(4000) := '[';
    l_part VARCHAR2(100);
    k PLS_INTEGER := 1;
  BEGIN
    LOOP
      l_part := REGEXP_SUBSTR(p, '[^,]+', 1, k);
      EXIT WHEN l_part IS NULL;
      l := l || CASE WHEN k > 1 THEN ',' END || '{"i":' || it(SUBSTR(l_part, 1, INSTR(l_part, ':') - 1)) || ',"q":'
        || SUBSTR(l_part, INSTR(l_part, ':') + 1) || '}';
      k := k + 1;
    END LOOP;
    RETURN l || ']';
  END lines;
  FUNCTION open_on(p_table VARCHAR2, p_guests NUMBER, p_waiter VARCHAR2, p_items VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    l := NOONA_RST_PKG.open_order('{"table":' || tbl(p_table) || ',"guests":' || p_guests || ',"waiter":"' || p_waiter || '"}');
    NOONA_RST_PKG.add_items(l, lines(p_items));
    RETURN l;
  END open_on;
  FUNCTION open_other(p_type VARCHAR2, p_extra VARCHAR2, p_items VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    l := NOONA_RST_PKG.open_order('{"type":"' || p_type || '","terminal":' || l_term || CASE WHEN p_extra IS NOT NULL THEN ',' || p_extra END || '}');
    NOONA_RST_PKG.add_items(l, lines(p_items));
    RETURN l;
  END open_other;
  -- سداد ثم إرجاع وقت الطلب إلى يوم وساعة سابقين (لبيانات لوحة المبيعات)
  PROCEDURE pay(p_order NUMBER, p_pays VARCHAR2, p_days NUMBER, p_hour NUMBER, p_cust NUMBER DEFAULT NULL) IS
    l_tot NUMBER;
    l_doc VARCHAR2(4000);
    l_at  TIMESTAMP;
  BEGIN
    l_k := l_k + 1;
    SELECT total_amount INTO l_tot FROM rst_order WHERE id = p_order;
    l_doc := '{"key":"demo-rst-' || l_co || '-' || l_k || '","orders":[' || p_order || ']' || CASE WHEN p_cust IS NOT NULL THEN ',"cust":' || p_cust END
          || ',"pays":' || REPLACE(REPLACE(p_pays, '#T#', TO_CHAR(l_tot, 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS=''.,''')),
                                   '#H#', TO_CHAR(ROUND(l_tot / 2, 2), 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS=''.,'''));
    l_doc := REPLACE(REPLACE(l_doc, '#R40#', TO_CHAR(l_tot - 40, 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS=''.,''')),
                     '"a":' || TO_CHAR(ROUND(l_tot / 2, 2), 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS=''.,''') || '}]',
                     '"a":' || TO_CHAR(l_tot - ROUND(l_tot / 2, 2), 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS=''.,''') || '}]') || '}';
    l_r := NOONA_RST_PKG.settle(l_doc);
    l_at := CAST(TRUNC(SYSDATE) - p_days AS TIMESTAMP) + NUMTODSINTERVAL(p_hour, 'HOUR') + NUMTODSINTERVAL(MOD(l_k * 7, 50), 'MINUTE');
    UPDATE rst_order SET opened_at = l_at - INTERVAL '35' MINUTE, billed_at = l_at - INTERVAL '5' MINUTE, closed_at = l_at WHERE id = p_order;
    UPDATE rst_order_line SET sent_at = l_at - INTERVAL '30' MINUTE, ready_at = l_at - INTERVAL '15' MINUTE, kitchen_status = 'SERVED'
     WHERE order_id = p_order AND kitchen_status <> 'VOID';
  END pay;
BEGIN
  NOONA_APEX_PKG.post_auth(c_admin, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  SELECT COUNT(*) INTO l_n FROM pos_terminal WHERE company_id = l_co AND code = 'RST';
  IF l_n > 0 THEN
    say('بيانات المطعم التجريبية محملة سابقاً لهذه الشركة؛ لم يضف شيء.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;

  -- نقطة بيع المطعم بدرج مستقل
  IF NOONA_POS_PKG.is_ready = 'N' THEN
    l_n := NOONA_POS_PKG.quick_setup;
  END IF;
  l_box := NOONA_CSH_PKG.create_cash_box('RST-01', 'درج كاشير المطعم', '1101', 'POS_DRAWER');
  SELECT MIN(id) INTO l_bank FROM csh_bank_account WHERE company_id = l_co AND status_code = 'ACTIVE';
  l_term := NOONA_POS_PKG.create_terminal('RST', 'كاشير المطعم', NOONA_INV_PKG.default_warehouse, l_box, l_bank, NULL);
  l_n := NOONA_RST_PKG.quick_setup;
  SELECT MIN(id) INTO l_hall FROM rst_area WHERE company_id = l_co AND code = 'HALL';
  l_hall := NOONA_RST_PKG.save_area(l_hall, 'HALL', 'الصالة الرئيسية', l_term, 10);
  l_out := NOONA_RST_PKG.save_area(NULL, 'OUT', 'الجلسات الخارجية', l_term, 20);
  l_n := NOONA_RST_PKG.add_tables(l_out, 6, 'T', 2);
  l_fam := NOONA_RST_PKG.save_area(NULL, 'FAM', 'قسم العائلات', l_term, 30);
  l_n := NOONA_RST_PKG.add_tables(l_fam, 4, 'F', 6);
  UPDATE rst_table SET shape = 'ROUND' WHERE area_id = l_fam;
  UPDATE rst_table SET seats = 6, shape = 'LONG' WHERE company_id = l_co AND code IN ('T9', 'T10');
  say('المطعم: نقطة بيع «كاشير المطعم» ودرجها، 3 صالات و20 طاولة');

  -- قائمة الطعام (الأسعار شاملة ضريبة القيمة المضافة)
  l_n := NOONA_RST_PKG.menu_category('RM_HOT', 'مشروبات ساخنة');
  item('ARCOF', l_n, 'قهوة عربية (دلة)', 25);
  item('ESP', l_n, 'إسبريسو', 12);
  item('LATTE', l_n, 'لاتيه', 17);
  item('CAPP', l_n, 'كابتشينو', 17);
  item('TEA', l_n, 'شاي بالنعناع', 8);
  l_n := NOONA_RST_PKG.menu_category('RM_COLD', 'مشروبات باردة وعصائر');
  item('ORJ', l_n, 'عصير برتقال طازج', 18);
  item('LEMIN', l_n, 'ليمون بالنعناع', 16);
  item('ICELAT', l_n, 'آيس لاتيه', 19);
  item('WATER', l_n, 'مياه معدنية', 3);
  item('SODA', l_n, 'مشروب غازي', 6);
  l_n := NOONA_RST_PKG.menu_category('RM_STRT', 'مقبلات وسلطات');
  item('HUMUS', l_n, 'حمص بالطحينة', 14);
  item('FATT', l_n, 'سلطة فتوش', 16);
  item('FRIES', l_n, 'بطاطس مقلية', 12);
  item('SAMB', l_n, 'سمبوسة (6 قطع)', 15);
  l_n := NOONA_RST_PKG.menu_category('RM_MAIN', 'الوجبات الرئيسية');
  item('KABSA', l_n, 'كبسة دجاج', 32);
  item('MANDI', l_n, 'مندي لحم', 58);
  item('GRILL', l_n, 'مشاوي مشكلة', 65);
  item('PASTA', l_n, 'باستا ألفريدو', 36);
  l_n := NOONA_RST_PKG.menu_category('RM_SAND', 'البرجر والسندويتشات');
  item('BURG', l_n, 'برجر لحم كلاسيك', 29);
  item('CHBURG', l_n, 'برجر دجاج مقرمش', 26);
  item('SHAW', l_n, 'شاورما دجاج', 14);
  item('CLUB', l_n, 'كلوب ساندويتش', 24);
  l_n := NOONA_RST_PKG.menu_category('RM_DSRT', 'الحلويات');
  item('KUN', l_n, 'كنافة بالقشطة', 22);
  item('CAKE', l_n, 'تشيز كيك', 21);
  item('UMALI', l_n, 'أم علي', 19);
  item('ICE', l_n, 'آيس كريم (3 كرات)', 15);
  say('قائمة الطعام: 6 فئات و' || l_codes.COUNT || ' صنفاً');

  -- العملاء الآجلون
  l_c1 := NOONA_RST_PKG.quick_customer('شركة الأفق للمقاولات (حساب الموظفين)', '0112345678', 5000);
  l_c2 := NOONA_RST_PKG.quick_customer('مكتب المهندس سامي الحربي', '0559876543', 1500);
  l_c3 := NOONA_RST_PKG.quick_customer('عبدالله محمد القحطاني', '0501112233', 800);
  say('العملاء الآجلون: 3 بحدود ائتمان');

  -- أسبوع من الطلبات المسددة
  FOR d IN REVERSE 1 .. 6 LOOP
    l_o := open_on('T' || (MOD(d, 8) + 1), 4, 'خالد', 'KABSA:2,MANDI:1,HUMUS:1,ORJ:2,WATER:4');
    pay(l_o, '[{"m":"CASH","a":#T#}]', d, 13);
    l_o := open_on('T' || (MOD(d + 3, 8) + 1), 2, 'سعيد', 'BURG:2,FRIES:1,SODA:2');
    pay(l_o, '[{"m":"MADA","a":#T#,"ref":"' || (4400 + d) || '"}]', d, 14);
    l_o := open_other('TAKEAWAY', '"name":"سفري"', 'LATTE:2,CAKE:1');
    pay(l_o, '[{"m":"CASH","a":#T#}]', d, 10);
    l_o := open_other('TAKEAWAY', '"name":"سفري"', 'SHAW:4,SODA:2');
    pay(l_o, '[{"m":"APPLE_PAY","a":#T#}]', d, 20);
    l_o := open_on('F' || (MOD(d, 4) + 1), 6, 'منى', 'GRILL:2,FATT:2,KUN:2,LEMIN:4,ARCOF:1');
    pay(l_o, '[{"m":"MADA","a":#H#,"ref":"' || (5500 + d) || '"},{"m":"CASH","a":#H#}]', d, 21);
    l_o := open_other('DELIVERY', '"name":"عميل توصيل","phone":"05' || (40000000 + d * 1111) || '","addr":"حي الملقا"', 'PASTA:1,CHBURG:2,ICE:1');
    pay(l_o, '[{"m":"STC_PAY","a":#T#}]', d, 22);
    IF MOD(d, 2) = 0 THEN
      l_o := open_other('TAKEAWAY', '"cust":' || l_c1, 'KABSA:3,WATER:3,TEA:3');
      pay(l_o, '[{"m":"CREDIT","a":#T#}]', d, 12, l_c1);
    END IF;
    IF d IN (2, 5) THEN
      l_o := open_on('T' || (10 + d), 2, 'سعيد', 'CLUB:2,ICELAT:2');
      pay(l_o, '[{"m":"CREDIT","a":#T#}]', d, 16, l_c2);
    END IF;
    IF d = 3 THEN
      l_o := open_on('T7', 3, 'خالد', 'MANDI:1,SAMB:1,ESP:3');
      pay(l_o, '[{"m":"CASH","a":40},{"m":"CREDIT","a":#R40#}]', d, 19, l_c3);
    END IF;
  END LOOP;
  -- إلغاء طلب قبل التحضير
  l_o := open_on('T3', 2, 'سعيد', 'ESP:2');
  NOONA_RST_PKG.cancel_order(l_o, 'العميل غادر قبل الطلب');
  say('طلبات الأسبوع: صالة وسفري وتوصيل وآجل ومختلط وطلب ملغى');

  -- تحصيل من العميل الآجل
  l_n := NOONA_RST_PKG.collect('{"cust":' || l_c1 || ',"amount":150,"method":"CASH","notes":"دفعة من حساب موظفي الشركة"}');
  l_n := NOONA_RST_PKG.collect('{"cust":' || l_c2 || ',"amount":50,"method":"MADA","ref":"77889"}');
  say('تحصيل نقدي وشبكة من عميلين آجلين');

  -- إقفال الوردية بقيدها
  l_sh := NOONA_POS_PKG.current_shift(l_term);
  IF l_sh IS NOT NULL THEN
    l_n := NOONA_POS_PKG.close_shift(l_sh, NOONA_POS_PKG.expected_cash(l_sh));
    say('أقفلت وردية المطعم وقيدت المبيعات (قيد ' || l_n || ')');
  END IF;

  -- الوضع الحالي
  l_o := open_on('T1', 4, 'خالد', 'KABSA:2,FATT:1,ORJ:2,WATER:2');
  l_n := NOONA_RST_PKG.send_kitchen(l_o);
  l_o := open_on('T2', 2, 'سعيد', 'BURG:1,CHBURG:1,FRIES:2,SODA:2');
  l_n := NOONA_RST_PKG.send_kitchen(l_o);
  NOONA_RST_PKG.kitchen_ready(l_o, l_n);
  l_o := open_on('T5', 3, 'خالد', 'GRILL:1,HUMUS:1,LEMIN:3,KUN:1');
  l_n := NOONA_RST_PKG.send_kitchen(l_o);
  NOONA_RST_PKG.kitchen_served(l_o);
  l_r := NOONA_RST_PKG.bill_html(l_o);
  l_o := open_on('F2', 5, 'منى', 'MANDI:2,FATT:2,ARCOF:1');
  l_n := NOONA_RST_PKG.send_kitchen(l_o);
  NOONA_RST_PKG.add_items(l_o, lines('UMALI:2'));
  l_o := open_other('TAKEAWAY', '"name":"سفري - أبو فهد"', 'SHAW:3,SODA:3');
  l_n := NOONA_RST_PKG.send_kitchen(l_o);
  l_o := open_other('DELIVERY', '"name":"نورة","phone":"0533334444","addr":"حي الياسمين - شارع 12"', 'PASTA:2,CAKE:2');
  l_n := tbl('T1');
  UPDATE rst_order SET opened_at = SYSTIMESTAMP - INTERVAL '25' MINUTE WHERE company_id = l_co AND status_code IN ('OPEN', 'BILLED') AND table_id = l_n;
  UPDATE rst_order_line SET sent_at = SYSTIMESTAMP - INTERVAL '22' MINUTE
   WHERE order_id IN (SELECT id FROM rst_order WHERE table_id = l_n AND status_code = 'OPEN') AND kitchen_status = 'SENT';
  say('الآن: 4 طاولات مشغولة (في المطبخ، جاهزة، طبع الحساب)، طلب سفري وطلب توصيل مفتوحان');

  COMMIT;
  say('');
  say('تم تحميل بيانات المطعم التجريبية. افتح «المبيعات ونقاط البيع» ← المطاعم والكافتريا ← الصالة والطلبات.');
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  RAISE;
END;
/
EXIT
