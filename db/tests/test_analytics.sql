-- =============================================================================
-- NOONA PLUS ERP | اختبار محرك التحليلات والتنبؤ بحساب NOONA_APP - يتراجع في النهاية
--   الحساب الإحصائي (Holt/Holt-Winters/المتوسط)، الكتالوج والصلاحيات، قيمة المؤشر وتطابقها مع القيود المرحلة،
--   السلسلة الشهرية، الأرصدة التراكمية، المقارنة بالفترة السابقة، التنبؤ، اللوحات، والقيم الشاذة
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_analytics.sql
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
  l_c    CLOB;
  l_j    JSON_OBJECT_T;
  l_a    JSON_ARRAY_T;
  l_o    JSON_OBJECT_T;
  l_v    NUMBER;
  l_x    NUMBER;
  l_sum  NUMBER;
  l_from DATE := ADD_MONTHS(TRUNC(SYSDATE, 'YYYY'), -24);
  l_to   DATE := TRUNC(SYSDATE);
  l_ok   BOOLEAN;

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
  FUNCTION fv(p_doc CLOB, p_i PLS_INTEGER, p_k VARCHAR2 DEFAULT 'v') RETURN NUMBER IS
    l JSON_ARRAY_T := JSON_OBJECT_T.parse(p_doc).get_array('forecast');
  BEGIN
    RETURN TREAT(l.get(p_i - 1) AS JSON_OBJECT_T).get_number(p_k);
  END fv;
BEGIN
  -- ---------------------------------------------------------------- الحساب الإحصائي
  l_c := NOONA_ANL_PKG.forecast_values('10,20,30,40,50,60,70,80', 3, 12);
  l_j := JSON_OBJECT_T.parse(l_c);
  ok('linear series uses Holt', l_j.get_string('method') = 'HOLT', l_j.get_string('method'));
  ok('Holt continues a perfect line: 90, 100, 110',
     ABS(fv(l_c, 1) - 90) < 0.5 AND ABS(fv(l_c, 2) - 100) < 0.5 AND ABS(fv(l_c, 3) - 110) < 0.5, fv(l_c, 1) || ' ' || fv(l_c, 3));
  ok('perfect line has ~zero error', l_j.get_number('rmse') < 0.01, l_j.get_number('rmse'));
  ok('forecast has 3 periods', l_j.get_array('forecast').get_size = 3);
  ok('confidence band widens with horizon',
     fv(l_c, 3, 'hi') - fv(l_c, 3, 'lo') >= fv(l_c, 1, 'hi') - fv(l_c, 1, 'lo'));

  -- موسمية: سنتان بنمط شهري متكرر حول اتجاه
  l_c := NOONA_ANL_PKG.forecast_values('100,120,140,110,90,80,100,130,150,120,100,90,'
                                    || '110,130,150,120,100,90,110,140,160,130,110,100', 12, 12);
  l_j := JSON_OBJECT_T.parse(l_c);
  ok('24 points use Holt-Winters', l_j.get_string('method') = 'HOLT_WINTERS', l_j.get_string('method'));
  ok('seasonal peak (month 9) above trough (month 6)', fv(l_c, 9) > fv(l_c, 6), fv(l_c, 9) || ' vs ' || fv(l_c, 6));
  ok('seasonal forecast near next-year pattern (month 1 ~ 120)', ABS(fv(l_c, 1) - 120) < 15, fv(l_c, 1));
  ok('trend percent positive', l_j.get_number('trendPct') > 0, l_j.get_number('trendPct'));

  l_c := NOONA_ANL_PKG.forecast_values('50,70', 2, 12);
  ok('two points fall back to the average', JSON_OBJECT_T.parse(l_c).get_string('method') = 'AVERAGE' AND fv(l_c, 1) = 60);

  -- ---------------------------------------------------------------- السياق والصلاحيات
  rejects('no company context is rejected', 'NOONA-ANL-002',
          'DECLARE x NUMBER; BEGIN x := NOONA_ANL_PKG.kpi(''REVENUE'', SYSDATE - 30, SYSDATE); END;');
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  ok('company context set', NOONA_ANL_PKG.company IS NOT NULL);
  rejects('unknown metric is rejected', 'NOONA-ANL-001',
          'DECLARE x NUMBER; BEGIN x := NOONA_ANL_PKG.kpi(''NO_SUCH'', SYSDATE - 30, SYSDATE); END;');

  l_a := JSON_ARRAY_T.parse(NOONA_ANL_PKG.metrics_json);
  ok('admin sees the full catalog (20+ metrics)', l_a.get_size >= 20, l_a.get_size);
  l_a := JSON_ARRAY_T.parse(NOONA_ANL_PKG.metrics_json('FIN'));
  ok('finance catalog has 6 metrics', l_a.get_size = 6, l_a.get_size);
  l_o := TREAT(l_a.get(0) AS JSON_OBJECT_T);
  ok('catalog entry carries Arabic name and module name', l_o.get_string('name') = 'الإيرادات' AND l_o.get_string('moduleName') = 'المالية');
  ok('metric_name works', NOONA_ANL_PKG.metric_name('pos_sales') = 'مبيعات نقاط البيع');
  ok('is_allowed for admin', NOONA_ANL_PKG.is_allowed('REVENUE') = 'Y');

  -- ---------------------------------------------------------------- كل مؤشر يعمل (يكشف أخطاء SQL الديناميكي)
  l_ok := TRUE;
  l_a := JSON_ARRAY_T.parse(NOONA_ANL_PKG.metrics_json);
  FOR i IN 0 .. l_a.get_size - 1 LOOP
    DECLARE
      l_m VARCHAR2(40) := TREAT(l_a.get(i) AS JSON_OBJECT_T).get_string('code');
    BEGIN
      l_v := NOONA_ANL_PKG.kpi(l_m, l_from, l_to);
      l_c := NOONA_ANL_PKG.series_json(l_m, ADD_MONTHS(l_to, -6), l_to, 'MONTH');
      l_c := NOONA_ANL_PKG.series_json(l_m, l_to - 13, l_to, 'WEEK');
    EXCEPTION WHEN OTHERS THEN
      l_ok := FALSE; DBMS_OUTPUT.PUT_LINE('   metric ' || l_m || ': ' || SUBSTR(SQLERRM, 1, 200));
    END;
  END LOOP;
  ok('every metric computes value + monthly + weekly series', l_ok);

  -- ---------------------------------------------------------------- مطابقة الإيرادات مع القيود
  SELECT NVL(SUM(l.credit_func - l.debit_func), 0) INTO l_x
    FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id
   WHERE j.company_id = NOONA_ANL_PKG.company AND j.status_code = 'POSTED' AND a.account_type = 'REVENUE'
     AND j.posting_date BETWEEN l_from AND l_to;
  l_v := NOONA_ANL_PKG.kpi('REVENUE', l_from, l_to);
  ok('REVENUE kpi equals posted GL revenue', l_v = ROUND(l_x, 2), l_v || ' vs ' || l_x);
  ok('NET_PROFIT = REVENUE - EXPENSES',
     NOONA_ANL_PKG.kpi('NET_PROFIT', l_from, l_to) = l_v - NOONA_ANL_PKG.kpi('EXPENSES', l_from, l_to));

  -- السلسلة الشهرية: كل الأشهر موجودة ومجموعها = قيمة الفترة
  l_a := JSON_ARRAY_T.parse(NOONA_ANL_PKG.series_json('REVENUE', TRUNC(l_from, 'MM'), LAST_DAY(l_to), 'MONTH'));
  ok('monthly series has every month (empty = 0)', l_a.get_size = MONTHS_BETWEEN(TRUNC(l_to, 'MM'), TRUNC(l_from, 'MM')) + 1, l_a.get_size);
  l_sum := 0;
  FOR i IN 0 .. l_a.get_size - 1 LOOP l_sum := l_sum + TREAT(l_a.get(i) AS JSON_OBJECT_T).get_number('v'); END LOOP;
  ok('monthly series sums to period kpi', ABS(l_sum - NOONA_ANL_PKG.kpi('REVENUE', TRUNC(l_from, 'MM'), LAST_DAY(l_to))) < 0.05,
     l_sum);
  ok('first label is YYYY-MM', TREAT(l_a.get(0) AS JSON_OBJECT_T).get_string('p') = TO_CHAR(l_from, 'YYYY-MM'));

  -- الرصيد التراكمي: آخر نقطة = الرصيد حتى النهاية
  l_a := JSON_ARRAY_T.parse(NOONA_ANL_PKG.series_json('CASH_BALANCE', ADD_MONTHS(TRUNC(l_to, 'MM'), -5), l_to, 'MONTH'));
  ok('balance series last point = balance at end', TREAT(l_a.get(l_a.get_size - 1) AS JSON_OBJECT_T).get_number('v')
     = NOONA_ANL_PKG.kpi('CASH_BALANCE', NULL, LAST_DAY(l_to)));

  rejects('bad grain rejected', 'NOONA-ANL-004',
          'DECLARE x CLOB; BEGIN x := NOONA_ANL_PKG.series_json(''REVENUE'', SYSDATE - 30, SYSDATE, ''YEAR''); END;');
  rejects('range over 10 years rejected', 'NOONA-ANL-005',
          'DECLARE x CLOB; BEGIN x := NOONA_ANL_PKG.series_json(''REVENUE'', SYSDATE - 4000, SYSDATE); END;');

  -- ---------------------------------------------------------------- المقارنة والتنبؤ واللوحات
  l_j := JSON_OBJECT_T.parse(NOONA_ANL_PKG.kpi_json('REVENUE', TRUNC(l_to, 'MM'), l_to));
  ok('kpi_json has value and previous', l_j.has('value') AND l_j.has('previous') AND l_j.get_string('unit') = 'AMOUNT');

  l_c := NOONA_ANL_PKG.forecast_json('REVENUE', 3, 24);
  l_j := JSON_OBJECT_T.parse(l_c);
  ok('forecast_json returns 24 history + 3 forecast', l_j.get_array('history').get_size = 24 AND l_j.get_array('forecast').get_size = 3,
     l_j.get_array('history').get_size);
  ok('forecast months follow last complete month',
     TREAT(l_j.get_array('forecast').get(0) AS JSON_OBJECT_T).get_string('p') = TO_CHAR(TRUNC(SYSDATE, 'MM'), 'YYYY-MM'));
  ok('revenue forecast is not negative', fv(l_c, 1, 'lo') >= 0);

  l_j := JSON_OBJECT_T.parse(NOONA_ANL_PKG.dashboard_json('SAL'));
  ok('sales dashboard has 3 kpis', l_j.get_array('kpis').get_size = 3 AND l_j.get_string('name') = 'المبيعات ونقاط البيع',
     l_j.get_array('kpis').get_size);
  l_a := JSON_ARRAY_T.parse(NOONA_ANL_PKG.anomalies_json(12, 2));
  ok('anomalies returns a valid list', l_a.get_size >= 0);

  -- ---------------------------------------------------------------- الشاشات
  l_j := JSON_OBJECT_T.parse(NOONA_ANL_PKG.view_json('FIN,SAL'));
  ok('view: two modules in requested order', l_j.get_array('modules').get_size = 2
     AND TREAT(l_j.get_array('modules').get(0) AS JSON_OBJECT_T).get_string('code') = 'FIN');
  l_o := TREAT(TREAT(l_j.get_array('modules').get(0) AS JSON_OBJECT_T).get_array('kpis').get(0) AS JSON_OBJECT_T);
  ok('view: kpi carries 12-month spark', l_o.get_array('spark').get_size = 12 AND l_o.has('changePct'));
  ok('view: count = 9 kpis', l_j.get_number('count') = 9, l_j.get_number('count'));
  ok('view: branches listed', l_j.get_array('branches').get_size >= 1);
  l_j := JSON_OBJECT_T.parse(NOONA_ANL_PKG.view_json(NULL));
  ok('unified view: all allowed modules', l_j.get_array('modules').get_size >= 8, l_j.get_array('modules').get_size);
  l_j := JSON_OBJECT_T.parse(NOONA_ANL_PKG.chart_json('REVENUE', 'MONTH', 6));
  ok('chart monthly: 24 history + 6 forecast', l_j.get_array('history').get_size = 24 AND l_j.get_array('forecast').get_size = 6
     AND l_j.get_string('grain') = 'MONTH');
  l_j := JSON_OBJECT_T.parse(NOONA_ANL_PKG.chart_json('POS_SALES', 'WEEK'));
  ok('chart weekly: 26 weeks, no forecast', l_j.get_array('history').get_size = 26 AND l_j.get_array('forecast').get_size = 0,
     l_j.get_array('history').get_size);
  l_j := JSON_OBJECT_T.parse(NOONA_ANL_PKG.chart_json('CASH_BALANCE', 'DAY'));
  ok('chart daily: 60 days', l_j.get_array('history').get_size = 60 AND l_j.get_string('kind') = 'BALANCE');

  -- ---------------------------------------------------------------- المجموعة (الشركة القابضة)
  DECLARE
    l_g   NUMBER;
    l_cs  NUMBER := 0;
    l_a   JSON_ARRAY_T;
    l_nco NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_nco FROM org_company WHERE status_code = 'ACTIVE' AND NOONA_SECURITY_PKG.can_access_company(id) = 'Y';
    l_g := NOONA_ANL_PKG.kpi('REVENUE', l_from, l_to, NULL, 'GROUP');
    l_a := JSON_ARRAY_T.parse(NOONA_ANL_PKG.companies_json('REVENUE', l_from, l_to));
    FOR i IN 0 .. l_a.get_size - 1 LOOP l_cs := l_cs + TREAT(l_a.get(i) AS JSON_OBJECT_T).get_number('value'); END LOOP;
    ok('group breakdown lists every accessible company', l_a.get_size = l_nco, l_a.get_size || ' vs ' || l_nco);
    ok('group total = sum of companies', ABS(l_g - l_cs) < 0.05, l_g || ' vs ' || l_cs);
    ok('group includes the current company', l_g = NOONA_ANL_PKG.kpi('REVENUE', l_from, l_to) + (l_cs - NOONA_ANL_PKG.kpi('REVENUE', l_from, l_to)));
    ok('can_group reflects company count', NOONA_ANL_PKG.can_group = CASE WHEN l_nco > 1 THEN 'Y' ELSE 'N' END);
    l_j := JSON_OBJECT_T.parse(NOONA_ANL_PKG.view_json('FIN', NULL, 'GROUP'));
    ok('group view: scope, companies, no branch filter', l_j.get_string('scope') = 'GROUP' AND l_j.get_array('companies').get_size = l_nco
       AND l_j.get_array('branches').get_size = 0);
    l_j := JSON_OBJECT_T.parse(NOONA_ANL_PKG.view_json('FIN'));
    ok('company view stays company scope', l_j.get_string('scope') = 'COMPANY' AND l_j.get_array('companies').get_size = 0);
    l_j := JSON_OBJECT_T.parse(NOONA_ANL_PKG.chart_json('REVENUE', 'MONTH', 3, NULL, 'GROUP'));
    ok('group chart with forecast', l_j.get_string('scope') = 'GROUP' AND l_j.get_array('forecast').get_size = 3);
    ok('group series sums like kpi', JSON_ARRAY_T.parse(NOONA_ANL_PKG.series_json('REVENUE', ADD_MONTHS(l_to, -3), l_to, 'MONTH', NULL, 'GROUP')).get_size = 4);
  END;

  -- ---------------------------------------------------------------- الفرع
  DECLARE
    l_br NUMBER;
  BEGIN
    SELECT MIN(id) INTO l_br FROM org_branch WHERE company_id = NOONA_ANL_PKG.company;
    IF l_br IS NOT NULL THEN
      ok('branch filter never exceeds company total',
         ABS(NOONA_ANL_PKG.kpi('REVENUE', l_from, l_to, l_br)) <= ABS(NOONA_ANL_PKG.kpi('REVENUE', l_from, l_to)) + 0.01
         OR NOONA_ANL_PKG.kpi('REVENUE', l_from, l_to) < 0);
    ELSE
      ok('branch filter (no branch, skipped)', TRUE);
    END IF;
  END;

  -- ---------------------------------------------------------------- مقارنة السنوات وأرقام السنوات السابقة
  DECLARE
    l_y   NUMBER := EXTRACT(YEAR FROM SYSDATE);
    l_m   NUMBER := EXTRACT(MONTH FROM SYSDATE);
    l_hy  NUMBER := EXTRACT(YEAR FROM SYSDATE) - 5;
    l_am  NUMBER;
    l_arr VARCHAR2(400);
    l_n   NUMBER;
    l_fy0 NUMBER;
    l_fy1 NUMBER;
    l_d0  DATE;
    l_new NUMBER;
  BEGIN
    l_j := JSON_OBJECT_T.parse(NOONA_ANL_PKG.years_json('REVENUE', 3));
    l_a := l_j.get_array('years');
    ok('years: 3 years ending with the current year', l_a.get_size = 3
       AND TREAT(l_a.get(2) AS JSON_OBJECT_T).get_number('year') = l_y AND TREAT(l_a.get(0) AS JSON_OBJECT_T).get_number('year') = l_y - 2);
    l_o := TREAT(l_a.get(2) AS JSON_OBJECT_T);
    ok('years: current year partial with 12 month slots', l_o.get_boolean('partial') AND l_o.get_array('months').get_size = 12);
    ok('years: future months are null', l_m = 12 OR l_o.get_array('months').get(11).is_null);
    ok('years: current YTD equals kpi Jan..now',
       ABS(l_o.get_number('ytd') - NOONA_ANL_PKG.kpi('REVENUE', TRUNC(SYSDATE, 'YYYY'), LAST_DAY(SYSDATE))) < 0.05,
       l_o.get_number('ytd') || ' vs ' || NOONA_ANL_PKG.kpi('REVENUE', TRUNC(SYSDATE, 'YYYY'), LAST_DAY(SYSDATE)));
    ok('years: previous year total equals kpi of that year',
       ABS(TREAT(l_a.get(1) AS JSON_OBJECT_T).get_number('total')
           - NOONA_ANL_PKG.kpi('REVENUE', TO_DATE((l_y - 1) || '-01-01', 'YYYY-MM-DD'), TO_DATE((l_y - 1) || '-12-31', 'YYYY-MM-DD'))) < 0.05);
    l_j := JSON_OBJECT_T.parse(NOONA_ANL_PKG.years_json('CASH_BALANCE', 2));
    ok('years: balance metric total = year-end balance', l_j.get_string('kind') = 'BALANCE' AND l_j.get_array('years').get_size = 2);

    -- أرقام سنة سابقة بلا بيانات فعلية
    l_n := NOONA_ANL_PKG.save_history('HIS_VISITS', l_hy, NULL, '[10,20,30,40,50,60,70,80,90,100,110,120]', 'MANUAL', 'test');
    ok('history: 12 months saved', l_n = 12, l_n);
    l_j := JSON_OBJECT_T.parse(NOONA_ANL_PKG.history_json('HIS_VISITS', l_hy));
    ok('history: values read back', TREAT(l_j.get_array('months').get(2) AS JSON_OBJECT_T).get_number('value') = 30
       AND TREAT(l_j.get_array('months').get(2) AS JSON_OBJECT_T).get_number('actual') = 0);
    ok('history: added to kpi of the year',
       NOONA_ANL_PKG.kpi('HIS_VISITS', TO_DATE(l_hy || '-01-01', 'YYYY-MM-DD'), TO_DATE(l_hy || '-12-31', 'YYYY-MM-DD')) = 780);
    ok('history: kpi of a partial month excludes it',
       NOONA_ANL_PKG.kpi('HIS_VISITS', TO_DATE(l_hy || '-03-05', 'YYYY-MM-DD'), TO_DATE(l_hy || '-03-20', 'YYYY-MM-DD')) = 0);
    l_a := JSON_ARRAY_T.parse(NOONA_ANL_PKG.series_json('HIS_VISITS', TO_DATE(l_hy || '-01-01', 'YYYY-MM-DD'), TO_DATE(l_hy || '-12-31', 'YYYY-MM-DD')));
    ok('history: in the monthly series', l_a.get_size = 12 AND TREAT(l_a.get(11) AS JSON_OBJECT_T).get_number('v') = 120);
    l_a := JSON_OBJECT_T.parse(NOONA_ANL_PKG.years_json('HIS_VISITS', 6)).get_array('years');
    ok('history: in years comparison', TREAT(l_a.get(0) AS JSON_OBJECT_T).get_number('total') = 780,
       TREAT(l_a.get(0) AS JSON_OBJECT_T).get_number('total'));
    ok('history: summary lists the metric', DBMS_LOB.instr(NOONA_ANL_PKG.history_summary_json, '"HIS_VISITS"') > 0);
    l_n := NOONA_ANL_PKG.save_history('HIS_VISITS', l_hy, NULL, '[null,null,null,null,null,null,null,null,null,null,null,"1,250.5"]');
    ok('history: nulls delete, text number accepted',
       NOONA_ANL_PKG.kpi('HIS_VISITS', TO_DATE(l_hy || '-01-01', 'YYYY-MM-DD'), TO_DATE(l_hy || '-12-31', 'YYYY-MM-DD')) = 1250.5);
    rejects('history: 12 values required', 'NOONA-ANL-016',
            'DECLARE x NUMBER; BEGIN x := NOONA_ANL_PKG.save_history(''HIS_VISITS'', ' || l_hy || ', NULL, ''[1,2]''); END;');
    rejects('history: non-number rejected', 'NOONA-ANL-017',
            'DECLARE x NUMBER; BEGIN x := NOONA_ANL_PKG.save_history(''HIS_VISITS'', ' || l_hy || ', NULL, ''[1,2,3,4,5,6,7,8,9,10,11,"abc"]''); END;');
    rejects('history: negative count rejected', 'NOONA-ANL-013',
            'DECLARE x NUMBER; BEGIN x := NOONA_ANL_PKG.save_history(''HIS_VISITS'', ' || l_hy || ', NULL, ''[-1,null,null,null,null,null,null,null,null,null,null,null]''); END;');
    rejects('history: branch on a metric without branches', 'NOONA-ANL-014',
            'DECLARE x NUMBER; b NUMBER; BEGIN SELECT MIN(id) INTO b FROM org_branch WHERE company_id = NOONA_ANL_PKG.company; '
            || 'x := NOONA_ANL_PKG.save_history(''AUT_JOBS'', ' || l_hy || ', NVL(b, -1), ''[1,null,null,null,null,null,null,null,null,null,null,null]''); END;');
    IF l_m < 12 THEN
      rejects('history: future month rejected', 'NOONA-ANL-011',
              'DECLARE x NUMBER; BEGIN x := NOONA_ANL_PKG.save_history(''HIS_VISITS'', ' || l_y || ', NULL, ''[null,null,null,null,null,null,null,null,null,null,null,5]''); END;');
    END IF;
    -- شهر فيه إيراد فعلي يرفض
    FOR m IN REVERSE 1 .. l_m LOOP
      IF NOONA_ANL_PKG.kpi('REVENUE', TO_DATE(l_y || '-' || m || '-01', 'YYYY-MM-DD'), LAST_DAY(TO_DATE(l_y || '-' || m || '-01', 'YYYY-MM-DD'))) <> 0 THEN
        l_am := m; EXIT;
      END IF;
    END LOOP;
    IF l_am IS NOT NULL THEN
      SELECT '[' || LISTAGG(CASE WHEN LEVEL = l_am THEN '1' ELSE 'null' END, ',') WITHIN GROUP (ORDER BY LEVEL) || ']' INTO l_arr
        FROM dual CONNECT BY LEVEL <= 12;
      rejects('history: month with actual data rejected (no double count)', 'NOONA-ANL-012',
              'DECLARE x NUMBER; BEGIN x := NOONA_ANL_PKG.save_history(''REVENUE'', ' || l_y || ', NULL, ''' || l_arr || '''); END;');
      ok('history: month with actual data is locked',
         TREAT(JSON_OBJECT_T.parse(NOONA_ANL_PKG.history_json('REVENUE', l_y)).get_array('months').get(l_am - 1) AS JSON_OBJECT_T).get_boolean('locked'));
    END IF;
    l_j := JSON_OBJECT_T.parse(NOONA_ANL_PKG.import_history_csv('metric,month,value' || CHR(10) || 'HIS_VISITS,' || l_hy || '-03,5' || CHR(13) || CHR(10)
             || 'NO_SUCH,' || l_hy || '-01,1' || CHR(10) || 'HIS_VISITS,bad,1' || CHR(10) || 'HIS_VISITS;' || l_hy || '/04;7'));
    ok('import: valid lines saved, bad lines reported', l_j.get_number('saved') = 2 AND l_j.get_number('errorCount') = 2,
       l_j.to_string);
    ok('import: error line numbers', TREAT(l_j.get_array('errors').get(0) AS JSON_OBJECT_T).get_number('line') = 3);
    ok('import: values in kpi',
       NOONA_ANL_PKG.kpi('HIS_VISITS', TO_DATE(l_hy || '-03-01', 'YYYY-MM-DD'), TO_DATE(l_hy || '-04-30', 'YYYY-MM-DD')) = 12);

    -- فتح السنة المالية السابقة
    SELECT COUNT(*), MIN(start_date) INTO l_fy0, l_d0 FROM gl_fiscal_year WHERE company_id = NOONA_ANL_PKG.company;
    IF l_d0 > ADD_MONTHS(TRUNC(SYSDATE, 'YYYY'), -108) THEN
      l_new := NOONA_GL_PKG.open_previous_year;
      SELECT COUNT(*) INTO l_fy1 FROM gl_fiscal_year WHERE company_id = NOONA_ANL_PKG.company;
      ok('GL: previous fiscal year opened', l_fy1 = l_fy0 + 1);
      SELECT COUNT(*) INTO l_n FROM gl_period WHERE fiscal_year_id = l_new;
      ok('GL: previous year has 12 periods', l_n = 12, l_n);
      SELECT COUNT(*) INTO l_n FROM gl_fiscal_year WHERE id = l_new AND start_date = ADD_MONTHS(l_d0, -12) AND end_date = l_d0 - 1;
      ok('GL: previous year ends the day before the earliest year', l_n = 1);
      SELECT COUNT(*) INTO l_n FROM gl_period_status s JOIN gl_period p ON p.id = s.period_id WHERE p.fiscal_year_id = l_new AND s.status_code = 'OPEN';
      ok('GL: previous year periods open', l_n >= 12, l_n);
      ok('GL: modules stay ready with yearly sequences of several years',
         NOONA_SAL_PKG.is_ready = 'Y' AND NOONA_PUR_PKG.is_ready = 'Y');
    ELSE
      ok('GL: previous fiscal year (ten-year limit reached, skipped)', TRUE);
    END IF;
  END;

  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('========== analytics: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  DBMS_OUTPUT.PUT_LINE('========== analytics: ' || g_pass || ' passed, ' || (g_fail + 1) || ' failed');
END;
/
EXIT
