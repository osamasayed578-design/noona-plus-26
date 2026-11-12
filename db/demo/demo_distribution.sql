-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية للتوزيع والمبيعات الميدانية (تشغل بعد demo_trade_data و demo_hr)
--   ثلاثة مندوبين مربوطين بموظفي الموارد البشرية وبمستخدمين، خطوط سير ومحلات بمواقع GPS في الرياض،
--   تحميل السيارات، زيارات بيع وتحصيل نقدي وتحويل وشيك، مرتجع، أوامر توريد (مسلم وقيد الانتظار)،
--   زيارات بلا شراء، تسوية اليوم واعتمادها، العمولات ومستحقات العاملين الميدانيين
--   sqlplus NOONA_APP@... @demo/demo_distribution.sql <مسؤول المؤسسة>
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE
COLUMN 1 NEW_VALUE 1 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
DEFINE ADMIN_USER = '&1'
DECLARE
  c_admin CONSTANT VARCHAR2(100) := NVL(UPPER(TRIM('&ADMIN_USER')), 'ADMIN');
  TYPE t_num IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  TYPE t_str IS TABLE OF VARCHAR2(400) INDEX BY PLS_INTEGER;
  l_co NUMBER; l_n NUMBER; l_x NUMBER; l_wh NUMBER; l_role NUMBER; l_mem NUMBER;
  l_rep t_num; l_rt t_num; l_shop t_num; l_it t_num; l_emp t_num; l_inv t_num;
  l_rname t_str; l_ruser t_str; l_rtname t_str;
  l_v NUMBER; l_c NUMBER; l_ord NUMBER; l_st NUMBER; l_ln NUMBER; l_k PLS_INTEGER := 0; l_lines VARCHAR2(4000);
  PROCEDURE login(p_user VARCHAR2) IS
  BEGIN
    NOONA_APEX_PKG.cleanup_request;
    NOONA_APEX_PKG.post_auth(p_user, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  END login;
  -- المندوب الحالي للتطبيق الميداني: المسؤول ينفذ زيارات كل مندوب بالتناوب ثم تربط المستخدمات الفعلية في النهاية
  PROCEDURE act_as(p_i PLS_INTEGER) IS
  BEGIN
    UPDATE dst_rep SET user_name = NULL WHERE company_id = l_co AND user_name = c_admin;
    UPDATE dst_rep SET user_name = c_admin WHERE id = l_rep(p_i);
  END act_as;
  FUNCTION lines(p_q1 NUMBER, p_q2 NUMBER, p_q3 NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN '[{"i":' || l_it(1) || ',"q":' || p_q1 || '},{"i":' || l_it(2) || ',"q":' || p_q2 || '},{"i":' || l_it(3) || ',"q":' || p_q3 || '}]';
  END lines;
BEGIN
  login(c_admin);
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  SELECT COUNT(*) INTO l_n FROM dst_rep WHERE company_id = l_co;
  IF l_n > 0 THEN DBMS_OUTPUT.PUT_LINE('بيانات التوزيع التجريبية محملة سابقاً - لم يضف شيء.'); RETURN; END IF;
  IF NOONA_SAL_PKG.is_ready = 'N' THEN l_n := NOONA_SAL_PKG.quick_setup; END IF;
  l_n := NOONA_DST_PKG.quick_setup;
  l_wh := NOONA_INV_PKG.default_warehouse;

  -- أصناف التوزيع: أصناف قابلة للبيع بسعر، ويضاف لها رصيد كاف في المستودع الرئيسي
  FOR r IN (SELECT i.id FROM inv_item i
             WHERE i.is_sellable = 'Y' AND i.status_code = 'ACTIVE' AND i.item_type IN ('STOCK', 'FINISHED_GOOD')
               AND i.tracking_mode = 'NONE' ORDER BY i.id) LOOP
    EXIT WHEN l_k = 3;
    DECLARE l_p NUMBER; l_inc VARCHAR2(1); l_tc NUMBER; l_net NUMBER; l_tx NUMBER;
    BEGIN
      NOONA_SAL_PKG.price_line(r.id, 1, l_p, 0, l_inc, l_tc, TRUNC(SYSDATE), l_net, l_tx);
      IF NVL(l_net, 0) > 0 THEN l_k := l_k + 1; l_it(l_k) := r.id; END IF;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END LOOP;
  WHILE l_k < 3 LOOP
    l_k := l_k + 1;
    l_it(l_k) := NOONA_INV_PKG.save_item('{"name":"' || CASE l_k WHEN 1 THEN 'مياه معدنية 330 مل (كرتون 40)' WHEN 2 THEN 'عصير برتقال 200 مل (كرتون 24)'
                 ELSE 'بسكويت بالتمر (كرتون 48)' END || '","code":"DST-' || l_k || '","price":' || CASE l_k WHEN 1 THEN 18 WHEN 2 THEN 36 ELSE 42 END
                 || ',"incl":"Y"}');
  END LOOP;
  l_lines := NULL;
  FOR i IN 1 .. 3 LOOP
    l_lines := l_lines || CASE WHEN i > 1 THEN ',' END || '{"i":' || l_it(i) || ',"q":400,"c":' || (8 + i * 4) || '}';
  END LOOP;
  l_n := NOONA_INV_PKG.save_stock_doc('{"id":null,"type":"ADJ_IN","date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '","wh":' || l_wh
        || ',"reason":"COUNT","action":"POST","lines":[' || l_lines || ']}');

  -- المندوبون: موظفون من الموارد البشرية (إن وجدوا) ومستخدمون للتطبيق الميداني بدور المندوب
  l_rname(1) := 'سعد العتيبي'; l_rname(2) := 'ماجد القحطاني'; l_rname(3) := 'فيصل الشمري';
  l_ruser(1) := 'DEMO_REP1'; l_ruser(2) := 'DEMO_REP2'; l_ruser(3) := 'DEMO_REP3';
  l_rtname(1) := 'خط العليا والملز'; l_rtname(2) := 'خط النسيم والروضة'; l_rtname(3) := 'خط الشفا والعزيزية';
  l_k := 0;
  FOR r IN (SELECT e.id FROM hr_employee e WHERE e.status_code = 'ACTIVE' AND NOONA_WRK_PKG.employment_of(e.id) IS NOT NULL ORDER BY e.id DESC) LOOP
    EXIT WHEN l_k = 3;
    l_k := l_k + 1; l_emp(l_k) := r.id;
  END LOOP;
  SELECT MIN(id) INTO l_role FROM sec_role WHERE code = 'DEMO_DST_REP';
  IF l_role IS NULL THEN
    l_role := NOONA_SEC_ADMIN_PKG.create_role('DEMO_DST_REP', 'مندوب مبيعات ميداني (تجريبي)');
    l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'DST', 'VIEW,CREATE,UPDATE');
    l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'SAL', 'VIEW,CREATE');
  END IF;
  FOR i IN 1 .. 3 LOOP
    SELECT MIN(m.id) INTO l_mem FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id WHERE u.username = l_ruser(i);
    IF l_mem IS NULL THEN
      l_mem := NOONA_SEC_ADMIN_PKG.create_user(l_ruser(i), l_rname(i) || ' (مندوب)', LOWER(REPLACE(l_ruser(i), '_', '.')) || '@noona.local', l_co);
    END IF;
    BEGIN l_n := NOONA_SEC_ADMIN_PKG.grant_role(l_mem, l_role, l_co, 'بيانات تجريبية'); EXCEPTION WHEN OTHERS THEN NULL; END;
    l_rep(i) := NOONA_DST_PKG.save_rep('{"code":"REP-0' || i || '","name":"' || l_rname(i) || '","phone":"05' || (50000000 + i * 1111111)
             || '","basis":"' || CASE i WHEN 3 THEN 'COLLECTION' ELSE 'SALES' END || '","rate":' || CASE i WHEN 1 THEN 2 WHEN 2 THEN 2.5 ELSE 1.5 END
             || ',"target":' || (60000 + i * 15000) || '}');
    UPDATE dst_rep SET vehicle_plate = 'أ ب ج ' || (4410 + i) WHERE id = l_rep(i);
    IF l_emp.EXISTS(i) THEN
      BEGIN NOONA_WRK_PKG.set_worker('REP', l_rep(i), l_emp(i), CASE i WHEN 3 THEN 'CASH' ELSE 'PAYROLL' END);
      EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('تنبيه ربط الموظف: ' || SQLERRM); END;
    END IF;
    l_rt(i) := NOONA_DST_PKG.save_route('{"code":"RT-0' || i || '","name":"' || l_rtname(i) || '","rep":' || l_rep(i)
             || ',"region":"الرياض","days":"' || CASE i WHEN 1 THEN 'SUN,MON,TUE,WED,THU,FRI,SAT' WHEN 2 THEN 'SUN,TUE,THU,SAT' ELSE 'MON,WED,SAT' END || '"}');
  END LOOP;

  -- المحلات: أربعة على كل خط بمواقعها (يترك محل بلا موقع ليحفظ في أول زيارة)
  DECLARE
    TYPE t_s IS TABLE OF VARCHAR2(200);
    n t_s := t_s('بقالة النور', 'سوبرماركت الفجر', 'تموينات الريان', 'ميني ماركت السلام',
                 'بقالة الياسمين', 'أسواق الوفاء', 'تموينات البركة', 'بقالة الأمل',
                 'سوبرماركت الشفا', 'تموينات الهدى', 'بقالة الخير', 'أسواق المدينة');
    t t_s := t_s('GROCERY', 'SUPERMARKET', 'KIOSK', 'CAFE');
  BEGIN
    FOR i IN 1 .. 12 LOOP
      l_shop(i) := NOONA_DST_PKG.save_shop('{"name":"' || n(i) || '","owner":"' || CASE MOD(i, 3) WHEN 0 THEN 'أبو خالد' WHEN 1 THEN 'أبو محمد' ELSE 'أبو فهد' END
                 || '","phone":"05' || (10000000 + i * 734521) || '","type":"' || t(MOD(i - 1, 4) + 1) || '","route":' || l_rt(CEIL(i / 4))
                 || ',"landmark":"' || CASE MOD(i, 2) WHEN 0 THEN 'بجوار مسجد الحي' ELSE 'على الشارع العام' END || '"'
                 || CASE WHEN i <> 4 THEN ',"lat":' || TO_CHAR(24.65 + CEIL(i / 4) * 0.03 + MOD(i, 4) * 0.004, 'FM90.0000')
                    || ',"lng":' || TO_CHAR(46.66 + CEIL(i / 4) * 0.02 + MOD(i, 4) * 0.005, 'FM90.0000') END || '}');
    END LOOP;
  END;

  -- يوم كل مندوب: تحميل السيارة ثم زيارات بيع وتحصيل وبلا شراء ومرتجع وأمر توريد ثم التسوية
  FOR r IN 1 .. 3 LOOP
    act_as(r);
    l_x := NOONA_DST_PKG.load_van('{"rep":' || l_rep(r) || ',"direction":"LOAD","wh":' || l_wh || ',"lines":' || lines(60, 40, 30) || '}');
    -- المحل الأول: بيع ونقد
    l_v := NOONA_DST_PKG.start_visit('{"shop":' || l_shop((r - 1) * 4 + 1) || ',"lat":' || TO_CHAR(24.65 + r * 0.03 + 0.004, 'FM90.0000')
         || ',"lng":' || TO_CHAR(46.66 + r * 0.02 + 0.005, 'FM90.0000') || '}');
    l_inv(r) := NOONA_DST_PKG.visit_sale('{"visit":' || l_v || ',"lines":' || lines(10, 6, 4) || ',"pay":{"method":"CASH","amount":300}}');
    NOONA_DST_PKG.close_visit(l_v, NULL, 'تم العرض على الرف الأمامي');
    -- المحل الثاني: بيع آجل جزئي وتحويل بنكي مؤكد وشيك
    l_v := NOONA_DST_PKG.start_visit('{"shop":' || l_shop((r - 1) * 4 + 2) || '}');
    l_x := NOONA_DST_PKG.visit_sale('{"visit":' || l_v || ',"lines":' || lines(15, 10, 8) || '}');
    l_c := NOONA_DST_PKG.collect('{"visit":' || l_v || ',"amount":250,"method":"BANK_TRANSFER","ref":"TRF-' || r || TO_CHAR(SYSDATE, 'MMDD')
         || '","bank":"مصرف الراجحي","invoice":' || l_x || '}');
    NOONA_DST_PKG.verify_collection(l_c);
    l_c := NOONA_DST_PKG.collect('{"visit":' || l_v || ',"amount":150,"method":"CHEQUE","ref":"CHQ-' || r || '0071","bank":"البنك الأهلي","chequeDate":"'
         || TO_CHAR(SYSDATE + 20, 'YYYY-MM-DD') || '"}');
    NOONA_DST_PKG.close_visit(l_v);
    -- المحل الثالث: بلا شراء بسبب (والثاني في الخط الثاني: المحل مغلق)
    l_v := NOONA_DST_PKG.start_visit('{"shop":' || l_shop((r - 1) * 4 + 3) || '}');
    NOONA_DST_PKG.close_visit(l_v, CASE r WHEN 2 THEN 'CLOSED' ELSE 'STOCKED' END, 'يكفيه المخزون حتى الأسبوع القادم');
    -- المحل الرابع: أول زيارة تحفظ موقعه، تحويل ينتظر التأكيد، وأمر توريد
    l_v := NOONA_DST_PKG.start_visit('{"shop":' || l_shop(r * 4) || ',"lat":' || TO_CHAR(24.66 + r * 0.03, 'FM90.0000')
         || ',"lng":' || TO_CHAR(46.67 + r * 0.02, 'FM90.0000') || '}');
    l_x := NOONA_DST_PKG.visit_sale('{"visit":' || l_v || ',"lines":' || lines(5, 5, 2) || '}');
    l_c := NOONA_DST_PKG.collect('{"visit":' || l_v || ',"amount":120,"method":"BANK_TRANSFER","ref":"TRF-P' || r || TO_CHAR(SYSDATE, 'MMDD')
         || '","bank":"بنك الرياض","invoice":' || l_x || '}');
    l_ord := NOONA_DST_PKG.place_order('{"visit":' || l_v || ',"date":"' || TO_CHAR(SYSDATE + 2, 'YYYY-MM-DD') || '","lines":' || lines(20, 12, 10) || '}');
    NOONA_DST_PKG.close_visit(l_v);
    -- مرتجع على فاتورة المحل الأول وأمر يسلم من المستودع
    l_v := NOONA_DST_PKG.start_visit('{"shop":' || l_shop((r - 1) * 4 + 1) || '}');
    SELECT MIN(id) INTO l_ln FROM sal_invoice_line WHERE invoice_id = l_inv(r);
    l_x := NOONA_DST_PKG.visit_return('{"visit":' || l_v || ',"invoice":' || l_inv(r) || ',"reason":"عبوات تالفة","lines":[{"l":' || l_ln || ',"q":1}]}');
    l_x := NOONA_DST_PKG.place_order('{"visit":' || l_v || ',"date":"' || TO_CHAR(SYSDATE + 1, 'YYYY-MM-DD') || '","lines":' || lines(8, 4, 4) || '}');
    NOONA_DST_PKG.close_visit(l_v);
    IF r <> 3 THEN l_x := NOONA_DST_PKG.deliver_order(l_x); END IF;
    -- تسوية اليوم (المندوب الثاني بعجز 20 يبقى في عهدته، والثالث لم يسلم بعد)
    IF r < 3 THEN
      l_st := NOONA_DST_PKG.settle_day('{"rep":' || l_rep(r) || ',"counted":' || CASE r WHEN 1 THEN 300 ELSE 280 END || '}');
      IF r = 1 THEN NOONA_DST_PKG.approve_settlement(l_st); END IF;
    END IF;
    -- تفريغ جزء من بضاعة السيارة للمستودع
    IF r = 1 THEN
      l_x := NOONA_DST_PKG.load_van('{"rep":' || l_rep(r) || ',"direction":"UNLOAD","wh":' || l_wh || ',"lines":' || lines(10, 5, 5) || '}');
    END IF;
  END LOOP;
  UPDATE dst_rep SET user_name = NULL WHERE company_id = l_co AND user_name = c_admin;
  FOR i IN 1 .. 3 LOOP
    UPDATE dst_rep SET user_name = l_ruser(i) WHERE id = l_rep(i);
  END LOOP;
  l_n := NOONA_DST_PKG.calc_commissions(SYSDATE);
  BEGIN l_n := NOONA_WRK_PKG.collect(TRUNC(SYSDATE, 'MM'));
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('تنبيه المستحقات: ' || SQLERRM); END;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('التوزيع: 3 مندوبين و3 خطوط و12 محلاً، 15 زيارة ببيع وتحصيل نقدي وتحويل وشيك ومرتجع وأوامر توريد وتسويات وعمولات');
  DBMS_OUTPUT.PUT_LINE('تم تحميل بيانات التوزيع التجريبية. افتح «التوزيع والمبيعات الميدانية».');
  NOONA_APEX_PKG.cleanup_request;
END;
/
EXIT
