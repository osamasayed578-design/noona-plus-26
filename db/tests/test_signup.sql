-- =============================================================================
-- NOONA PLUS ERP | اختبار التسجيل الذاتي (NOONA_SIGNUP_PKG): الحساب والرموز والتحقق، بيانات المؤسسة، التسعير والمتطلبات،
--   التجهيز الآلي (المؤسسة والوحدات والاشتراك التجريبي وكلمة المرور)، منع التجربة المكررة، الخطة المدفوعة بالتحويل وتأكيدها
-- ينشئ مؤسسات تجريبية حقيقية (التجهيز يعتمد معاملات مستقلة). التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_signup.sql
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
  l_mob2 VARCHAR2(20) := '05' || LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 99999999)), 8, '0');
  l_pwd  VARCHAR2(30) := 'Signup#2026x';
  l_tok  VARCHAR2(100); l_tok2 VARCHAR2(100); l_tok3 VARCHAR2(100);
  l_msg  VARCHAR2(400); l_e VARCHAR2(10); l_m VARCHAR2(10);
  l_s    VARCHAR2(4000); l_c CLOB; l_n NUMBER; l_ten NUMBER; l_id NUMBER;
  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END); END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  PROCEDURE codes IS
  BEGIN
    l_msg := NOONA_SIGNUP_PKG.demo_message;
    l_e := REGEXP_SUBSTR(l_msg, 'رمز البريد ([0-9]{6})', 1, 1, NULL, 1);
    l_m := REGEXP_SUBSTR(l_msg, 'رمز الجوال ([0-9]{6})', 1, 1, NULL, 1);
  END codes;
BEGIN
  -- ======================================================== الحساب
  BEGIN
    l_tok := NOONA_SIGNUP_PKG.start_signup('عميل', 'bad-email', l_mob, 'SG' || l_sfx, l_pwd, 'Y');
    ok('invalid email refused', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('invalid email refused', 'NOONA-SGN-021', SQLERRM); END;
  BEGIN
    l_tok := NOONA_SIGNUP_PKG.start_signup('عميل', 's' || l_sfx || '@test.sa', l_mob, 'SG' || l_sfx, l_pwd, 'N');
    ok('terms required', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('terms required', 'NOONA-SGN-024', SQLERRM); END;
  BEGIN
    l_tok := NOONA_SIGNUP_PKG.start_signup('عميل', 's' || l_sfx || '@test.sa', l_mob, 'ADMIN', l_pwd, 'Y');
    ok('existing username refused', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('existing username refused', 'NOONA-SGN-025', SQLERRM); END;
  BEGIN
    l_tok := NOONA_SIGNUP_PKG.start_signup('عميل', 's' || l_sfx || '@test.sa', l_mob, 'SG' || l_sfx, 'short', 'Y');
    ok('weak password refused', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('weak password refused', INSTR(SQLERRM, 'NOONA-') > 0, SQLERRM); END;
  l_tok := NOONA_SIGNUP_PKG.start_signup('سارة العمري', 'S' || l_sfx || '@Test.sa', '+966' || SUBSTR(l_mob, 2), 'sg' || l_sfx, l_pwd, 'Y', '10.9.' || l_sfx);
  codes;
  ok('signup started with demo codes', l_tok IS NOT NULL AND LENGTH(l_e) = 6 AND LENGTH(l_m) = 6, l_msg);
  ok('mobile normalised and email lowercased', NOONA_SIGNUP_PKG.field(l_tok, 'MOBILE') = l_mob
     AND NOONA_SIGNUP_PKG.field(l_tok, 'EMAIL') = 's' || l_sfx || '@test.sa', NOONA_SIGNUP_PKG.field(l_tok, 'MOBILE'));
  ok('step 2 (verify)', NOONA_SIGNUP_PKG.step(l_tok) = 2);
  BEGIN
    NOONA_SIGNUP_PKG.resend(l_tok);
    ok('resend throttled', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('resend throttled', 'NOONA-SGN-011', SQLERRM); END;
  BEGIN
    NOONA_SIGNUP_PKG.save_org(l_tok, 'مؤسسة', NULL, 'SA', NULL, NULL, NULL);
    ok('org before verify refused', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('org before verify refused', 'NOONA-SGN-030', SQLERRM); END;
  BEGIN
    NOONA_SIGNUP_PKG.verify(l_tok, '000000', l_m);
    ok('wrong code refused', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('wrong code refused', 'NOONA-SGN-015', SQLERRM); END;
  NOONA_SIGNUP_PKG.verify(l_tok, l_e, l_m);
  ok('verified -> step 3', NOONA_SIGNUP_PKG.step(l_tok) = 3);

  -- ======================================================== المؤسسة والخطة
  BEGIN
    NOONA_SIGNUP_PKG.save_org(l_tok, 'مؤسسة الضياء ' || l_sfx, 'Aldiya', 'SA', '1010123456', '123', 'الرياض');
    ok('bad VAT refused', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('bad VAT refused', 'NOONA-SGN-034', SQLERRM); END;
  NOONA_SIGNUP_PKG.save_org(l_tok, 'مؤسسة الضياء ' || l_sfx, 'Aldiya', 'SA', '10' || SUBSTR(l_mob, 3), '3' || LPAD(SUBSTR(l_sfx, 1, 9), 13, '1') || '3', 'الرياض');
  ok('org saved -> step 4', NOONA_SIGNUP_PKG.step(l_tok) = 4);
  l_c := NOONA_SIGNUP_PKG.quote_json('FIN:SCM', 5, 'ANNUAL');
  ok('annual quote: (299+199+3x39) x 12 x 80% + VAT 15%',
     JSON_VALUE(l_c, '$.monthly' RETURNING NUMBER) = 615 AND JSON_VALUE(l_c, '$.subtotal' RETURNING NUMBER) = 5904
     AND JSON_VALUE(l_c, '$.total' RETURNING NUMBER) = 6789.6, SUBSTR(l_c, 1, 300));
  ok('trial quote is free', JSON_VALUE(NOONA_SIGNUP_PKG.quote_json('FIN', 1, 'TRIAL'), '$.total' RETURNING NUMBER) = 0);
  ok('quote html', INSTR(NOONA_SIGNUP_PKG.quote_html('FIN:SCM', 5, 'ANNUAL'), '6,789.60') > 0);
  BEGIN
    NOONA_SIGNUP_PKG.save_plan(l_tok, 'POS', 3, 'TRIAL');
    ok('requirements enforced (POS needs FIN and SCM)', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('requirements enforced (POS needs FIN and SCM)', 'NOONA-SGN-042', SQLERRM); END;
  BEGIN
    NOONA_SIGNUP_PKG.save_plan(l_tok, 'FIN', 3, 'MONTHLY', 'CARD');
    ok('card payment not yet available', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('card payment not yet available', 'NOONA-SGN-045', SQLERRM); END;
  NOONA_SIGNUP_PKG.save_plan(l_tok, 'FIN:SCM:POS', 4, 'TRIAL');
  ok('plan saved', NOONA_SIGNUP_PKG.field(l_tok, 'PLAN') = 'TRIAL');

  -- ======================================================== التجهيز
  l_s := NOONA_SIGNUP_PKG.finish(l_tok);
  ok('finish returns the username', l_s = UPPER('sg' || l_sfx), l_s);
  ok('step 5 (done)', NOONA_SIGNUP_PKG.step(l_tok) = 5);
  COMMIT;   -- التجهيز نهائي (يتراجع الاختبار عن الاستيراد التجريبي فقط)
  SELECT tenant_id INTO l_ten FROM plt_signup WHERE username = UPPER('sg' || l_sfx);
  SELECT COUNT(*) INTO l_n FROM plt_tenant WHERE id = l_ten AND status_code = 'TRIAL';
  ok('tenant created in trial', l_n = 1);
  -- جلسة العميل نفسه (مسؤول مؤسسته)
  NOONA_APEX_PKG.post_auth(UPPER('sg' || l_sfx), TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  ok('logged in to the new tenant', TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'TENANT_ID')) = l_ten AND NOONA_APEX_PKG.is_tenant_admin = 'Y',
     SYS_CONTEXT('NOONA_CTX', 'TENANT_ID'));
  SELECT COUNT(*) INTO l_n FROM plt_subscription WHERE tenant_id = l_ten AND status_code = 'TRIAL' AND current_period_end = TRUNC(SYSDATE) + 13;
  ok('14-day trial subscription', l_n = 1);
  ok('chosen modules enabled', NOONA_PLATFORM_PKG.module_enabled('GL') = 'Y' AND NOONA_PLATFORM_PKG.module_enabled('INV') = 'Y'
     AND NOONA_PLATFORM_PKG.module_enabled('SAL') = 'Y');
  ok('other modules disabled', NOONA_PLATFORM_PKG.module_enabled('MFG') = 'N' AND NOONA_PLATFORM_PKG.module_enabled('HIS') = 'N');
  SELECT COUNT(*) INTO l_n FROM org_company WHERE legal_name_ar = 'مؤسسة الضياء ' || l_sfx;
  ok('company created', l_n = 1);
  SELECT COUNT(*) INTO l_n FROM org_legal_registration;
  ok('CR and VAT registered', l_n = 2, l_n);
  SELECT COUNT(*) INTO l_n FROM sec_user WHERE username = UPPER('sg' || l_sfx) AND mobile = l_mob;
  ok('admin user with mobile', l_n = 1);
  ok('company set up for the chosen systems (ledger, cash, sales)', NOONA_GL_PKG.primary_ledger IS NOT NULL AND NOONA_CSH_PKG.is_ready = 'Y'
     AND NOONA_SAL_PKG.is_ready = 'Y', NOONA_GL_PKG.primary_ledger || ' ' || NOONA_CSH_PKG.is_ready || ' ' || NOONA_SAL_PKG.is_ready);
  l_n := NOONA_CONN_PKG.import_csv('CUSTOMERS', 'c.csv', 'name,phone' || CHR(10) || 'عميل أول ' || l_sfx || ',0550000001');
  SELECT ok_rows INTO l_n FROM api_import_job WHERE id = l_n;
  ok('new organisation can import customers right away', l_n = 1, l_n);
  NOONA_APEX_PKG.logout;
  COMMIT;   -- التحقق من كلمة المرور معاملة مستقلة لا ترى غير المحفوظ
  l_s := NOONA_APEX_PKG.check_password('sg' || l_sfx, l_pwd);
  ok('customer password works', l_s = 'OK', l_s);
  ok('finish is idempotent', NOONA_SIGNUP_PKG.finish(l_tok) = UPPER('sg' || l_sfx));

  -- ======================================================== التجربة المكررة والخطة المدفوعة
  l_tok2 := NOONA_SIGNUP_PKG.start_signup('شخص آخر', 't' || l_sfx || '@test.sa', l_mob, 'sh' || l_sfx, l_pwd, 'Y');
  codes; NOONA_SIGNUP_PKG.verify(l_tok2, l_e, l_m);
  NOONA_SIGNUP_PKG.save_org(l_tok2, 'مؤسسة ثانية ' || l_sfx, NULL, 'SA', NULL, NULL, NULL);
  BEGIN
    NOONA_SIGNUP_PKG.save_plan(l_tok2, 'FIN', 2, 'TRIAL');
    ok('second trial with same mobile refused', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('second trial with same mobile refused', 'NOONA-SGN-046', SQLERRM); END;
  NOONA_SIGNUP_PKG.save_plan(l_tok2, 'FIN:HR', 6, 'ANNUAL', 'BANK_TRANSFER', 'TRF-' || l_sfx);
  ok('paid plan amount due', NOONA_SIGNUP_PKG.field(l_tok2, 'TOTAL') IS NOT NULL AND NOONA_SIGNUP_PKG.field(l_tok2, 'PAYMENT') = 'BANK_TRANSFER');
  l_s := NOONA_SIGNUP_PKG.finish(l_tok2);
  ok('paid signup waits for payment', NOONA_SIGNUP_PKG.field(l_tok2, 'STATUS') = 'PAYMENT_PENDING');
  BEGIN
    NOONA_SIGNUP_PKG.confirm_payment(1, NULL);
    ok('confirm needs platform admin', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('confirm needs platform admin', 'NOONA-SEC-031', SQLERRM); END;
  NOONA_APEX_PKG.post_auth('PLATFORM', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  SELECT id, tenant_id INTO l_id, l_ten FROM plt_signup WHERE username = UPPER('sh' || l_sfx);
  l_c := NOONA_SIGNUP_PKG.signups_html('PAYMENT_PENDING');
  ok('platform sees pending transfer', INSTR(l_c, 'TRF-' || l_sfx) > 0);
  NOONA_SIGNUP_PKG.confirm_payment(l_id, 'وصل التحويل');
  ok('payment confirmed -> annual subscription active', NOONA_PLATFORM_ADMIN_PKG.sub_info(l_ten, 'PLAN') = 'اشتراك سنوي'
     AND NOONA_PLATFORM_ADMIN_PKG.sub_info(l_ten, 'STATUS') = 'ACTIVE',
     NOONA_PLATFORM_ADMIN_PKG.sub_info(l_ten, 'PLAN') || ' ' || NOONA_PLATFORM_ADMIN_PKG.sub_info(l_ten, 'STATUS'));
  SELECT COUNT(*) INTO l_n FROM plt_tenant WHERE id = l_ten AND status_code = 'ACTIVE';
  ok('tenant active', l_n = 1);
  BEGIN
    NOONA_SIGNUP_PKG.confirm_payment(l_id, NULL);
    ok('double confirm refused', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('double confirm refused', 'NOONA-SGN-060', SQLERRM); END;
  -- طلب غير مكتمل يرفض
  l_tok3 := NOONA_SIGNUP_PKG.start_signup('طلب ثالث', 'u' || l_sfx || '@test.sa', l_mob2, 'su' || l_sfx, l_pwd, 'Y');
  SELECT id INTO l_id FROM plt_signup WHERE username = UPPER('su' || l_sfx);
  NOONA_SIGNUP_PKG.reject_signup(l_id, 'بيانات غير جادة');
  BEGIN
    NOONA_SIGNUP_PKG.verify(l_tok3, '1', '1');
    ok('rejected signup cannot continue', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('rejected signup cannot continue', 'NOONA-SGN-002', SQLERRM); END;
  NOONA_SIGNUP_PKG.save_offering('FIN', 299);
  ok('price update', JSON_VALUE(NOONA_SIGNUP_PKG.quote_json('FIN', 1, 'MONTHLY'), '$.subtotal' RETURNING NUMBER) = 299);
  ok('offerings cards', INSTR(NOONA_SIGNUP_PKG.offerings_html, 'المالية والمحاسبة') > 0);
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('==== signup: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
END;
/
EXIT
