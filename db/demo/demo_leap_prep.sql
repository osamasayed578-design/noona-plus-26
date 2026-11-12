-- =============================================================================
-- NOONA PLUS ERP | تجهيز عرض المعرض (يعاد تشغيله قبل كل عرض - لا يكرر بيانات)
--   يجهز شركة التوزيع لمسار العرض الثابت بحساب مسؤول المؤسسة:
--   * يربط المندوب الأول بمسؤول المؤسسة (ليظهر «يومي» على جواله)، ويبقي حسابات بقية المندوبين كما هي
--   * يغلق أي زيارة مفتوحة للمندوب، ويحمّل سيارته إن قل رصيدها عن حاجة العرض
--   * يتأكد أن أول محل في خط سيره له موقع ورصيد ائتماني يسمح بالبيع
--   sqlplus NOONA_APP@... @demo/demo_leap_prep.sql <مسؤول مؤسسة التوزيع>
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
  l_co NUMBER; l_rep NUMBER; l_van NUMBER; l_wh NUMBER; l_shop NUMBER; l_x NUMBER; l_n PLS_INTEGER := 0;
  l_lines VARCHAR2(4000); l_name VARCHAR2(200); l_sname VARCHAR2(200);
BEGIN
  NOONA_APEX_PKG.cleanup_request;
  NOONA_APEX_PKG.post_auth(c_admin, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  SELECT MIN(id) INTO l_rep FROM dst_rep WHERE company_id = l_co AND status_code = 'ACTIVE';
  IF l_rep IS NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'لا يوجد مندوب: شغّل بيانات التوزيع (demo_distribution.sql) أولاً');
  END IF;
  -- المندوب الأول على جوال مسؤول المؤسسة
  UPDATE dst_rep SET user_name = NULL WHERE company_id = l_co AND user_name = c_admin AND id <> l_rep;
  UPDATE dst_rep SET user_name = c_admin WHERE id = l_rep;
  SELECT full_name, van_warehouse_id INTO l_name, l_van FROM dst_rep WHERE id = l_rep;
  -- لا زيارة مفتوحة تمنع بدء زيارة العرض
  FOR v IN (SELECT id FROM dst_visit WHERE rep_id = l_rep AND status_code = 'OPEN') LOOP
    BEGIN NOONA_DST_PKG.close_visit(v.id, 'OTHER', 'أغلقت لتجهيز العرض');
    EXCEPTION WHEN OTHERS THEN UPDATE dst_visit SET status_code = 'CLOSED', checkout_at = SYSTIMESTAMP WHERE id = v.id; END;
  END LOOP;
  -- رصيد السيارة: كل صنف فيها أقل من 20 يحمّل له 40 من المستودع الرئيسي (ويضاف للمستودع إن نقص)
  l_wh := NOONA_INV_PKG.default_warehouse;
  FOR i IN (SELECT DISTINCT o.item_id FROM inv_onhand o WHERE o.warehouse_id = l_van) LOOP
    IF NOONA_INV_PKG.on_hand(i.item_id, l_van) < 20 THEN
      IF NOONA_INV_PKG.on_hand(i.item_id, l_wh) < 40 THEN
        l_x := NOONA_INV_PKG.save_stock_doc('{"id":null,"type":"ADJ_IN","date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '","wh":' || l_wh
            || ',"reason":"COUNT","action":"POST","lines":[{"i":' || i.item_id || ',"q":200,"c":10}]}');
      END IF;
      l_lines := l_lines || CASE WHEN l_lines IS NOT NULL THEN ',' END || '{"i":' || i.item_id || ',"q":40}';
      l_n := l_n + 1;
    END IF;
  END LOOP;
  IF l_lines IS NOT NULL THEN
    l_x := NOONA_DST_PKG.load_van('{"rep":' || l_rep || ',"direction":"LOAD","wh":' || l_wh || ',"lines":[' || l_lines || ']}');
  END IF;
  -- محل العرض: أول محل في خط سير المندوب، بموقع وحد ائتماني واسع
  SELECT MIN(s.id) KEEP (DENSE_RANK FIRST ORDER BY s.route_seq, s.id) INTO l_shop
    FROM dst_shop s JOIN dst_route r ON r.id = s.route_id WHERE r.rep_id = l_rep AND s.status_code = 'ACTIVE';
  IF l_shop IS NOT NULL THEN
    UPDATE dst_shop SET latitude = NVL(latitude, 24.7136), longitude = NVL(longitude, 46.6753) WHERE id = l_shop;
    l_sname := NOONA_DST_PKG.shop_label(l_shop);
  END IF;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('LEAP_OK المندوب: ' || l_name || ' (على حساب ' || c_admin || ')، محل العرض: ' || l_sname || '، أصناف حمّلت للسيارة: ' || l_n);
  NOONA_APEX_PKG.cleanup_request;
END;
/
EXIT
