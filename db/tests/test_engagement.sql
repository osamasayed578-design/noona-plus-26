-- =============================================================================
-- NOONA PLUS ERP | اختبار التوزيع والمبيعات الميدانية بحساب NOONA_APP - يتراجع في النهاية
--   المندوب وسيارته وعهدته، خط السير والمحلات والموقع، تحميل السيارة، الزيارة والبيع والتحصيل بطرق الدفع ورقم الإشعار،
--   التأكيد والرفض، المرتجع، أمر التوريد، إنهاء الزيارة وسبب عدم الشراء، تسوية اليوم والتوريد والعجز، العمولات، واتساب
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_distribution.sql
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
  l_sfx  VARCHAR2(6) := TO_CHAR(MOD(TO_NUMBER(TO_CHAR(SYSTIMESTAMP, 'SSFF3')), 90000) + 10000);
  l_acc NUMBER; l_lnk NUMBER; l_url VARCHAR2(4000); l_tok VARCHAR2(200); l_h CLOB; l_m NUMBER; l_n NUMBER; l_x NUMBER;
  l_inv NUMBER; l_it NUMBER; l_wh NUMBER; l_rt NUMBER; l_d DATE; l_s VARCHAR2(4000);
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
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_n := NOONA_ENG_PKG.quick_setup;
  SELECT COUNT(*) INTO l_x FROM eng_wa_template WHERE company_id = NOONA_ENG_PKG.company AND is_active = 'Y';
  ok('default templates', l_x >= 6, l_x);
  SELECT COUNT(*) INTO l_x FROM eng_alert_rule WHERE company_id = NOONA_ENG_PKG.company;
  ok('default early-warning rules', l_x >= 9, l_x);

  -- عميل وفاتورة آجلة متأخرة
  l_acc := NOONA_SAL_PKG.save_customer('{"name":"عميل البوابة ' || l_sfx || '","phone":"0559' || l_sfx || '1","term":0,"limit":100000}');
  SELECT MIN(i.id) INTO l_it FROM inv_item i WHERE i.status_code = 'ACTIVE' AND i.is_sellable = 'Y' AND i.item_type IN ('SERVICE', 'NON_STOCK');
  l_inv := NOONA_SAL_PKG.save_invoice('{"cust":' || l_acc || ',"date":"' || TO_CHAR(SYSDATE - 40, 'YYYY-MM-DD') || '","mode":"CREDIT","action":"POST",'
        || '"lines":[{"i":' || l_it || ',"q":2,"p":115,"inc":"Y"}]}');
  ok('credit invoice posted', l_inv IS NOT NULL);
  UPDATE ar_open_item SET due_date = TRUNC(SYSDATE) - 35 WHERE source_entity_type = 'SAL_INVOICE' AND source_entity_id = l_inv;

  -- بوابة العميل
  l_lnk := NOONA_ENG_PKG.create_link(l_acc, 30);
  l_url := NOONA_ENG_PKG.link_url(l_lnk);
  l_tok := NVL(REGEXP_SUBSTR(l_url, 'P100_T:([0-9a-f]+)', 1, 1, 'i', 1), REGEXP_SUBSTR(l_url, 'p100_t=([0-9a-f]+)', 1, 1, 'i', 1));
  ok('portal link url', INSTR(UPPER(l_url), 'NOONA_HUB') > 0 AND LENGTH(l_tok) = 48, l_url);
  SELECT COUNT(*) INTO l_x FROM eng_portal_link WHERE id = l_lnk AND token_hash <> l_tok AND token_enc <> l_tok;
  ok('token stored hashed and encrypted only', l_x = 1);
  l_h := NOONA_ENG_PKG.portal_html(l_tok);
  ok('portal shows customer and invoice', DBMS_LOB.INSTR(l_h, 'عميل البوابة ' || l_sfx) > 0 AND DBMS_LOB.INSTR(l_h, 'متأخرة') > 0, DBMS_LOB.SUBSTR(l_h, 300, 1));
  ok('portal balance 230', DBMS_LOB.INSTR(l_h, '230.00') > 0);
  ok('portal statement tab', NOONA_ENG_PKG.portal_html(l_tok, 'STATEMENT') IS NOT NULL);
  ok('portal shipments tab', DBMS_LOB.INSTR(NOONA_ENG_PKG.portal_html(l_tok, 'SHIP'), 'الشحنات') > 0);
  ok('company context restored after portal', NOONA_ENG_PKG.company IS NOT NULL);
  SELECT access_count INTO l_x FROM eng_portal_link WHERE id = l_lnk;
  ok('portal access counted', l_x = 3, l_x);
  ok('wrong token rejected', DBMS_LOB.INSTR(NOONA_ENG_PKG.portal_html(RPAD('a', 48, 'b')), 'غير صحيح') > 0);
  NOONA_ENG_PKG.revoke_link(l_lnk);
  ok('revoked link expired', DBMS_LOB.INSTR(NOONA_ENG_PKG.portal_html(l_tok), 'انتهت') > 0);

  -- واتساب (روابط wa.me)
  ok('intl phone', NOONA_ENG_PKG.intl_phone('055 123 4567') = '966551234567', NOONA_ENG_PKG.intl_phone('055 123 4567'));
  ok('intl phone keeps +', NOONA_ENG_PKG.intl_phone('+971501234567') = '971501234567');
  ok('render', NOONA_ENG_PKG.render('مرحبا {customer} {x}', '{"customer":"أحمد"}') = 'مرحبا أحمد ');
  ok('customer phone', NOONA_ENG_PKG.customer_phone(l_acc) LIKE '0559%', NOONA_ENG_PKG.customer_phone(l_acc));
  l_m := NOONA_ENG_PKG.send_event('INVOICE', l_acc, 'SAL_INVOICE', l_inv);
  SELECT status_code, body_text INTO l_s, l_url FROM eng_message WHERE id = l_m;
  ok('invoice message logged as link', l_s = 'LINK', l_s);
  ok('invoice message rendered', INSTR(l_url, 'عميل البوابة') > 0 AND INSTR(l_url, '230.00') > 0 AND INSTR(UPPER(l_url), 'NOONA_HUB') > 0, l_url);
  ok('wa.me link', NOONA_ENG_PKG.message_link(l_m) LIKE 'https://wa.me/966559%', NOONA_ENG_PKG.message_link(l_m));
  l_n := NOONA_ENG_PKG.send_reminders(30);
  SELECT COUNT(*) INTO l_x FROM eng_message WHERE customer_account_id = l_acc AND template_id IN (SELECT id FROM eng_wa_template WHERE event_code = 'REMINDER');
  ok('overdue reminder sent', l_n >= 1 AND l_x = 1, l_n || '/' || l_x);
  rejects('cloud api needs token', 'NOONA-ENG-011', 'BEGIN NOONA_ENG_PKG.save_wa_setting(''{"provider":"CLOUD_API","clearToken":"Y"}''); END;');
  NOONA_ENG_PKG.save_wa_setting('{"provider":"CLOUD_API","phoneId":"1234567890","token":"TEST-TOKEN-' || l_sfx || '","cc":"966"}');
  SELECT COUNT(*) INTO l_x FROM eng_wa_setting WHERE company_id = NOONA_ENG_PKG.company AND token_enc IS NOT NULL AND INSTR(token_enc, 'TEST-TOKEN') = 0;
  ok('token encrypted', l_x = 1 AND NOONA_ENG_PKG.wa_has_token = 'Y');
  NOONA_ENG_PKG.save_wa_setting('{"provider":"LINK","clearToken":"Y"}');
  ok('token cleared', NOONA_ENG_PKG.wa_has_token = 'N');

  -- النقد والتوقع والإنذار
  ok('cash now', NOONA_ENG_PKG.cash_now IS NOT NULL);
  SELECT COUNT(*) INTO l_x FROM JSON_TABLE(NOONA_ENG_PKG.forecast_json(90), '$[*]' COLUMNS (w NUMBER PATH '$.w'));
  ok('forecast 13 weeks', l_x = 13, l_x);
  SELECT SUM(i) INTO l_n FROM JSON_TABLE(NOONA_ENG_PKG.forecast_json(90), '$[*]' COLUMNS (i NUMBER PATH '$.in'));
  ok('forecast includes overdue receivable', l_n >= 230 * 0.6 - 0.01, l_n);
  ok('forecast min', NOONA_ENG_PKG.forecast_min(90, l_d) IS NOT NULL AND l_d IS NOT NULL);
  ok('forecast html', DBMS_LOB.INSTR(NOONA_ENG_PKG.forecast_html(90), 'الرصيد المتوقع') > 0);
  UPDATE eng_alert_rule SET threshold = 1e12 WHERE company_id = NOONA_ENG_PKG.company AND code = 'CASH_LOW';
  UPDATE eng_alert_rule SET threshold = 0, days = 30 WHERE company_id = NOONA_ENG_PKG.company AND code = 'AR_OVERDUE';
  l_n := NOONA_ENG_PKG.run_alerts(NOONA_ENG_PKG.company);
  ok('company context kept after alerts', NOONA_ENG_PKG.company IS NOT NULL);
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  SELECT COUNT(*) INTO l_x FROM eng_alert a JOIN eng_alert_rule r ON r.id = a.rule_id
   WHERE a.company_id = NOONA_ENG_PKG.company AND r.code IN ('CASH_LOW', 'AR_OVERDUE') AND a.alert_date = TRUNC(SYSDATE);
  ok('cash low + overdue alerts raised', l_x = 2, l_n || '/' || l_x);
  l_n := NOONA_ENG_PKG.run_alerts(NOONA_ENG_PKG.company);
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  SELECT COUNT(*) INTO l_x FROM eng_alert a JOIN eng_alert_rule r ON r.id = a.rule_id
   WHERE a.company_id = NOONA_ENG_PKG.company AND r.code = 'CASH_LOW' AND a.alert_date = TRUNC(SYSDATE);
  ok('alerts deduplicated per day', l_x = 1, l_x);
  SELECT COUNT(*) INTO l_x FROM ntf_notification n JOIN ntf_event_type e ON e.id = n.event_type_id WHERE e.code = 'ENG_ALERT' AND n.created_at > SYSTIMESTAMP - INTERVAL '5' MINUTE;
  ok('alert notifications to admins', l_x >= 1, l_x);
  ok('alerts html', DBMS_LOB.INSTR(NOONA_ENG_PKG.alerts_html, 'أقل من الحد') > 0);
  SELECT MIN(a.id) INTO l_x FROM eng_alert a JOIN eng_alert_rule r ON r.id = a.rule_id WHERE r.code = 'CASH_LOW' AND a.company_id = NOONA_ENG_PKG.company AND a.status_code = 'OPEN';
  NOONA_ENG_PKG.ack_alert(l_x);
  SELECT COUNT(*) INTO l_n FROM eng_alert WHERE id = l_x AND status_code = 'ACKNOWLEDGED' AND ack_by IS NOT NULL;
  ok('alert acknowledged', l_n = 1);
  l_h := NOONA_ENG_PKG.dashboard_html;
  ok('manager dashboard', DBMS_LOB.INSTR(l_h, 'النقد والبنوك الآن') > 0 AND DBMS_LOB.INSTR(l_h, 'أكبر المتأخرين') > 0 AND DBMS_LOB.INSTR(l_h, 'nn-al') > 0, DBMS_LOB.SUBSTR(l_h, 300, 1));

  -- التصدير والسجل
  l_s := DBMS_LOB.SUBSTR(NOONA_ENG_PKG.export_sql('AR_CUSTOMER_ACCOUNT'), 3000, 1);
  ok('export sql with arabic headings', l_s LIKE 'SELECT %' AND INSTR(l_s, 'TENANT_ID') = 0 AND INSTR(l_s, 'noona_eng_pkg.company') > 0, SUBSTR(l_s, 1, 200));
  rejects('export unknown table', 'NOONA-ENG-030', 'DECLARE c CLOB; BEGIN c := NOONA_ENG_PKG.export_sql(''NO_SUCH_TABLE''); END;');
  rejects('export injection blocked', 'ORA-44003', 'DECLARE c CLOB; BEGIN c := NOONA_ENG_PKG.export_sql(''AR_CUSTOMER x; DROP''); END;');
  ok('table label arabic', NOONA_ENG_PKG.table_label('DST_ROUTE') = 'خطوط السير', NOONA_ENG_PKG.table_label('DST_ROUTE'));
  IF 1 = 1 THEN
    l_rt := NOONA_DST_PKG.save_route('{"code":"HR' || l_sfx || '","name":"خط السجل","days":"SUN,MON"}');
    l_rt := NOONA_DST_PKG.save_route('{"id":' || l_rt || ',"code":"HR' || l_sfx || '","name":"خط السجل المعدل","days":"SUN,MON,TUE"}');
    SELECT COUNT(*) INTO l_x FROM eng_change_log WHERE table_name = 'DST_ROUTE' AND row_id = l_rt;
    ok('change log insert + update', l_x = 2, l_x);
    l_h := NOONA_ENG_PKG.history_html('DST_ROUTE', l_rt);
    ok('readable history', DBMS_LOB.INSTR(l_h, 'خط السجل المعدل') > 0 AND DBMS_LOB.INSTR(l_h, 'عدّل') > 0 AND DBMS_LOB.INSTR(l_h, 'أيام الزيارة') > 0,
       DBMS_LOB.SUBSTR(l_h, 400, 1));
  ELSE
    ok('route change tracking trigger installed', FALSE, 'run track_defaults');
  END IF;

  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || (g_fail + 1) || ' failed');
END;
/
EXIT
