-- =============================================================================
-- NOONA PLUS | اختبار الشركة القابضة والقوائم الموحدة (NOONA_CONSOL_PKG) بحساب NOONA_APP
--   قابضة بدليل خاص + تابعتان بدليل المجموعة الموحد، قرض ورسوم إدارة بين الشركات تستبعد، ثم فرق متعمد يمنع الاعتماد
--   كل التغييرات تتراجع في النهاية (ROLLBACK)
-- =============================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
DECLARE
  g_pass PLS_INTEGER := 0;
  g_fail PLS_INTEGER := 0;
  l_sfx  VARCHAR2(10) := TO_CHAR(MOD(ABS(DBMS_RANDOM.RANDOM), 90000) + 10000);
  l_bg NUMBER; l_h NUMBER; l_a NUMBER; l_b NUMBER; l_grp NUMBER; l_n NUMBER; l_x NUMBER;
  l_lh NUMBER; l_la NUMBER; l_lb NUMBER; l_cc NUMBER; l_lc NUMBER; l_rt NUMBER;
  l_c  CLOB;
  l_s  VARCHAR2(4000);
  l_d  DATE := TRUNC(SYSDATE);
  TYPE t_ids IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  g_j t_ids; g_jc t_ids;
  l_mem NUMBER; l_role NUMBER;
  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN ' -> ' || SUBSTR(p_info, 1, 300) END); END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  -- قيد يدوي يرسل للاعتماد؛ يعتمده المحاسب المعتمد لاحقاً (فصل المهام)
  PROCEDURE jv(p_desc VARCHAR2, p_lines VARCHAR2) IS
    l_j NUMBER;
  BEGIN
    l_j := NOONA_GL_PKG.create_journal(l_d, p_desc);
    NOONA_GL_PKG.save_lines(l_j, p_lines);
    NOONA_GL_PKG.submit_journal(l_j);
    g_j(g_j.COUNT + 1) := l_j; g_jc(g_j.COUNT) := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  END jv;
  PROCEDURE login(p_user VARCHAR2) IS
  BEGIN
    NOONA_APEX_PKG.cleanup_request;
    NOONA_APEX_PKG.post_auth(p_user, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  END login;
  -- اعتماد القيود المرسلة بالمحاسب المعتمد ثم العودة لـ ADMIN في الشركة p_back
  PROCEDURE approve_all(p_back NUMBER) IS
    l_st VARCHAR2(30);
  BEGIN
    login('CNA' || l_sfx);
    FOR i IN 1 .. g_j.COUNT LOOP
      NOONA_SECURITY_PKG.switch_company(g_jc(i));
      NOONA_GL_PKG.approve_journal(g_j(i), 'مطابق');
      SELECT status_code INTO l_st FROM gl_journal WHERE id = g_j(i);
      IF l_st <> 'POSTED' THEN RAISE_APPLICATION_ERROR(-20999, 'journal not posted: ' || l_st); END IF;
    END LOOP;
    g_j.DELETE; g_jc.DELETE;
    login('ADMIN');
    NOONA_SECURITY_PKG.switch_company(p_back);
  END approve_all;
  FUNCTION has(p_html CLOB, p_text VARCHAR2) RETURN BOOLEAN IS BEGIN RETURN DBMS_LOB.INSTR(p_html, p_text) > 0; END;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  UPDATE dms_archive_rule SET is_active = 'N';

  -- الشركة القابضة (مجموعة الأعمال) وشركاتها
  l_bg := NOONA_CONSOL_PKG.save_business_group(NULL, 'HG' || l_sfx, 'مجموعة الاختبار القابضة', 'SAR');
  ok('business group created', l_bg IS NOT NULL);
  BEGIN l_x := NOONA_CONSOL_PKG.save_business_group(l_bg, 'HG' || l_sfx, 'x', 'SAR', l_bg); ok('group cannot be its own parent', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('group cannot be its own parent', 'NOONA-CNS-011', SQLERRM); END;
  l_h := NOONA_PLATFORM_PKG.create_company('HQ' || l_sfx, 'القابضة للاختبار', 'Test Holding', 'SA', 'SAR');
  l_a := NOONA_PLATFORM_PKG.create_company('SA' || l_sfx, 'التابعة أ للاختبار', 'Sub A', 'SA', 'SAR');
  l_b := NOONA_PLATFORM_PKG.create_company('SB' || l_sfx, 'التابعة ب للاختبار', 'Sub B', 'SA', 'SAR');
  NOONA_CONSOL_PKG.set_company_group(l_h, l_bg);
  NOONA_CONSOL_PKG.set_company_group(l_a, l_bg);
  NOONA_CONSOL_PKG.set_company_group(l_b, l_bg);
  SELECT COUNT(*) INTO l_n FROM org_company WHERE business_group_id = l_bg;
  ok('three companies linked to the holding group', l_n = 3, l_n);

  -- دليل خاص للقابضة، ودليل المجموعة الموحد للتابعتين
  NOONA_SECURITY_PKG.switch_company(l_h);
  l_lh := NOONA_GL_PKG.quick_setup(l_h, 'OWN');
  ok('holding has its own chart', NOONA_GL_PKG.coa_mode(l_h) = 'OWN');
  l_x := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, '1190', 'جاري الشركات التابعة', '11', 'ASSET', 'Y', 'INTERCOMPANY');
  l_x := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, '4190', 'رسوم إدارة من الشركات التابعة', '4', 'REVENUE', 'Y', NULL);
  NOONA_SECURITY_PKG.switch_company(l_a);
  l_la := NOONA_GL_PKG.quick_setup(l_a, 'GROUP');
  NOONA_SECURITY_PKG.switch_company(l_b);
  l_lb := NOONA_GL_PKG.quick_setup(l_b, 'GROUP');
  SELECT COUNT(DISTINCT coa_id) INTO l_n FROM gl_ledger WHERE id IN (l_la, l_lb);
  SELECT MAX(c.owner_level) INTO l_s FROM gl_ledger g JOIN gl_chart_of_accounts c ON c.id = g.coa_id WHERE g.id = l_la;
  ok('subsidiaries share one group chart', l_n = 1 AND l_s = 'BUSINESS_GROUP' AND NOONA_GL_PKG.coa_mode(l_b) = 'GROUP', l_n || ' ' || l_s);
  SELECT COUNT(DISTINCT coa_id) INTO l_n FROM gl_ledger WHERE id IN (l_lh, l_la);
  ok('holding chart is separate from the group chart', l_n = 2, l_n);
  l_x := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, '2190', 'جاري الشركة القابضة', '21', 'LIABILITY', 'Y', 'INTERCOMPANY');
  l_x := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, '5290', 'رسوم إدارة للشركة القابضة', '52', 'EXPENSE', 'Y', NULL);
  BEGIN NOONA_CONSOL_PKG.set_company_group(l_a, NULL); ok('company on the group chart cannot leave the group', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('company on the group chart cannot leave the group', 'NOONA-CNS-013', SQLERRM); END;

  -- محاسب معتمد للقيود في كل شركات المؤسسة
  l_mem := NOONA_SEC_ADMIN_PKG.create_user('CNA' || l_sfx, 'محاسب المجموعة', 'cna' || l_sfx || '@x.local', l_h);
  l_role := NOONA_SEC_ADMIN_PKG.create_role('CNR' || l_sfx, 'معتمد قيود المجموعة');
  l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'GL', 'VIEW,CREATE,UPDATE,SUBMIT,APPROVE,REJECT,POST,REVERSE,CANCEL');
  l_n := NOONA_SEC_ADMIN_PKG.grant_role(l_mem, l_role, NULL, 'اختبار');

  -- القيود
  NOONA_SECURITY_PKG.switch_company(l_h);
  jv('رأس مال القابضة', '[{"a":"1102","d":1000000},{"a":"3101","c":1000000}]');
  jv('قرض للتابعة أ', '[{"a":"1190","d":200000},{"a":"1102","c":200000}]');
  jv('رسوم إدارة من التابعة أ', '[{"a":"1102","d":30000},{"a":"4190","c":30000}]');
  NOONA_SECURITY_PKG.switch_company(l_a);
  jv('قرض من القابضة', '[{"a":"1102","d":200000},{"a":"2190","c":200000}]');
  jv('رسوم إدارة للقابضة', '[{"a":"5290","d":30000},{"a":"1102","c":30000}]');
  jv('مبيعات خارجية', '[{"a":"1102","d":80000},{"a":"4101","c":80000}]');
  NOONA_SECURITY_PKG.switch_company(l_b);
  jv('رأس مال التابعة ب', '[{"a":"1102","d":50000},{"a":"3101","c":50000}]');
  jv('مصروفات التابعة ب', '[{"a":"5202","d":10000},{"a":"1102","c":10000}]');
  approve_all(l_h);

  -- مجموعة التجميع: 1190/2190 «بين الشركات» بتصنيفها، و4190/5290 بقاعدة الاستبعاد
  l_grp := NOONA_CONSOL_PKG.save_group(NULL, 'CG' || l_sfx, 'تجميع مجموعة الاختبار', l_bg, 'SAR', '4190, 5290');
  ok('elimination rule saved', NOONA_CONSOL_PKG.elim_accounts(l_grp) = '4190,5290', NOONA_CONSOL_PKG.elim_accounts(l_grp));
  l_s := NOONA_CONSOL_PKG.members_text(l_grp);
  ok('members are the three companies', INSTR(l_s, 'القابضة للاختبار') > 0 AND INSTR(l_s, 'التابعة أ') > 0 AND INSTR(l_s, 'التابعة ب') > 0, l_s);

  l_c := NOONA_CONSOL_PKG.report(l_grp, 'IS', TRUNC(l_d, 'YYYY'), l_d);
  ok('consolidated income: intercompany fee eliminated, net profit 70,000',
     has(l_c, 'صافي الربح') AND has(l_c, '<td class="nn-cns-total">70,000.00</td></tr></tbody>') AND NOT has(l_c, 'is-bad'), DBMS_LOB.SUBSTR(l_c, 300, DBMS_LOB.GETLENGTH(l_c) - 900));
  ok('consolidated income keeps external sales 80,000', has(l_c, '>80,000.00</td>'));
  l_c := NOONA_CONSOL_PKG.report(l_grp, 'BS', NULL, l_d);
  ok('consolidated cash 1,120,000 and balanced', has(l_c, '>1,120,000.00</td>') AND has(l_c, 'is-ok') AND NOT has(l_c, 'is-bad'));
  ok('intercompany loan shown then eliminated', has(l_c, 'بين الشركات') AND has(l_c, '>(200,000.00)</td>'));
  l_c := NOONA_CONSOL_PKG.report(l_grp, 'TB', TRUNC(l_d, 'YYYY'), l_d, 'N');
  ok('consolidated trial balance balanced (summary view)', has(l_c, 'الميزان الموحد متوازن') AND NOT has(l_c, 'الاستبعاد</th>'));
  l_x := NOONA_CONSOL_PKG.approve(l_grp, TRUNC(l_d, 'YYYY'), l_d);
  SELECT status_code INTO l_s FROM gl_consolidation_run WHERE id = l_x;
  ok('balanced consolidation approved and saved', l_s = 'APPROVED', l_s);

  -- الاستثمار في التابعات وحقوق الأقلية وترجمة العملة:
  --   القابضة تستثمر 60,000 في التابعة ب (ملكية 80%) و37,500 في تابعة بالدولار (ملكية 100%)
  l_cc := NOONA_PLATFORM_PKG.create_company('SC' || l_sfx, 'التابعة ج بالدولار', 'Sub C USD', 'US', 'USD', l_bg);
  NOONA_SECURITY_PKG.switch_company(l_cc);
  l_lc := NOONA_GL_PKG.quick_setup(l_cc, 'OWN');
  jv('رأس مال التابعة ج', '[{"a":"1102","d":10000},{"a":"3101","c":10000}]');
  jv('مبيعات التابعة ج', '[{"a":"1102","d":2000},{"a":"4101","c":2000}]');
  NOONA_SECURITY_PKG.switch_company(l_h);
  l_x := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, '1250', 'استثمارات في شركات تابعة', '12', 'ASSET', 'Y', NULL);
  jv('استثمار في التابعة ب', '[{"a":"1250","d":60000},{"a":"1102","c":60000}]');
  jv('استثمار في التابعة ج', '[{"a":"1250","d":37500},{"a":"1102","c":37500}]');
  approve_all(l_h);
  -- سعر الدولار في القابضة: 3.70 من أول السنة و3.75 اليوم (الإقفال)
  SELECT MIN(id) INTO l_rt FROM ref_rate_type WHERE code = 'ACCOUNTING';
  DELETE FROM ref_exchange_rate WHERE company_id = l_h AND rate_type_id = l_rt
     AND ((from_currency = 'USD' AND to_currency = 'SAR') OR (from_currency = 'SAR' AND to_currency = 'USD'));
  INSERT INTO ref_exchange_rate (company_id, rate_type_id, from_currency, to_currency, rate_date, effective_at, rate, inverse_rate, source_code, status_code, approved_by)
  VALUES (l_h, l_rt, 'USD', 'SAR', TRUNC(l_d, 'YYYY'), CAST(TRUNC(l_d, 'YYYY') AS TIMESTAMP), 3.70, ROUND(1 / 3.70, 10), 'MANUAL', 'APPROVED', 'ADMIN');
  INSERT INTO ref_exchange_rate (company_id, rate_type_id, from_currency, to_currency, rate_date, effective_at, rate, inverse_rate, source_code, status_code, approved_by)
  VALUES (l_h, l_rt, 'USD', 'SAR', l_d, CAST(l_d AS TIMESTAMP), 3.75, ROUND(1 / 3.75, 10), 'MANUAL', 'APPROVED', 'ADMIN');
  BEGIN l_x := NOONA_CONSOL_PKG.save_group(l_grp, 'CG' || l_sfx, 'تجميع مجموعة الاختبار', l_bg, 'SAR', '4190, 5290', NULL, 'SB' || l_sfx || ':80');
    ok('minority interest needs an investment account', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('minority interest needs an investment account', 'NOONA-CNS-016', SQLERRM); END;
  BEGIN l_x := NOONA_CONSOL_PKG.save_group(l_grp, 'CG' || l_sfx, 'تجميع مجموعة الاختبار', l_bg, 'SAR', '4190, 5290', '1250', 'SB' || l_sfx || ':120');
    ok('ownership above 100% rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('ownership above 100% rejected', 'NOONA-CNS-015', SQLERRM); END;
  l_x := NOONA_CONSOL_PKG.save_group(l_grp, 'CG' || l_sfx, 'تجميع مجموعة الاختبار', l_bg, 'SAR', '4190, 5290', '1250', 'sb' || l_sfx || ': 80');
  ok('investment account and ownership saved', NOONA_CONSOL_PKG.invest_accounts(l_grp) = '1250'
     AND NOONA_CONSOL_PKG.ownership_text(l_grp) = 'SB' || l_sfx || ':80', NOONA_CONSOL_PKG.invest_accounts(l_grp) || ' ' || NOONA_CONSOL_PKG.ownership_text(l_grp));
  l_c := NOONA_CONSOL_PKG.report(l_grp, 'BS', NULL, l_d);
  ok('goodwill 20,000 = investment 97,500 - 80% x 50,000 - 100% x 37,500', has(l_c, 'الشهرة') AND has(l_c, '>20,000.00</td>'));
  ok('minority interest 8,000 = 20% x (50,000 - 10,000)', has(l_c, 'حقوق الأقلية (غير المسيطرة)') AND has(l_c, '>8,000.00</td>'));
  ok('USD subsidiary translated: cash 12,000 x 3.75 and translation difference 90.91',
     has(l_c, '>45,000.00</td>') AND has(l_c, 'فروق ترجمة العملات الأجنبية') AND has(l_c, '>90.91</td>'));
  ok('consolidated cash 1,067,500 and balanced with investment eliminated',
     has(l_c, '>1,067,500.00</td>') AND has(l_c, 'is-ok') AND NOT has(l_c, 'is-bad'), DBMS_LOB.SUBSTR(l_c, 400, DBMS_LOB.GETLENGTH(l_c) - 1200));
  l_c := NOONA_CONSOL_PKG.report(l_grp, 'IS', TRUNC(l_d, 'YYYY'), l_d);
  ok('income: USD sales at average rate, minority share of loss, profit to holding 79,409.09',
     has(l_c, '>7,409.09</td>') AND has(l_c, 'حصة حقوق الأقلية') AND has(l_c, '>2,000.00</td>') AND has(l_c, '>79,409.09</td>'),
     DBMS_LOB.SUBSTR(l_c, 500, DBMS_LOB.GETLENGTH(l_c) - 1300));
  l_c := NOONA_CONSOL_PKG.report(l_grp, 'TB', TRUNC(l_d, 'YYYY'), l_d, 'N');
  ok('trial balance with translation difference still balanced', has(l_c, 'الميزان الموحد متوازن') AND has(l_c, 'فروق ترجمة العملات الأجنبية'));
  l_x := NOONA_CONSOL_PKG.approve(l_grp, TRUNC(l_d, 'YYYY'), l_d);
  ok('consolidation with investment and minority approved', l_x IS NOT NULL);

  -- فرق متعمد: رصيد بين الشركات من طرف واحد
  jv('تحويل للتابعة أ لم يسجل عندها', '[{"a":"1190","d":5000},{"a":"1102","c":5000}]');
  approve_all(l_h);
  l_c := NOONA_CONSOL_PKG.report(l_grp, 'BS', NULL, l_d);
  ok('unmatched intercompany balance flagged with the difference', has(l_c, 'is-bad') AND has(l_c, 'فرق مطابقة المعاملات بين الشركات') AND has(l_c, '5,000.00'));
  BEGIN l_x := NOONA_CONSOL_PKG.approve(l_grp, TRUNC(l_d, 'YYYY'), l_d); ok('unbalanced consolidation cannot be approved', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('unbalanced consolidation cannot be approved', 'NOONA-CNS-010', SQLERRM); END;

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
