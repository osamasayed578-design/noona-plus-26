-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية لسنتين سابقتين (2024 و2025) وأشهر 2026 قبل بدء العمل للمقارنة في كل الموديولات
--   * يفتح السنتين الماليتين السابقتين ويرحل قيداً ملخصاً لكل شهر (نتائج النظام السابق) بالإيرادات والمصروفات
--     بموسمية ونمو سنوي، فتظهر مقارنة السنوات في القوائم المالية والتحليلات
--   * أرقام شهرية للموديولات (المبيعات ونقاط البيع والمشتريات والرواتب والتصنيع والمستشفى والسيارات والفندق
--     والعقارات والمطاعم والنقل) في «أرقام السنوات السابقة» (BI_HISTORY_VALUE) بمصدر «ترحيل»
--   يعاد تشغيله بأمان: القيود لا تتكرر، والأرقام الشهرية تستبدل
--   sqlplus NOONA_APP@//host:1521/PDB @demo/demo_history.sql <username>
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON
DECLARE
  c_admin CONSTANT VARCHAR2(128) := '&1';
  TYPE t_vals IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  -- موسمية شهرية (رمضان والأعياد ونهاية السنة أعلى، الصيف أهدأ)
  TYPE t_12 IS VARRAY(12) OF NUMBER;
  c_season CONSTANT t_12 := t_12(0.93, 0.95, 1.07, 1.14, 1.03, 0.90, 0.87, 0.94, 1.00, 1.03, 1.06, 1.12);
  l_n     NUMBER;
  l_min   DATE;
  l_fy    NUMBER;
  l_j     NUMBER;
  l_ids   SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();
  l_lines VARCHAR2(4000);
  l_rev   NUMBER;
  l_exp   NUMBER;

  PROCEDURE login(p_user VARCHAR2) IS
  BEGIN
    NOONA_APEX_PKG.cleanup_request;
    NOONA_APEX_PKG.post_auth(p_user, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  END login;
  -- معامل الشهر: نمو السنة × موسمية الشهر × نمو خفيف داخل السنة × تذبذب ثابت (يتكرر الناتج نفسه عند إعادة التشغيل)
  FUNCTION f(p_y NUMBER, p_m NUMBER, p_key NUMBER, p_season BOOLEAN DEFAULT TRUE) RETURN NUMBER IS
  BEGIN
    RETURN CASE p_y WHEN 2024 THEN 0.80 WHEN 2025 THEN 0.91 ELSE 1.0 END
         * CASE WHEN p_season THEN c_season(p_m) ELSE 1 END
         * (1 + (p_m - 6) * 0.004)
         * (1 + (MOD(p_y * 37 + p_m * 91 + p_key * 53, 9) - 4) / 100);
  END f;
  FUNCTION amt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(ROUND(p, 2), 'FM9999999990.00', 'NLS_NUMERIC_CHARACTERS=''.,''');
  END amt;
  -- حسابات الشركة الموجودة فعلاً (موديول غير مجهز في الشركة = حسابه غير موجود فيتجاهل)
  FUNCTION has_acc(p_acc VARCHAR2) RETURN BOOLEAN IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM gl_account a JOIN gl_ledger g ON g.coa_id = a.coa_id
     WHERE g.id = NOONA_GL_PKG.primary_ledger AND a.account_code = p_acc AND a.is_postable = 'Y' AND a.allow_manual_posting = 'Y';
    RETURN l > 0;
  END has_acc;
  PROCEDURE cr(p_acc VARCHAR2, p NUMBER) IS
  BEGIN
    IF NOT has_acc(p_acc) THEN RETURN; END IF;
    l_lines := l_lines || CASE WHEN l_lines IS NOT NULL THEN ',' END || '{"a":"' || p_acc || '","c":' || amt(p) || '}';
    l_rev := l_rev + ROUND(p, 2);
  END cr;
  PROCEDURE dr(p_acc VARCHAR2, p NUMBER) IS
  BEGIN
    IF NOT has_acc(p_acc) THEN RETURN; END IF;
    l_lines := l_lines || CASE WHEN l_lines IS NOT NULL THEN ',' END || '{"a":"' || p_acc || '","d":' || amt(p) || '}';
    l_exp := l_exp + ROUND(p, 2);
  END dr;
  -- قاعدة الأرشفة في الشركة قد تشترط مرجعاً ورقياً (أو صورة) قبل اعتماد القيد: يسجل رقم الأصل في النظام السابق،
  -- وإن اشترطت القاعدة ملفاً يرفق ملف نصي بملخص القيد
  PROCEDURE paper_ref(p_journal NUMBER, p_y NUMBER, p_m NUMBER) IS
    l_doc NUMBER;
    -- صفحة PDF صغيرة (قاعدة الأرشفة تقبل PDF والصور ومستندات Office فقط)
    c_pdf CONSTANT RAW(2000) := HEXTORAW('255044462D312E340A312030206F626A3C3C2F547970652F436174616C6F672F50616765732032203020523E3E656E646F626A0A322030206F626A3C3C2F547970652F50616765732F4B6964735B33203020525D2F436F756E7420313E3E656E646F626A' || '0A332030206F626A3C3C2F547970652F506167652F506172656E742032203020522F4D65646961426F785B30203020353935203834325D2F436F6E74656E74732034203020522F5265736F75726365733C3C2F466F6E743C3C2F46312035203020523E3E' || '3E3E3E3E656E646F626A0A342030206F626A3C3C2F4C656E6774682036303E3E73747265616D0A4254202F46312031342054662036302037383020546420284E4F4F4E4120504C5553202D206C6567616379206D6F6E74686C792073756D6D6172792920' || '546A2045540A656E6473747265616D20656E646F626A0A352030206F626A3C3C2F547970652F466F6E742F537562747970652F54797065312F42617365466F6E742F48656C7665746963613E3E656E646F626A0A747261696C65723C3C2F526F6F742031' || '203020523E3E0A2525454F460A');
    l_ref VARCHAR2(30) := 'LEGACY-' || p_y || LPAD(p_m, 2, '0');
    l_dt  DATE := LAST_DAY(TO_DATE(p_y || '-' || p_m || '-01', 'YYYY-MM-DD'));
  BEGIN
    IF NOONA_DMS_PKG.has_reference('GL_JOURNAL', p_journal) = 'Y' THEN RETURN; END IF;
    l_doc := NOONA_DMS_PKG.archive_document('GL_JOURNAL', p_journal, NULL, 'قيد ملخص ' || l_ref || ' من النظام السابق', l_ref,
                                            'أرشيف النظام السابق', l_dt);
    IF NOONA_DMS_PKG.has_reference('GL_JOURNAL', p_journal) = 'N' THEN
      l_doc := NOONA_DMS_PKG.archive_document('GL_JOURNAL', p_journal, NULL, 'ملخص ' || l_ref, l_ref, 'أرشيف النظام السابق', l_dt,
                                              'ملف ملخص مرفق بالبيانات التجريبية', l_ref || '.pdf', 'application/pdf', c_pdf);
    END IF;
  END paper_ref;
  -- أرقام سنة لمؤشر من دالة شهرية
  PROCEDURE hist(p_metric VARCHAR2, p_y NUMBER, p_v t_vals) IS
    l VARCHAR2(4000) := '[';
    x NUMBER;
    a JSON_ARRAY_T := JSON_OBJECT_T.parse(NOONA_ANL_PKG.history_json(p_metric, p_y)).get_array('months');
  BEGIN
    -- الأشهر التي فيها بيانات فعلية في النظام تترك (لا ازدواج)
    FOR m IN 1 .. 12 LOOP
      l := l || CASE WHEN m > 1 THEN ',' END
        || CASE WHEN p_v.EXISTS(m) AND NOT TREAT(a.get(m - 1) AS JSON_OBJECT_T).get_boolean('locked') THEN amt(p_v(m)) ELSE 'null' END;
    END LOOP;
    x := NOONA_ANL_PKG.save_history(p_metric, p_y, NULL, l || ']', 'LEGACY', 'ترحيل من النظام السابق (بيانات تجريبية)');
  EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  skip ' || p_metric || ' ' || p_y || ': ' || REGEXP_SUBSTR(SQLERRM, 'NOONA-[A-Z]+-[0-9]+: [^' || CHR(10) || ']+'));
  END hist;
BEGIN
  login(c_admin);

  -- ====================================================== السنوات المالية السابقة
  SELECT MIN(start_date) INTO l_min FROM gl_fiscal_year WHERE company_id = NOONA_GL_PKG.company;
  WHILE l_min > DATE '2024-01-01' LOOP
    l_fy := NOONA_GL_PKG.open_previous_year;
    SELECT MIN(start_date) INTO l_min FROM gl_fiscal_year WHERE company_id = NOONA_GL_PKG.company;
    DBMS_OUTPUT.PUT_LINE('opened fiscal year starting ' || TO_CHAR(l_min, 'YYYY-MM-DD'));
  END LOOP;

  -- ====================================================== قيد ملخص لكل شهر من النظام السابق
  -- 2024 و2025 كاملتين، و2026 حتى سبتمبر (بدء العمل على نونا في أكتوبر 2026)
  FOR y IN 2024 .. 2026 LOOP
      FOR m IN 1 .. CASE y WHEN 2026 THEN 9 ELSE 12 END LOOP
        SELECT COUNT(*) INTO l_n FROM gl_journal WHERE company_id = NOONA_GL_PKG.company AND reference_no = 'LEGACY-' || y || LPAD(m, 2, '0')
           AND status_code NOT IN ('CANCELLED');
        CONTINUE WHEN l_n > 0;
        l_lines := NULL; l_rev := 0; l_exp := 0;
        cr('4101', 430000 * f(y, m, 1));                 -- المبيعات
        cr('4110', 96000 * f(y, m, 2));                  -- الإيواء
        cr('4120', 142000 * f(y, m, 3, FALSE));          -- الكشوفات
        cr('4121', 38000 * f(y, m, 4, FALSE));           -- المختبرات
        cr('4126', 52000 * f(y, m, 5, FALSE));           -- الأدوية
        cr('4130', 180000 * f(y, m, 6, FALSE));          -- المشروعات
        cr('4150', 61000 * (CASE y WHEN 2024 THEN 0.92 WHEN 2025 THEN 1 ELSE 1.06 END)); -- الإيجارات (ثابتة)
        cr('4160', 46000 * f(y, m, 7));                  -- خدمة السيارات
        cr('4170', 124000 * f(y, m, 8));                 -- النقل والشحن
        dr('5101', 430000 * f(y, m, 1) * 0.63);          -- تكلفة المبيعات
        dr('5150', 180000 * f(y, m, 6, FALSE) * 0.72);   -- تكاليف المشروعات
        dr('5201', CASE y WHEN 2024 THEN 196000 WHEN 2025 THEN 214000 ELSE 229000 END * (1 + (m - 1) * 0.003)); -- الرواتب
        dr('5214', CASE y WHEN 2024 THEN 17600 WHEN 2025 THEN 19300 ELSE 20600 END);   -- التأمينات
        dr('5202', 35000);                               -- الإيجارات
        dr('5203', 11000 + 6000 * CASE WHEN m BETWEEN 6 AND 9 THEN 1 ELSE 0 END); -- الكهرباء (الصيف أعلى)
        dr('5204', 4200);
        dr('5205', 9000 * f(y, m, 9, FALSE));
        dr('5206', CASE y WHEN 2024 THEN 14800 WHEN 2025 THEN 15900 ELSE 16400 END);   -- الإهلاك
        dr('5208', 12500 * c_season(m));                 -- الدعاية
        dr('5220', 142000 * f(y, m, 3, FALSE) * 0.17);   -- عمولات الأطباء
        dr('523001', 124000 * f(y, m, 8) * 0.24);        -- وقود الشاحنات
        dr('5302', 6100 * f(y, m, 10));
        -- الصافي إلى البنك (ربح) أو منه (خسارة)
        IF l_rev >= l_exp THEN
          l_lines := l_lines || ',{"a":"1102","d":' || amt(l_rev - l_exp) || '}';
        ELSE
          l_lines := l_lines || ',{"a":"1102","c":' || amt(l_exp - l_rev) || '}';
        END IF;
        l_j := NOONA_GL_PKG.save_journal_doc('{"id":null,"type":"GENERAL","date":"' || TO_CHAR(LAST_DAY(TO_DATE(y || '-' || m || '-01', 'YYYY-MM-DD')), 'YYYY-MM-DD')
          || '","desc":"نتائج شهر ' || y || '-' || LPAD(m, 2, '0') || ' من النظام السابق (قيد ملخص)","ref":"LEGACY-' || y || LPAD(m, 2, '0')
          || '","action":"SUBMIT","lines":[' || l_lines || ']}');
        l_ids.EXTEND; l_ids(l_ids.COUNT) := l_j;
        paper_ref(l_j, y, m);
      END LOOP;
  END LOOP;
  IF l_ids.COUNT > 0 THEN
    login('DEMO_APPROVER');
    FOR i IN 1 .. l_ids.COUNT LOOP
      NOONA_GL_PKG.approve_journal(l_ids(i), 'مطابق لميزان النظام السابق');
    END LOOP;
    login(c_admin);
  END IF;
  DBMS_OUTPUT.PUT_LINE('posted ' || l_ids.COUNT || ' monthly legacy journals');

  -- ====================================================== أرقام الموديولات للسنتين
  FOR y IN 2024 .. 2026 LOOP
    DECLARE
      v t_vals;
      -- 2026: حتى سبتمبر فقط (الأشهر التي فيها بيانات فعلية تترك تلقائياً)
      PROCEDURE put(p_metric VARCHAR2) IS
      BEGIN
        IF y = 2026 THEN FOR m IN 10 .. 12 LOOP v.DELETE(m); END LOOP; END IF;
        hist(p_metric, y, v); v.DELETE;
      END put;
    BEGIN
      FOR m IN 1 .. 12 LOOP v(m) := 430000 * f(y, m, 1) * 0.68 * 1.15; END LOOP; put('SALES_INVOICED');   -- الفواتير شاملة الضريبة
      FOR m IN 1 .. 12 LOOP v(m) := 430000 * f(y, m, 1) * 0.32 * 1.15; END LOOP; put('POS_SALES');
      FOR m IN 1 .. 12 LOOP v(m) := ROUND(430000 * f(y, m, 1) * 0.32 * 1.15 / 86); END LOOP; put('POS_TICKETS');
      FOR m IN 1 .. 12 LOOP v(m) := 430000 * f(y, m + 1 - TRUNC(m / 12) * 12, 1) * 0.63 * 1.08 * 1.15; END LOOP; put('PURCHASES'); -- شراء قبل البيع بشهر
      FOR m IN 1 .. 12 LOOP v(m) := (CASE y WHEN 2024 THEN 196000 WHEN 2025 THEN 214000 ELSE 229000 END * (1 + (m - 1) * 0.003)) + CASE y WHEN 2024 THEN 17600 WHEN 2025 THEN 19300 ELSE 20600 END; END LOOP;
      put('PAYROLL_COST');
      FOR m IN 1 .. 12 LOOP v(m) := MOD(y + m * 7, 4) + CASE WHEN m IN (1, 9) THEN 3 ELSE 1 END; END LOOP; put('HIRES');
      FOR m IN 1 .. 12 LOOP v(m) := ROUND(1500 * f(y, m, 11)); END LOOP; put('PRODUCTION_QTY');
      FOR m IN 1 .. 12 LOOP v(m) := ROUND(11 * f(y, m, 12)); END LOOP; put('PRODUCTION_ORDERS');
      FOR m IN 1 .. 12 LOOP v(m) := ROUND(1850 * f(y, m, 3, FALSE) * CASE WHEN m IN (1, 2, 12) THEN 1.12 ELSE 1 END); END LOOP; put('HIS_VISITS'); -- الشتاء أعلى
      FOR m IN 1 .. 12 LOOP v(m) := (142000 * f(y, m, 3, FALSE) + 38000 * f(y, m, 4, FALSE) + 52000 * f(y, m, 5, FALSE)) * 1.0; END LOOP; put('HIS_REVENUE');
      FOR m IN 1 .. 12 LOOP v(m) := ROUND(140 * f(y, m, 7)); END LOOP; put('AUT_JOBS');
      FOR m IN 1 .. 12 LOOP v(m) := 46000 * f(y, m, 7) * 1.15; END LOOP; put('AUT_REVENUE');
      FOR m IN 1 .. 12 LOOP v(m) := ROUND(410 * f(y, m, 2) * CASE WHEN m IN (4, 6, 12) THEN 1.18 ELSE 1 END); END LOOP; put('HOTEL_CHECKINS');
      FOR m IN 1 .. 12 LOOP v(m) := CASE WHEN MOD(m, 3) = 0 THEN 1250000 * f(y, m, 13, FALSE) WHEN MOD(m, 4) = 1 THEN 640000 * f(y, m, 14, FALSE) ELSE 0 END; END LOOP;
      put('RE_SALES');
      FOR m IN 1 .. 12 LOOP v(m) := 185000 * f(y, m, 15) * CASE WHEN m IN (3, 4) THEN 1.2 ELSE 1 END; END LOOP; put('RST_SALES');
      FOR m IN 1 .. 12 LOOP v(m) := 124000 * f(y, m, 8) * 1.15; END LOOP; put('TRN_REVENUE');
      FOR m IN 1 .. 12 LOOP v(m) := ROUND(124000 * f(y, m, 8) / 39); END LOOP; put('TRN_TONNAGE');
      FOR m IN 1 .. 12 LOOP v(m) := ROUND(124000 * f(y, m, 8) / 39 / 23); END LOOP; put('TRN_TRIPS');
      FOR m IN 1 .. 12 LOOP v(m) := ROUND(124000 * f(y, m, 8) / 39 / 23 * 545); END LOOP; put('TRN_DISTANCE');
      FOR m IN 1 .. 12 LOOP v(m) := 2 + MOD(y * 3 + m * 5, 4) + CASE WHEN m BETWEEN 6 AND 8 THEN 2 ELSE 0 END; END LOOP; put('TRN_INCIDENTS'); -- الحرارة صيفاً
    END;
  END LOOP;
  SELECT COUNT(*) INTO l_n FROM bi_history_value WHERE company_id = NOONA_ANL_PKG.company;
  DBMS_OUTPUT.PUT_LINE('prior-year monthly figures: ' || l_n);
  COMMIT;
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  NOONA_APEX_PKG.cleanup_request;
END;
/
EXIT
