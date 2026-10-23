-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية للمطاعم والكافتريا (بعد التحديث 24) - تشغل بحساب NOONA_APP ولا تكرر
-- (تكتشف نقطة البيع ذات الرمز RST):
--   sqlplus NOONA_APP@//host:1521/PDB @demo/demo_restaurant.sql ADMIN
-- المحتوى:
--   * نقطة بيع «كاشير المطعم» بدرج نقدي مستقل
--   * ثلاث صالات: الرئيسية (10 طاولات)، الجلسات الخارجية (6)، العائلات (4 طاولات دائرية)
--   * قائمة طعام من 6 فئات و26 صنفاً بأسعار شاملة الضريبة
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
    it(p_key) := NOONA_RST_PKG.save_menu_item(NULL, p_name, p_cat, p_price);
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
