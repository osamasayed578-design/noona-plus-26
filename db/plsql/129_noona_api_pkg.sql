-- =============================================================================
-- NOONA PLUS ERP | NOONA_API_PKG - واجهات REST والأحداث الصادرة والتكاملات
--   * عملاء API: لكل عميل حساب خدمة (مستخدم تكامل) بدور وشركة؛ السر يعرض مرة واحدة ويحفظ Hash فقط
--   * رمز الدخول (POST /v1/token): رمز Bearer مؤقت؛ كل طلب يعمل بجلسة حساب الخدمة فتطبق الصلاحيات وعزل البيانات كالمستخدم العادي
--   * الموجه: سجل نقاط النهاية (API_ENDPOINT) بالصلاحية لكل نقطة، حد المعدل، قائمة IP، Idempotency-Key للعمليات المالية،
--     سجل لكل طلب (بدون أسرار)، وتحويل أخطاء الأعمال إلى أكواد HTTP
--   * الأحداث: publish من حزم الأعمال يكتب في الصندوق الصادر مع المعاملة نفسها؛ الموزع يرسل Webhooks موقعة HMAC-SHA256
--     بإعادة محاولة متزايدة ورسائل SMS/واتساب بقوالب لكل حدث
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_API_PKG AUTHID DEFINER AS
  c_version CONSTANT VARCHAR2(10) := 'v1';

  FUNCTION company RETURN NUMBER;
  FUNCTION status_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION event_label(p_event IN VARCHAR2) RETURN VARCHAR2;
  -- مساعدات (عامة لاستخدامها داخل SQL)
  FUNCTION sha_hex(p IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION param(p_params IN CLOB, p_k IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION render(p_tpl IN VARCHAR2, p_payload IN CLOB) RETURN VARCHAR2;

  -- ---------------------------------------------------------- العملاء
  -- {"name","company","role","description","ips","rate":60,"ttl":60,"expires":"YYYY-MM-DD"}
  -- يعيد {"id","clientId","clientSecret"}: السر لا يمكن استرجاعه بعد ذلك
  FUNCTION create_client(p_doc IN CLOB) RETURN CLOB;
  FUNCTION rotate_secret(p_client_id IN NUMBER) RETURN VARCHAR2;
  PROCEDURE set_client_status(p_client_id IN NUMBER, p_status IN VARCHAR2);
  PROCEDURE revoke_tokens(p_client_id IN NUMBER);

  -- ---------------------------------------------------------- الطلبات
  -- رمز الدخول: {"access_token","token_type":"Bearer","expires_in"}
  FUNCTION issue_token(p_client_key IN VARCHAR2, p_secret IN VARCHAR2, p_ip IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  -- معالجة طلب كامل (قابلة للاختبار دون ORDS): يعيد جسم الاستجابة وحالة HTTP
  FUNCTION handle(p_method IN VARCHAR2, p_route IN VARCHAR2, p_id IN VARCHAR2, p_body IN CLOB, p_auth IN VARCHAR2,
                  p_idem IN VARCHAR2 DEFAULT NULL, p_params IN CLOB DEFAULT NULL, p_ip IN VARCHAR2 DEFAULT NULL,
                  p_status OUT NUMBER) RETURN CLOB;
  -- معالج ORDS: يكتب الاستجابة JSON
  PROCEDURE serve(p_method IN VARCHAR2, p_route IN VARCHAR2, p_id IN VARCHAR2 DEFAULT NULL, p_body IN CLOB DEFAULT NULL,
                  p_auth IN VARCHAR2 DEFAULT NULL, p_idem IN VARCHAR2 DEFAULT NULL, p_q IN VARCHAR2 DEFAULT NULL,
                  p_limit IN VARCHAR2 DEFAULT NULL, p_offset IN VARCHAR2 DEFAULT NULL, p_from IN VARCHAR2 DEFAULT NULL,
                  p_to IN VARCHAR2 DEFAULT NULL, p_filter IN VARCHAR2 DEFAULT NULL, p_status OUT NUMBER);
  -- توصيف OpenAPI 3 من سجل نقاط النهاية
  FUNCTION openapi RETURN CLOB;

  -- ---------------------------------------------------------- الأحداث والـWebhooks
  -- من حزم الأعمال بعد الحدث (لا يرفع خطأ أبداً)
  PROCEDURE publish(p_event IN VARCHAR2, p_entity IN VARCHAR2, p_id IN NUMBER);
  -- {"id","event":"SAL_INVOICE.POSTED|*","url","description","client"} ؛ يعيد {"id","secret"} عند الإنشاء
  FUNCTION save_webhook(p_doc IN CLOB) RETURN CLOB;
  PROCEDURE set_webhook_status(p_webhook_id IN NUMBER, p_status IN VARCHAR2);
  -- يرسل حدث اختبار PING للاشتراك
  FUNCTION test_webhook(p_webhook_id IN NUMBER) RETURN NUMBER;
  -- يعالج المستحق من الصندوق الصادر (لكل المؤسسات في المهمة، أو للمؤسسة الحالية من الشاشة)؛ يعيد عدد المعالج
  FUNCTION dispatch(p_limit IN NUMBER DEFAULT 100) RETURN NUMBER;
  PROCEDURE run_job;
  -- إعادة رسالة ميتة أو فاشلة للطابور
  PROCEDURE retry_outbox(p_outbox_id IN NUMBER);
  -- توقيع Webhook كما يحسبه المستقبل: sha256=hex(HMAC_SHA256(secret, timestamp || '.' || body))
  FUNCTION sign(p_secret IN VARCHAR2, p_timestamp IN VARCHAR2, p_body IN CLOB) RETURN VARCHAR2;

  -- ---------------------------------------------------------- الرسائل (SMS / واتساب)
  -- {"id","channel":"SMS|WHATSAPP","adapter":"SIMULATOR|REST","url","authHeader","secret","body","sender","env",
  --  "rules":[{"event","template"}],"status"}
  FUNCTION save_channel(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION send_message(p_channel IN VARCHAR2, p_to IN VARCHAR2, p_text IN VARCHAR2) RETURN NUMBER;

  -- ---------------------------------------------------------- الشاشات
  FUNCTION summary_html RETURN CLOB;
  FUNCTION clients_html RETURN CLOB;
  FUNCTION requests_html(p_client_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  FUNCTION webhooks_html RETURN CLOB;
  FUNCTION outbox_html(p_status IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION channels_html RETURN CLOB;
  FUNCTION endpoints_html RETURN CLOB;
END NOONA_API_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_API_PKG AS

  g_client    api_client%ROWTYPE;
  g_req_id    VARCHAR2(64);
  e_http      EXCEPTION;
  g_http      NUMBER;
  g_err_code  VARCHAR2(50);
  g_err_msg   VARCHAR2(1000);

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION jt(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_CORE_PKG.json_text(p); END jt;
  FUNCTION ts(p TIMESTAMP WITH LOCAL TIME ZONE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD HH24:MI'); END ts;

  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    IF p_permission NOT LIKE '%.VIEW' THEN
      NOONA_CORE_PKG.assert_tenant_writable;
    END IF;
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  PROCEDURE fail(p_http NUMBER, p_code VARCHAR2, p_msg VARCHAR2) IS
  BEGIN
    g_http := p_http; g_err_code := p_code; g_err_msg := p_msg;
    RAISE e_http;
  END fail;

  FUNCTION js(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_k) AND NOT p_o.get(p_k).is_null THEN TRIM(p_o.get_string(p_k)) END;
  END js;
  FUNCTION jn(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_k) AND NOT p_o.get(p_k).is_null THEN p_o.get_number(p_k) END;
  EXCEPTION WHEN OTHERS THEN
    RETURN TO_NUMBER(REPLACE(p_o.get_string(p_k), ',', ''));
  END jn;

  FUNCTION sha_hex(p IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN LOWER(RAWTOHEX(DBMS_CRYPTO.HASH(UTL_I18N.STRING_TO_RAW(p, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256)));
  END sha_hex;
  FUNCTION sha_clob(p CLOB) RETURN VARCHAR2 IS
  BEGIN
    IF p IS NULL THEN RETURN sha_hex('-'); END IF;
    RETURN LOWER(RAWTOHEX(DBMS_CRYPTO.HASH(p, DBMS_CRYPTO.HASH_SH256)));
  END sha_clob;
  FUNCTION random_key(p_bytes PLS_INTEGER) RETURN VARCHAR2 IS
  BEGIN
    RETURN LOWER(RAWTOHEX(DBMS_CRYPTO.RANDOMBYTES(p_bytes)));
  END random_key;

  -- ================================================================ تشفير الأسرار (مفتاح خاص بالتكاملات)
  FUNCTION enc_key RETURN RAW IS
    l RAW(64);
  BEGIN
    SELECT MAX(key_value) INTO l FROM noona_keystore WHERE key_name = 'API';
    IF l IS NULL THEN
      l := DBMS_CRYPTO.RANDOMBYTES(32);
      INSERT INTO noona_keystore (key_name, key_value) VALUES ('API', l);
    END IF;
    RETURN l;
  END enc_key;
  FUNCTION encrypt(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p IS NULL THEN RETURN NULL; END IF;
    RETURN RAWTOHEX(DBMS_CRYPTO.ENCRYPT(UTL_I18N.STRING_TO_RAW(p, 'AL32UTF8'),
                                        DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5, enc_key));
  END encrypt;
  FUNCTION decrypt(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p IS NULL THEN RETURN NULL; END IF;
    RETURN UTL_I18N.RAW_TO_CHAR(DBMS_CRYPTO.DECRYPT(HEXTORAW(p), DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5, enc_key),
                                'AL32UTF8');
  END decrypt;

  FUNCTION sign(p_secret IN VARCHAR2, p_timestamp IN VARCHAR2, p_body IN CLOB) RETURN VARCHAR2 IS
    l_b BLOB;
  BEGIN
    l_b := APEX_UTIL.clob_to_blob(TO_CLOB(p_timestamp || '.') || p_body, 'AL32UTF8');
    RETURN 'sha256=' || LOWER(RAWTOHEX(DBMS_CRYPTO.MAC(l_b, DBMS_CRYPTO.HMAC_SH256, UTL_I18N.STRING_TO_RAW(p_secret, 'AL32UTF8'))));
  END sign;

  FUNCTION status_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'ACTIVE' THEN 'فعال' WHEN 'SUSPENDED' THEN 'موقوف' WHEN 'REVOKED' THEN 'ملغى' WHEN 'EXPIRED' THEN 'منتهي'
      WHEN 'PAUSED' THEN 'متوقف مؤقتاً' WHEN 'DISABLED' THEN 'معطل' WHEN 'PENDING' THEN 'بالانتظار' WHEN 'PROCESSING' THEN 'قيد المعالجة'
      WHEN 'SENT' THEN 'أرسل' WHEN 'DELIVERED' THEN 'سلم' WHEN 'FAILED' THEN 'فشل (سيعاد)' WHEN 'DEAD' THEN 'متوقف بعد المحاولات'
      WHEN 'CANCELLED' THEN 'ملغى' WHEN 'DRAFT' THEN 'مسودة' ELSE p_code END;
  END status_label;

  FUNCTION badge(p_code VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<span class="nn-badge ' || CASE WHEN p_code IN ('ACTIVE', 'SENT', 'DELIVERED') THEN 'is-success'
                                            WHEN p_code IN ('DEAD', 'REVOKED', 'FAILED') THEN 'is-danger'
                                            WHEN p_code IN ('PENDING', 'PROCESSING', 'PAUSED') THEN 'is-warning' ELSE 'is-muted' END || '">'
        || esc(status_label(p_code)) || '</span>';
  END badge;

  FUNCTION event_label(p_event IN VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(200);
  BEGIN
    l := CASE p_event WHEN 'SAL_INVOICE.POSTED' THEN 'فاتورة مبيعات مرحلة' WHEN 'AR_RECEIPT.CREATED' THEN 'تحصيل من عميل'
      WHEN 'AP_INVOICE.POSTED' THEN 'فاتورة مورد مرحلة' WHEN 'RE_SALE_CONTRACT.SIGNED' THEN 'توقيع عقد بيع وحدة'
      WHEN 'PRP_LEASE.ACTIVATED' THEN 'تفعيل عقد إيجار' WHEN 'AUT_JOB_CARD.READY' THEN 'سيارة جاهزة للاستلام' WHEN 'ORDER.CREATED' THEN 'طلب متجر إلكتروني' WHEN 'PING' THEN 'اختبار'
      WHEN '*' THEN 'كل الأحداث' END;
    RETURN NVL(l, p_event);
  END event_label;

  -- ================================================================ العملاء
  FUNCTION create_client(p_doc IN CLOB) RETURN CLOB IS
    l_o      JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_name   VARCHAR2(200) := js(l_o, 'name');
    l_co     NUMBER := NVL(jn(l_o, 'company'), company);
    l_role   NUMBER := jn(l_o, 'role');
    l_key    VARCHAR2(100);
    l_secret VARCHAR2(100) := random_key(24);
    l_mem    NUMBER;
    l_user   NUMBER;
    l_g      NUMBER;
    l_id     NUMBER;
    l_uname  VARCHAR2(128);
    l_exp    DATE := TO_DATE(js(l_o, 'expires'), 'YYYY-MM-DD');
    l_desc   VARCHAR2(1000); l_ips VARCHAR2(1000); l_rate NUMBER; l_ttl NUMBER;
  BEGIN
    guard('API_CLIENT.CREATE');
    NOONA_CORE_PKG.assert(l_name IS NOT NULL AND l_role IS NOT NULL, 'NOONA-API-001', 'اسم العميل والدور مطلوبان', 'Name and role are required');
    l_key := 'nn_' || random_key(8);
    l_uname := 'API_' || UPPER(SUBSTR(l_key, 4));
    -- حساب الخدمة: عضو في المؤسسة بالدور والشركة المحددين فقط
    l_mem := NOONA_SEC_ADMIN_PKG.create_user(l_uname, 'تكامل: ' || l_name, LOWER(l_uname) || '@api.noona.local', l_co);
    l_g := NOONA_SEC_ADMIN_PKG.grant_role(l_mem, l_role, l_co, 'عميل API: ' || l_name);
    SELECT user_id INTO l_user FROM sec_user_membership WHERE id = l_mem;
    NOONA_CORE_PKG.begin_system;
    UPDATE sec_user SET user_type = 'INTEGRATION' WHERE id = l_user;
    NOONA_CORE_PKG.end_system;
    l_desc := js(l_o, 'description'); l_ips := js(l_o, 'ips'); l_rate := NVL(jn(l_o, 'rate'), 60); l_ttl := NVL(jn(l_o, 'ttl'), 60);
    INSERT INTO api_client (client_id, name_ar, name_en, service_user_id, owner_member_id, company_id, role_id, description, ip_allowlist,
                            rate_limit_per_min, token_ttl_min, expires_at, status_code)
    VALUES (l_key, l_name, l_name, l_user, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID')), l_co, l_role, l_desc, l_ips,
            l_rate, l_ttl, CAST(l_exp AS TIMESTAMP), 'ACTIVE')
    RETURNING id INTO l_id;
    INSERT INTO api_client_secret (api_client_id, secret_hash, secret_hint, status_code)
    VALUES (l_id, sha_hex(l_secret), SUBSTR(l_secret, -4), 'ACTIVE');
    NOONA_AUDIT_PKG.log_event('SECURITY', 'API_CLIENT', l_id, 'CREATE', 'SUCCESS', p_new_values => JSON_OBJECT('client' VALUE l_key, 'role' VALUE l_role));
    RETURN JSON_OBJECT('id' VALUE l_id, 'clientId' VALUE l_key, 'clientSecret' VALUE l_secret);
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END create_client;

  FUNCTION rotate_secret(p_client_id IN NUMBER) RETURN VARCHAR2 IS
    l_secret VARCHAR2(100) := random_key(24);
    l_n      NUMBER;
  BEGIN
    guard('API_CLIENT.UPDATE');
    SELECT COUNT(*) INTO l_n FROM api_client WHERE id = p_client_id;
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-API-002', 'العميل غير موجود', 'Client not found');
    UPDATE api_client_secret SET status_code = 'REVOKED' WHERE api_client_id = p_client_id AND status_code = 'ACTIVE';
    INSERT INTO api_client_secret (api_client_id, secret_hash, secret_hint, status_code)
    VALUES (p_client_id, sha_hex(l_secret), SUBSTR(l_secret, -4), 'ACTIVE');
    revoke_tokens(p_client_id);
    NOONA_AUDIT_PKG.log_event('SECURITY', 'API_CLIENT', p_client_id, 'ROTATE_SECRET', 'SUCCESS');
    RETURN l_secret;
  END rotate_secret;

  PROCEDURE revoke_tokens(p_client_id IN NUMBER) IS
  BEGIN
    guard('API_CLIENT.UPDATE');
    FOR t IN (SELECT id, session_ref FROM api_access_token WHERE api_client_id = p_client_id AND revoked_at IS NULL AND expires_at > SYSTIMESTAMP) LOOP
      UPDATE api_access_token SET revoked_at = SYSTIMESTAMP WHERE id = t.id;
      NOONA_CORE_PKG.begin_system;
      UPDATE sec_session SET status_code = 'TERMINATED', ended_at = SYSTIMESTAMP, end_reason = 'API_TOKEN_REVOKED'
       WHERE apex_session_id = t.session_ref AND status_code = 'ACTIVE';
      NOONA_CORE_PKG.end_system;
    END LOOP;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END revoke_tokens;

  PROCEDURE set_client_status(p_client_id IN NUMBER, p_status IN VARCHAR2) IS
  BEGIN
    guard('API_CLIENT.UPDATE');
    NOONA_CORE_PKG.assert(p_status IN ('ACTIVE', 'SUSPENDED', 'REVOKED'), 'NOONA-API-003', 'حالة غير صحيحة', 'Invalid status');
    UPDATE api_client SET status_code = p_status WHERE id = p_client_id;
    IF p_status <> 'ACTIVE' THEN
      revoke_tokens(p_client_id);
    END IF;
    NOONA_AUDIT_PKG.log_event('SECURITY', 'API_CLIENT', p_client_id, 'STATUS_' || p_status, 'SUCCESS');
  END set_client_status;

  -- ================================================================ الدخول وجلسة الخدمة
  FUNCTION issue_token(p_client_key IN VARCHAR2, p_secret IN VARCHAR2, p_ip IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_c     api_client%ROWTYPE;
    l_n     NUMBER;
    l_tok   VARCHAR2(100) := random_key(32);
    l_ref   NUMBER := 9e15 + TRUNC(DBMS_RANDOM.value(0, 1e15));
    l_uname VARCHAR2(128);
  BEGIN
    NOONA_CORE_PKG.begin_system;
    BEGIN
      SELECT * INTO l_c FROM api_client WHERE client_id = p_client_key;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.end_system;
      fail(401, 'invalid_client', 'Unknown client');
    END;
    SELECT COUNT(*) INTO l_n FROM api_client_secret
     WHERE api_client_id = l_c.id AND status_code = 'ACTIVE' AND secret_hash = sha_hex(p_secret) AND (expires_at IS NULL OR expires_at > SYSTIMESTAMP);
    IF l_n = 0 OR l_c.status_code <> 'ACTIVE' OR (l_c.expires_at IS NOT NULL AND l_c.expires_at < SYSTIMESTAMP) THEN
      NOONA_CORE_PKG.end_system;
      fail(401, 'invalid_client', 'Invalid client credentials or client not active');
    END IF;
    UPDATE api_client_secret SET last_used_at = SYSTIMESTAMP WHERE api_client_id = l_c.id AND status_code = 'ACTIVE';
    SELECT username INTO l_uname FROM sec_user WHERE id = l_c.service_user_id;
    NOONA_CORE_PKG.end_system;
    -- جلسة حساب الخدمة في شركة العميل
    NOONA_SECURITY_PKG.establish_session(p_username => l_uname, p_tenant_id => l_c.tenant_id, p_company_id => l_c.company_id,
                                         p_apex_session_id => l_ref, p_ip_address => p_ip, p_auth_method => 'API_TOKEN');
    INSERT INTO api_access_token (tenant_id, api_client_id, token_hash, session_ref, expires_at, client_ip)
    VALUES (l_c.tenant_id, l_c.id, sha_hex(l_tok), l_ref, SYSTIMESTAMP + NUMTODSINTERVAL(l_c.token_ttl_min, 'MINUTE'), p_ip);
    NOONA_CTX_PKG.clear_context;
    RETURN JSON_OBJECT('access_token' VALUE l_tok, 'token_type' VALUE 'Bearer', 'expires_in' VALUE l_c.token_ttl_min * 60);
  EXCEPTION WHEN e_http THEN RAISE;
    WHEN OTHERS THEN
      NOONA_CORE_PKG.end_system;
      RAISE;
  END issue_token;

  FUNCTION ip_allowed(p_list VARCHAR2, p_ip VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    IF TRIM(p_list) IS NULL THEN RETURN TRUE; END IF;
    FOR r IN (SELECT TRIM(column_value) v FROM TABLE(apex_string.split(p_list, ','))) LOOP
      IF r.v = p_ip OR (r.v LIKE '%*' AND p_ip LIKE REPLACE(r.v, '*', '%')) THEN RETURN TRUE; END IF;
    END LOOP;
    RETURN FALSE;
  END ip_allowed;

  -- يتحقق من رمز Bearer ويفتح جلسة حساب الخدمة
  PROCEDURE authenticate(p_auth VARCHAR2, p_ip VARCHAR2) IS
    l_tok   VARCHAR2(200) := TRIM(REGEXP_REPLACE(p_auth, '^\s*Bearer\s+', '', 1, 1, 'i'));
    l_t     api_access_token%ROWTYPE;
    l_uname VARCHAR2(128);
    l_n     NUMBER;
  BEGIN
    IF l_tok IS NULL OR NOT REGEXP_LIKE(p_auth, '^\s*Bearer\s+\S+', 'i') THEN
      fail(401, 'unauthorized', 'Missing bearer token');
    END IF;
    NOONA_CORE_PKG.begin_system;
    BEGIN
      SELECT * INTO l_t FROM api_access_token WHERE token_hash = sha_hex(l_tok);
      SELECT * INTO g_client FROM api_client WHERE id = l_t.api_client_id;
      SELECT username INTO l_uname FROM sec_user WHERE id = g_client.service_user_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.end_system;
      fail(401, 'invalid_token', 'Unknown token');
    END;
    IF l_t.revoked_at IS NOT NULL OR l_t.expires_at < SYSTIMESTAMP OR g_client.status_code <> 'ACTIVE' THEN
      NOONA_CORE_PKG.end_system;
      fail(401, 'invalid_token', 'Token expired or revoked');
    END IF;
    IF NOT ip_allowed(g_client.ip_allowlist, p_ip) THEN
      NOONA_CORE_PKG.end_system;
      fail(403, 'ip_not_allowed', 'Client IP is not in the allow list');
    END IF;
    -- حد المعدل بالدقيقة
    SELECT COUNT(*) INTO l_n FROM api_request_log WHERE api_client_id = g_client.id AND created_at > SYSTIMESTAMP - INTERVAL '1' MINUTE;
    NOONA_CORE_PKG.end_system;
    IF l_n >= NVL(g_client.rate_limit_per_min, 60) THEN
      fail(429, 'rate_limited', 'Too many requests: limit ' || g_client.rate_limit_per_min || ' per minute');
    END IF;
    NOONA_SECURITY_PKG.attach_session(l_t.session_ref, l_uname);
  EXCEPTION WHEN e_http THEN RAISE;
    WHEN OTHERS THEN
      NOONA_CORE_PKG.end_system;
      fail(401, 'invalid_token', 'Session is no longer valid');
  END authenticate;

  -- في نفس معاملة الطلب: عند الخطأ يتراجع الطلب إلى نقطة الحفظ ثم يسجل، وORDS يثبت بعد المعالج
  PROCEDURE log_request(p_endpoint NUMBER, p_status NUMBER, p_ms NUMBER, p_size NUMBER, p_ip VARCHAR2, p_err VARCHAR2) IS
  BEGIN
    INSERT INTO api_request_log (tenant_id, request_id, correlation_id, api_client_id, endpoint_id, http_status, duration_ms, request_size, client_ip, error_code)
    VALUES (g_client.tenant_id, g_req_id, g_req_id, g_client.id, p_endpoint, p_status, p_ms, p_size, SUBSTR(p_ip, 1, 45), SUBSTR(p_err, 1, 50));
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END log_request;

  -- ================================================================ مساعدات الاستجابة
  FUNCTION param(p_params IN CLOB, p_k IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_params IS NOT NULL THEN JSON_VALUE(p_params, '$."' || p_k || '"') END;
  END param;

  FUNCTION page_of(p_items CLOB, p_limit NUMBER, p_offset NUMBER, p_count NUMBER) RETURN CLOB IS
  BEGIN
    RETURN '{"items":' || NVL(p_items, '[]') || ',"limit":' || p_limit || ',"offset":' || p_offset || ',"count":' || NVL(p_count, 0)
        || ',"hasMore":' || CASE WHEN NVL(p_count, 0) = p_limit THEN 'true' ELSE 'false' END || '}';
  END page_of;

  FUNCTION item_for(p_o JSON_OBJECT_T) RETURN NUMBER IS
    l NUMBER := jn(p_o, 'item');
    l_sku VARCHAR2(100) := js(p_o, 'sku');
  BEGIN
    IF l IS NULL AND l_sku IS NOT NULL THEN
      l := NOONA_INV_PKG.item_by_barcode(l_sku);
      IF l IS NULL THEN
        SELECT MIN(id) INTO l FROM inv_item WHERE item_no = l_sku OR item_code = l_sku;
      END IF;
      IF l IS NULL THEN fail(422, 'unknown_sku', 'Unknown item SKU: ' || l_sku); END IF;
    END IF;
    RETURN l;
  END item_for;

  -- تحويل أسطر الواجهة [{item|sku, description, qty, price, discount, taxCode}] إلى أسطر المستند
  FUNCTION doc_lines(p_lines JSON_ARRAY_T, p_with_disc BOOLEAN) RETURN JSON_ARRAY_T IS
    l_a JSON_ARRAY_T := JSON_ARRAY_T();
    l_i JSON_OBJECT_T;
    l_o JSON_OBJECT_T;
    l_item NUMBER;
  BEGIN
    IF p_lines IS NULL OR p_lines.get_size = 0 THEN fail(400, 'invalid_request', 'lines are required'); END IF;
    FOR k IN 0 .. p_lines.get_size - 1 LOOP
      l_i := TREAT(p_lines.get(k) AS JSON_OBJECT_T);
      l_item := item_for(l_i);
      l_o := JSON_OBJECT_T();
      IF l_item IS NOT NULL THEN l_o.put('i', l_item); END IF;
      IF js(l_i, 'description') IS NOT NULL THEN l_o.put('d', js(l_i, 'description')); END IF;
      l_o.put('q', NVL(jn(l_i, 'qty'), 1));
      IF jn(l_i, 'price') IS NOT NULL THEN l_o.put('p', jn(l_i, 'price')); END IF;
      IF js(l_i, 'priceIncludesTax') IS NOT NULL THEN l_o.put('inc', js(l_i, 'priceIncludesTax')); END IF;
      IF p_with_disc AND jn(l_i, 'discount') IS NOT NULL THEN l_o.put('disc', jn(l_i, 'discount')); END IF;
      IF js(l_i, 'taxCode') IS NOT NULL THEN l_o.put('tc', js(l_i, 'taxCode')); END IF;
      l_a.append(l_o);
    END LOOP;
    RETURN l_a;
  END doc_lines;

  -- ================================================================ نقاط النهاية v1
  FUNCTION r_customers(p_method VARCHAR2, p_id VARCHAR2, p_body CLOB, p_params CLOB, p_status OUT NUMBER) RETURN CLOB IS
    l_c CLOB; l_n NUMBER; l_lim NUMBER := LEAST(NVL(TO_NUMBER(param(p_params, 'limit')), 50), 500);
    l_off NUMBER := NVL(TO_NUMBER(param(p_params, 'offset')), 0); l_q VARCHAR2(200) := param(p_params, 'q'); l_id NUMBER;
  BEGIN
    p_status := 200;
    IF p_method = 'POST' THEN
      l_id := NOONA_SAL_PKG.save_customer(p_body);
      p_status := 201;
      RETURN NOONA_SAL_PKG.customer_json(l_id);
    ELSIF p_id IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM ar_customer_account WHERE id = TO_NUMBER(p_id) AND company_id = company;
      IF l_n = 0 THEN fail(404, 'not_found', 'Customer not found'); END IF;
      l_c := NOONA_SAL_PKG.customer_json(TO_NUMBER(p_id));
      RETURN SUBSTR(l_c, 1, LENGTH(l_c) - 1) || ',"balance":' || NVL(TO_CHAR(NOONA_SAL_PKG.customer_balance(TO_NUMBER(p_id)), 'FM9999999999990.00'), '0') || '}';
    END IF;
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE id, 'number' VALUE account_no, 'name' VALUE name, 'taxNumber' VALUE tax_number, 'mobile' VALUE mobile,
                                     'status' VALUE status_code) ORDER BY name RETURNING CLOB), COUNT(*)
      INTO l_c, l_n
      FROM (SELECT a.id, a.account_no, p.display_name_ar name, p.tax_number, a.status_code,
                   (SELECT MAX(x.mobile) FROM ref_contact x WHERE x.party_id = p.id) mobile
              FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id JOIN pty_party p ON p.id = c.party_id
             WHERE a.company_id = company AND c.is_walk_in = 'N'
               AND (l_q IS NULL OR INSTR(LOWER(p.display_name_ar || ' ' || p.tax_number || ' ' || a.account_no), LOWER(l_q)) > 0)
             ORDER BY p.display_name_ar OFFSET l_off ROWS FETCH NEXT l_lim ROWS ONLY);
    RETURN page_of(l_c, l_lim, l_off, l_n);
  END r_customers;

  FUNCTION r_suppliers(p_method VARCHAR2, p_id VARCHAR2, p_body CLOB, p_params CLOB, p_status OUT NUMBER) RETURN CLOB IS
    l_c CLOB; l_n NUMBER; l_lim NUMBER := LEAST(NVL(TO_NUMBER(param(p_params, 'limit')), 50), 500);
    l_off NUMBER := NVL(TO_NUMBER(param(p_params, 'offset')), 0); l_q VARCHAR2(200) := param(p_params, 'q'); l_id NUMBER;
  BEGIN
    p_status := 200;
    IF p_method = 'POST' THEN
      l_id := NOONA_PUR_PKG.save_supplier(p_body);
      p_status := 201;
      RETURN NOONA_PUR_PKG.supplier_json(l_id);
    ELSIF p_id IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM ap_supplier_account WHERE id = TO_NUMBER(p_id) AND company_id = company;
      IF l_n = 0 THEN fail(404, 'not_found', 'Supplier not found'); END IF;
      RETURN NOONA_PUR_PKG.supplier_json(TO_NUMBER(p_id));
    END IF;
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE id, 'number' VALUE account_no, 'name' VALUE name, 'taxNumber' VALUE tax_number, 'country' VALUE country_code,
                                     'status' VALUE status_code) ORDER BY name RETURNING CLOB), COUNT(*)
      INTO l_c, l_n
      FROM (SELECT a.id, a.account_no, p.display_name_ar name, p.tax_number, p.country_code, a.status_code
              FROM ap_supplier_account a JOIN ap_supplier s ON s.id = a.supplier_id JOIN pty_party p ON p.id = s.party_id
             WHERE a.company_id = company AND (l_q IS NULL OR INSTR(LOWER(p.display_name_ar || ' ' || p.tax_number), LOWER(l_q)) > 0)
             ORDER BY p.display_name_ar OFFSET l_off ROWS FETCH NEXT l_lim ROWS ONLY);
    RETURN page_of(l_c, l_lim, l_off, l_n);
  END r_suppliers;

  FUNCTION r_items(p_method VARCHAR2, p_id VARCHAR2, p_body CLOB, p_params CLOB, p_status OUT NUMBER) RETURN CLOB IS
    l_c CLOB; l_n NUMBER; l_lim NUMBER := LEAST(NVL(TO_NUMBER(param(p_params, 'limit')), 50), 500);
    l_off NUMBER := NVL(TO_NUMBER(param(p_params, 'offset')), 0); l_q VARCHAR2(200) := param(p_params, 'q'); l_id NUMBER;
    l_o JSON_OBJECT_T;
  BEGIN
    p_status := 200;
    IF p_method = 'POST' THEN
      l_o := JSON_OBJECT_T.parse(p_body);
      l_c := NOONA_CONN_PKG.item_doc(NVL(js(l_o, 'number'), js(l_o, 'code')), js(l_o, 'name'), js(l_o, 'nameEn'), js(l_o, 'type'), jn(l_o, 'price'),
                                     js(l_o, 'barcode'), js(l_o, 'category'), NVL(js(l_o, 'priceIncludesTax'), 'N'));
      l_id := NOONA_INV_PKG.save_item(l_c);
      p_status := 201;
      RETURN NOONA_INV_PKG.item_json(l_id);
    ELSIF p_id IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM inv_item WHERE id = TO_NUMBER(p_id);
      IF l_n = 0 THEN fail(404, 'not_found', 'Item not found'); END IF;
      l_c := NOONA_INV_PKG.item_json(TO_NUMBER(p_id));
      RETURN SUBSTR(l_c, 1, LENGTH(l_c) - 1) || ',"onHand":' || NVL(TO_CHAR(NOONA_INV_PKG.on_hand(TO_NUMBER(p_id)), 'FM9999999999990.999'), '0') || '}';
    END IF;
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE id, 'number' VALUE item_no, 'name' VALUE name_ar, 'type' VALUE item_type, 'status' VALUE status_code,
                                     'barcode' VALUE bc) ORDER BY item_no RETURNING CLOB), COUNT(*)
      INTO l_c, l_n
      FROM (SELECT i.id, i.item_no, i.name_ar, i.item_type, i.status_code, (SELECT MIN(b.barcode) FROM inv_item_barcode b WHERE b.item_id = i.id) bc
              FROM inv_item i WHERE i.status_code = 'ACTIVE'
               AND (l_q IS NULL OR INSTR(LOWER(i.name_ar || ' ' || i.item_no || ' ' || i.name_en), LOWER(l_q)) > 0)
             ORDER BY i.item_no OFFSET l_off ROWS FETCH NEXT l_lim ROWS ONLY);
    RETURN page_of(l_c, l_lim, l_off, l_n);
  END r_items;

  FUNCTION r_sales_invoices(p_method VARCHAR2, p_id VARCHAR2, p_body CLOB, p_params CLOB, p_status OUT NUMBER) RETURN CLOB IS
    l_c CLOB; l_n NUMBER; l_lim NUMBER := LEAST(NVL(TO_NUMBER(param(p_params, 'limit')), 50), 500);
    l_off NUMBER := NVL(TO_NUMBER(param(p_params, 'offset')), 0);
    l_from DATE := NVL(TO_DATE(param(p_params, 'from'), 'YYYY-MM-DD'), TRUNC(SYSDATE) - 30);
    l_to DATE := NVL(TO_DATE(param(p_params, 'to'), 'YYYY-MM-DD'), TRUNC(SYSDATE));
    l_o JSON_OBJECT_T; l_d JSON_OBJECT_T := JSON_OBJECT_T(); l_id NUMBER; l_cust NUMBER;
  BEGIN
    p_status := 200;
    IF p_method = 'POST' THEN
      l_o := JSON_OBJECT_T.parse(p_body);
      l_cust := jn(l_o, 'customer');
      IF l_cust IS NULL AND js(l_o, 'customerName') IS NOT NULL THEN
        l_cust := NOONA_SAL_PKG.save_customer(JSON_OBJECT('name' VALUE js(l_o, 'customerName'), 'phone' VALUE js(l_o, 'customerPhone'),
                                                          'tax' VALUE js(l_o, 'customerTaxNumber'), 'term' VALUE 'NET30'));
      END IF;
      IF l_cust IS NOT NULL THEN l_d.put('cust', l_cust); END IF;
      IF js(l_o, 'date') IS NOT NULL THEN l_d.put('date', js(l_o, 'date')); END IF;
      l_d.put('mode', NVL(js(l_o, 'mode'), CASE WHEN l_cust IS NULL THEN 'CASH' ELSE 'CREDIT' END));
      IF js(l_o, 'place') IS NOT NULL THEN l_d.put('place', js(l_o, 'place')); END IF;
      l_d.put('action', CASE WHEN NVL(js(l_o, 'post'), 'true') IN ('false', 'N') THEN 'SAVE' ELSE 'POST' END);
      l_d.put('lines', doc_lines(l_o.get_array('lines'), TRUE));
      l_id := NOONA_SAL_PKG.save_invoice(l_d.to_clob);
      p_status := 201;
      RETURN NOONA_SAL_PKG.invoice_json(l_id);
    ELSIF p_id IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM sal_invoice WHERE id = TO_NUMBER(p_id) AND company_id = company;
      IF l_n = 0 THEN fail(404, 'not_found', 'Invoice not found'); END IF;
      l_c := NOONA_SAL_PKG.invoice_json(TO_NUMBER(p_id));
      SELECT MAX(einvoice_status) INTO g_err_code FROM sal_invoice WHERE id = TO_NUMBER(p_id);
      RETURN SUBSTR(l_c, 1, LENGTH(l_c) - 1) || ',"einvoiceStatus":' || jt(g_err_code) || ',"qr":' || jt(NOONA_EINV_PKG.invoice_qr(TO_NUMBER(p_id))) || '}';
    END IF;
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE id, 'number' VALUE doc_no, 'date' VALUE TO_CHAR(doc_date, 'YYYY-MM-DD'), 'type' VALUE doc_type,
                                     'customer' VALUE customer_account_id, 'customerName' VALUE customer_name_snapshot, 'subtotal' VALUE subtotal,
                                     'tax' VALUE tax_amount, 'total' VALUE total_amount, 'status' VALUE status_code, 'einvoiceStatus' VALUE einvoice_status)
                         ORDER BY doc_date, id RETURNING CLOB), COUNT(*)
      INTO l_c, l_n
      FROM (SELECT * FROM sal_invoice WHERE company_id = company AND doc_date BETWEEN l_from AND l_to AND status_code <> 'DRAFT'
               AND (param(p_params, 'customer') IS NULL OR customer_account_id = TO_NUMBER(param(p_params, 'customer')))
             ORDER BY doc_date, id OFFSET l_off ROWS FETCH NEXT l_lim ROWS ONLY);
    RETURN page_of(l_c, l_lim, l_off, l_n);
  END r_sales_invoices;

  FUNCTION r_receipts(p_body CLOB, p_status OUT NUMBER) RETURN CLOB IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_body);
    l_d   JSON_OBJECT_T := JSON_OBJECT_T();
    l_a   JSON_ARRAY_T := JSON_ARRAY_T();
    l_al  JSON_ARRAY_T;
    l_x   JSON_OBJECT_T;
    l_y   JSON_OBJECT_T;
    l_oi  NUMBER;
    l_id  NUMBER;
    l_c   CLOB;
    l_inv NUMBER;
  BEGIN
    l_d.put('cust', jn(l_o, 'customer')); l_d.put('amount', jn(l_o, 'amount')); l_d.put('place', js(l_o, 'place'));
    l_d.put('method', NVL(js(l_o, 'method'), 'BANK_APP'));
    IF js(l_o, 'date') IS NOT NULL THEN l_d.put('date', js(l_o, 'date')); END IF;
    IF js(l_o, 'reference') IS NOT NULL THEN l_d.put('ref', js(l_o, 'reference')); END IF;
    IF l_o.has('allocations') THEN
      l_al := l_o.get_array('allocations');
      FOR k IN 0 .. l_al.get_size - 1 LOOP
        l_x := TREAT(l_al.get(k) AS JSON_OBJECT_T);
        l_inv := jn(l_x, 'invoice');
        SELECT MIN(id) INTO l_oi FROM ar_open_item WHERE source_entity_type = 'SAL_INVOICE' AND source_entity_id = l_inv AND open_amount > 0;
        IF l_oi IS NULL THEN fail(422, 'not_open', 'Invoice ' || jn(l_x, 'invoice') || ' has no open balance'); END IF;
        l_y := JSON_OBJECT_T(); l_y.put('inv', l_oi); l_y.put('a', jn(l_x, 'amount'));
        l_a.append(l_y);
      END LOOP;
      l_d.put('alloc', l_a);
    END IF;
    l_id := NOONA_SAL_PKG.receive(l_d.to_clob);
    p_status := 201;
    SELECT JSON_OBJECT('id' VALUE id, 'number' VALUE doc_no, 'date' VALUE TO_CHAR(doc_date, 'YYYY-MM-DD'), 'amount' VALUE amount) INTO l_c
      FROM ar_receipt WHERE id = l_id;
    RETURN l_c;
  END r_receipts;

  FUNCTION r_purchase_invoices(p_method VARCHAR2, p_body CLOB, p_params CLOB, p_status OUT NUMBER) RETURN CLOB IS
    l_c CLOB; l_n NUMBER; l_lim NUMBER := LEAST(NVL(TO_NUMBER(param(p_params, 'limit')), 50), 500);
    l_off NUMBER := NVL(TO_NUMBER(param(p_params, 'offset')), 0);
    l_from DATE := NVL(TO_DATE(param(p_params, 'from'), 'YYYY-MM-DD'), TRUNC(SYSDATE) - 30);
    l_to DATE := NVL(TO_DATE(param(p_params, 'to'), 'YYYY-MM-DD'), TRUNC(SYSDATE));
    l_o JSON_OBJECT_T; l_d JSON_OBJECT_T := JSON_OBJECT_T(); l_id NUMBER;
  BEGIN
    p_status := 200;
    IF p_method = 'POST' THEN
      l_o := JSON_OBJECT_T.parse(p_body);
      l_d.put('sup', jn(l_o, 'supplier'));
      IF js(l_o, 'date') IS NOT NULL THEN l_d.put('date', js(l_o, 'date')); END IF;
      l_d.put('supInv', js(l_o, 'supplierInvoiceNumber'));
      l_d.put('mode', NVL(js(l_o, 'mode'), 'CREDIT'));
      IF js(l_o, 'place') IS NOT NULL THEN l_d.put('place', js(l_o, 'place')); END IF;
      l_d.put('action', CASE WHEN NVL(js(l_o, 'post'), 'true') IN ('false', 'N') THEN 'SAVE' ELSE 'POST' END);
      l_d.put('lines', doc_lines(l_o.get_array('lines'), TRUE));
      l_id := NOONA_PUR_PKG.save_invoice(l_d.to_clob);
      p_status := 201;
      RETURN NOONA_PUR_PKG.invoice_json(l_id);
    END IF;
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE id, 'number' VALUE doc_no, 'supplierInvoiceNumber' VALUE supplier_invoice_no,
                                     'date' VALUE TO_CHAR(doc_date, 'YYYY-MM-DD'), 'supplier' VALUE supplier_account_id, 'total' VALUE total_amount,
                                     'status' VALUE status_code) ORDER BY doc_date, id RETURNING CLOB), COUNT(*)
      INTO l_c, l_n
      FROM (SELECT * FROM ap_invoice WHERE company_id = company AND doc_date BETWEEN l_from AND l_to AND status_code <> 'DRAFT'
             ORDER BY doc_date, id OFFSET l_off ROWS FETCH NEXT l_lim ROWS ONLY);
    RETURN page_of(l_c, l_lim, l_off, l_n);
  END r_purchase_invoices;

  FUNCTION r_accounts RETURN CLOB IS
    l_c CLOB;
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE a.id, 'code' VALUE a.account_code, 'name' VALUE a.name_ar, 'type' VALUE a.account_type,
                                     'postable' VALUE a.is_postable) ORDER BY a.account_code RETURNING CLOB)
      INTO l_c FROM gl_account a WHERE a.coa_id = NOONA_GL_PKG.primary_coa AND a.status_code = 'ACTIVE';
    RETURN '{"items":' || NVL(l_c, '[]') || '}';
  END r_accounts;

  FUNCTION r_trial_balance(p_params CLOB) RETURN CLOB IS
    l_c  CLOB;
    l_to DATE := NVL(TO_DATE(param(p_params, 'to'), 'YYYY-MM-DD'), TRUNC(SYSDATE));
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('code' VALUE code, 'name' VALUE name, 'debit' VALUE dr, 'credit' VALUE cr, 'balance' VALUE dr - cr)
                         ORDER BY code RETURNING CLOB)
      INTO l_c
      FROM (SELECT a.account_code code, a.name_ar name, SUM(l.debit_func) dr, SUM(l.credit_func) cr
              FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id
             WHERE j.company_id = company AND j.status_code IN ('POSTED', 'REVERSED') AND j.posting_date <= l_to
             GROUP BY a.account_code, a.name_ar HAVING SUM(l.debit_func) <> 0 OR SUM(l.credit_func) <> 0);
    RETURN '{"asOf":"' || TO_CHAR(l_to, 'YYYY-MM-DD') || '","items":' || NVL(l_c, '[]') || '}';
  END r_trial_balance;

  FUNCTION r_units(p_params CLOB) RETURN CLOB IS
    l_c CLOB;
  BEGIN
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE u.id, 'property' VALUE p.name_ar, 'code' VALUE u.code, 'type' VALUE u.unit_type, 'usage' VALUE u.usage_type,
                                     'area' VALUE NVL(u.net_area_sqm, u.gross_area_sqm), 'bedrooms' VALUE u.bedrooms, 'price' VALUE u.list_price,
                                     'status' VALUE u.status_code) ORDER BY p.code, u.code RETURNING CLOB)
      INTO l_c FROM re_unit u JOIN re_property p ON p.id = u.property_id
     WHERE u.company_id = company AND (param(p_params, 'status') IS NULL OR u.status_code = param(p_params, 'status'))
       AND (param(p_params, 'property') IS NULL OR u.property_id = TO_NUMBER(param(p_params, 'property')));
    RETURN '{"items":' || NVL(l_c, '[]') || '}';
  END r_units;

  FUNCTION r_webhooks(p_method VARCHAR2, p_id VARCHAR2, p_body CLOB, p_status OUT NUMBER) RETURN CLOB IS
    l_c CLOB; l_n NUMBER; l_o JSON_OBJECT_T;
  BEGIN
    p_status := 200;
    IF p_method = 'POST' AND p_id IS NOT NULL THEN
      l_n := test_webhook(TO_NUMBER(p_id));
      p_status := 202;
      RETURN JSON_OBJECT('queued' VALUE l_n);
    ELSIF p_method = 'POST' THEN
      l_o := JSON_OBJECT_T.parse(p_body);
      l_o.put('client', g_client.id);
      p_status := 201;
      RETURN save_webhook(l_o.to_clob);
    ELSIF p_method = 'DELETE' THEN
      SELECT COUNT(*) INTO l_n FROM api_webhook_subscription WHERE id = TO_NUMBER(p_id) AND api_client_id = g_client.id;
      IF l_n = 0 THEN fail(404, 'not_found', 'Webhook not found'); END IF;
      set_webhook_status(TO_NUMBER(p_id), 'DISABLED');
      p_status := 200;
      RETURN '{"deleted":true}';
    END IF;
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE id, 'event' VALUE event_type, 'url' VALUE target_url, 'status' VALUE status_code,
                                     'lastDelivery' VALUE TO_CHAR(last_delivery_at, 'YYYY-MM-DD"T"HH24:MI:SS'), 'lastHttpStatus' VALUE last_http_status)
                         ORDER BY id RETURNING CLOB)
      INTO l_c FROM api_webhook_subscription WHERE api_client_id = g_client.id AND status_code <> 'DISABLED';
    RETURN '{"items":' || NVL(l_c, '[]') || '}';
  END r_webhooks;

  -- ================================================================ الموجه
  FUNCTION route_key(p_route VARCHAR2, p_id VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '/' || p_route || CASE WHEN p_id IS NOT NULL THEN '/{id}' END;
  END route_key;

  FUNCTION handle(p_method IN VARCHAR2, p_route IN VARCHAR2, p_id IN VARCHAR2, p_body IN CLOB, p_auth IN VARCHAR2,
                  p_idem IN VARCHAR2 DEFAULT NULL, p_params IN CLOB DEFAULT NULL, p_ip IN VARCHAR2 DEFAULT NULL,
                  p_status OUT NUMBER) RETURN CLOB IS
    l_t0   TIMESTAMP := SYSTIMESTAMP;
    l_ep   api_endpoint%ROWTYPE;
    l_res  CLOB;
    l_hash VARCHAR2(128);
    l_idk  api_idempotency_key%ROWTYPE;
    l_msg  VARCHAR2(4000);
    l_code VARCHAR2(50);
    l_path VARCHAR2(200) := route_key(p_route, p_id);
    l_o    JSON_OBJECT_T;
  BEGIN
    g_req_id := random_key(12);
    g_client := NULL;
    g_http := NULL;
    SAVEPOINT api_request;
    -- طلبات بلا مصادقة
    IF p_route = 'token' AND p_method = 'POST' THEN
      l_o := JSON_OBJECT_T.parse(NVL(p_body, '{}'));
      l_res := issue_token(NVL(js(l_o, 'client_id'), js(l_o, 'clientId')), NVL(js(l_o, 'client_secret'), js(l_o, 'clientSecret')), p_ip);
      p_status := 200;
      RETURN l_res;
    ELSIF p_route = 'openapi.json' THEN
      p_status := 200;
      RETURN openapi;
    END IF;
    BEGIN
      SELECT * INTO l_ep FROM api_endpoint WHERE api_version = c_version AND http_method = p_method AND path_template = l_path AND is_active = 'Y';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      fail(404, 'not_found', 'No endpoint ' || p_method || ' /' || c_version || l_path);
    END;
    authenticate(p_auth, p_ip);
    IF l_ep.permission_code IS NOT NULL AND NOONA_SECURITY_PKG.has_permission(l_ep.permission_code, company) <> 'Y' THEN
      fail(403, 'forbidden', 'Missing permission ' || l_ep.permission_code);
    END IF;
    IF p_method IN ('POST', 'PUT', 'PATCH') AND l_ep.handler_api <> 'webhooks' THEN
      NOONA_CORE_PKG.assert_tenant_writable;
    END IF;
    -- منع التكرار: نفس المفتاح بنفس الطلب يعيد الاستجابة المخزنة، وبطلب مختلف يرفض
    IF l_ep.requires_idempotency = 'Y' THEN
      IF TRIM(p_idem) IS NULL THEN
        fail(400, 'idempotency_key_required', 'Idempotency-Key header is required for this operation');
      END IF;
      l_hash := sha_clob(p_body);
      BEGIN
        SELECT * INTO l_idk FROM api_idempotency_key WHERE scope_code = l_ep.handler_api AND idempotency_key = TRIM(p_idem);
        IF l_idk.request_hash <> l_hash THEN
          fail(409, 'idempotency_conflict', 'Idempotency-Key was used with a different request');
        END IF;
        p_status := l_idk.response_status;
        log_request(l_ep.id, p_status, EXTRACT(SECOND FROM (SYSTIMESTAMP - l_t0)) * 1000, DBMS_LOB.getlength(p_body), p_ip, 'REPLAY');
        NOONA_CTX_PKG.clear_context;
        RETURN l_idk.response_body;
      EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      END;
    END IF;
    l_res := CASE l_ep.handler_api
      WHEN 'ping' THEN JSON_OBJECT('ok' VALUE 'true', 'client' VALUE g_client.client_id, 'company' VALUE company,
                                   'user' VALUE SYS_CONTEXT('NOONA_CTX', 'USERNAME'), 'time' VALUE TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS'))
      WHEN 'customers' THEN r_customers(p_method, p_id, p_body, p_params, p_status)
      WHEN 'suppliers' THEN r_suppliers(p_method, p_id, p_body, p_params, p_status)
      WHEN 'items' THEN r_items(p_method, p_id, p_body, p_params, p_status)
      WHEN 'sales-invoices' THEN r_sales_invoices(p_method, p_id, p_body, p_params, p_status)
      WHEN 'receipts' THEN r_receipts(p_body, p_status)
      WHEN 'purchase-invoices' THEN r_purchase_invoices(p_method, p_body, p_params, p_status)
      WHEN 'accounts' THEN r_accounts
      WHEN 'trial-balance' THEN r_trial_balance(p_params)
      WHEN 'units' THEN r_units(p_params)
      WHEN 'orders' THEN NOONA_CONN_PKG.ingest_order(p_body, g_client.client_id)
      WHEN 'webhooks' THEN r_webhooks(p_method, p_id, p_body, p_status)
      END;
    p_status := CASE WHEN l_ep.handler_api = 'orders' THEN 201 ELSE NVL(p_status, 200) END;
    IF l_ep.requires_idempotency = 'Y' THEN
      INSERT INTO api_idempotency_key (idempotency_key, scope_code, request_hash, response_status, response_body, expires_at)
      VALUES (TRIM(p_idem), l_ep.handler_api, l_hash, p_status, l_res, SYSTIMESTAMP + INTERVAL '7' DAY);
    END IF;
    log_request(l_ep.id, p_status, EXTRACT(SECOND FROM (SYSTIMESTAMP - l_t0)) * 1000, DBMS_LOB.getlength(p_body), p_ip, NULL);
    NOONA_CTX_PKG.clear_context;
    RETURN l_res;
  EXCEPTION
    WHEN e_http THEN
      ROLLBACK TO api_request;
      p_status := g_http;
      log_request(l_ep.id, p_status, EXTRACT(SECOND FROM (SYSTIMESTAMP - l_t0)) * 1000, DBMS_LOB.getlength(p_body), p_ip, g_err_code);
      NOONA_CTX_PKG.clear_context;
      RETURN JSON_OBJECT('error' VALUE JSON_OBJECT('code' VALUE g_err_code, 'message' VALUE g_err_msg, 'requestId' VALUE g_req_id));
    WHEN OTHERS THEN
      ROLLBACK TO api_request;
      l_msg := SQLERRM;
      l_code := REGEXP_SUBSTR(l_msg, 'NOONA-[A-Z]+-[0-9]+');
      p_status := CASE WHEN l_code IN ('NOONA-SEC-100') THEN 403 WHEN l_code LIKE 'NOONA-SEC-%' THEN 401 WHEN l_code IS NOT NULL THEN 422
                       WHEN SQLCODE IN (-40441, -40587, -1858, -1840, -1722, -6502, -40834) THEN 400 ELSE 500 END;
      log_request(l_ep.id, p_status, EXTRACT(SECOND FROM (SYSTIMESTAMP - l_t0)) * 1000, DBMS_LOB.getlength(p_body), p_ip, NVL(l_code, 'ORA' || SQLCODE));
      NOONA_CTX_PKG.clear_context;
      RETURN JSON_OBJECT('error' VALUE JSON_OBJECT(
               'code' VALUE NVL(l_code, CASE WHEN p_status = 400 THEN 'invalid_request' ELSE 'server_error' END),
               'message' VALUE CASE WHEN l_code IS NOT NULL THEN REGEXP_REPLACE(TRIM(REGEXP_SUBSTR(l_msg, 'NOONA-[A-Z]+-[0-9]+: [^' || CHR(10) || ']+')),
                                                                                '\s*\[cid=[^]]+\]', '')
                                    WHEN p_status = 400 THEN 'Malformed request (JSON, number or date format)' ELSE 'Unexpected error' END,
               'requestId' VALUE g_req_id));
  END handle;

  PROCEDURE serve(p_method IN VARCHAR2, p_route IN VARCHAR2, p_id IN VARCHAR2 DEFAULT NULL, p_body IN CLOB DEFAULT NULL,
                  p_auth IN VARCHAR2 DEFAULT NULL, p_idem IN VARCHAR2 DEFAULT NULL, p_q IN VARCHAR2 DEFAULT NULL,
                  p_limit IN VARCHAR2 DEFAULT NULL, p_offset IN VARCHAR2 DEFAULT NULL, p_from IN VARCHAR2 DEFAULT NULL,
                  p_to IN VARCHAR2 DEFAULT NULL, p_filter IN VARCHAR2 DEFAULT NULL, p_status OUT NUMBER) IS
    l_res    CLOB;
    l_params CLOB;
    l_pos    PLS_INTEGER := 1;
    l_ip     VARCHAR2(100);
  BEGIN
    BEGIN l_ip := OWA_UTIL.get_cgi_env('REMOTE_ADDR'); EXCEPTION WHEN OTHERS THEN NULL; END;
    SELECT JSON_OBJECT('q' VALUE p_q, 'limit' VALUE p_limit, 'offset' VALUE p_offset, 'from' VALUE p_from, 'to' VALUE p_to,
                       'status' VALUE p_filter, 'customer' VALUE CASE WHEN p_route = 'sales-invoices' THEN p_filter END,
                       'property' VALUE CASE WHEN p_route = 'units' THEN p_q END ABSENT ON NULL)
      INTO l_params FROM dual;
    l_res := handle(UPPER(p_method), p_route, p_id, p_body, p_auth, p_idem, l_params, l_ip, p_status);
    OWA_UTIL.mime_header('application/json', FALSE, 'UTF-8');
    HTP.p('X-Request-Id: ' || g_req_id);
    OWA_UTIL.http_header_close;
    WHILE l_pos <= NVL(DBMS_LOB.getlength(l_res), 0) LOOP
      HTP.prn(DBMS_LOB.substr(l_res, 8000, l_pos));
      l_pos := l_pos + 8000;
    END LOOP;
  END serve;

  FUNCTION openapi RETURN CLOB IS
    l_c   CLOB;
    l_p   VARCHAR2(500);
    l_first BOOLEAN := TRUE;
    l_m   VARCHAR2(4000);
  BEGIN
    l_c := '{"openapi":"3.0.3","info":{"title":"NOONA PLUS ERP API","version":"' || c_version || '",'
        || '"description":"REST API. Get a token with POST /token (client_id, client_secret), then send Authorization: Bearer <token>. '
        || 'Financial operations require an Idempotency-Key header. Errors: {error:{code,message,requestId}}."},'
        || '"servers":[{"url":"/ords/noona/' || c_version || '"}],'
        || '"components":{"securitySchemes":{"bearer":{"type":"http","scheme":"bearer"}}},"security":[{"bearer":[]}],"paths":{'
        || '"/token":{"post":{"summary":"Issue access token","security":[],"requestBody":{"content":{"application/json":{"schema":{"type":"object",'
        || '"properties":{"client_id":{"type":"string"},"client_secret":{"type":"string"}}}}}},"responses":{"200":{"description":"Token"}}}}';
    FOR p IN (SELECT DISTINCT path_template FROM api_endpoint WHERE api_version = c_version AND is_active = 'Y' ORDER BY 1) LOOP
      l_c := l_c || (',"' || REPLACE(p.path_template, '{id}', '{id}') || '":{');
      l_first := TRUE;
      FOR e IN (SELECT * FROM api_endpoint WHERE api_version = c_version AND is_active = 'Y' AND path_template = p.path_template ORDER BY http_method) LOOP
        l_m := CASE WHEN l_first THEN '' ELSE ',' END || '"' || LOWER(e.http_method) || '":{"summary":' || jt(e.module_code || ' ' || e.handler_api)
            || ',"x-permission":' || jt(e.permission_code)
            || CASE WHEN INSTR(e.path_template, '{id}') > 0 THEN ',"parameters":[{"name":"id","in":"path","required":true,"schema":{"type":"integer"}}'
                    || CASE WHEN e.requires_idempotency = 'Y' THEN ',{"name":"Idempotency-Key","in":"header","required":true,"schema":{"type":"string"}}' END || ']'
                    WHEN e.requires_idempotency = 'Y' THEN ',"parameters":[{"name":"Idempotency-Key","in":"header","required":true,"schema":{"type":"string"}}]'
                    WHEN e.http_method = 'GET' THEN ',"parameters":[{"name":"q","in":"query","schema":{"type":"string"}},{"name":"limit","in":"query","schema":{"type":"integer"}},'
                         || '{"name":"offset","in":"query","schema":{"type":"integer"}},{"name":"from","in":"query","schema":{"type":"string","format":"date"}},'
                         || '{"name":"to","in":"query","schema":{"type":"string","format":"date"}}]' END
            || CASE WHEN e.http_method IN ('POST', 'PUT', 'PATCH') THEN ',"requestBody":{"content":{"application/json":{"schema":{"type":"object"}}}}' END
            || ',"responses":{"200":{"description":"OK"},"201":{"description":"Created"},"401":{"description":"Unauthorized"},'
            || '"403":{"description":"Forbidden"},"409":{"description":"Idempotency conflict"},"422":{"description":"Business rule violation"},'
            || '"429":{"description":"Rate limited"}}}';
        DBMS_LOB.append(l_c, l_m);
        l_first := FALSE;
      END LOOP;
      DBMS_LOB.append(l_c, '}');
    END LOOP;
    RETURN l_c || ('}}');
  END openapi;

  -- ================================================================ الأحداث
  FUNCTION event_payload(p_event VARCHAR2, p_entity VARCHAR2, p_id NUMBER) RETURN CLOB IS
    l_data   CLOB;
    l_mobile VARCHAR2(50);
    l_name   VARCHAR2(400);
    l_no     VARCHAR2(50);
    l_total  NUMBER;
    l_key    VARCHAR2(40);
    l_res    CLOB;
  BEGIN
    IF p_entity = 'SAL_INVOICE' THEN
      l_data := NOONA_SAL_PKG.invoice_json(p_id);
      SELECT MAX(x.mobile), MAX(i.customer_name_snapshot), MAX(i.doc_no), MAX(i.total_amount) INTO l_mobile, l_name, l_no, l_total
        FROM sal_invoice i JOIN ar_customer_account a ON a.id = i.customer_account_id JOIN ar_customer c ON c.id = a.customer_id
        LEFT JOIN ref_contact x ON x.party_id = c.party_id WHERE i.id = p_id;
    ELSIF p_entity = 'AR_RECEIPT' THEN
      SELECT JSON_OBJECT('id' VALUE r.id, 'number' VALUE r.doc_no, 'date' VALUE TO_CHAR(r.doc_date, 'YYYY-MM-DD'), 'customer' VALUE r.customer_account_id,
                         'amount' VALUE r.amount), MAX(x.mobile), MAX(p.display_name_ar), r.doc_no, r.amount
        INTO l_data, l_mobile, l_name, l_no, l_total
        FROM ar_receipt r JOIN ar_customer_account a ON a.id = r.customer_account_id JOIN ar_customer c ON c.id = a.customer_id
        JOIN pty_party p ON p.id = c.party_id LEFT JOIN ref_contact x ON x.party_id = c.party_id
       WHERE r.id = p_id GROUP BY r.id, r.doc_no, r.doc_date, r.customer_account_id, r.amount;
    ELSIF p_entity = 'AP_INVOICE' THEN
      l_data := NOONA_PUR_PKG.invoice_json(p_id);
    ELSIF p_entity = 'RE_SALE_CONTRACT' THEN
      SELECT JSON_OBJECT('id' VALUE c.id, 'number' VALUE c.doc_no, 'unit' VALUE NOONA_RE_PKG.unit_label(c.unit_id), 'buyer' VALUE p.display_name_ar,
                         'total' VALUE c.total_amount, 'signed' VALUE TO_CHAR(c.signed_date, 'YYYY-MM-DD')),
             (SELECT MAX(mobile) FROM ref_contact x WHERE x.party_id = c.buyer_party_id), p.display_name_ar, c.doc_no, c.total_amount
        INTO l_data, l_mobile, l_name, l_no, l_total
        FROM re_sale_contract c JOIN pty_party p ON p.id = c.buyer_party_id WHERE c.id = p_id;
    ELSIF p_entity = 'PRP_LEASE' THEN
      SELECT JSON_OBJECT('id' VALUE l.id, 'number' VALUE l.doc_no, 'tenant' VALUE p.display_name_ar, 'start' VALUE TO_CHAR(l.start_date, 'YYYY-MM-DD'),
                         'end' VALUE TO_CHAR(l.end_date, 'YYYY-MM-DD'), 'annualRent' VALUE l.annual_rent),
             (SELECT MAX(mobile) FROM ref_contact x WHERE x.party_id = l.lessee_party_id), p.display_name_ar, l.doc_no, l.annual_rent
        INTO l_data, l_mobile, l_name, l_no, l_total
        FROM prp_lease l JOIN pty_party p ON p.id = l.lessee_party_id WHERE l.id = p_id;
    ELSIF p_entity = 'AUT_JOB_CARD' THEN
      SELECT JSON_OBJECT('id' VALUE j.id, 'number' VALUE j.doc_no, 'plate' VALUE v.plate_no, 'vehicle' VALUE v.make || ' ' || v.model,
                         'customer' VALUE j.customer_name, 'total' VALUE j.total_amount,
                         'completed' VALUE TO_CHAR(j.completed_at, 'YYYY-MM-DD"T"HH24:MI:SS')),
             j.customer_phone, j.customer_name, j.doc_no || ' / ' || v.plate_no, j.total_amount
        INTO l_data, l_mobile, l_name, l_no, l_total
        FROM aut_job_card j JOIN aut_vehicle v ON v.id = j.vehicle_id WHERE j.id = p_id;
    END IF;
    l_key := random_key(10);
    SELECT JSON_OBJECT('event' VALUE p_event, 'id' VALUE l_key, 'occurredAt' VALUE TO_CHAR(SYS_EXTRACT_UTC(SYSTIMESTAMP), 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
                       'company' VALUE company, 'entity' VALUE p_entity, 'entityId' VALUE p_id,
                       'notify' VALUE JSON_OBJECT('mobile' VALUE l_mobile, 'name' VALUE l_name, 'number' VALUE l_no, 'total' VALUE l_total),
                       'data' VALUE NVL(l_data, TO_CLOB('{}')) FORMAT JSON RETURNING CLOB)
      INTO l_res FROM dual;
    RETURN l_res;
  END event_payload;

  FUNCTION render(p_tpl IN VARCHAR2, p_payload IN CLOB) RETURN VARCHAR2 IS
  BEGIN
    RETURN REPLACE(REPLACE(REPLACE(REPLACE(p_tpl, '{{name}}', JSON_VALUE(p_payload, '$.notify.name')),
                                   '{{number}}', JSON_VALUE(p_payload, '$.notify.number')),
                           '{{total}}', TO_CHAR(TO_NUMBER(JSON_VALUE(p_payload, '$.notify.total')), 'FM999,999,999,990.00')),
                   '{{company}}', NOONA_APEX_PKG.company_name);
  END render;

  PROCEDURE publish(p_event IN VARCHAR2, p_entity IN VARCHAR2, p_id IN NUMBER) IS
    l_subs    NUMBER;
    l_rules   NUMBER;
    l_payload CLOB;
    l_co      NUMBER := company;
    l_to      VARCHAR2(50);
  BEGIN
    SELECT COUNT(*) INTO l_subs FROM api_webhook_subscription
     WHERE status_code = 'ACTIVE' AND (company_id IS NULL OR company_id = l_co) AND event_type IN (p_event, '*');
    SELECT COUNT(*) INTO l_rules FROM api_integration_config c JOIN api_integration i ON i.id = c.integration_id
     WHERE c.status_code = 'ACTIVE' AND (c.company_id IS NULL OR c.company_id = l_co) AND i.integration_type IN ('SMS', 'WHATSAPP')
       AND JSON_EXISTS(c.config_info, '$.rules[*]?(@.event == $e)' PASSING p_event AS "e");
    IF l_subs + l_rules = 0 THEN
      RETURN;
    END IF;
    l_payload := event_payload(p_event, p_entity, p_id);
    FOR s IN (SELECT id FROM api_webhook_subscription
               WHERE status_code = 'ACTIVE' AND (company_id IS NULL OR company_id = l_co) AND event_type IN (p_event, '*')) LOOP
      INSERT INTO api_outbox (company_id, aggregate_type, aggregate_id, event_type, payload, destination, status_code)
      VALUES (l_co, p_entity, p_id, p_event, l_payload, 'WEBHOOK:' || s.id, 'PENDING');
    END LOOP;
    l_to := JSON_VALUE(l_payload, '$.notify.mobile');
    IF l_to IS NOT NULL THEN
      FOR c IN (SELECT c.id, i.integration_type, r.tpl FROM api_integration_config c JOIN api_integration i ON i.id = c.integration_id,
                       JSON_TABLE(c.config_info, '$.rules[*]' COLUMNS (ev VARCHAR2(100) PATH '$.event', tpl VARCHAR2(1000) PATH '$.template')) r
                 WHERE c.status_code = 'ACTIVE' AND (c.company_id IS NULL OR c.company_id = l_co) AND i.integration_type IN ('SMS', 'WHATSAPP')
                   AND r.ev = p_event) LOOP
        INSERT INTO api_outbox (company_id, aggregate_type, aggregate_id, event_type, payload, destination, status_code)
        VALUES (l_co, p_entity, p_id, p_event, JSON_OBJECT('to' VALUE l_to, 'text' VALUE render(c.tpl, l_payload), 'config' VALUE c.id),
                c.integration_type || ':' || c.id, 'PENDING');
      END LOOP;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    -- النشر لا يوقف المعاملة الأصلية أبداً
    NOONA_AUDIT_PKG.log_event('API', 'API_OUTBOX', p_id, 'PUBLISH_' || p_event, 'FAILURE',
                              p_new_values => JSON_OBJECT('error' VALUE SUBSTR(SQLERRM, 1, 500)));
  END publish;

  FUNCTION save_webhook(p_doc IN CLOB) RETURN CLOB IS
    l_o      JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id     NUMBER := jn(l_o, 'id');
    l_url    VARCHAR2(1000) := js(l_o, 'url');
    l_ev     VARCHAR2(100) := NVL(js(l_o, 'event'), '*');
    l_secret VARCHAR2(100);
    l_desc   VARCHAR2(500) := js(l_o, 'description');
    l_cl     NUMBER := jn(l_o, 'client');
    l_enc    VARCHAR2(400);
  BEGIN
    guard('API_WEBHOOK_SUBSCRIPTION.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(REGEXP_LIKE(l_url, '^(https?|test)://'), 'NOONA-API-010', 'عنوان الاستقبال يبدأ بـ https://', 'Target URL must start with https://');
    NOONA_CORE_PKG.assert(l_ev = '*' OR l_ev IN ('SAL_INVOICE.POSTED', 'AR_RECEIPT.CREATED', 'AP_INVOICE.POSTED', 'RE_SALE_CONTRACT.SIGNED',
                                                 'PRP_LEASE.ACTIVATED', 'AUT_JOB_CARD.READY', 'ORDER.CREATED', 'PING'), 'NOONA-API-011', 'حدث غير معروف: ' || l_ev, 'Unknown event');
    IF l_id IS NULL THEN
      l_secret := 'whsec_' || random_key(20);
      l_enc := encrypt(l_secret);
      INSERT INTO api_webhook_subscription (api_client_id, event_type, target_url, signing_secret_ref, failure_count, company_id, description, status_code)
      VALUES (l_cl, l_ev, l_url, l_enc, 0, company, l_desc, 'ACTIVE')
      RETURNING id INTO l_id;
      RETURN JSON_OBJECT('id' VALUE l_id, 'event' VALUE l_ev, 'url' VALUE l_url, 'secret' VALUE l_secret);
    END IF;
    UPDATE api_webhook_subscription SET event_type = l_ev, target_url = l_url, description = l_desc WHERE id = l_id;
    RETURN JSON_OBJECT('id' VALUE l_id, 'event' VALUE l_ev, 'url' VALUE l_url);
  END save_webhook;

  PROCEDURE set_webhook_status(p_webhook_id IN NUMBER, p_status IN VARCHAR2) IS
  BEGIN
    guard('API_WEBHOOK_SUBSCRIPTION.UPDATE');
    NOONA_CORE_PKG.assert(p_status IN ('ACTIVE', 'PAUSED', 'DISABLED'), 'NOONA-API-003', 'حالة غير صحيحة', 'Invalid status');
    UPDATE api_webhook_subscription SET status_code = p_status, failure_count = CASE WHEN p_status = 'ACTIVE' THEN 0 ELSE failure_count END
     WHERE id = p_webhook_id;
    IF p_status = 'DISABLED' THEN
      UPDATE api_outbox SET status_code = 'CANCELLED' WHERE destination = 'WEBHOOK:' || p_webhook_id AND status_code IN ('PENDING', 'FAILED');
    END IF;
  END set_webhook_status;

  FUNCTION test_webhook(p_webhook_id IN NUMBER) RETURN NUMBER IS
    l_n   NUMBER;
    l_key VARCHAR2(40) := random_key(10);
  BEGIN
    guard('API_WEBHOOK_SUBSCRIPTION.UPDATE');
    SELECT COUNT(*) INTO l_n FROM api_webhook_subscription WHERE id = p_webhook_id AND status_code <> 'DISABLED';
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-API-012', 'الاشتراك غير موجود', 'Webhook not found');
    INSERT INTO api_outbox (company_id, aggregate_type, aggregate_id, event_type, payload, destination, status_code)
    VALUES (company, 'API_WEBHOOK_SUBSCRIPTION', p_webhook_id, 'PING',
            JSON_OBJECT('event' VALUE 'PING', 'id' VALUE l_key, 'occurredAt' VALUE TO_CHAR(SYS_EXTRACT_UTC(SYSTIMESTAMP), 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
                        'data' VALUE JSON_OBJECT('message' VALUE 'NOONA PLUS webhook test')),
            'WEBHOOK:' || p_webhook_id, 'PENDING');
    RETURN 1;
  END test_webhook;

  -- ---------------------------------------------------------------- الإرسال
  -- test://ok و test://fail لاختبار الدورة دون شبكة؛ غير ذلك HTTPS عبر APEX_WEB_SERVICE (يحتاج ACL ومحفظة شهادات)
  FUNCTION http_post(p_url VARCHAR2, p_body CLOB, p_headers SYS.ODCIVARCHAR2LIST, p_resp OUT VARCHAR2) RETURN NUMBER IS
    l_r CLOB;
    k   PLS_INTEGER := 0;
  BEGIN
    IF p_url LIKE 'test://ok%' THEN p_resp := '{"received":true}'; RETURN 200; END IF;
    IF p_url LIKE 'test://fail%' THEN p_resp := 'simulated failure'; RETURN 500; END IF;
    APEX_WEB_SERVICE.g_request_headers.DELETE;
    APEX_WEB_SERVICE.g_request_headers(1).name := 'Content-Type';
    APEX_WEB_SERVICE.g_request_headers(1).value := 'application/json; charset=utf-8';
    FOR i IN 1 .. p_headers.COUNT LOOP
      IF INSTR(p_headers(i), ':') > 0 THEN
        k := APEX_WEB_SERVICE.g_request_headers.COUNT + 1;
        APEX_WEB_SERVICE.g_request_headers(k).name := SUBSTR(p_headers(i), 1, INSTR(p_headers(i), ':') - 1);
        APEX_WEB_SERVICE.g_request_headers(k).value := TRIM(SUBSTR(p_headers(i), INSTR(p_headers(i), ':') + 1));
      END IF;
    END LOOP;
    l_r := APEX_WEB_SERVICE.make_rest_request(p_url => p_url, p_http_method => 'POST', p_body => p_body, p_transfer_timeout => 15);
    p_resp := DBMS_LOB.substr(l_r, 900, 1);
    RETURN APEX_WEB_SERVICE.g_status_code;
  EXCEPTION WHEN OTHERS THEN
    p_resp := SUBSTR(SQLERRM, 1, 900);
    RETURN 0;
  END http_post;

  PROCEDURE send_one(p_outbox_id NUMBER) IS
    o       api_outbox%ROWTYPE;
    s       api_webhook_subscription%ROWTYPE;
    c       api_integration_config%ROWTYPE;
    l_http  NUMBER;
    l_resp  VARCHAR2(1000);
    l_ts    VARCHAR2(20) := TO_CHAR(ROUND((CAST(SYS_EXTRACT_UTC(SYSTIMESTAMP) AS DATE) - DATE '1970-01-01') * 86400));
    l_t0    TIMESTAMP := SYSTIMESTAMP;
    l_ok    BOOLEAN;
    l_y     VARCHAR2(1);
    l_tries NUMBER;
    l_body  CLOB;
    l_hdr   SYS.ODCIVARCHAR2LIST;
    l_url   VARCHAR2(1000);
    l_cfg   CLOB;
  BEGIN
    SELECT * INTO o FROM api_outbox WHERE id = p_outbox_id FOR UPDATE SKIP LOCKED;
    UPDATE api_outbox SET status_code = 'PROCESSING', attempts = attempts + 1 WHERE id = o.id;
    IF o.destination LIKE 'WEBHOOK:%' THEN
      SELECT * INTO s FROM api_webhook_subscription WHERE id = TO_NUMBER(SUBSTR(o.destination, 9));
      IF s.status_code <> 'ACTIVE' AND o.event_type <> 'PING' THEN
        UPDATE api_outbox SET status_code = 'CANCELLED', last_error = 'Subscription ' || s.status_code WHERE id = o.id;
        RETURN;
      END IF;
      l_hdr := SYS.ODCIVARCHAR2LIST('X-Noona-Event: ' || o.event_type, 'X-Noona-Delivery: ' || o.id, 'X-Noona-Timestamp: ' || l_ts,
                                    'X-Noona-Signature: ' || sign(decrypt(s.signing_secret_ref), l_ts, o.payload));
      l_http := http_post(s.target_url, o.payload, l_hdr, l_resp);
      l_ok := l_http BETWEEN 200 AND 299;
      l_y := CASE WHEN l_ok THEN 'Y' ELSE 'N' END;
      INSERT INTO api_webhook_delivery (tenant_id, subscription_id, outbox_id, attempt_no, http_status, duration_ms, next_retry_at, event_type,
                                        response_snippet, status_code)
      VALUES (s.tenant_id, s.id, o.id, o.attempts + 1, l_http, EXTRACT(SECOND FROM (SYSTIMESTAMP - l_t0)) * 1000,
              CASE WHEN l_y = 'N' THEN SYSTIMESTAMP + NUMTODSINTERVAL(LEAST(POWER(2, o.attempts + 1), 360), 'MINUTE') END, o.event_type,
              SUBSTR(l_resp, 1, 1000), CASE WHEN l_y = 'Y' THEN 'DELIVERED' WHEN o.attempts + 1 >= 10 THEN 'DEAD' ELSE 'FAILED' END);
      UPDATE api_webhook_subscription SET last_delivery_at = SYSTIMESTAMP, last_http_status = l_http,
                                          failure_count = CASE WHEN l_y = 'Y' THEN 0 ELSE failure_count + 1 END,
                                          status_code = CASE WHEN l_y = 'N' AND failure_count + 1 >= 50 THEN 'PAUSED' ELSE status_code END
       WHERE id = s.id;
    ELSE
      -- SMS / واتساب
      SELECT * INTO c FROM api_integration_config WHERE id = TO_NUMBER(JSON_VALUE(o.payload, '$.config'));
      l_cfg := c.config_info;
      IF NVL(JSON_VALUE(l_cfg, '$.adapter'), 'SIMULATOR') = 'SIMULATOR' THEN
        l_http := 200; l_resp := 'simulated: ' || JSON_VALUE(o.payload, '$.to');
      ELSE
        l_url := JSON_VALUE(l_cfg, '$.url');
        l_body := REPLACE(REPLACE(REPLACE(JSON_VALUE(l_cfg, '$.body'), '{{to}}', JSON_VALUE(o.payload, '$.to')),
                                  '{{text}}', REPLACE(REPLACE(JSON_VALUE(o.payload, '$.text'), '\', '\\'), '"', '\"')),
                          '{{sender}}', JSON_VALUE(l_cfg, '$.sender'));
        l_hdr := SYS.ODCIVARCHAR2LIST(REPLACE(NVL(JSON_VALUE(l_cfg, '$.authHeader'), 'Authorization: Bearer {{secret}}'), '{{secret}}', decrypt(c.secret_ref)));
        l_http := http_post(l_url, l_body, l_hdr, l_resp);
      END IF;
      l_ok := l_http BETWEEN 200 AND 299;
    END IF;
    l_y := CASE WHEN l_ok THEN 'Y' ELSE 'N' END;
    l_resp := SUBSTR('HTTP ' || l_http || ' ' || l_resp, 1, 1000);
    UPDATE api_outbox SET status_code = CASE WHEN l_y = 'Y' THEN 'SENT' WHEN attempts >= 10 THEN 'DEAD' ELSE 'FAILED' END,
                          processed_at = CASE WHEN l_y = 'Y' THEN SYSTIMESTAMP END, last_error = CASE WHEN l_y = 'N' THEN l_resp END,
                          next_attempt_at = CASE WHEN l_y = 'N' THEN SYSTIMESTAMP + NUMTODSINTERVAL(LEAST(POWER(2, attempts), 360), 'MINUTE') ELSE next_attempt_at END
     WHERE id = o.id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    UPDATE api_outbox SET status_code = 'DEAD', last_error = 'Destination not found' WHERE id = p_outbox_id;
  END send_one;

  FUNCTION dispatch(p_limit IN NUMBER DEFAULT 100) RETURN NUMBER IS
    l_n NUMBER := 0;
    l_t NUMBER := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'TENANT_ID'));
  BEGIN
    IF l_t IS NOT NULL THEN
      guard('API_WEBHOOK_SUBSCRIPTION.UPDATE');
    END IF;
    FOR o IN (SELECT id FROM api_outbox WHERE status_code IN ('PENDING', 'FAILED') AND next_attempt_at <= SYSTIMESTAMP
                -- الصندوق الصادر مشترك مع أحداث داخلية (سير العمل): الموزع يرسل وجهات التكامل فقط
                AND (destination LIKE 'WEBHOOK:%' OR destination LIKE 'SMS:%' OR destination LIKE 'WHATSAPP:%') AND (l_t IS NULL OR tenant_id = l_t)
              ORDER BY priority_no, id FETCH FIRST p_limit ROWS ONLY) LOOP
      send_one(o.id);
      l_n := l_n + 1;
    END LOOP;
    RETURN l_n;
  END dispatch;

  PROCEDURE run_job IS
    l_n NUMBER;
  BEGIN
    NOONA_CTX_PKG.clear_context;
    NOONA_CORE_PKG.begin_system;
    l_n := dispatch(500);
    DELETE FROM api_idempotency_key WHERE expires_at < SYSTIMESTAMP;
    UPDATE api_access_token SET revoked_at = NVL(revoked_at, expires_at) WHERE expires_at < SYSTIMESTAMP - INTERVAL '1' DAY AND revoked_at IS NULL;
    NOONA_CORE_PKG.end_system;
    COMMIT;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    ROLLBACK;
    RAISE;
  END run_job;

  PROCEDURE retry_outbox(p_outbox_id IN NUMBER) IS
  BEGIN
    guard('API_WEBHOOK_SUBSCRIPTION.UPDATE');
    UPDATE api_outbox SET status_code = 'PENDING', attempts = 0, next_attempt_at = SYSTIMESTAMP, last_error = NULL
     WHERE id = p_outbox_id AND status_code IN ('DEAD', 'FAILED', 'CANCELLED');
  END retry_outbox;

  -- ================================================================ الرسائل
  FUNCTION integration_id(p_type VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    -- المنصة تزرعها عامة (seed 18)؛ وإن غابت تنشأ هنا
    SELECT MIN(id) INTO l FROM api_integration WHERE code = p_type || '_GATEWAY';
    IF l IS NULL THEN
      NOONA_CORE_PKG.begin_system;
      INSERT INTO api_integration (tenant_id, code, name_ar, name_en, provider_name, integration_type, direction, auth_method, handles_pii,
                                   idempotency_strategy, status_code)
      VALUES (NULL, p_type || '_GATEWAY', CASE p_type WHEN 'SMS' THEN 'بوابة الرسائل النصية' ELSE 'واتساب للأعمال' END, p_type || ' gateway',
              'Generic REST', p_type, 'OUTBOUND', 'API_KEY', 'Y', 'معرف الرسالة في الصندوق الصادر', 'ACTIVE')
      RETURNING id INTO l;
      NOONA_CORE_PKG.end_system;
    END IF;
    RETURN l;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END integration_id;

  FUNCTION save_channel(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := jn(l_o, 'id');
    l_ch   VARCHAR2(30) := NVL(js(l_o, 'channel'), 'SMS');
    l_cfg  JSON_OBJECT_T := JSON_OBJECT_T();
    l_sec  VARCHAR2(500) := js(l_o, 'secret');
    l_env  VARCHAR2(30) := NVL(js(l_o, 'env'), 'PRODUCTION');
    l_int  NUMBER;
    l_st   VARCHAR2(30) := NVL(js(l_o, 'status'), 'ACTIVE');
    l_cfgc CLOB;
    l_secr VARCHAR2(1000);
  BEGIN
    guard('API_INTEGRATION_CONFIG.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_ch IN ('SMS', 'WHATSAPP'), 'NOONA-API-020', 'القناة SMS أو WHATSAPP', 'Channel must be SMS or WHATSAPP');
    l_cfg.put('adapter', NVL(js(l_o, 'adapter'), 'SIMULATOR'));
    NOONA_CORE_PKG.assert(js(l_o, 'adapter') IS NULL OR js(l_o, 'adapter') = 'SIMULATOR' OR js(l_o, 'url') LIKE 'http%', 'NOONA-API-021',
                          'أدخل عنوان مزود الرسائل', 'Provider URL is required');
    l_cfg.put('url', js(l_o, 'url')); l_cfg.put('authHeader', js(l_o, 'authHeader'));
    l_cfg.put('body', NVL(js(l_o, 'body'), '{"to":"{{to}}","text":"{{text}}","sender":"{{sender}}"}')); l_cfg.put('sender', js(l_o, 'sender'));
    IF l_o.has('rules') THEN l_cfg.put('rules', l_o.get_array('rules')); ELSE l_cfg.put('rules', JSON_ARRAY_T()); END IF;
    l_int := integration_id(l_ch);
    l_cfgc := l_cfg.to_clob;
    l_secr := encrypt(l_sec);
    IF l_id IS NULL THEN
      SELECT MIN(id) INTO l_id FROM api_integration_config WHERE integration_id = l_int AND company_id = company AND environment = l_env;
    END IF;
    IF l_id IS NULL THEN
      INSERT INTO api_integration_config (integration_id, company_id, environment, config_info, secret_ref, status_code)
      VALUES (l_int, company, l_env, l_cfgc, l_secr, l_st)
      RETURNING id INTO l_id;
    ELSE
      UPDATE api_integration_config SET config_info = l_cfgc, secret_ref = NVL(l_secr, secret_ref), status_code = l_st, environment = l_env
       WHERE id = l_id;
    END IF;
    RETURN l_id;
  END save_channel;

  FUNCTION send_message(p_channel IN VARCHAR2, p_to IN VARCHAR2, p_text IN VARCHAR2) RETURN NUMBER IS
    l_cfg NUMBER;
    l_id  NUMBER;
  BEGIN
    guard('API_INTEGRATION_CONFIG.UPDATE');
    SELECT MIN(c.id) INTO l_cfg FROM api_integration_config c JOIN api_integration i ON i.id = c.integration_id
     WHERE i.integration_type = p_channel AND c.status_code = 'ACTIVE' AND (c.company_id IS NULL OR c.company_id = company);
    NOONA_CORE_PKG.assert(l_cfg IS NOT NULL, 'NOONA-API-022', 'لا يوجد إعداد فعال لقناة ' || p_channel, 'Channel is not configured');
    NOONA_CORE_PKG.assert(REGEXP_LIKE(p_to, '^\+?[0-9]{8,15}$') AND TRIM(p_text) IS NOT NULL, 'NOONA-API-023', 'رقم الجوال أو النص غير صحيح',
                          'Invalid number or text');
    INSERT INTO api_outbox (company_id, aggregate_type, aggregate_id, event_type, payload, destination, status_code)
    VALUES (company, 'API_INTEGRATION_CONFIG', l_cfg, 'MESSAGE', JSON_OBJECT('to' VALUE p_to, 'text' VALUE p_text, 'config' VALUE l_cfg),
            p_channel || ':' || l_cfg, 'PENDING')
    RETURNING id INTO l_id;
    RETURN l_id;
  END send_message;

  -- ================================================================ الشاشات
  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_cls VARCHAR2 DEFAULT 'is-info') RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_cls || '"><span class="nn-kpi-icon fa ' || p_icon || '" aria-hidden="true"></span><div><div class="nn-kpi-value">'
        || p_value || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION summary_html RETURN CLOB IS
    l_cl NUMBER; l_req NUMBER; l_err NUMBER; l_wh NUMBER; l_pend NUMBER; l_dead NUMBER;
  BEGIN
    guard('API_CLIENT.VIEW');
    SELECT COUNT(*) INTO l_cl FROM api_client WHERE status_code = 'ACTIVE';
    SELECT COUNT(*), COUNT(CASE WHEN http_status >= 400 THEN 1 END) INTO l_req, l_err FROM api_request_log WHERE created_at > SYSTIMESTAMP - 1;
    SELECT COUNT(*) INTO l_wh FROM api_webhook_subscription WHERE status_code = 'ACTIVE';
    SELECT COUNT(CASE WHEN status_code IN ('PENDING', 'FAILED') THEN 1 END), COUNT(CASE WHEN status_code = 'DEAD' THEN 1 END) INTO l_pend, l_dead FROM api_outbox
     WHERE (destination LIKE 'WEBHOOK:%' OR destination LIKE 'SMS:%' OR destination LIKE 'WHATSAPP:%');
    RETURN '<div class="nn-kpis">' || kpi('عملاء API فعالون', l_cl, 'fa-key', 'is-info') || kpi('طلبات آخر 24 ساعة', l_req, 'fa-exchange', 'is-info')
        || kpi('طلبات بأخطاء', l_err, 'fa-exclamation-circle', CASE WHEN l_err > 0 THEN 'is-warning' ELSE 'is-muted' END)
        || kpi('اشتراكات Webhook', l_wh, 'fa-bolt', 'is-success')
        || kpi('أحداث بالانتظار', l_pend, 'fa-clock-o', CASE WHEN l_pend > 0 THEN 'is-warning' ELSE 'is-muted' END)
        || kpi('أحداث متوقفة', l_dead, 'fa-ban', CASE WHEN l_dead > 0 THEN 'is-danger' ELSE 'is-muted' END) || '</div>';
  END summary_html;

  FUNCTION clients_html RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('API_CLIENT.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>العميل</th><th>معرف العميل</th><th>الشركة</th><th>الدور</th><th>حد المعدل</th><th>IP</th>'
        || '<th>آخر استخدام</th><th>طلبات اليوم</th><th>الحالة</th></tr></thead><tbody>';
    FOR c IN (SELECT c.*, o.legal_name_ar coname, r.name_ar rname,
                     (SELECT MAX(last_used_at) FROM api_client_secret s WHERE s.api_client_id = c.id) used,
                     (SELECT COUNT(*) FROM api_request_log g WHERE g.api_client_id = c.id AND g.created_at > TRUNC(SYSTIMESTAMP)) today,
                     (SELECT MAX(secret_hint) FROM api_client_secret s WHERE s.api_client_id = c.id AND s.status_code = 'ACTIVE') hint
                FROM api_client c LEFT JOIN org_company o ON o.id = c.company_id LEFT JOIN sec_role r ON r.id = c.role_id ORDER BY c.id DESC) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr data-client="' || c.id || '"><td><b>' || esc(c.name_ar) || '</b><br><small>' || esc(c.description) || '</small></td><td dir="ltr"><code>'
          || esc(c.client_id) || '</code><br><small>سر ينتهي بـ …' || esc(c.hint) || '</small></td><td>' || esc(c.coname) || '</td><td>' || esc(c.rname)
          || '</td><td>' || c.rate_limit_per_min || '/دقيقة</td><td dir="ltr"><small>' || esc(NVL(c.ip_allowlist, 'الكل')) || '</small></td><td>' || ts(c.used)
          || '</td><td>' || c.today || '</td><td>' || badge(c.status_code) || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا يوجد عملاء API؛ أنشئ عميلاً لكل نظام يتكامل معكم</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody></table>');
  END clients_html;

  FUNCTION requests_html(p_client_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('API_CLIENT.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>الوقت</th><th>العميل</th><th>الطلب</th><th>الحالة</th><th class="n">المدة (ms)</th><th>IP</th>'
        || '<th>الخطأ</th><th>معرف الطلب</th></tr></thead><tbody>';
    FOR r IN (SELECT g.*, c.name_ar cname, e.http_method, e.path_template FROM api_request_log g LEFT JOIN api_client c ON c.id = g.api_client_id
                LEFT JOIN api_endpoint e ON e.id = g.endpoint_id
               WHERE (p_client_id IS NULL OR g.api_client_id = p_client_id) ORDER BY g.id DESC FETCH FIRST 200 ROWS ONLY) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr><td>' || TO_CHAR(r.created_at, 'YYYY-MM-DD HH24:MI:SS') || '</td><td>' || esc(r.cname) || '</td><td dir="ltr"><code>'
          || esc(r.http_method || ' /' || c_version || r.path_template) || '</code></td><td><span class="nn-badge '
          || CASE WHEN r.http_status < 300 THEN 'is-success' WHEN r.http_status < 500 THEN 'is-warning' ELSE 'is-danger' END || '">' || r.http_status
          || '</span></td><td class="n">' || r.duration_ms || '</td><td dir="ltr">' || esc(r.client_ip) || '</td><td>' || esc(r.error_code) || '</td><td dir="ltr"><small>'
          || esc(r.request_id) || '</small></td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد طلبات بعد</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody></table>');
  END requests_html;

  FUNCTION webhooks_html RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('API_WEBHOOK_SUBSCRIPTION.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>الحدث</th><th>العنوان</th><th>العميل</th><th>آخر تسليم</th><th>آخر استجابة</th><th>إخفاقات متتالية</th>'
        || '<th>الحالة</th></tr></thead><tbody>';
    FOR w IN (SELECT w.*, c.name_ar cname FROM api_webhook_subscription w LEFT JOIN api_client c ON c.id = w.api_client_id
               WHERE w.status_code <> 'DISABLED' ORDER BY w.id DESC) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr data-wh="' || w.id || '"><td>' || esc(event_label(w.event_type)) || '<br><small dir="ltr">' || esc(w.event_type) || '</small></td><td dir="ltr"><small>'
          || esc(w.target_url) || '</small><br><small>' || esc(w.description) || '</small></td><td>' || esc(NVL(w.cname, 'من الشاشة')) || '</td><td>'
          || ts(w.last_delivery_at) || '</td><td>' || w.last_http_status || '</td><td>' || w.failure_count || '</td><td>' || badge(w.status_code) || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد اشتراكات Webhook</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody></table>');
  END webhooks_html;

  FUNCTION outbox_html(p_status IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('API_WEBHOOK_SUBSCRIPTION.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>#</th><th>الوقت</th><th>الحدث</th><th>الوجهة</th><th>المحاولات</th><th>المحاولة التالية</th>'
        || '<th>آخر خطأ</th><th>الحالة</th></tr></thead><tbody>';
    FOR o IN (SELECT * FROM api_outbox WHERE (p_status IS NULL OR status_code = p_status) AND (destination LIKE 'WEBHOOK:%' OR destination LIKE 'SMS:%' OR destination LIKE 'WHATSAPP:%')
               ORDER BY id DESC FETCH FIRST 200 ROWS ONLY) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr data-outbox="' || o.id || '"><td>' || o.id || '</td><td>' || TO_CHAR(o.created_at, 'YYYY-MM-DD HH24:MI') || '</td><td>' || esc(event_label(o.event_type)) || '</td><td dir="ltr">'
          || esc(o.destination) || '</td><td>' || TO_CHAR(o.attempts) || '</td><td>' || CASE WHEN o.status_code IN ('PENDING', 'FAILED') THEN TO_CHAR(o.next_attempt_at, 'YYYY-MM-DD HH24:MI') END
          || '</td><td><small>' || esc(SUBSTR(o.last_error, 1, 160)) || '</small></td><td>' || badge(o.status_code) || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد أحداث صادرة</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody></table>');
  END outbox_html;

  FUNCTION channels_html RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
    l_r VARCHAR2(4000);
  BEGIN
    guard('API_INTEGRATION_CONFIG.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>القناة</th><th>المحول</th><th>المزود</th><th>المرسل</th><th>القواعد</th><th>الحالة</th></tr></thead><tbody>';
    FOR c IN (SELECT c.*, i.integration_type FROM api_integration_config c JOIN api_integration i ON i.id = c.integration_id
               WHERE i.integration_type IN ('SMS', 'WHATSAPP') ORDER BY c.id) LOOP
      l_n := l_n + 1;
      SELECT LISTAGG(event_label(ev) || ': ' || tpl, '<br>') WITHIN GROUP (ORDER BY ev) INTO l_r
        FROM JSON_TABLE(c.config_info, '$.rules[*]' COLUMNS (ev VARCHAR2(100) PATH '$.event', tpl VARCHAR2(300) PATH '$.template'));
      l_h := l_h || ('<tr><td>' || CASE c.integration_type WHEN 'SMS' THEN 'رسائل نصية' ELSE 'واتساب' END || '</td><td>'
          || CASE JSON_VALUE(c.config_info, '$.adapter') WHEN 'REST' THEN 'مزود REST' ELSE 'المحاكي' END || '</td><td dir="ltr"><small>'
          || esc(JSON_VALUE(c.config_info, '$.url')) || '</small></td><td>' || esc(JSON_VALUE(c.config_info, '$.sender')) || '</td><td><small>' || l_r
          || '</small></td><td>' || badge(c.status_code) || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد قنوات رسائل</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody></table>');
  END channels_html;

  FUNCTION endpoints_html RETURN CLOB IS
    l_h CLOB;
  BEGIN
    guard('API_CLIENT.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>الطريقة</th><th>المسار</th><th>الوحدة</th><th>الصلاحية المطلوبة</th><th>منع التكرار</th></tr></thead><tbody>'
        || '<tr><td dir="ltr"><code>POST</code></td><td dir="ltr"><code>/' || c_version || '/token</code></td><td>دخول</td><td>-</td><td></td></tr>';
    FOR e IN (SELECT * FROM api_endpoint WHERE api_version = c_version AND is_active = 'Y' ORDER BY path_template, http_method) LOOP
      l_h := l_h || ('<tr><td dir="ltr"><code>' || e.http_method || '</code></td><td dir="ltr"><code>/' || c_version || esc(e.path_template) || '</code></td><td>'
          || esc(e.module_code) || '</td><td dir="ltr"><small>' || esc(e.permission_code) || '</small></td><td>'
          || CASE WHEN e.requires_idempotency = 'Y' THEN '<span class="nn-badge is-info">مطلوب</span>' END || '</td></tr>');
    END LOOP;
    RETURN l_h || ('</tbody></table>');
  END endpoints_html;
END NOONA_API_PKG;
/
SHOW ERRORS PACKAGE BODY NOONA_API_PKG
