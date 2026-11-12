-- =============================================================================
-- NOONA PLUS ERP | NOONA_SIGNUP_PKG - التسجيل الذاتي للعملاء
--   1) الحساب: الاسم والبريد والجوال واسم الدخول وكلمة المرور والموافقة على الشروط ← رمز تحقق للبريد والجوال
--   2) التحقق بالرمز (6 أرقام، 10 دقائق، 5 محاولات، إعادة الإرسال بعد دقيقة وحتى 5 مرات)
--   3) المؤسسة: الاسم والدولة والسجل التجاري والرقم الضريبي والمدينة
--   4) الأنظمة وعدد المستخدمين والخطة (تجربة مجانية أو شهري/ربع سنوي/نصف سنوي/سنوي) مع السعر فوراً
--   5) الإنهاء: تجهيز المؤسسة آلياً (الشركة والفرع والمسؤول بكلمة مروره والأنظمة المختارة) وتجربة 14 يوماً؛
--      الخطة المدفوعة بالتحويل البنكي تبدأ تجربة حتى يعتمد مسؤول المنصة التحويل فيتحول الاشتراك للمدفوع
--   * وضع الرموز: DEMO (يعرض الرمز على الشاشة، للتجربة المحلية) أو EMAIL (يرسل رمز البريد عبر APEX_MAIL)
--   * تجربة مجانية واحدة لكل بريد وجوال وسجل تجاري؛ حد للتسجيلات من نفس عنوان IP
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_SIGNUP_PKG AUTHID DEFINER AS
  c_terms_version CONSTANT VARCHAR2(20) := '2026.1';

  -- الخطوة 1: يعيد رمز الجلسة (يحفظ في الصفحة)؛ الرموز ترسل فوراً
  FUNCTION start_signup(p_name IN VARCHAR2, p_email IN VARCHAR2, p_mobile IN VARCHAR2, p_username IN VARCHAR2,
                        p_password IN VARCHAR2, p_terms IN VARCHAR2, p_ip IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
  PROCEDURE resend(p_token IN VARCHAR2);
  -- في وضع DEMO: نص الرموز المرسلة في هذا الطلب (للعرض على الشاشة)
  FUNCTION demo_message RETURN VARCHAR2;
  -- الخطوة 2
  PROCEDURE verify(p_token IN VARCHAR2, p_email_code IN VARCHAR2, p_mobile_code IN VARCHAR2);
  -- الخطوة 3
  PROCEDURE save_org(p_token IN VARCHAR2, p_name_ar IN VARCHAR2, p_name_en IN VARCHAR2, p_country IN VARCHAR2,
                     p_cr IN VARCHAR2, p_vat IN VARCHAR2, p_city IN VARCHAR2);
  -- الخطوة 4: p_offerings رموز مفصولة بـ : أو ,
  PROCEDURE save_plan(p_token IN VARCHAR2, p_offerings IN VARCHAR2, p_users IN NUMBER, p_plan IN VARCHAR2,
                      p_payment IN VARCHAR2 DEFAULT NULL, p_payment_ref IN VARCHAR2 DEFAULT NULL);
  -- الخطوة 5: ينشئ المؤسسة؛ يعيد اسم الدخول
  FUNCTION finish(p_token IN VARCHAR2) RETURN VARCHAR2;

  -- الحالة والعرض
  FUNCTION step(p_token IN VARCHAR2) RETURN NUMBER;
  FUNCTION field(p_token IN VARCHAR2, p_name IN VARCHAR2) RETURN VARCHAR2;
  -- السعر: {"lines":[{"code","name","monthly"}],"users","userPrice","monthly","months","discountPct","subtotal","vat","total","currency"}
  FUNCTION quote_json(p_offerings IN VARCHAR2, p_users IN NUMBER, p_plan IN VARCHAR2) RETURN CLOB;
  FUNCTION quote_html(p_offerings IN VARCHAR2, p_users IN NUMBER, p_plan IN VARCHAR2) RETURN CLOB;
  FUNCTION offerings_html RETURN CLOB;
  -- صفحة الموقع العامة: بطاقات الأنظمة بأسعارها، والباقات بخصوماتها (من جداول الأسعار مباشرة)
  FUNCTION site_systems_html(p_signup_url IN VARCHAR2) RETURN CLOB;
  FUNCTION site_plans_html(p_signup_url IN VARCHAR2) RETURN CLOB;
  -- واجهة صفحة الدخول (عامة): عرض متحرك للأنظمة من العروض الفعالة وأرقام وزر التجربة،
  --   ولوحة «أهلاً بعودتك» و«ما الجديد» (LOGIN.WHATS_NEW) لمن دخل سابقاً من نفس الجهاز
  FUNCTION login_showcase_html(p_signup_url IN VARCHAR2, p_site_url IN VARCHAR2) RETURN CLOB;
  -- يتحقق من الأنظمة ومتطلباتها؛ يعيد الرموز المعتمدة مفصولة بفاصلة
  FUNCTION validate_offerings(p_offerings IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION bank_details RETURN VARCHAR2;
  FUNCTION setting(p_key IN VARCHAR2) RETURN VARCHAR2;

  -- مسؤول المنصة
  FUNCTION signups_html(p_status IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  PROCEDURE confirm_payment(p_signup_id IN NUMBER, p_note IN VARCHAR2 DEFAULT NULL);
  PROCEDURE reject_signup(p_signup_id IN NUMBER, p_note IN VARCHAR2);
  PROCEDURE save_offering(p_code IN VARCHAR2, p_price IN NUMBER, p_active IN VARCHAR2 DEFAULT 'Y');
  PROCEDURE save_plan_discount(p_plan_code IN VARCHAR2, p_pct IN NUMBER, p_self_service IN VARCHAR2 DEFAULT 'Y');
  PROCEDURE save_setting(p_key IN VARCHAR2, p_value IN VARCHAR2);
  -- إغلاق الطلبات غير المكتملة بعد 7 أيام (يومياً)
  FUNCTION expire_stale RETURN NUMBER;
END NOONA_SIGNUP_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_SIGNUP_PKG AS

  c_iterations CONSTANT PLS_INTEGER := 20000;
  g_demo VARCHAR2(400);

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;
  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(NVL(p, 0), 'FM999,999,990.00'); END;
  FUNCTION hash(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN RAWTOHEX(DBMS_CRYPTO.HASH(UTL_I18N.string_to_raw(p, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256));
  END hash;

  FUNCTION setting(p_key IN VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT MAX(default_value) INTO l FROM plt_setting_def WHERE setting_key = p_key;
    RETURN l;
  END setting;

  FUNCTION demo_message RETURN VARCHAR2 IS BEGIN RETURN g_demo; END;

  FUNCTION get_row(p_token VARCHAR2, p_lock BOOLEAN DEFAULT FALSE) RETURN plt_signup%ROWTYPE IS
    l plt_signup%ROWTYPE;
    l_h VARCHAR2(128) := hash(p_token);
  BEGIN
    IF p_lock THEN
      SELECT * INTO l FROM plt_signup WHERE token_hash = l_h FOR UPDATE;
    ELSE
      SELECT * INTO l FROM plt_signup WHERE token_hash = l_h;
    END IF;
    NOONA_CORE_PKG.assert(l.status_code NOT IN ('EXPIRED', 'REJECTED'), 'NOONA-SGN-002', 'انتهت صلاحية طلب التسجيل؛ ابدأ من جديد',
                          'Signup expired; start again');
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-SGN-001', 'طلب التسجيل غير موجود؛ ابدأ من جديد', 'Signup not found');
  END get_row;

  FUNCTION norm_mobile(p VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(40) := REGEXP_REPLACE(TRANSLATE(p, '٠١٢٣٤٥٦٧٨٩', '0123456789'), '[^0-9+]', '');
  BEGIN
    IF l LIKE '+9665%' THEN l := '0' || SUBSTR(l, 5); ELSIF l LIKE '009665%' THEN l := '0' || SUBSTR(l, 6);
    ELSIF l LIKE '9665%' THEN l := '0' || SUBSTR(l, 4); END IF;
    RETURN l;
  END norm_mobile;

  -- الرموز: ستة أرقام عشوائية؛ تحفظ بصمتها فقط
  PROCEDURE send_codes(p_id NUMBER) IS
    l plt_signup%ROWTYPE;
    l_e VARCHAR2(6) := LPAD(TRUNC(DBMS_RANDOM.VALUE(0, 1000000)), 6, '0');
    l_m VARCHAR2(6) := LPAD(TRUNC(DBMS_RANDOM.VALUE(0, 1000000)), 6, '0');
    l_mode VARCHAR2(20) := CASE WHEN NOONA_MAIL_PKG.enabled = 'Y' THEN NVL(setting('SIGNUP.OTP_MODE'), 'DEMO') ELSE 'DEMO' END;
    l_he VARCHAR2(128); l_hm VARCHAR2(128); l_x NUMBER;
  BEGIN
    SELECT * INTO l FROM plt_signup WHERE id = p_id FOR UPDATE;
    NOONA_CORE_PKG.assert(l.otp_sent_count < 5, 'NOONA-SGN-010', 'تجاوزت عدد مرات إرسال الرمز؛ ابدأ تسجيلاً جديداً لاحقاً',
                          'Too many codes sent');
    NOONA_CORE_PKG.assert(l.last_sent_at IS NULL OR l.last_sent_at < SYSTIMESTAMP - INTERVAL '60' SECOND, 'NOONA-SGN-011',
                          'انتظر دقيقة قبل طلب رمز جديد', 'Wait a minute before requesting a new code');
    l_he := hash(l.id || ':E:' || l_e); l_hm := hash(l.id || ':M:' || l_m);
    UPDATE plt_signup SET email_otp_hash = l_he, mobile_otp_hash = l_hm,
                          otp_expires_at = SYSTIMESTAMP + INTERVAL '10' MINUTE, otp_sent_count = otp_sent_count + 1, otp_failed = 0,
                          last_sent_at = SYSTIMESTAMP
     WHERE id = p_id;
    IF l_mode = 'EMAIL' THEN
      -- البريد عبر APEX_MAIL (يتطلب إعداد SMTP في APEX)؛ الجوال لا يتحقق منه حتى يربط مزود رسائل
      l_x := NOONA_MAIL_PKG.send(l.email, 'رمز التحقق - نونا بلس',
               NOONA_MAIL_PKG.wrap('رمز التحقق', '<p>مرحباً ' || NOONA_UI_PKG.esc(l.full_name) || '،</p><p>رمز التحقق لتسجيلك في نونا بلس:</p>'
               || '<p style="font-size:26px;font-weight:bold;letter-spacing:6px">' || l_e || '</p><p>صالح 10 دقائق.</p>'));
      g_demo := NULL;
    ELSE
      g_demo := 'وضع تجريبي (لا يوجد مزود رسائل): رمز البريد ' || l_e || ' ورمز الجوال ' || l_m;
    END IF;
  END send_codes;

  FUNCTION start_signup(p_name IN VARCHAR2, p_email IN VARCHAR2, p_mobile IN VARCHAR2, p_username IN VARCHAR2,
                        p_password IN VARCHAR2, p_terms IN VARCHAR2, p_ip IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
    l_email VARCHAR2(320) := LOWER(TRIM(p_email));
    l_mob   VARCHAR2(40) := norm_mobile(p_mobile);
    l_user  VARCHAR2(128) := UPPER(TRIM(p_username));
    l_tok   VARCHAR2(64) := RAWTOHEX(DBMS_CRYPTO.RANDOMBYTES(24));
    l_salt  VARCHAR2(32) := RAWTOHEX(DBMS_CRYPTO.RANDOMBYTES(16));
    l_n     NUMBER;
    l_id    NUMBER;
    l_th    VARCHAR2(128) := hash(l_tok);
    l_pwh   VARCHAR2(200);
  BEGIN
    NOONA_CORE_PKG.assert(NVL(setting('SIGNUP.ENABLED'), 'Y') = 'Y', 'NOONA-SGN-003', 'التسجيل الذاتي متوقف حالياً؛ تواصل معنا',
                          'Self-service signup is disabled');
    NOONA_CORE_PKG.assert(TRIM(p_name) IS NOT NULL, 'NOONA-SGN-020', 'الاسم إلزامي', 'Name is required');
    NOONA_CORE_PKG.assert(REGEXP_LIKE(l_email, '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$'), 'NOONA-SGN-021', 'البريد الإلكتروني غير صحيح',
                          'Invalid email');
    NOONA_CORE_PKG.assert(REGEXP_LIKE(l_mob, '^05[0-9]{8}$') OR REGEXP_LIKE(l_mob, '^\+[1-9][0-9]{7,14}$'), 'NOONA-SGN-022',
                          'رقم الجوال غير صحيح (مثال 0551234567 أو بالرمز الدولي +971...)', 'Invalid mobile');
    NOONA_CORE_PKG.assert(REGEXP_LIKE(l_user, '^[A-Z][A-Z0-9_.]{3,29}$'), 'NOONA-SGN-023',
                          'اسم الدخول بالإنجليزية: يبدأ بحرف، من 4 إلى 30 حرفاً أو رقماً أو _ .', 'Invalid username');
    NOONA_CORE_PKG.assert(p_terms = 'Y', 'NOONA-SGN-024', 'الموافقة على الشروط وسياسة الخصوصية مطلوبة', 'Accept the terms');
    NOONA_APEX_PKG.assert_password_policy(l_user, p_password);
    l_pwh := NOONA_APEX_PKG.hash_password(p_password, l_salt, c_iterations);
    NOONA_CORE_PKG.begin_system;
    SELECT COUNT(*) INTO l_n FROM sec_user WHERE username = l_user;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-SGN-025', 'اسم الدخول مستخدم؛ اختر اسماً آخر', 'Username is taken');
    SELECT COUNT(*) INTO l_n FROM sec_user WHERE LOWER(email) = l_email AND status_code NOT IN ('CLOSED', 'DISABLED');
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-SGN-026', 'البريد مسجل لحساب قائم؛ ادخل بحسابك', 'Email already has an account');
    SELECT COUNT(*) INTO l_n FROM plt_signup
     WHERE username = l_user AND status_code IN ('STARTED', 'VERIFIED', 'DETAILS') AND created_at > SYSTIMESTAMP - INTERVAL '7' DAY
       AND email <> l_email;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-SGN-025', 'اسم الدخول مستخدم؛ اختر اسماً آخر', 'Username is taken');
    IF p_ip IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM plt_signup WHERE ip_address = p_ip AND created_at > SYSTIMESTAMP - INTERVAL '1' HOUR;
      NOONA_CORE_PKG.assert(l_n < 5, 'NOONA-SGN-027', 'محاولات تسجيل كثيرة من نفس الجهاز؛ حاول بعد ساعة', 'Too many signups from this address');
    END IF;
    -- طلب سابق غير مكتمل لنفس البريد: يغلق
    UPDATE plt_signup SET status_code = 'EXPIRED' WHERE email = l_email AND status_code IN ('STARTED', 'VERIFIED', 'DETAILS');
    INSERT INTO plt_signup (full_name, email, mobile, username, password_hash, password_salt, token_hash, terms_version, terms_accepted_at,
                            ip_address, country_code, currency_code, status_code, created_by)
    VALUES (TRIM(p_name), l_email, l_mob, l_user, l_pwh, l_salt, l_th,
            c_terms_version, SYSTIMESTAMP, SUBSTR(p_ip, 1, 64), 'SA', 'SAR', 'STARTED', 'SIGNUP')
    RETURNING id INTO l_id;
    send_codes(l_id);
    NOONA_CORE_PKG.end_system;
    RETURN l_tok;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END start_signup;

  PROCEDURE resend(p_token IN VARCHAR2) IS
    l plt_signup%ROWTYPE;
  BEGIN
    NOONA_CORE_PKG.begin_system;
    l := get_row(p_token);
    NOONA_CORE_PKG.assert(l.status_code = 'STARTED', 'NOONA-SGN-012', 'تم التحقق مسبقاً', 'Already verified');
    send_codes(l.id);
    NOONA_CORE_PKG.end_system;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END resend;

  PROCEDURE verify(p_token IN VARCHAR2, p_email_code IN VARCHAR2, p_mobile_code IN VARCHAR2) IS
    l      plt_signup%ROWTYPE;
    l_mode VARCHAR2(20) := CASE WHEN NOONA_MAIL_PKG.enabled = 'Y' THEN NVL(setting('SIGNUP.OTP_MODE'), 'DEMO') ELSE 'DEMO' END;
    l_ok   BOOLEAN;
  BEGIN
    NOONA_CORE_PKG.begin_system;
    l := get_row(p_token, TRUE);
    IF l.status_code <> 'STARTED' THEN NOONA_CORE_PKG.end_system; RETURN; END IF;
    NOONA_CORE_PKG.assert(l.otp_failed < 5, 'NOONA-SGN-013', 'محاولات خاطئة كثيرة؛ اطلب رمزاً جديداً', 'Too many wrong attempts');
    NOONA_CORE_PKG.assert(l.otp_expires_at > SYSTIMESTAMP, 'NOONA-SGN-014', 'انتهت صلاحية الرمز؛ اطلب رمزاً جديداً', 'Code expired');
    l_ok := hash(l.id || ':E:' || TRIM(p_email_code)) = l.email_otp_hash
            AND (l_mode = 'EMAIL' OR hash(l.id || ':M:' || TRIM(p_mobile_code)) = l.mobile_otp_hash);
    IF NOT l_ok THEN
      UPDATE plt_signup SET otp_failed = otp_failed + 1 WHERE id = l.id;
      COMMIT;     -- عداد المحاولات يحفظ رغم رفع الخطأ
      NOONA_CORE_PKG.raise_error('NOONA-SGN-015', 'الرمز غير صحيح', 'Wrong code');
    END IF;
    UPDATE plt_signup SET email_verified_at = SYSTIMESTAMP, mobile_verified_at = CASE WHEN l_mode = 'EMAIL' THEN NULL ELSE SYSTIMESTAMP END,
                          email_otp_hash = NULL, mobile_otp_hash = NULL, status_code = 'VERIFIED'
     WHERE id = l.id;
    NOONA_CORE_PKG.end_system;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END verify;

  PROCEDURE save_org(p_token IN VARCHAR2, p_name_ar IN VARCHAR2, p_name_en IN VARCHAR2, p_country IN VARCHAR2,
                     p_cr IN VARCHAR2, p_vat IN VARCHAR2, p_city IN VARCHAR2) IS
    l     plt_signup%ROWTYPE;
    l_ctry VARCHAR2(2) := UPPER(NVL(TRIM(p_country), 'SA'));
    l_cur  VARCHAR2(3);
    l_cr   VARCHAR2(50) := REGEXP_REPLACE(TRANSLATE(p_cr, '٠١٢٣٤٥٦٧٨٩', '0123456789'), '\s', '');
    l_vat  VARCHAR2(50) := REGEXP_REPLACE(TRANSLATE(p_vat, '٠١٢٣٤٥٦٧٨٩', '0123456789'), '\s', '');
  BEGIN
    NOONA_CORE_PKG.begin_system;
    l := get_row(p_token, TRUE);
    NOONA_CORE_PKG.assert(l.status_code IN ('VERIFIED', 'DETAILS'), 'NOONA-SGN-030', 'أكمل التحقق من الرمز أولاً', 'Verify first');
    NOONA_CORE_PKG.assert(TRIM(p_name_ar) IS NOT NULL, 'NOONA-SGN-031', 'اسم المؤسسة إلزامي', 'Organisation name is required');
    l_cur := CASE l_ctry WHEN 'SA' THEN 'SAR' WHEN 'AE' THEN 'AED' WHEN 'BH' THEN 'BHD' WHEN 'OM' THEN 'OMR' WHEN 'QA' THEN 'QAR'
                         WHEN 'KW' THEN 'KWD' WHEN 'EG' THEN 'EGP' WHEN 'SD' THEN 'SDG' END;
    NOONA_CORE_PKG.assert(l_cur IS NOT NULL, 'NOONA-SGN-032', 'الدولة غير مدعومة بعد', 'Country not supported yet');
    NOONA_CORE_PKG.assert(l_ctry <> 'SA' OR l_cr IS NULL OR REGEXP_LIKE(l_cr, '^[0-9]{10}$'), 'NOONA-SGN-033',
                          'السجل التجاري 10 أرقام', 'CR must be 10 digits');
    NOONA_CORE_PKG.assert(l_ctry <> 'SA' OR l_vat IS NULL OR REGEXP_LIKE(l_vat, '^3[0-9]{13}3$'), 'NOONA-SGN-034',
                          'الرقم الضريبي 15 رقماً يبدأ وينتهي بالرقم 3', 'VAT number must be 15 digits starting and ending with 3');
    UPDATE plt_signup SET org_name_ar = TRIM(p_name_ar), org_name_en = TRIM(p_name_en), country_code = l_ctry, currency_code = l_cur,
                          cr_no = l_cr, vat_no = l_vat, city = TRIM(p_city), status_code = 'DETAILS'
     WHERE id = l.id;
    NOONA_CORE_PKG.end_system;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END save_org;

  -- ---------------------------------------------------------------- التسعير
  FUNCTION norm_list(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN ',' || UPPER(REPLACE(REPLACE(p, ':', ','), ' ')) || ',';
  END norm_list;

  FUNCTION quote_json(p_offerings IN VARCHAR2, p_users IN NUMBER, p_plan IN VARCHAR2) RETURN CLOB IS
    l_list  VARCHAR2(4000) := norm_list(p_offerings);
    l_lines JSON_ARRAY_T := JSON_ARRAY_T();
    l_o     JSON_OBJECT_T;
    l_r     JSON_OBJECT_T := JSON_OBJECT_T();
    l_mon   NUMBER := 0;
    l_users NUMBER := GREATEST(NVL(p_users, 1), 1);
    l_up    NUMBER := NVL(TO_NUMBER(setting('SIGNUP.USER_PRICE')), 0);
    l_free  NUMBER := NVL(TO_NUMBER(setting('SIGNUP.FREE_USERS')), 0);
    l_vatp  NUMBER := NVL(TO_NUMBER(setting('SIGNUP.VAT_PCT')), 15);
    l_cycle VARCHAR2(30);
    l_disc  NUMBER := 0;
    l_months NUMBER;
    l_sub   NUMBER;
  BEGIN
    FOR o IN (SELECT code, name_ar, monthly_price FROM plt_offering WHERE is_active = 'Y' AND INSTR(l_list, ',' || code || ',') > 0
               ORDER BY sort_order) LOOP
      l_o := JSON_OBJECT_T(); l_o.put('code', o.code); l_o.put('name', o.name_ar); l_o.put('monthly', o.monthly_price);
      l_lines.append(l_o);
      l_mon := l_mon + o.monthly_price;
    END LOOP;
    SELECT MAX(billing_cycle), MAX(discount_pct) INTO l_cycle, l_disc FROM plt_plan WHERE code = UPPER(p_plan);
    l_months := CASE l_cycle WHEN 'MONTHLY' THEN 1 WHEN 'QUARTERLY' THEN 3 WHEN 'SEMI_ANNUAL' THEN 6 WHEN 'ANNUAL' THEN 12 ELSE 0 END;
    l_mon := l_mon + GREATEST(l_users - l_free, 0) * l_up;
    l_sub := ROUND(l_mon * l_months * (1 - NVL(l_disc, 0) / 100), 2);
    l_r.put('lines', l_lines); l_r.put('users', l_users); l_r.put('userPrice', l_up); l_r.put('freeUsers', l_free);
    l_r.put('monthly', l_mon); l_r.put('months', l_months); l_r.put('discountPct', NVL(l_disc, 0)); l_r.put('subtotal', l_sub);
    l_r.put('vatPct', l_vatp); l_r.put('vat', ROUND(l_sub * l_vatp / 100, 2)); l_r.put('total', l_sub + ROUND(l_sub * l_vatp / 100, 2));
    l_r.put('currency', 'SAR'); l_r.put('plan', UPPER(p_plan));
    RETURN l_r.to_clob;
  END quote_json;

  FUNCTION quote_html(p_offerings IN VARCHAR2, p_users IN NUMBER, p_plan IN VARCHAR2) RETURN CLOB IS
    l_q  JSON_OBJECT_T := JSON_OBJECT_T.parse(quote_json(p_offerings, p_users, p_plan));
    l_ln JSON_ARRAY_T := l_q.get_array('lines');
    l_e  JSON_OBJECT_T;
    l_h  CLOB;
    l_m  NUMBER := l_q.get_number('months');
  BEGIN
    IF l_ln.get_size = 0 THEN RETURN '<div class="nn-empty">اختر نظاماً واحداً على الأقل</div>'; END IF;
    l_h := '<table class="nn-prj-t nn-sgn-q"><thead><tr><th>البند</th><th class="n">شهرياً (ريال)</th></tr></thead><tbody>';
    FOR i IN 0 .. l_ln.get_size - 1 LOOP
      l_e := TREAT(l_ln.get(i) AS JSON_OBJECT_T);
      l_h := l_h || ('<tr><td>' || esc(l_e.get_string('name')) || '</td><td class="n">' || fmt(l_e.get_number('monthly')) || '</td></tr>');
    END LOOP;
    l_h := l_h || ('<tr><td>المستخدمون: ' || l_q.get_number('users')
        || CASE WHEN l_q.get_number('freeUsers') > 0 THEN ' (أول ' || l_q.get_number('freeUsers') || ' مجاناً)' END
        || ' × ' || fmt(l_q.get_number('userPrice')) || '</td><td class="n">'
        || fmt(GREATEST(l_q.get_number('users') - l_q.get_number('freeUsers'), 0) * l_q.get_number('userPrice')) || '</td></tr>'
        || '<tr class="nn-rpt-total"><td>الإجمالي الشهري</td><td class="n">' || fmt(l_q.get_number('monthly')) || '</td></tr>');
    IF l_m = 0 THEN
      l_h := l_h || ('<tr class="nn-rpt-total"><td>تجربة مجانية 14 يوماً بكل الأنظمة المختارة</td><td class="n">0.00</td></tr>');
    ELSE
      l_h := l_h || ('<tr><td>المدة ' || l_m || ' شهر' || CASE WHEN l_q.get_number('discountPct') > 0 THEN ' بخصم ' || l_q.get_number('discountPct') || '%' END
          || '</td><td class="n">' || fmt(l_q.get_number('subtotal')) || '</td></tr><tr><td>ضريبة القيمة المضافة ' || l_q.get_number('vatPct')
          || '%</td><td class="n">' || fmt(l_q.get_number('vat')) || '</td></tr><tr class="nn-rpt-total"><td>المستحق</td><td class="n">'
          || fmt(l_q.get_number('total')) || '</td></tr>');
    END IF;
    RETURN l_h || ('</tbody></table>');
  END quote_html;

  FUNCTION offerings_html RETURN CLOB IS
    l_h CLOB := '<div class="nn-sgn-cards">';
  BEGIN
    FOR o IN (SELECT * FROM plt_offering WHERE is_active = 'Y' ORDER BY sort_order) LOOP
      l_h := l_h || ('<div class="nn-sgn-card"><span class="fa ' || esc(o.icon) || '"></span><b>' || esc(o.name_ar) || '</b><small>'
          || esc(o.description) || '</small><em>' || CASE WHEN o.monthly_price = 0 THEN 'مشمول' ELSE fmt(o.monthly_price) || ' ريال شهرياً' END
          || '</em></div>');
    END LOOP;
    RETURN l_h || ('</div>');
  END offerings_html;

  FUNCTION bank_details RETURN VARCHAR2 IS
  BEGIN
    RETURN NVL(setting('SIGNUP.BANK_DETAILS'), 'يحدد مسؤول المنصة بيانات الحساب البنكي');
  END bank_details;

  FUNCTION site_systems_html(p_signup_url IN VARCHAR2) RETURN CLOB IS
    l_h CLOB := '<div class="nnw-grid nnw-sys">';
  BEGIN
    FOR o IN (SELECT * FROM plt_offering WHERE is_active = 'Y' ORDER BY sort_order) LOOP
      l_h := l_h || ('<div class="nnw-card"><div class="nnw-ic"><span class="fa ' || esc(o.icon) || '"></span></div><h3>' || esc(o.name_ar)
          || '</h3><p>' || esc(o.description) || '</p><div class="nnw-price">'
          || CASE WHEN o.monthly_price = 0 THEN '<b>مشمول</b> مع كل اشتراك'
                  ELSE '<b>' || TO_CHAR(o.monthly_price, 'FM999,990') || '</b> ريال / شهرياً' END || '</div></div>');
    END LOOP;
    RETURN l_h || ('</div>');
  END site_systems_html;

  FUNCTION login_showcase_html(p_signup_url IN VARCHAR2, p_site_url IN VARCHAR2) RETURN CLOB IS
    l_h    CLOB;
    l_dots VARCHAR2(4000);
    l_n    PLS_INTEGER := 0;
    l_news VARCHAR2(4000) := setting('LOGIN.WHATS_NEW');
    l_item VARCHAR2(1000);
    l_i    PLS_INTEGER := 1;
  BEGIN
    l_h := '<div class="nnl-show" id="nnlShow"><div class="nnl-orb nnl-orb1"></div><div class="nnl-orb nnl-orb2"></div>'
        || '<div class="nnl-new"><div class="nnl-kicker">نظام ERP عربي سحابي متكامل</div>'
        || '<h1 class="nnl-h1">كل أعمال مؤسستك في نظام واحد</h1><div class="nnl-slides">';
    FOR o IN (SELECT * FROM plt_offering WHERE is_active = 'Y' ORDER BY sort_order) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<div class="nnl-slide' || CASE WHEN l_n = 1 THEN ' is-on' END || '" data-code="' || esc(o.code) || '">'
          || '<span class="nnl-ic"><span class="fa ' || esc(o.icon) || '" aria-hidden="true"></span></span><div class="nnl-txt"><h2>'
          || esc(o.name_ar) || '</h2><p>' || esc(o.description) || '</p><div class="nnl-price">'
          || CASE WHEN o.monthly_price = 0 THEN 'مشمول مع كل اشتراك'
                  ELSE 'من <b>' || TO_CHAR(o.monthly_price, 'FM999,990') || '</b> ريال شهرياً' END || '</div></div></div>');
      l_dots := l_dots || '<button type="button" class="nnl-dot' || CASE WHEN l_n = 1 THEN ' is-on' END || '" aria-label="'
             || esc(o.name_ar) || '"></button>';
    END LOOP;
    l_h := l_h || ('</div><div class="nnl-dots">' || l_dots || '</div>'
        || '<div class="nnl-stats"><div><b data-count="' || l_n || '">0</b><span>نظاماً</span></div>'
        || '<div><b data-count="14">0</b><span>يوم تجربة مجانية</span></div>'
        || '<div><b data-count="8">0</b><span>دول بضرائبها</span></div>'
        || '<div><b data-count="24">0</b><span>ساعة بلا توقف</span></div></div>'
        || '<div class="nnl-cta"><a class="nnl-btn nnl-btn-primary" href="' || p_signup_url || '">ابدأ تجربتك المجانية</a>'
        || '<a class="nnl-btn nnl-btn-ghost" href="' || p_site_url || '">المزايا والأسعار</a></div></div>');
    -- لوحة العائدين: أهلاً بعودتك + ما الجديد + ترويج لنظام غير مشترك فيه
    l_h := l_h || '<div class="nnl-back" hidden><div class="nnl-kicker">نونا بلس</div><h1 class="nnl-h1">أهلاً بعودتك<span class="nnl-org"></span></h1>'
        || '<h3 class="nnl-h3"><span class="fa fa-star" aria-hidden="true"></span> ما الجديد في النظام</h3><ul class="nnl-news">';
    WHILE l_news IS NOT NULL AND l_i <= 8 LOOP
      l_item := TRIM(REGEXP_SUBSTR(l_news, '[^|]+', 1, l_i));
      EXIT WHEN l_item IS NULL;
      l_h := l_h || ('<li><b>' || esc(TRIM(REGEXP_SUBSTR(l_item, '^[^:]+'))) || '</b>'
          || CASE WHEN INSTR(l_item, ':') > 0 THEN '<span>' || esc(TRIM(SUBSTR(l_item, INSTR(l_item, ':') + 1))) || '</span>' END || '</li>');
      l_i := l_i + 1;
    END LOOP;
    l_h := l_h || '</ul><h3 class="nnl-h3 nnl-promo-h"><span class="fa fa-plus-circle" aria-hidden="true"></span> قد يهمك أيضاً</h3>'
        || '<div class="nnl-promo"></div><a class="nnl-tour" href="#">جولة على كل الأنظمة</a></div></div>';
    RETURN l_h;
  END login_showcase_html;

  FUNCTION site_plans_html(p_signup_url IN VARCHAR2) RETURN CLOB IS
    l_h   CLOB := '<div class="nnw-grid nnw-plans">';
    l_fin NUMBER;
    l_up  NUMBER := NVL(TO_NUMBER(setting('SIGNUP.USER_PRICE')), 0);
    l_fr  NUMBER := NVL(TO_NUMBER(setting('SIGNUP.FREE_USERS')), 0);
  BEGIN
    SELECT NVL(MAX(monthly_price), 0) INTO l_fin FROM plt_offering WHERE code = 'FIN' AND is_active = 'Y';
    l_h := l_h || ('<div class="nnw-plan nnw-plan-trial"><h3>تجربة مجانية</h3><div class="nnw-amt"><b>0</b> ريال</div><small>14 يوماً</small><ul>'
        || '<li>كل الأنظمة التي تختارها</li><li>بلا بطاقة ولا دفع</li><li>بياناتك تبقى عند الاشتراك</li></ul>'
        || '<a class="nnw-btn nnw-btn-primary" href="' || p_signup_url || '">ابدأ مجاناً</a></div>');
    FOR p IN (SELECT code, name_ar, discount_pct, billing_cycle FROM plt_plan
               WHERE is_active = 'Y' AND self_service = 'Y' AND code <> 'TRIAL'
               ORDER BY DECODE(code, 'MONTHLY', 1, 'QUARTERLY', 2, 'SEMI_ANNUAL', 3, 'ANNUAL', 4, 9)) LOOP
      l_h := l_h || ('<div class="nnw-plan' || CASE WHEN p.code = 'ANNUAL' THEN ' nnw-plan-best' END || '">'
          || CASE WHEN p.code = 'ANNUAL' THEN '<span class="nnw-tag">الأوفر</span>' END
          || '<h3>' || esc(p.name_ar) || '</h3><div class="nnw-amt"><b>' || TO_CHAR(ROUND(l_fin * (1 - p.discount_pct / 100)), 'FM999,990')
          || '</b> ريال / شهرياً</div><small>للمالية والمحاسبة' || CASE WHEN p.discount_pct > 0 THEN ' بعد خصم ' || p.discount_pct || '%' END
          || '</small><ul><li>أضف ما تحتاج من الأنظمة</li><li>' || CASE WHEN l_fr > 0 THEN 'أول ' || l_fr || ' مستخدمين مجاناً، ثم ' END
          || TO_CHAR(l_up, 'FM990') || ' ريال للمستخدم</li><li>تحديثات ودعم فني ونسخ احتياطي يومي</li></ul>'
          || '<a class="nnw-btn' || CASE WHEN p.code = 'ANNUAL' THEN ' nnw-btn-primary' END || '" href="' || p_signup_url || '">اشترك الآن</a></div>');
    END LOOP;
    RETURN l_h || ('</div><p class="nnw-note">الأسعار بالريال السعودي قبل ضريبة القيمة المضافة 15%. السعر النهائي يظهر لك أثناء التسجيل حسب الأنظمة وعدد المستخدمين.</p>');
  END site_plans_html;

  FUNCTION validate_offerings(p_offerings IN VARCHAR2) RETURN VARCHAR2 IS
    l_list  VARCHAR2(4000) := norm_list(p_offerings);
    l_codes VARCHAR2(400);
    l_need  VARCHAR2(400);
    l_n     NUMBER;
  BEGIN
    SELECT LISTAGG(code, ',') WITHIN GROUP (ORDER BY sort_order), COUNT(*) INTO l_codes, l_n
      FROM plt_offering WHERE is_active = 'Y' AND INSTR(l_list, ',' || code || ',') > 0;
    NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-SGN-041', 'اختر نظاماً واحداً على الأقل', 'Choose at least one system');
    -- المتطلبات: مثل المالية للمخزون والمبيعات
    FOR o IN (SELECT name_ar, requires_codes FROM plt_offering WHERE INSTR(l_list, ',' || code || ',') > 0 AND requires_codes IS NOT NULL) LOOP
      FOR r IN (SELECT TRIM(REGEXP_SUBSTR(o.requires_codes, '[^,]+', 1, LEVEL)) c FROM dual
                CONNECT BY REGEXP_SUBSTR(o.requires_codes, '[^,]+', 1, LEVEL) IS NOT NULL) LOOP
        IF INSTR(',' || l_codes || ',', ',' || r.c || ',') = 0 THEN
          SELECT MAX(name_ar) INTO l_need FROM plt_offering WHERE code = r.c;
          NOONA_CORE_PKG.raise_error('NOONA-SGN-042', o.name_ar || ' يتطلب ' || l_need || '؛ أضفه إلى اختيارك', 'Missing required system');
        END IF;
      END LOOP;
    END LOOP;
    RETURN l_codes;
  END validate_offerings;

  PROCEDURE save_plan(p_token IN VARCHAR2, p_offerings IN VARCHAR2, p_users IN NUMBER, p_plan IN VARCHAR2,
                      p_payment IN VARCHAR2 DEFAULT NULL, p_payment_ref IN VARCHAR2 DEFAULT NULL) IS
    l      plt_signup%ROWTYPE;
    l_list VARCHAR2(4000) := norm_list(p_offerings);
    l_codes VARCHAR2(400);
    l_need VARCHAR2(4000);
    l_n    NUMBER;
    l_trial BOOLEAN := UPPER(p_plan) = 'TRIAL';
    l_q    CLOB;
    l_pay  VARCHAR2(30) := CASE WHEN UPPER(p_plan) = 'TRIAL' THEN 'NONE' ELSE NVL(UPPER(p_payment), 'BANK_TRANSFER') END;
  BEGIN
    NOONA_CORE_PKG.begin_system;
    l := get_row(p_token, TRUE);
    NOONA_CORE_PKG.assert(l.status_code IN ('DETAILS'), 'NOONA-SGN-040', 'أكمل بيانات المؤسسة أولاً', 'Complete the organisation first');
    l_codes := validate_offerings(p_offerings);
    NOONA_CORE_PKG.assert(NVL(p_users, 0) BETWEEN 1 AND 1000, 'NOONA-SGN-043', 'عدد المستخدمين بين 1 و 1000', 'Users must be 1-1000');
    SELECT COUNT(*) INTO l_n FROM plt_plan WHERE code = UPPER(p_plan) AND is_active = 'Y' AND self_service = 'Y';
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-SGN-044', 'اختر الخطة', 'Choose a plan');
    NOONA_CORE_PKG.assert(l_pay IN ('NONE', 'BANK_TRANSFER'), 'NOONA-SGN-045',
      'الدفع بالبطاقة غير متاح بعد؛ اختر التحويل البنكي أو ابدأ بالتجربة المجانية', 'Card payment is not available yet');
    IF l_trial THEN
      -- تجربة واحدة لكل بريد أو جوال أو سجل تجاري
      SELECT COUNT(*) INTO l_n FROM plt_signup
       WHERE id <> l.id AND tenant_id IS NOT NULL AND plan_code = 'TRIAL'
         AND (email = l.email OR mobile = l.mobile OR (l.cr_no IS NOT NULL AND cr_no = l.cr_no));
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-SGN-046', 'سبقت لك تجربة مجانية بنفس البريد أو الجوال أو السجل؛ اختر خطة مدفوعة',
                            'A free trial was already used');
    END IF;
    l_q := quote_json(l_codes, p_users, p_plan);
    UPDATE plt_signup SET offerings = l_codes, user_count = p_users, plan_code = UPPER(p_plan), payment_method = l_pay,
                          payment_ref = SUBSTR(TRIM(p_payment_ref), 1, 200), quote = l_q,
                          amount_due = JSON_VALUE(l_q, '$.total' RETURNING NUMBER)
     WHERE id = l.id;
    NOONA_CORE_PKG.end_system;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END save_plan;

  -- ---------------------------------------------------------------- التجهيز
  FUNCTION service_user RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM sec_user WHERE username = 'NOONA_SIGNUP';
    IF l IS NULL THEN
      INSERT INTO sec_user (username, email, display_name, user_type, preferred_language, mfa_required, status_code)
      VALUES ('NOONA_SIGNUP', 'signup@noona.local', 'التسجيل الذاتي', 'SERVICE', 'ar', 'N', 'ACTIVE')
      RETURNING id INTO l;
    END IF;
    RETURN l;
  END service_user;

  FUNCTION finish(p_token IN VARCHAR2) RETURN VARCHAR2 IS
    l       plt_signup%ROWTYPE;
    l_ten   NUMBER;
    l_user  NUMBER;
    l_mem   NUMBER;
    l_co    NUMBER;
    l_br    NUMBER;
    l_mods  VARCHAR2(4000);
    l_x     VARCHAR2(4000);
    l_sub   NUMBER;
    l_code  VARCHAR2(30);
    l_svc   NUMBER;
    l_t     NUMBER;
  BEGIN
    NOONA_CORE_PKG.begin_system;
    l := get_row(p_token, TRUE);
    IF l.tenant_id IS NOT NULL THEN NOONA_CORE_PKG.end_system; RETURN l.username; END IF;
    NOONA_CORE_PKG.assert(l.status_code = 'DETAILS' AND l.plan_code IS NOT NULL, 'NOONA-SGN-050', 'أكمل اختيار الأنظمة والخطة', 'Choose systems and plan');
    l_svc := service_user;
    SELECT LISTAGG(m.id, ',') WITHIN GROUP (ORDER BY m.id) INTO l_mods
      FROM plt_module m
     WHERE m.is_active = 'Y'
       AND EXISTS (SELECT 1 FROM plt_offering o
                    WHERE INSTR(',' || l.offerings || ',', ',' || o.code || ',') > 0
                      AND INSTR(',' || REPLACE(o.module_codes, ' ') || ',', ',' || m.module_code || ',') > 0);
    l_code := 'S' || LPAD(l.id, 6, '0');
    NOONA_CORE_PKG.end_system;
    -- جلسة منصة باسم خدمة التسجيل (تجهيز المؤسسة واشتراكها ووحداتها من نفس إجراءات مسؤول المنصة)
    NOONA_CTX_PKG.set_platform_context(l_svc, 'NOONA_SIGNUP');
    l_ten := NOONA_PLATFORM_PKG.provision_tenant(
               p_tenant_code => l_code, p_tenant_slug => LOWER(l_code), p_name_ar => l.org_name_ar, p_name_en => NVL(l.org_name_en, l.org_name_ar),
               p_country_code => l.country_code, p_base_currency => l.currency_code, p_admin_username => l.username,
               p_admin_email => l.email, p_admin_name => l.full_name, p_company_code => 'HQ', p_company_name_ar => l.org_name_ar,
               p_idempotency_key => 'SIGNUP-' || l.id, p_is_trial => 'Y');
    l_x := NOONA_PLATFORM_ADMIN_PKG.set_tenant_modules(l_ten, l_mods);
    l_sub := NOONA_PLATFORM_ADMIN_PKG.set_subscription(l_ten, 'TRIAL', TRUNC(SYSDATE), 1, NULL,
               'تسجيل ذاتي' || CASE WHEN l.plan_code <> 'TRIAL' THEN ' (بانتظار تأكيد الدفع: ' || l.plan_code || ')' END);
    NOONA_PLATFORM_ADMIN_PKG.set_tenant_limit(l_ten, 'USERS', l.user_count);
    NOONA_CTX_PKG.clear_context;
    NOONA_CORE_PKG.begin_system;
    -- كلمة المرور التي اختارها العميل، والجوال
    SELECT id INTO l_user FROM sec_user WHERE username = l.username;
    UPDATE sec_credential SET status_code = 'REVOKED' WHERE user_id = l_user AND credential_type = 'PASSWORD' AND status_code = 'ACTIVE';
    INSERT INTO sec_credential (user_id, credential_type, secret_hash, hash_algorithm, salt, last_changed_at, status_code)
    VALUES (l_user, 'PASSWORD', l.password_hash, 'PBKDF2-SHA256-' || c_iterations, l.password_salt, SYSTIMESTAMP, 'ACTIVE');
    UPDATE sec_user SET mobile = l.mobile, mfa_required = 'N' WHERE id = l_user;
    UPDATE plt_signup SET tenant_id = l_ten, password_hash = 'USED', status_code = CASE WHEN l.plan_code = 'TRIAL' THEN 'PROVISIONED' ELSE 'PAYMENT_PENDING' END
     WHERE id = l.id;
    SELECT m.id, m.default_company_id, m.default_branch_id INTO l_mem, l_co, l_br FROM sec_user_membership m
     WHERE m.user_id = l_user AND m.tenant_id = l_ten;
    NOONA_CORE_PKG.end_system;
    -- السجل التجاري والرقم الضريبي للشركة (بصلاحيات مسؤول المؤسسة الجديدة)
    -- تجهيز الشركة للأنظمة المختارة (الدليل والسنة المالية والنقدية والمخزون والمبيعات...) بصلاحيات مسؤولها الجديد
    BEGIN
      NOONA_CTX_PKG.set_context(l_ten, l_user, l_mem, l.username, l_co, l_br, 'ar', 'INTERNAL', NULL, NULL, 'Y');
      l_x := NOONA_ACCOUNT_PKG.setup_company;
    EXCEPTION WHEN OTHERS THEN NULL;     -- يستكمل من «بدء التشغيل» (زر تجهيز الأنظمة)
    END;
    NOONA_CTX_PKG.clear_context;
    IF l.cr_no IS NOT NULL OR l.vat_no IS NOT NULL THEN
      BEGIN
        NOONA_CTX_PKG.set_context(l_ten, l_user, l_mem, l.username, l_co, l_br, 'ar', 'INTERNAL', NULL, NULL, 'Y');
        FOR r IN (SELECT 'CR' k, l.cr_no n FROM dual WHERE l.cr_no IS NOT NULL UNION ALL SELECT 'VAT', l.vat_no FROM dual WHERE l.vat_no IS NOT NULL) LOOP
          SELECT MIN(id) INTO l_t FROM loc_registration_type WHERE code = l.country_code || '_' || r.k;
          IF l_t IS NOT NULL THEN
            l_t := NOONA_LOC_PKG.save_registration('{"type":' || l_t || ',"number":"' || r.n || '"}');
          END IF;
        END LOOP;
      EXCEPTION WHEN OTHERS THEN NULL;    -- تستكمل من بيانات الشركة؛ لا تمنع إنشاء المؤسسة
      END;
      NOONA_CTX_PKG.clear_context;
    END IF;
    BEGIN
      NOONA_ACCOUNT_PKG.notify_admins(l_ten, 'مرحباً بك في نونا بلس', 'تم إنشاء مؤسستك ' || l.org_name_ar,
        '<p>اسم الدخول: <b dir="ltr">' || l.username || '</b>. تجربتك المجانية تمتد 14 يوماً بكل الأنظمة التي اخترتها.</p>'
        || '<p>ابدأ من «إدارة المؤسسة ← بدء التشغيل ونقل البيانات» لاستيراد حساباتك وعملائك وأرصدتك من ملفات Excel.</p>'
        || CASE WHEN l.plan_code <> 'TRIAL' THEN '<p>طلبت خطة ' || l.plan_code || ' بمبلغ ' || fmt(l.amount_due)
                || ' ريال؛ تتحول مؤسستك للاشتراك المدفوع فور تأكيد التحويل.</p>' END,
        NOONA_MAIL_PKG.url('NOONA_MASTER', 'home'), 'الدخول إلى النظام');
    EXCEPTION WHEN OTHERS THEN NULL;     -- البريد لا يمنع إنشاء المؤسسة
    END;
    NOONA_CORE_PKG.begin_system;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'PLT_TENANT', l_ten, 'SELF_SIGNUP', 'SUCCESS',
      p_new_values => '{"signup":' || l.id || ',"plan":"' || l.plan_code || '","offerings":"' || l.offerings || '"}');
    NOONA_CORE_PKG.end_system;
    RETURN l.username;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CTX_PKG.clear_context;
    NOONA_CORE_PKG.reset_system;
    RAISE;
  END finish;

  FUNCTION step(p_token IN VARCHAR2) RETURN NUMBER IS
    l plt_signup%ROWTYPE;
  BEGIN
    IF p_token IS NULL THEN RETURN 1; END IF;
    NOONA_CORE_PKG.begin_system;
    BEGIN
      l := get_row(p_token);
    EXCEPTION WHEN OTHERS THEN
      NOONA_CORE_PKG.end_system;
      RETURN 1;
    END;
    NOONA_CORE_PKG.end_system;
    RETURN CASE WHEN l.tenant_id IS NOT NULL THEN 5 WHEN l.status_code = 'STARTED' THEN 2 WHEN l.status_code = 'VERIFIED' THEN 3 ELSE 4 END;
  END step;

  FUNCTION field(p_token IN VARCHAR2, p_name IN VARCHAR2) RETURN VARCHAR2 IS
    l plt_signup%ROWTYPE;
  BEGIN
    IF p_token IS NULL THEN RETURN NULL; END IF;
    NOONA_CORE_PKG.begin_system;
    l := get_row(p_token);
    NOONA_CORE_PKG.end_system;
    RETURN CASE UPPER(p_name) WHEN 'EMAIL' THEN l.email WHEN 'MOBILE' THEN l.mobile WHEN 'USERNAME' THEN l.username
                WHEN 'NAME' THEN l.full_name WHEN 'ORG' THEN l.org_name_ar WHEN 'PLAN' THEN l.plan_code WHEN 'STATUS' THEN l.status_code
                WHEN 'PAYMENT' THEN l.payment_method WHEN 'TOTAL' THEN fmt(l.amount_due) END;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RETURN NULL;
  END field;

  -- ---------------------------------------------------------------- مسؤول المنصة
  FUNCTION st_label(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p WHEN 'STARTED' THEN 'بانتظار التحقق' WHEN 'VERIFIED' THEN 'تحقق' WHEN 'DETAILS' THEN 'بيانات المؤسسة'
                  WHEN 'PROVISIONED' THEN 'تجربة فعالة' WHEN 'PAYMENT_PENDING' THEN 'بانتظار تأكيد التحويل' WHEN 'PAID' THEN 'مدفوع'
                  WHEN 'REJECTED' THEN 'مرفوض' WHEN 'EXPIRED' THEN 'منتهٍ' ELSE p END;
  END st_label;

  FUNCTION signups_html(p_status IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    l_h := '<table class="nn-prj-t"><thead><tr><th>#</th><th>التاريخ</th><th>الاسم</th><th>البريد / الجوال</th><th>المؤسسة</th><th>الأنظمة</th>'
        || '<th class="n">المستخدمون</th><th>الخطة</th><th class="n">المستحق</th><th>مرجع التحويل</th><th>الحالة</th></tr></thead><tbody>';
    FOR s IN (SELECT * FROM plt_signup WHERE (p_status IS NULL OR status_code = p_status) ORDER BY id DESC FETCH FIRST 200 ROWS ONLY) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr><td>' || s.id || '</td><td>' || TO_CHAR(s.created_at, 'YYYY-MM-DD HH24:MI') || '</td><td>' || esc(s.full_name)
          || '<br><small dir="ltr">' || esc(s.username) || '</small></td><td dir="ltr">' || esc(s.email) || '<br>' || esc(s.mobile) || '</td><td>'
          || esc(s.org_name_ar) || CASE WHEN s.cr_no IS NOT NULL THEN '<br><small>س.ت ' || esc(s.cr_no) || '</small>' END || '</td><td>'
          || esc(s.offerings) || '</td><td class="n">' || s.user_count || '</td><td>' || esc(s.plan_code) || '</td><td class="n">' || fmt(s.amount_due)
          || '</td><td>' || esc(s.payment_ref) || '</td><td><span class="nn-badge '
          || CASE s.status_code WHEN 'PAYMENT_PENDING' THEN 'is-warning' WHEN 'PAID' THEN 'is-success' WHEN 'PROVISIONED' THEN 'is-info'
                                WHEN 'REJECTED' THEN 'is-danger' ELSE 'is-muted' END || '">' || st_label(s.status_code) || '</span></td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد طلبات</div>'); END IF;
    RETURN l_h || ('</tbody></table>');
  END signups_html;

  PROCEDURE confirm_payment(p_signup_id IN NUMBER, p_note IN VARCHAR2 DEFAULT NULL) IS
    l     plt_signup%ROWTYPE;
    l_sub NUMBER;
    l_inv VARCHAR2(100);
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    SELECT * INTO l FROM plt_signup WHERE id = p_signup_id FOR UPDATE;
    NOONA_CORE_PKG.assert(l.status_code = 'PAYMENT_PENDING' AND l.tenant_id IS NOT NULL, 'NOONA-SGN-060', 'الطلب ليس بانتظار تأكيد الدفع',
                          'Signup is not awaiting payment');
    -- الاشتراك المدفوع يبدأ من اليوم لمدة الخطة
    l_sub := NOONA_PLATFORM_ADMIN_PKG.set_subscription(l.tenant_id, l.plan_code, TRUNC(SYSDATE), 1, NULL,
               'تأكيد تحويل التسجيل الذاتي ' || l.payment_ref || NVL2(p_note, ' - ' || p_note, ''));
    l_inv := NOONA_ACCOUNT_PKG.issue_invoice(l.tenant_id, 'اشتراك نونا بلس - ' || l.plan_code || ' - ' || REPLACE(l.offerings, ',', '، ')
                                             || ' - ' || l.user_count || ' مستخدمين', JSON_VALUE(l.quote, '$.subtotal' RETURNING NUMBER), l.payment_ref);
    UPDATE plt_signup SET status_code = 'PAID', decided_by = NOONA_CTX_PKG.current_user_name, decision_note = SUBSTR(p_note, 1, 1000),
                          invoice_ref = l_inv
     WHERE id = p_signup_id;
    NOONA_ACCOUNT_PKG.notify_admins(l.tenant_id, 'تم تأكيد اشتراكك - نونا بلس', 'تم تأكيد الدفع',
      '<p>تحول اشتراك مؤسستك إلى خطة ' || l.plan_code || '.' || NVL2(l_inv, ' فاتورتك رقم ' || l_inv || ' مرسلة في رسالة مستقلة.', '') || '</p>',
      NOONA_MAIL_PKG.url('NOONA_ADMIN', 'my-subscription'), 'اشتراكي');
    NOONA_AUDIT_PKG.log_event('CONFIG', 'PLT_TENANT', l.tenant_id, 'CONFIRM_SIGNUP_PAYMENT', 'SUCCESS',
      p_new_values => '{"signup":' || l.id || ',"plan":"' || l.plan_code || '","amount":' || NVL(l.amount_due, 0) || '}', p_reason => p_note);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-SGN-061', 'الطلب غير موجود', 'Signup not found');
  END confirm_payment;

  PROCEDURE reject_signup(p_signup_id IN NUMBER, p_note IN VARCHAR2) IS
    l plt_signup%ROWTYPE;
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.assert(TRIM(p_note) IS NOT NULL, 'NOONA-SGN-062', 'سبب الرفض إلزامي', 'Reason is required');
    SELECT * INTO l FROM plt_signup WHERE id = p_signup_id FOR UPDATE;
    NOONA_CORE_PKG.assert(l.status_code IN ('PAYMENT_PENDING', 'STARTED', 'VERIFIED', 'DETAILS'), 'NOONA-SGN-063',
                          'لا يرفض إلا طلب غير مكتمل أو بانتظار الدفع', 'Only pending signups can be rejected');
    -- المؤسسة المنشأة تبقى في تجربتها حتى تنتهي (لا تحذف بياناتها)؛ يرفض التحويل فقط
    UPDATE plt_signup SET status_code = CASE WHEN l.tenant_id IS NOT NULL THEN 'PROVISIONED' ELSE 'REJECTED' END,
                          decided_by = NOONA_CTX_PKG.current_user_name, decision_note = SUBSTR(p_note, 1, 1000)
     WHERE id = p_signup_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'PLT_SIGNUP', p_signup_id, 'REJECT', 'SUCCESS', p_reason => p_note);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-SGN-061', 'الطلب غير موجود', 'Signup not found');
  END reject_signup;

  PROCEDURE save_offering(p_code IN VARCHAR2, p_price IN NUMBER, p_active IN VARCHAR2 DEFAULT 'Y') IS
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.assert(NVL(p_price, -1) >= 0, 'NOONA-SGN-070', 'السعر لا يكون سالباً', 'Price cannot be negative');
    UPDATE plt_offering SET monthly_price = p_price, is_active = NVL(p_active, 'Y') WHERE code = UPPER(p_code);
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-SGN-071', 'النظام غير موجود', 'Offering not found');
    NOONA_AUDIT_PKG.log_event('CONFIG', 'PLT_OFFERING', NULL, 'PRICE_' || UPPER(p_code), 'SUCCESS', p_new_values => '{"price":' || p_price || '}');
  END save_offering;

  PROCEDURE save_plan_discount(p_plan_code IN VARCHAR2, p_pct IN NUMBER, p_self_service IN VARCHAR2 DEFAULT 'Y') IS
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.assert(NVL(p_pct, -1) BETWEEN 0 AND 90, 'NOONA-SGN-072', 'الخصم بين 0 و 90%', 'Discount must be 0-90%');
    UPDATE plt_plan SET discount_pct = p_pct, self_service = NVL(p_self_service, 'Y') WHERE code = UPPER(p_plan_code);
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-SGN-073', 'الخطة غير موجودة', 'Plan not found');
  END save_plan_discount;

  PROCEDURE save_setting(p_key IN VARCHAR2, p_value IN VARCHAR2) IS
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    NOONA_CORE_PKG.assert(p_key LIKE 'SIGNUP.%' OR p_key LIKE 'MAIL.%' OR p_key LIKE 'PLATFORM.%' OR p_key LIKE 'BILLING.%' OR p_key LIKE 'LOGIN.%', 'NOONA-SGN-074', 'إعداد غير معروف', 'Unknown setting');
    NOONA_CORE_PKG.assert(p_key <> 'SIGNUP.OTP_MODE' OR p_value IN ('DEMO', 'EMAIL'), 'NOONA-SGN-075', 'وضع الرموز: DEMO أو EMAIL', 'OTP mode: DEMO or EMAIL');
    UPDATE plt_setting_def SET default_value = p_value WHERE setting_key = p_key;
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-SGN-074', 'إعداد غير معروف', 'Unknown setting');
    NOONA_AUDIT_PKG.log_event('CONFIG', 'PLT_SETTING_DEF', NULL, p_key, 'SUCCESS');
  END save_setting;

  FUNCTION expire_stale RETURN NUMBER IS
    l NUMBER;
  BEGIN
    NOONA_CORE_PKG.begin_system;
    UPDATE plt_signup SET status_code = 'EXPIRED', password_hash = 'EXPIRED'
     WHERE status_code IN ('STARTED', 'VERIFIED', 'DETAILS') AND created_at < SYSTIMESTAMP - INTERVAL '7' DAY;
    l := SQL%ROWCOUNT;
    NOONA_CORE_PKG.end_system;
    RETURN l;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END expire_stale;

END NOONA_SIGNUP_PKG;
/
