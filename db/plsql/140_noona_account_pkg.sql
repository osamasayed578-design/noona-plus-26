-- =============================================================================
-- NOONA PLUS ERP | NOONA_ACCOUNT_PKG - خدمات الحساب والاشتراك
--   * «نسيت كلمة المرور»: رمز بالبريد (15 دقيقة، 5 محاولات، مرة واحدة)؛ لا يكشف وجود الحساب من عدمه
--   * «اشتراكي» لمسؤول المؤسسة: الخطة والفترة والأنظمة والمستخدمون، وطلب إضافة أنظمة أو مستخدمين أو تجديد أو ترقية
--     بالسعر فوراً؛ يطبق عند تأكيد مسؤول المنصة للتحويل
--   * فاتورة الاشتراك: فاتورة مبيعات حقيقية في مؤسسة صاحب المنصة (BILLING.SELLER_USERNAME) فتمر بمسار الفاتورة
--     الإلكترونية والقيود، وترسل للعميل بالبريد
--   * تنبيهات يومية بالبريد: قرب انتهاء التجربة أو الاشتراك (3 أيام ويوم)، والتحول للقراءة فقط؛ بلا تكرار
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_ACCOUNT_PKG AUTHID DEFINER AS
  -- ---------------------------------------------------------- استعادة كلمة المرور (صفحة عامة)
  -- يعيد رمز جلسة دائماً (حتى لو لم يوجد الحساب) حتى لا يكشف الحسابات؛ يرسل الرمز للبريد إن وجد
  FUNCTION request_reset(p_login IN VARCHAR2, p_ip IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
  PROCEDURE complete_reset(p_token IN VARCHAR2, p_code IN VARCHAR2, p_new IN VARCHAR2, p_confirm IN VARCHAR2);

  -- ---------------------------------------------------------- اشتراكي (مسؤول المؤسسة)
  FUNCTION tenant RETURN NUMBER;
  -- تجهيز الشركة الحالية للأنظمة المشترك فيها (الأستاذ العام ودليله والسنة المالية، النقدية، المخزون، المشتريات، المبيعات،
  -- نقاط البيع، الرواتب، الأصول، التصنيع، الأرشيف)؛ آمن لإعادة التشغيل، ويعيد ملخصاً بما جهز
  FUNCTION setup_company RETURN VARCHAR2;
  FUNCTION tenant_offerings(p_tenant_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION user_limit(p_tenant_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
  FUNCTION my_subscription_html RETURN CLOB;
  FUNCTION request_change(p_offerings IN VARCHAR2, p_users IN NUMBER, p_plan IN VARCHAR2, p_payment_ref IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  PROCEDURE cancel_request(p_request_id IN NUMBER);
  FUNCTION my_requests_html RETURN CLOB;

  -- ---------------------------------------------------------- مسؤول المنصة
  FUNCTION requests_html(p_status IN VARCHAR2 DEFAULT 'PENDING') RETURN CLOB;
  PROCEDURE confirm_request(p_request_id IN NUMBER, p_note IN VARCHAR2 DEFAULT NULL);
  PROCEDURE reject_request(p_request_id IN NUMBER, p_note IN VARCHAR2);
  -- فاتورة الاشتراك في مؤسسة صاحب المنصة؛ يعيد رقمها (NULL إن لم يضبط حساب البائع) ويرسلها للعميل بالبريد
  FUNCTION issue_invoice(p_tenant_id IN NUMBER, p_description IN VARCHAR2, p_subtotal IN NUMBER, p_payment_ref IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;
  -- بريد لمسؤولي مؤسسة
  PROCEDURE notify_admins(p_tenant_id IN NUMBER, p_subject IN VARCHAR2, p_title IN VARCHAR2, p_body IN VARCHAR2,
                          p_link IN VARCHAR2 DEFAULT NULL, p_link_text IN VARCHAR2 DEFAULT NULL);
  -- المهمة اليومية: تنبيهات الانتهاء وإغلاق طلبات التسجيل غير المكتملة؛ يعيد عدد الرسائل
  FUNCTION daily_notices RETURN NUMBER;
END NOONA_ACCOUNT_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_ACCOUNT_PKG AS

  c_iterations CONSTANT PLS_INTEGER := 20000;

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;
  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(NVL(p, 0), 'FM999,999,990.00'); END;
  FUNCTION hash(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN RAWTOHEX(DBMS_CRYPTO.HASH(UTL_I18N.string_to_raw(p, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256));
  END hash;
  FUNCTION tenant RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'TENANT_ID')); END;

  -- ================================================================ استعادة كلمة المرور
  FUNCTION request_reset(p_login IN VARCHAR2, p_ip IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
    l_login VARCHAR2(320) := TRIM(p_login);
    l_tok   VARCHAR2(64) := RAWTOHEX(DBMS_CRYPTO.RANDOMBYTES(24));
    l_code  VARCHAR2(6) := LPAD(TRUNC(DBMS_RANDOM.VALUE(0, 1000000)), 6, '0');
    l_th    VARCHAR2(128);
    l_ch    VARCHAR2(128);
    l_user  sec_user%ROWTYPE;
    l_n     NUMBER;
    l_x     NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert(NOONA_MAIL_PKG.enabled = 'Y', 'NOONA-ACC-001',
      'استعادة كلمة المرور بالبريد غير مفعلة بعد؛ اطلب من مسؤول مؤسستك تعيين كلمة مرور جديدة لك', 'Email password reset is not enabled');
    NOONA_CORE_PKG.assert(l_login IS NOT NULL, 'NOONA-ACC-002', 'أدخل اسم الدخول أو البريد', 'Enter your username or email');
    NOONA_CORE_PKG.begin_system;
    IF p_ip IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM plt_password_reset WHERE ip_address = p_ip AND created_at > SYSTIMESTAMP - INTERVAL '1' HOUR;
      NOONA_CORE_PKG.assert(l_n < 10, 'NOONA-ACC-003', 'طلبات كثيرة من نفس الجهاز؛ حاول بعد ساعة', 'Too many requests');
    END IF;
    BEGIN
      SELECT * INTO l_user FROM sec_user
       WHERE (username = UPPER(l_login) OR LOWER(email) = LOWER(l_login))
         AND status_code NOT IN ('CLOSED', 'DISABLED', 'SUSPENDED') AND user_type NOT IN ('SERVICE', 'INTEGRATION')
       FETCH FIRST 1 ROWS ONLY;
    EXCEPTION WHEN NO_DATA_FOUND THEN l_user.id := NULL;
    END;
    IF l_user.id IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM plt_password_reset WHERE user_id = l_user.id AND created_at > SYSTIMESTAMP - INTERVAL '1' HOUR;
      IF l_n < 3 THEN
        l_th := hash(l_tok); l_ch := hash(l_tok || ':' || l_code);
        INSERT INTO plt_password_reset (user_id, token_hash, code_hash, expires_at, ip_address, created_by)
        VALUES (l_user.id, l_th, l_ch, SYSTIMESTAMP + INTERVAL '15' MINUTE, SUBSTR(p_ip, 1, 64), 'RESET');
        l_x := NOONA_MAIL_PKG.send(l_user.email, 'رمز استعادة كلمة المرور - نونا بلس',
                 NOONA_MAIL_PKG.wrap('استعادة كلمة المرور',
                   '<p>مرحباً ' || esc(l_user.display_name) || '،</p><p>رمز استعادة كلمة المرور لحسابك <b dir="ltr">' || esc(l_user.username)
                   || '</b>:</p><p style="font-size:26px;font-weight:bold;letter-spacing:6px">' || l_code || '</p>'
                   || '<p>صالح 15 دقيقة. إن لم تطلب الاستعادة فتجاهل هذه الرسالة؛ كلمة مرورك لم تتغير.</p>'));
      END IF;
    END IF;
    NOONA_CORE_PKG.end_system;
    RETURN l_tok;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END request_reset;

  PROCEDURE store_password(p_user_id NUMBER, p_password VARCHAR2) IS
    l_salt VARCHAR2(32) := RAWTOHEX(DBMS_CRYPTO.RANDOMBYTES(16));
    l_h    VARCHAR2(200) := NOONA_APEX_PKG.hash_password(p_password, l_salt, c_iterations);
  BEGIN
    UPDATE sec_credential SET status_code = 'REVOKED' WHERE user_id = p_user_id AND credential_type = 'PASSWORD' AND status_code = 'ACTIVE';
    INSERT INTO sec_credential (user_id, credential_type, secret_hash, hash_algorithm, salt, last_changed_at, status_code)
    VALUES (p_user_id, 'PASSWORD', l_h, 'PBKDF2-SHA256-' || c_iterations, l_salt, SYSTIMESTAMP, 'ACTIVE');
    UPDATE sec_user SET failed_logins = 0, locked_until = NULL WHERE id = p_user_id;
  END store_password;

  PROCEDURE complete_reset(p_token IN VARCHAR2, p_code IN VARCHAR2, p_new IN VARCHAR2, p_confirm IN VARCHAR2) IS
    l_r    plt_password_reset%ROWTYPE;
    l_user sec_user%ROWTYPE;
    l_th   VARCHAR2(128) := hash(p_token);
    l_ch   VARCHAR2(128) := hash(p_token || ':' || TRIM(p_code));
    l_x    NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert(p_new IS NOT NULL AND p_new = p_confirm, 'NOONA-ACC-010', 'كلمة المرور وتأكيدها غير متطابقين', 'Passwords do not match');
    NOONA_CORE_PKG.begin_system;
    BEGIN
      SELECT * INTO l_r FROM plt_password_reset WHERE token_hash = l_th FOR UPDATE;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-ACC-011', 'الرمز غير صحيح أو منتهٍ؛ اطلب رمزاً جديداً', 'Invalid or expired code');
    END;
    NOONA_CORE_PKG.assert(l_r.used_at IS NULL AND l_r.expires_at > SYSTIMESTAMP AND l_r.attempts < 5, 'NOONA-ACC-011',
                          'الرمز غير صحيح أو منتهٍ؛ اطلب رمزاً جديداً', 'Invalid or expired code');
    IF l_r.code_hash <> l_ch THEN
      UPDATE plt_password_reset SET attempts = attempts + 1 WHERE id = l_r.id;
      COMMIT;
      NOONA_CORE_PKG.raise_error('NOONA-ACC-011', 'الرمز غير صحيح أو منتهٍ؛ اطلب رمزاً جديداً', 'Invalid or expired code');
    END IF;
    SELECT * INTO l_user FROM sec_user WHERE id = l_r.user_id;
    NOONA_APEX_PKG.assert_password_policy(l_user.username, p_new);
    store_password(l_user.id, p_new);
    UPDATE plt_password_reset SET used_at = SYSTIMESTAMP WHERE id = l_r.id;
    -- أي رموز أخرى سارية لنفس المستخدم تلغى
    UPDATE plt_password_reset SET used_at = SYSTIMESTAMP WHERE user_id = l_user.id AND used_at IS NULL;
    l_x := NOONA_MAIL_PKG.send(l_user.email, 'تم تغيير كلمة المرور - نونا بلس',
             NOONA_MAIL_PKG.wrap('تم تغيير كلمة المرور', '<p>تغيرت كلمة مرور حسابك <b dir="ltr">' || esc(l_user.username) || '</b> الآن. '
             || 'إن لم تكن أنت فتواصل فوراً مع مسؤول مؤسستك.</p>'));
    NOONA_CORE_PKG.end_system;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END complete_reset;

  -- ================================================================ اشتراكي
  PROCEDURE assert_tenant_admin IS
  BEGIN
    NOONA_CORE_PKG.assert(tenant IS NOT NULL AND NOONA_APEX_PKG.is_tenant_admin = 'Y', 'NOONA-ACC-020',
                          'إدارة الاشتراك لمسؤول المؤسسة فقط', 'Only the organisation administrator manages the subscription');
  END assert_tenant_admin;

  FUNCTION setup_company RETURN VARCHAR2 IS
    l_out VARCHAR2(4000);
    l_x   NUMBER;
    PROCEDURE run(p_label VARCHAR2, p_module VARCHAR2, p_sql VARCHAR2) IS
    BEGIN
      IF p_module IS NOT NULL AND NOONA_PLATFORM_PKG.module_enabled(p_module) = 'N' THEN RETURN; END IF;
      SAVEPOINT setup_step;
      EXECUTE IMMEDIATE 'DECLARE n NUMBER; BEGIN n := ' || p_sql || '; END;';
      l_out := l_out || CASE WHEN l_out IS NOT NULL THEN '، ' END || p_label;
    EXCEPTION WHEN OTHERS THEN
      ROLLBACK TO setup_step;
      l_out := l_out || CASE WHEN l_out IS NOT NULL THEN '، ' END || p_label || ' (تعذر: ' || SUBSTR(REGEXP_SUBSTR(SQLERRM, 'NOONA-[A-Z]+-[0-9]+: [^' || CHR(10) || ']+'), 1, 120) || ')';
    END run;
  BEGIN
    assert_tenant_admin;
    NOONA_CORE_PKG.assert(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID') IS NOT NULL, 'NOONA-ACC-040', 'اختر الشركة أولاً', 'Choose a company first');
    IF NOONA_GL_PKG.primary_ledger IS NULL THEN
      run('الأستاذ العام ودليل الحسابات والسنة المالية', 'GL', 'NOONA_GL_PKG.quick_setup(NULL, ''OWN'')');
    END IF;
    run('النقدية والبنوك', 'CSH', 'NOONA_CSH_PKG.quick_setup');
    run('المخزون', 'INV', 'NOONA_INV_PKG.quick_setup');
    run('المشتريات', 'PUR', 'NOONA_PUR_PKG.quick_setup');
    run('المبيعات', 'SAL', 'NOONA_SAL_PKG.quick_setup');
    run('نقاط البيع', 'SAL', 'NOONA_POS_PKG.quick_setup');
    run('الرواتب', 'PAY', 'NOONA_PAY_PKG.quick_setup');
    run('الأصول الثابتة', 'FA', 'NOONA_FA_PKG.quick_setup');
    run('التصنيع', 'MFG', 'NOONA_MFG_PKG.quick_setup');
    run('الأرشيف', NULL, 'NOONA_DMS_PKG.quick_setup');
    RETURN NVL(l_out, 'لا يوجد ما يجهز');
  END setup_company;

  FUNCTION tenant_offerings(p_tenant_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
    l_t   NUMBER := NVL(p_tenant_id, tenant);
    l_out VARCHAR2(4000);
    l_all NUMBER;
    l_on  NUMBER;
  BEGIN
    NOONA_CORE_PKG.begin_system;
    SELECT COUNT(*) INTO l_all FROM plt_entitlement WHERE tenant_id = l_t AND feature_id IS NULL AND metric_id IS NULL;
    FOR o IN (SELECT code, module_codes FROM plt_offering WHERE is_active = 'Y' ORDER BY sort_order) LOOP
      -- النظام مشترك فيه إذا كانت كل وحداته مفعلة (أو لا توجد استحقاقات أصلاً: بيئة تطوير)
      SELECT COUNT(*) INTO l_on FROM plt_module m
       WHERE INSTR(',' || REPLACE(o.module_codes, ' ') || ',', ',' || m.module_code || ',') > 0
         AND NOT EXISTS (SELECT 1 FROM plt_entitlement e WHERE e.tenant_id = l_t AND e.module_id = m.id AND e.is_enabled = 'Y'
                            AND e.feature_id IS NULL AND e.metric_id IS NULL
                            AND TRUNC(SYSDATE) BETWEEN e.effective_from AND NVL(e.effective_to, DATE '9999-12-31'));
      IF l_all = 0 OR l_on = 0 THEN
        l_out := l_out || CASE WHEN l_out IS NOT NULL THEN ':' END || o.code;
      END IF;
    END LOOP;
    NOONA_CORE_PKG.end_system;
    RETURN l_out;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END tenant_offerings;

  FUNCTION user_limit(p_tenant_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    NOONA_CORE_PKG.begin_system;
    SELECT MAX(e.limit_qty) INTO l FROM plt_entitlement e JOIN plt_usage_metric m ON m.id = e.metric_id
     WHERE e.tenant_id = NVL(p_tenant_id, tenant) AND m.code = 'USERS' AND e.is_enabled = 'Y';
    NOONA_CORE_PKG.end_system;
    RETURN l;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END user_limit;


  FUNCTION my_subscription_html RETURN CLOB IS
    l_h    CLOB;
    l_s    plt_subscription%ROWTYPE;
    l_plan VARCHAR2(200);
    l_code VARCHAR2(30);
    l_used NUMBER;
    l_lim  NUMBER;
    l_off  VARCHAR2(4000);
    l_st   VARCHAR2(30);
  BEGIN
    assert_tenant_admin;
    NOONA_CORE_PKG.begin_system;
    BEGIN
      SELECT * INTO l_s FROM plt_subscription WHERE tenant_id = tenant AND status_code NOT IN ('CANCELLED') ORDER BY id DESC FETCH FIRST 1 ROWS ONLY;
      SELECT p.name_ar, p.code INTO l_plan, l_code FROM plt_plan_version v JOIN plt_plan p ON p.id = v.plan_id WHERE v.id = l_s.plan_version_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
    SELECT status_code INTO l_st FROM plt_tenant WHERE id = tenant;
    SELECT COUNT(*) INTO l_used FROM sec_user_membership WHERE tenant_id = tenant AND status_code = 'ACTIVE';
    NOONA_CORE_PKG.end_system;
    l_lim := user_limit;
    l_off := tenant_offerings;
    l_h := '<div class="nn-kpis">'
        || '<div class="nn-kpi"><span class="nn-kpi-label">الخطة</span><span class="nn-kpi-value">' || esc(NVL(l_plan, '-')) || '</span></div>'
        || '<div class="nn-kpi"><span class="nn-kpi-label">تنتهي في</span><span class="nn-kpi-value">' || NVL(TO_CHAR(l_s.current_period_end, 'YYYY-MM-DD'), '-')
        || '</span></div><div class="nn-kpi' || CASE WHEN l_s.current_period_end - TRUNC(SYSDATE) <= 7 THEN ' is-danger' END
        || '"><span class="nn-kpi-label">الأيام المتبقية</span><span class="nn-kpi-value">'
        || NVL(TO_CHAR(GREATEST(l_s.current_period_end - TRUNC(SYSDATE), 0)), '-') || '</span></div>'
        || '<div class="nn-kpi"><span class="nn-kpi-label">المستخدمون</span><span class="nn-kpi-value">' || l_used || NVL2(l_lim, ' / ' || l_lim, '')
        || '</span></div></div><p><b>الحالة:</b> ' || esc(NOONA_UI_PKG.status_label(l_st))
        || CASE WHEN l_code = 'TRIAL' THEN ' — تجربة مجانية؛ اطلب خطة مدفوعة أدناه قبل انتهائها حتى لا تتحول المؤسسة للقراءة فقط.' END
        || '</p><p><b>الأنظمة المشترك فيها:</b> ';
    FOR o IN (SELECT name_ar FROM plt_offering WHERE INSTR(':' || l_off || ':', ':' || code || ':') > 0 ORDER BY sort_order) LOOP
      l_h := l_h || ('<span class="nn-badge is-info">' || esc(o.name_ar) || '</span> ');
    END LOOP;
    RETURN l_h || ('</p>');
  END my_subscription_html;

  FUNCTION request_change(p_offerings IN VARCHAR2, p_users IN NUMBER, p_plan IN VARCHAR2, p_payment_ref IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_codes VARCHAR2(4000);
    l_q     CLOB;
    l_id    NUMBER;
    l_n     NUMBER;
    l_org   VARCHAR2(400);
    l_x     NUMBER;
  BEGIN
    assert_tenant_admin;
    NOONA_CORE_PKG.assert(UPPER(p_plan) <> 'TRIAL', 'NOONA-ACC-021', 'اختر خطة مدفوعة', 'Choose a paid plan');
    NOONA_CORE_PKG.assert(NVL(p_users, 0) BETWEEN 1 AND 1000, 'NOONA-SGN-043', 'عدد المستخدمين بين 1 و 1000', 'Users must be 1-1000');
    l_codes := NOONA_SIGNUP_PKG.validate_offerings(p_offerings);
    NOONA_CORE_PKG.begin_system;
    SELECT COUNT(*) INTO l_n FROM plt_plan WHERE code = UPPER(p_plan) AND is_active = 'Y' AND self_service = 'Y';
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-SGN-044', 'اختر الخطة', 'Choose a plan');
    SELECT COUNT(*) INTO l_n FROM plt_sub_request WHERE tenant_id = tenant AND status_code = 'PENDING';
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-ACC-022', 'لديك طلب قائم بانتظار التأكيد؛ ألغه أولاً لتقديم طلب جديد', 'A request is already pending');
    SELECT COUNT(*) INTO l_n FROM sec_user_membership WHERE tenant_id = tenant AND status_code = 'ACTIVE';
    NOONA_CORE_PKG.assert(p_users >= l_n, 'NOONA-ACC-023', 'لديك ' || l_n || ' مستخدماً نشطاً؛ عطل بعضهم أولاً أو اطلب عدداً أكبر',
                          'Users below active count');
    l_q := NOONA_SIGNUP_PKG.quote_json(l_codes, p_users, p_plan);
    INSERT INTO plt_sub_request (tenant_id, offerings, user_count, plan_code, quote, amount_due, payment_ref, requested_by, status_code, created_by)
    VALUES (tenant, l_codes, p_users, UPPER(p_plan), l_q, JSON_VALUE(l_q, '$.total' RETURNING NUMBER), SUBSTR(TRIM(p_payment_ref), 1, 200),
            NOONA_CTX_PKG.current_user_name, 'PENDING', NOONA_CTX_PKG.current_user_name)
    RETURNING id INTO l_id;
    SELECT name_ar INTO l_org FROM plt_tenant WHERE id = tenant;
    NOONA_CORE_PKG.end_system;
    l_x := NOONA_MAIL_PKG.send(NOONA_MAIL_PKG.setting('PLATFORM.NOTIFY_EMAIL'), 'طلب اشتراك جديد: ' || l_org,
             NOONA_MAIL_PKG.wrap('طلب تعديل اشتراك', '<p>' || esc(l_org) || ' طلب الخطة ' || esc(UPPER(p_plan)) || ' بالأنظمة ' || esc(l_codes)
             || ' و' || p_users || ' مستخدماً. المستحق ' || fmt(JSON_VALUE(l_q, '$.total' RETURNING NUMBER)) || ' ريال'
             || NVL2(p_payment_ref, '، مرجع التحويل ' || esc(p_payment_ref), '') || '.</p>',
             NOONA_MAIL_PKG.url('NOONA_PLATFORM', 'signups'), 'فتح طلبات التسجيل'));
    RETURN l_id;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END request_change;

  PROCEDURE cancel_request(p_request_id IN NUMBER) IS
  BEGIN
    assert_tenant_admin;
    NOONA_CORE_PKG.begin_system;
    UPDATE plt_sub_request SET status_code = 'CANCELLED' WHERE id = p_request_id AND tenant_id = tenant AND status_code = 'PENDING';
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-ACC-024', 'لا يوجد طلب قائم بهذا الرقم', 'No pending request');
    NOONA_CORE_PKG.end_system;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END cancel_request;

  FUNCTION st_label(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p WHEN 'PENDING' THEN 'بانتظار تأكيد التحويل' WHEN 'APPROVED' THEN 'منفذ' WHEN 'REJECTED' THEN 'مرفوض' WHEN 'CANCELLED' THEN 'ملغى' ELSE p END;
  END st_label;

  FUNCTION req_rows(p_where_tenant NUMBER, p_status VARCHAR2, p_platform BOOLEAN) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    l_h := '<table class="nn-prj-t"><thead><tr><th>#</th><th>التاريخ</th>' || CASE WHEN p_platform THEN '<th>المؤسسة</th>' END
        || '<th>الأنظمة</th><th class="n">المستخدمون</th><th>الخطة</th><th class="n">المستحق</th><th>مرجع التحويل</th><th>الفاتورة</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT q.*, t.name_ar org FROM plt_sub_request q JOIN plt_tenant t ON t.id = q.tenant_id
               WHERE (p_where_tenant IS NULL OR q.tenant_id = p_where_tenant) AND (p_status IS NULL OR q.status_code = p_status)
               ORDER BY q.id DESC FETCH FIRST 100 ROWS ONLY) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr><td>' || r.id || '</td><td>' || TO_CHAR(r.created_at, 'YYYY-MM-DD') || '</td>'
          || CASE WHEN p_platform THEN '<td>' || esc(r.org) || '</td>' END || '<td>' || esc(r.offerings) || '</td><td class="n">' || r.user_count
          || '</td><td>' || esc(r.plan_code) || '</td><td class="n">' || fmt(r.amount_due) || '</td><td>' || esc(r.payment_ref) || '</td><td>'
          || esc(r.invoice_ref) || '</td><td><span class="nn-badge ' || CASE r.status_code WHEN 'PENDING' THEN 'is-warning' WHEN 'APPROVED' THEN 'is-success'
                                                                         WHEN 'REJECTED' THEN 'is-danger' ELSE 'is-muted' END || '">' || st_label(r.status_code)
          || '</span>' || CASE WHEN r.decision_note IS NOT NULL THEN '<br><small>' || esc(r.decision_note) || '</small>' END || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد طلبات</div>'); END IF;
    RETURN l_h || ('</tbody></table>');
  END req_rows;

  FUNCTION my_requests_html RETURN CLOB IS
    l CLOB;
  BEGIN
    assert_tenant_admin;
    NOONA_CORE_PKG.begin_system;
    l := req_rows(tenant, NULL, FALSE);
    NOONA_CORE_PKG.end_system;
    RETURN l;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END my_requests_html;

  FUNCTION requests_html(p_status IN VARCHAR2 DEFAULT 'PENDING') RETURN CLOB IS
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    RETURN req_rows(NULL, p_status, TRUE);
  END requests_html;

  -- ================================================================ البريد لمسؤولي المؤسسة
  FUNCTION admin_emails(p_tenant_id NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT LISTAGG(DISTINCT LOWER(u.email), ',') WITHIN GROUP (ORDER BY LOWER(u.email)) INTO l
      FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id
     WHERE m.tenant_id = p_tenant_id AND m.is_tenant_admin = 'Y' AND m.status_code = 'ACTIVE' AND u.status_code = 'ACTIVE' AND u.email LIKE '%@%';
    RETURN l;
  END admin_emails;

  PROCEDURE notify_admins(p_tenant_id IN NUMBER, p_subject IN VARCHAR2, p_title IN VARCHAR2, p_body IN VARCHAR2,
                          p_link IN VARCHAR2 DEFAULT NULL, p_link_text IN VARCHAR2 DEFAULT NULL) IS
    l_to VARCHAR2(4000);
    l_x  NUMBER;
  BEGIN
    NOONA_CORE_PKG.begin_system;
    l_to := admin_emails(p_tenant_id);
    NOONA_CORE_PKG.end_system;
    l_x := NOONA_MAIL_PKG.send(l_to, p_subject, NOONA_MAIL_PKG.wrap(p_title, p_body, p_link, p_link_text), p_now => FALSE);
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END notify_admins;

  -- ================================================================ فاتورة الاشتراك
  FUNCTION issue_invoice(p_tenant_id IN NUMBER, p_description IN VARCHAR2, p_subtotal IN NUMBER, p_payment_ref IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2 IS
    l_seller  VARCHAR2(128) := UPPER(NOONA_MAIL_PKG.setting('BILLING.SELLER_USERNAME'));
    l_place   VARCHAR2(30) := NOONA_MAIL_PKG.setting('BILLING.BANK_PLACE');
    l_tc      VARCHAR2(30) := NVL(NOONA_MAIL_PKG.setting('BILLING.TAX_CODE'), 'VAT15');
    l_racc    VARCHAR2(30) := NVL(NOONA_MAIL_PKG.setting('BILLING.REVENUE_ACCOUNT'), '4101');
    l_puid    VARCHAR2(40) := SYS_CONTEXT('NOONA_CTX', 'USER_ID');
    l_puser   VARCHAR2(128) := SYS_CONTEXT('NOONA_CTX', 'USERNAME');
    l_plat    VARCHAR2(1) := NVL(SYS_CONTEXT('NOONA_CTX', 'PLATFORM_ADMIN'), 'N');
    l_uid     NUMBER; l_mem NUMBER; l_ten NUMBER; l_co NUMBER; l_br NUMBER;
    l_org     VARCHAR2(400); l_vat VARCHAR2(50); l_cr VARCHAR2(50); l_mail VARCHAR2(4000);
    l_cust    NUMBER;
    l_inv     NUMBER;
    l_no      VARCHAR2(100);
    l_total   NUMBER;
    l_html    CLOB;
    l_x       NUMBER;
    PROCEDURE restore IS
    BEGIN
      IF l_plat = 'Y' THEN NOONA_CTX_PKG.set_platform_context(TO_NUMBER(l_puid), l_puser); ELSE NOONA_CTX_PKG.clear_context; END IF;
    END restore;
  BEGIN
    IF l_seller IS NULL OR NVL(p_subtotal, 0) <= 0 THEN RETURN NULL; END IF;
    NOONA_CORE_PKG.begin_system;
    SELECT t.name_ar, s.vat_no, s.cr_no INTO l_org, l_vat, l_cr
      FROM plt_tenant t LEFT JOIN plt_signup s ON s.tenant_id = t.id WHERE t.id = p_tenant_id FETCH FIRST 1 ROWS ONLY;
    l_mail := admin_emails(p_tenant_id);
    SELECT u.id, m.id, m.tenant_id, m.default_company_id, m.default_branch_id INTO l_uid, l_mem, l_ten, l_co, l_br
      FROM sec_user u JOIN sec_user_membership m ON m.user_id = u.id AND m.status_code = 'ACTIVE'
     WHERE u.username = l_seller FETCH FIRST 1 ROWS ONLY;
    NOONA_CORE_PKG.end_system;
    -- جلسة البائع (مؤسسة صاحب المنصة) لإصدار فاتورة مبيعات عادية
    NOONA_CTX_PKG.set_context(l_ten, l_uid, l_mem, l_seller, l_co, l_br, 'ar', 'INTERNAL', NULL, NULL, 'Y');
    SELECT MIN(a.id) INTO l_cust FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id JOIN pty_party p ON p.id = c.party_id
     WHERE a.company_id = l_co AND ((l_vat IS NOT NULL AND p.tax_number = l_vat) OR p.display_name_ar = l_org);
    IF l_cust IS NULL THEN
      l_cust := NOONA_SAL_PKG.save_customer(JSON_OBJECT('name' VALUE l_org, 'person' VALUE 'N', 'tax' VALUE l_vat, 'cr' VALUE l_cr,
                                                        'email' VALUE REGEXP_SUBSTR(l_mail, '[^,]+'), 'term' VALUE 'NET0' ABSENT ON NULL));
    END IF;
    l_inv := NOONA_SAL_PKG.save_invoice(JSON_OBJECT('cust' VALUE l_cust, 'date' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD'), 'mode' VALUE 'CREDIT',
               'notes' VALUE 'اشتراك نونا بلس' || NVL2(p_payment_ref, ' - تحويل ' || p_payment_ref, ''), 'action' VALUE 'POST',
               'lines' VALUE JSON_ARRAY(JSON_OBJECT('d' VALUE SUBSTR(p_description, 1, 900), 'q' VALUE 1, 'p' VALUE p_subtotal, 'inc' VALUE 'N',
                                                    'tc' VALUE l_tc, 'acc' VALUE l_racc))));
    SELECT doc_no, total_amount INTO l_no, l_total FROM sal_invoice WHERE id = l_inv;
    IF l_place IS NOT NULL THEN
      l_x := NOONA_SAL_PKG.receive(JSON_OBJECT('cust' VALUE l_cust, 'amount' VALUE l_total, 'place' VALUE l_place, 'ref' VALUE p_payment_ref,
               'notes' VALUE 'سداد اشتراك ' || l_no, 'alloc' VALUE JSON_ARRAY(JSON_OBJECT('inv' VALUE l_inv, 'a' VALUE l_total)) ABSENT ON NULL));
    END IF;
    l_html := NOONA_SAL_PKG.invoice_print(l_inv);
    restore;
    l_x := NOONA_MAIL_PKG.send(l_mail, 'فاتورة اشتراك نونا بلس ' || l_no,
             NOONA_MAIL_PKG.wrap('فاتورة الاشتراك ' || l_no, '<p>شكراً لاشتراكك في نونا بلس. مرفق فاتورة ' || esc(p_description)
             || ' بمبلغ ' || fmt(l_total) || ' ريال شاملاً الضريبة.</p>'), 'invoice_' || l_no || '.html',
             '<html dir="rtl"><head><meta charset="utf-8"></head><body>' || l_html || '</body></html>', FALSE);
    RETURN l_no;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.reset_system;
      restore;
      RETURN NULL;     -- حساب البائع غير صحيح: يكمل التأكيد بلا فاتورة
    WHEN OTHERS THEN
      NOONA_CORE_PKG.reset_system;
      restore;
      RAISE;
  END issue_invoice;

  -- ================================================================ تأكيد طلب التعديل
  PROCEDURE confirm_request(p_request_id IN NUMBER, p_note IN VARCHAR2 DEFAULT NULL) IS
    l_r    plt_sub_request%ROWTYPE;
    l_mods VARCHAR2(4000);
    l_x    VARCHAR2(400);
    l_sub  NUMBER;
    l_d    DATE;
    l_cur  VARCHAR2(30);
    l_st   VARCHAR2(30);
    l_inv  VARCHAR2(100);
    l_q    JSON_OBJECT_T;
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    SELECT * INTO l_r FROM plt_sub_request WHERE id = p_request_id FOR UPDATE;
    NOONA_CORE_PKG.assert(l_r.status_code = 'PENDING', 'NOONA-ACC-030', 'الطلب ليس بانتظار التأكيد', 'Request is not pending');
    SELECT LISTAGG(m.id, ',') WITHIN GROUP (ORDER BY m.id) INTO l_mods FROM plt_module m
     WHERE m.is_active = 'Y'
       AND EXISTS (SELECT 1 FROM plt_offering o WHERE INSTR(',' || REPLACE(l_r.offerings, ':', ',') || ',', ',' || o.code || ',') > 0
                      AND INSTR(',' || REPLACE(o.module_codes, ' ') || ',', ',' || m.module_code || ',') > 0);
    l_x := NOONA_PLATFORM_ADMIN_PKG.set_tenant_modules(l_r.tenant_id, l_mods);
    NOONA_PLATFORM_ADMIN_PKG.set_tenant_limit(l_r.tenant_id, 'USERS', l_r.user_count);
    -- نفس الخطة المدفوعة الفعالة: تجديد من نهاية الفترة؛ غير ذلك (تجربة أو تغيير خطة): الخطة الجديدة من اليوم
    NOONA_CORE_PKG.begin_system;
    BEGIN
      SELECT p.code, s.status_code INTO l_cur, l_st FROM plt_subscription s JOIN plt_plan_version v ON v.id = s.plan_version_id
        JOIN plt_plan p ON p.id = v.plan_id WHERE s.tenant_id = l_r.tenant_id ORDER BY s.id DESC FETCH FIRST 1 ROWS ONLY;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
    NOONA_CORE_PKG.end_system;
    IF l_cur = l_r.plan_code AND l_st IN ('ACTIVE', 'GRACE_PERIOD') THEN
      l_d := NOONA_PLATFORM_ADMIN_PKG.renew_subscription(l_r.tenant_id, 1, NULL, 'تجديد من «اشتراكي» ' || l_r.payment_ref);
    ELSE
      l_sub := NOONA_PLATFORM_ADMIN_PKG.set_subscription(l_r.tenant_id, l_r.plan_code, TRUNC(SYSDATE), 1, NULL, 'طلب «اشتراكي» ' || l_r.payment_ref);
    END IF;
    l_q := JSON_OBJECT_T.parse(l_r.quote);
    l_inv := issue_invoice(l_r.tenant_id, 'اشتراك نونا بلس - ' || l_r.plan_code || ' - ' || REPLACE(l_r.offerings, ':', '، ') || ' - '
                           || l_r.user_count || ' مستخدمين', l_q.get_number('subtotal'), l_r.payment_ref);
    UPDATE plt_sub_request SET status_code = 'APPROVED', decided_by = NOONA_CTX_PKG.current_user_name, decision_note = SUBSTR(p_note, 1, 1000),
                               invoice_ref = l_inv
     WHERE id = p_request_id;
    notify_admins(l_r.tenant_id, 'تم تفعيل طلب اشتراكك - نونا بلس', 'تم تأكيد الدفع وتفعيل الطلب',
                  '<p>فعلنا خطة ' || esc(l_r.plan_code) || ' بالأنظمة المطلوبة و' || l_r.user_count || ' مستخدماً.'
                  || NVL2(l_inv, ' فاتورتك رقم ' || esc(l_inv) || ' مرسلة في رسالة مستقلة.', '') || '</p>',
                  NOONA_MAIL_PKG.url('NOONA_ADMIN', 'my-subscription'), 'اشتراكي');
    NOONA_AUDIT_PKG.log_event('CONFIG', 'PLT_TENANT', l_r.tenant_id, 'CONFIRM_SUB_REQUEST', 'SUCCESS',
      p_new_values => '{"request":' || l_r.id || ',"plan":"' || l_r.plan_code || '","invoice":"' || l_inv || '"}', p_reason => p_note);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-ACC-031', 'الطلب غير موجود', 'Request not found');
  END confirm_request;

  PROCEDURE reject_request(p_request_id IN NUMBER, p_note IN VARCHAR2) IS
    l_r plt_sub_request%ROWTYPE;
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.assert(TRIM(p_note) IS NOT NULL, 'NOONA-SGN-062', 'سبب الرفض إلزامي', 'Reason is required');
    SELECT * INTO l_r FROM plt_sub_request WHERE id = p_request_id FOR UPDATE;
    NOONA_CORE_PKG.assert(l_r.status_code = 'PENDING', 'NOONA-ACC-030', 'الطلب ليس بانتظار التأكيد', 'Request is not pending');
    UPDATE plt_sub_request SET status_code = 'REJECTED', decided_by = NOONA_CTX_PKG.current_user_name, decision_note = SUBSTR(p_note, 1, 1000)
     WHERE id = p_request_id;
    notify_admins(l_r.tenant_id, 'بخصوص طلب اشتراكك - نونا بلس', 'لم يُنفذ طلبك', '<p>' || esc(p_note) || '</p>',
                  NOONA_MAIL_PKG.url('NOONA_ADMIN', 'my-subscription'), 'اشتراكي');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-ACC-031', 'الطلب غير موجود', 'Request not found');
  END reject_request;

  -- ================================================================ التنبيهات اليومية
  FUNCTION daily_notices RETURN NUMBER IS
    l_n    NUMBER := 0;
    l_x    NUMBER;
    l_link VARCHAR2(400) := NOONA_MAIL_PKG.url('NOONA_ADMIN', 'my-subscription');
    FUNCTION once(p_tenant NUMBER, p_code VARCHAR2, p_ref DATE) RETURN BOOLEAN IS
      l_to VARCHAR2(1000) := SUBSTR(admin_emails(p_tenant), 1, 1000);
    BEGIN
      INSERT INTO plt_notice_log (tenant_id, notice_code, ref_date, sent_to, created_by)
      VALUES (p_tenant, p_code, p_ref, l_to, 'SYSTEM');
      RETURN TRUE;
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN RETURN FALSE;
    END once;
  BEGIN
    l_x := NOONA_SIGNUP_PKG.expire_stale;
    NOONA_CORE_PKG.begin_system;
    FOR s IN (SELECT s.tenant_id, s.current_period_end e, s.status_code, p.code plan, t.name_ar
                FROM plt_subscription s JOIN plt_plan_version v ON v.id = s.plan_version_id JOIN plt_plan p ON p.id = v.plan_id
                JOIN plt_tenant t ON t.id = s.tenant_id
               WHERE s.status_code IN ('TRIAL', 'ACTIVE') AND s.current_period_end - TRUNC(SYSDATE) IN (3, 1)
                 AND s.id = (SELECT MAX(s2.id) FROM plt_subscription s2 WHERE s2.tenant_id = s.tenant_id)) LOOP
      IF once(s.tenant_id, CASE WHEN s.plan = 'TRIAL' THEN 'TRIAL_ENDING_' ELSE 'SUB_ENDING_' END || (s.e - TRUNC(SYSDATE)), s.e) THEN
        notify_admins(s.tenant_id,
          CASE WHEN s.plan = 'TRIAL' THEN 'تنتهي تجربتك المجانية بعد ' ELSE 'ينتهي اشتراكك بعد ' END || (s.e - TRUNC(SYSDATE)) || ' يوم - نونا بلس',
          CASE WHEN s.plan = 'TRIAL' THEN 'تجربتك المجانية تقترب من نهايتها' ELSE 'اشتراكك يقترب من نهايته' END,
          '<p>مؤسسة <b>' || esc(s.name_ar) || '</b>: ينتهي ' || CASE WHEN s.plan = 'TRIAL' THEN 'التجريب' ELSE 'الاشتراك' END || ' في '
          || TO_CHAR(s.e, 'YYYY-MM-DD') || '. بعدها تتحول المؤسسة إلى فترة سماح ثم للقراءة فقط، ولا تحذف بياناتك.</p>'
          || '<p>اطلب الخطة المناسبة من «إدارة المؤسسة ← اشتراكي» لتستمر دون انقطاع.</p>', l_link, 'اشتراكي');
        l_n := l_n + 1;
      END IF;
    END LOOP;
    FOR t IN (SELECT t.id, t.name_ar, t.status_code FROM plt_tenant t
               WHERE t.status_code IN ('GRACE_PERIOD', 'READ_ONLY', 'SUSPENDED')
                 AND EXISTS (SELECT 1 FROM plt_tenant_status_hist h WHERE h.tenant_id = t.id AND h.to_status = t.status_code
                                AND h.created_at > SYSTIMESTAMP - INTERVAL '2' DAY)) LOOP
      IF once(t.id, t.status_code, TRUNC(SYSDATE)) THEN
        notify_admins(t.id, CASE t.status_code WHEN 'GRACE_PERIOD' THEN 'انتهى اشتراكك: فترة سماح' WHEN 'READ_ONLY' THEN 'مؤسستك للقراءة فقط'
                            ELSE 'تم إيقاف مؤسستك' END || ' - نونا بلس',
          CASE t.status_code WHEN 'GRACE_PERIOD' THEN 'انتهى الاشتراك وبدأت فترة السماح' WHEN 'READ_ONLY' THEN 'المؤسسة الآن للقراءة فقط'
                             ELSE 'تم إيقاف المؤسسة' END,
          '<p>مؤسسة <b>' || esc(t.name_ar) || '</b>. بياناتك محفوظة كاملة؛ جدد الاشتراك من «إدارة المؤسسة ← اشتراكي» لاستئناف العمل.</p>',
          l_link, 'تجديد الاشتراك');
        l_n := l_n + 1;
      END IF;
    END LOOP;
    NOONA_CORE_PKG.end_system;
    BEGIN apex_mail.push_queue; EXCEPTION WHEN OTHERS THEN NULL; END;
    RETURN l_n;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END daily_notices;

END NOONA_ACCOUNT_PKG;
/
