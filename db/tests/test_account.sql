-- =============================================================================
-- NOONA PLUS ERP | اختبار خدمات الحساب والاشتراك (NOONA_ACCOUNT_PKG و NOONA_MAIL_PKG):
--   استعادة كلمة المرور بالبريد، «اشتراكي» وطلب التعديل وتأكيده (الوحدات والمستخدمون والخطة وفاتورة المبيعات)،
--   والتنبيهات اليومية بلا تكرار. يتطلب إعداد SMTP في APEX (أي خادم؛ يكفي وصول الرسائل لقائمة الإرسال).
-- ينشئ مؤسسة تجريبية حقيقية. التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_account.sql
-- =============================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE
DECLARE
  g_pass PLS_INTEGER := 0;
  g_fail PLS_INTEGER := 0;
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'MISSFF3');
  l_mob  VARCHAR2(20) := '05' || LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 99999999)), 8, '0');
  l_pwd  VARCHAR2(30) := 'Account#2026x';
  l_user VARCHAR2(40) := 'AC' || l_sfx;
  l_tok  VARCHAR2(100); l_s VARCHAR2(4000); l_c CLOB; l_n NUMBER; l_ten NUMBER; l_req NUMBER; l_x NUMBER;
  l_mail_on VARCHAR2(10); l_seller VARCHAR2(100);
  l_msg VARCHAR2(400); l_e VARCHAR2(10); l_m VARCHAR2(10);
  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END); END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION queued(p_to VARCHAR2, p_like VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM (SELECT mail_to, mail_subj FROM apex_mail_queue UNION ALL SELECT mail_to, mail_subj FROM apex_mail_log)
     WHERE LOWER(mail_to) LIKE '%' || LOWER(p_to) || '%' AND mail_subj LIKE '%' || p_like || '%';
    RETURN l;
  END queued;
  FUNCTION last_code(p_to VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(10);
  BEGIN
    SELECT REGEXP_SUBSTR(DBMS_LOB.substr(mail_body_html, 4000, 1), 'letter-spacing:6px">([0-9]{6})<', 1, 1, NULL, 1) INTO l
      FROM apex_mail_queue WHERE LOWER(mail_to) = LOWER(p_to) ORDER BY id DESC FETCH FIRST 1 ROWS ONLY;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
  END last_code;
BEGIN
  apex_util.set_security_group_id(apex_util.find_security_group_id('NOONAPLUS'));
  SELECT MAX(CASE WHEN setting_key = 'MAIL.ENABLED' THEN default_value END), MAX(CASE WHEN setting_key = 'BILLING.SELLER_USERNAME' THEN default_value END)
    INTO l_mail_on, l_seller FROM plt_setting_def WHERE setting_key IN ('MAIL.ENABLED', 'BILLING.SELLER_USERNAME');
  -- بدون بريد: الاستعادة غير متاحة
  UPDATE plt_setting_def SET default_value = 'N' WHERE setting_key = 'MAIL.ENABLED';
  BEGIN
    l_tok := NOONA_ACCOUNT_PKG.request_reset('ADMIN');
    ok('reset needs mail enabled', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('reset needs mail enabled', 'NOONA-ACC-001', SQLERRM); END;
  UPDATE plt_setting_def SET default_value = 'Y' WHERE setting_key = 'MAIL.ENABLED';
  UPDATE plt_setting_def SET default_value = 'ADMIN' WHERE setting_key = 'BILLING.SELLER_USERNAME';
  COMMIT;

  -- ======================================================== مؤسسة عميل جديدة بالتسجيل الذاتي
  l_tok := NOONA_SIGNUP_PKG.start_signup('عميل الاشتراك', 'ac' || l_sfx || '@test.local', l_mob, l_user, l_pwd, 'Y');
  l_msg := NOONA_SIGNUP_PKG.demo_message;
  l_e := REGEXP_SUBSTR(l_msg, 'رمز البريد ([0-9]{6})', 1, 1, NULL, 1); l_m := REGEXP_SUBSTR(l_msg, 'رمز الجوال ([0-9]{6})', 1, 1, NULL, 1);
  NOONA_SIGNUP_PKG.verify(l_tok, l_e, l_m);
  NOONA_SIGNUP_PKG.save_org(l_tok, 'شركة الاشتراك ' || l_sfx, NULL, 'SA', NULL, '3' || LPAD(SUBSTR(l_sfx, 1, 9), 13, '7') || '3', 'جدة');
  NOONA_SIGNUP_PKG.save_plan(l_tok, 'FIN', 3, 'TRIAL');
  l_s := NOONA_SIGNUP_PKG.finish(l_tok);
  COMMIT;
  ok('welcome mail queued', queued('ac' || l_sfx || '@test.local', 'مرحباً') = 1, queued('ac' || l_sfx || '@test.local', 'مرحباً'));

  -- ======================================================== استعادة كلمة المرور
  l_tok := NOONA_ACCOUNT_PKG.request_reset('nobody' || l_sfx || '@nowhere.x');
  ok('unknown login still returns a token (no account disclosure)', l_tok IS NOT NULL);
  l_tok := NOONA_ACCOUNT_PKG.request_reset('ac' || l_sfx || '@TEST.local', '10.8.' || l_sfx);
  COMMIT;
  l_s := last_code('ac' || l_sfx || '@test.local');
  ok('reset code mailed', LENGTH(l_s) = 6, l_s);
  BEGIN
    NOONA_ACCOUNT_PKG.complete_reset(l_tok, '000000', 'NewPass#2026x', 'NewPass#2026x');
    ok('wrong reset code refused', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('wrong reset code refused', 'NOONA-ACC-011', SQLERRM); END;
  BEGIN
    NOONA_ACCOUNT_PKG.complete_reset(l_tok, l_s, 'NewPass#2026x', 'Other#2026xx');
    ok('confirmation must match', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('confirmation must match', 'NOONA-ACC-010', SQLERRM); END;
  NOONA_ACCOUNT_PKG.complete_reset(l_tok, l_s, 'NewPass#2026x', 'NewPass#2026x');
  COMMIT;
  ok('new password works', NOONA_APEX_PKG.check_password(l_user, 'NewPass#2026x') = 'OK');
  ok('old password no longer works', NOONA_APEX_PKG.check_password(l_user, l_pwd) = 'INVALID');
  BEGIN
    NOONA_ACCOUNT_PKG.complete_reset(l_tok, l_s, 'Again#2026xyz', 'Again#2026xyz');
    ok('reset code is single use', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('reset code is single use', 'NOONA-ACC-011', SQLERRM); END;
  ok('password-changed notice mailed', queued('ac' || l_sfx || '@test.local', 'تم تغيير كلمة المرور') = 1);

  -- ======================================================== اشتراكي
  NOONA_APEX_PKG.post_auth(l_user, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_ten := NOONA_ACCOUNT_PKG.tenant;
  ok('current systems', NOONA_ACCOUNT_PKG.tenant_offerings = 'FIN:DOC', NOONA_ACCOUNT_PKG.tenant_offerings);
  ok('user limit', NOONA_ACCOUNT_PKG.user_limit = 3, NOONA_ACCOUNT_PKG.user_limit);
  l_c := NOONA_ACCOUNT_PKG.my_subscription_html;
  ok('subscription card shows trial', INSTR(l_c, 'تجربة') > 0 AND INSTR(l_c, 'المالية والمحاسبة') > 0);
  BEGIN
    l_req := NOONA_ACCOUNT_PKG.request_change('FIN:DOC', 3, 'TRIAL');
    ok('trial cannot be requested again', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('trial cannot be requested again', 'NOONA-ACC-021', SQLERRM); END;
  BEGIN
    l_req := NOONA_ACCOUNT_PKG.request_change('FIN:POS', 3, 'ANNUAL');
    ok('requirements checked on change', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('requirements checked on change', 'NOONA-SGN-042', SQLERRM); END;
  l_req := NOONA_ACCOUNT_PKG.request_change('FIN:SCM:DOC', 5, 'ANNUAL', 'TRF-AC' || l_sfx);
  ok('request created', l_req IS NOT NULL);
  BEGIN
    l_x := NOONA_ACCOUNT_PKG.request_change('FIN', 5, 'MONTHLY');
    ok('one pending request at a time', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('one pending request at a time', 'NOONA-ACC-022', SQLERRM); END;
  ok('my requests listed', INSTR(NOONA_ACCOUNT_PKG.my_requests_html, 'TRF-AC' || l_sfx) > 0);
  COMMIT;
  NOONA_APEX_PKG.logout;

  -- ======================================================== تأكيد المنصة
  NOONA_APEX_PKG.post_auth('PLATFORM', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  ok('platform sees the request', INSTR(NOONA_ACCOUNT_PKG.requests_html('PENDING'), 'TRF-AC' || l_sfx) > 0);
  NOONA_ACCOUNT_PKG.confirm_request(l_req, 'وصل التحويل');
  COMMIT;
  SELECT invoice_ref, status_code INTO l_s, l_msg FROM plt_sub_request WHERE id = l_req;
  ok('request approved with invoice', l_msg = 'APPROVED' AND l_s IS NOT NULL, l_msg || ' ' || l_s);
  ok('annual subscription active', NOONA_PLATFORM_ADMIN_PKG.sub_info(l_ten, 'STATUS') = 'ACTIVE'
     AND NOONA_PLATFORM_ADMIN_PKG.sub_info(l_ten, 'PLAN') = 'اشتراك سنوي', NOONA_PLATFORM_ADMIN_PKG.sub_info(l_ten, 'PLAN'));
  ok('modules now include inventory', NOONA_ACCOUNT_PKG.tenant_offerings(l_ten) = 'FIN:SCM:DOC', NOONA_ACCOUNT_PKG.tenant_offerings(l_ten));
  ok('user limit raised', NOONA_ACCOUNT_PKG.user_limit(l_ten) = 5);
  ok('invoice mailed to the customer', queued('ac' || l_sfx || '@test.local', 'فاتورة اشتراك') = 1);
  ok('activation mailed', queued('ac' || l_sfx || '@test.local', 'تم تفعيل طلب اشتراكك') = 1);
  -- التنبيهات: تجربة تنتهي بعد 3 أيام
  l_x := NOONA_PLATFORM_ADMIN_PKG.set_subscription(l_ten, 'TRIAL', TRUNC(SYSDATE) - 10, 1);
  COMMIT;
  NOONA_APEX_PKG.logout;
  l_n := NOONA_ACCOUNT_PKG.daily_notices;
  COMMIT;
  ok('trial ending notice sent', queued('ac' || l_sfx || '@test.local', 'تنتهي تجربتك المجانية بعد 3') = 1, l_n);
  l_n := NOONA_ACCOUNT_PKG.daily_notices;
  ok('notice not repeated', queued('ac' || l_sfx || '@test.local', 'تنتهي تجربتك المجانية بعد 3') = 1);
  -- الفاتورة في مؤسسة البائع
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  SELECT invoice_ref INTO l_s FROM plt_sub_request WHERE id = l_req;
  SELECT COUNT(*), MAX(total_amount) INTO l_n, l_x FROM sal_invoice WHERE doc_no = l_s AND status_code IN ('POSTED', 'PAID', 'PARTIALLY_PAID');
  SELECT JSON_VALUE(quote, '$.total' RETURNING NUMBER) INTO l_tok FROM plt_sub_request WHERE invoice_ref = l_s;
  ok('subscription sales invoice posted in the platform owner company', l_n = 1 AND ABS(l_x - TO_NUMBER(l_tok)) < 0.05, l_n || ' ' || l_x || ' vs ' || l_tok);
  NOONA_APEX_PKG.logout;
  UPDATE plt_setting_def SET default_value = l_mail_on WHERE setting_key = 'MAIL.ENABLED';
  UPDATE plt_setting_def SET default_value = l_seller WHERE setting_key = 'BILLING.SELLER_USERNAME';
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('==== account: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
END;
/
EXIT
