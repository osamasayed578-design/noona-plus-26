-- =============================================================================
-- NOONA PLUS ERP | الربط الإلكتروني للمستشفى: NOONA_HIS_LINK_PKG
--   قنوات الربط (شركات التأمين أو بوابة المطالبات، ومنصة الوصفات الإلكترونية) بثلاث طرق:
--     SIMULATOR  محاكاة داخلية للتجربة والتدريب (قواعد ثابتة موثقة)
--     REST       طلبات JSON إلى عنوان القناة عبر APEX_WEB_SERVICE (يحتاج صلاحية شبكة ACL ومحفظة شهادات لـ HTTPS)
--     EMAIL      إرسال الطلب ملفاً مرفقاً إلى بريد الجهة (من داخل التطبيق؛ يسجل الرد يدوياً)
--   الرسائل: التحقق من الأهلية، طلب الموافقة المسبقة ومتابعته، إرسال دفعة المطالبات ومتابعة قرارها، إرسال الوصفة وإلغاؤها.
--   كل رسالة تحفظ بطلبها واستجابتها وحالتها في HIS_LINK_MESSAGE، وأسرار القنوات مشفرة (AES-256) بمفتاح المنشأة.
--   صيغة الرسائل: NOONA HIS exchange v1 (docs/healthcare.md) - تحولها بوابة الربط إلى صيغة الجهة (مثل FHIR) عند الحاجة.
-- =============================================================================
SET DEFINE OFF

-- مخزن مفتاح التشفير: للمالك فقط (لا يمنح للتطبيق ولا يصدر)
DECLARE
  l_n NUMBER;
BEGIN
  SELECT COUNT(*) INTO l_n FROM user_tables WHERE table_name = 'NOONA_KEYSTORE';
  IF l_n = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLE NOONA_KEYSTORE (KEY_NAME VARCHAR2(30 CHAR) NOT NULL, KEY_VALUE RAW(64) NOT NULL, '
                   || 'CREATED_AT TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL, CONSTRAINT NOONA_KEYSTORE_PK PRIMARY KEY (KEY_NAME))';
  END IF;
END;
/

CREATE OR REPLACE PACKAGE NOONA_HIS_LINK_PKG AUTHID DEFINER AS

  FUNCTION company RETURN NUMBER;
  FUNCTION ymd(p IN DATE) RETURN VARCHAR2;

  -- ---------------------------------------------------------- القنوات
  -- {"id","code","name","kind":"INSURANCE|ERX","mode":"SIMULATOR|REST|EMAIL","url","auth":"NONE|BASIC|BEARER|API_KEY","user","secret",
  --  "key_header","provider","email","timeout","wallet","status"} ؛ السر الفارغ يبقي السر الحالي
  FUNCTION save_integration(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE set_payer_link(p_payer_id IN NUMBER, p_integration_id IN NUMBER, p_link_code IN VARCHAR2);
  -- اختبار الاتصال؛ يعيد الخلاصة
  FUNCTION test_connection(p_integration_id IN NUMBER) RETURN VARCHAR2;
  -- قناة الوصفات الإلكترونية النشطة (NULL إن لم توجد)
  FUNCTION erx_channel RETURN NUMBER;
  FUNCTION payer_channel(p_payer_id IN NUMBER) RETURN NUMBER;
  FUNCTION has_secret(p_integration_id IN NUMBER) RETURN VARCHAR2;

  -- ---------------------------------------------------------- العمليات (تعيد الحالة: ELIGIBLE/NOT_ELIGIBLE/APPROVED/REJECTED/PENDING/SENT/ERROR)
  FUNCTION check_eligibility(p_visit_id IN NUMBER) RETURN VARCHAR2;
  -- طلب موافقة مسبقة لطلب بانتظار الموافقة؛ القبول أو الرفض يطبق على الطلب مباشرة
  FUNCTION request_preauth(p_order_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION poll_preauth(p_order_id IN NUMBER) RETURN VARCHAR2;
  -- إرسال دفعة مسودة إلكترونياً (تصبح مرسلة بمرجع الجهة) ومتابعة قرارها (يسجل الرد والرفض تلقائياً)
  FUNCTION send_claim(p_batch_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION poll_claim(p_batch_id IN NUMBER) RETURN VARCHAR2;
  -- الوصفة إلى منصة الوصفات الإلكترونية (لا يمنع خطأ الإرسال حفظ الوصفة)
  FUNCTION send_prescription(p_rx_id IN NUMBER) RETURN VARCHAR2;
  PROCEDURE cancel_prescription(p_rx_id IN NUMBER);
  -- إعادة إرسال رسالة متعثرة، ومعالجة المتعثر (للمهمة المجدولة)؛ يعيد عدد الرسائل المعالجة
  FUNCTION retry(p_message_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION can_retry(p_message_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION process_pending RETURN NUMBER;

  -- ---------------------------------------------------------- العرض
  FUNCTION message_html(p_message_id IN NUMBER) RETURN CLOB;
  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION type_label(p_type IN VARCHAR2) RETURN VARCHAR2;
  -- استجابة المحاكي لطلب (عامة للاختبار والتوثيق)
  FUNCTION simulate(p_type IN VARCHAR2, p_request IN CLOB) RETURN CLOB;
END NOONA_HIS_LINK_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_HIS_LINK_PKG AS

  c_msg CONSTANT VARCHAR2(30) := 'HIS_LINK_MESSAGE';

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;
  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END;
  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;
  FUNCTION ymd(p IN DATE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD'); END;
  FUNCTION next_no RETURN VARCHAR2 IS
  BEGIN
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT company, c_msg, NULL, 'LM-', 1, 7, 'N', 'NEVER', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = c_msg);
    RETURN NOONA_REFERENCE_PKG.next_doc_no(c_msg, company, NULL, TRUNC(SYSDATE), c_msg, NULL);
  END next_no;

  -- ================================================================ تشفير الأسرار
  FUNCTION enc_key RETURN RAW IS
    l RAW(64);
  BEGIN
    SELECT MAX(key_value) INTO l FROM noona_keystore WHERE key_name = 'HIS_LINK';
    IF l IS NULL THEN
      l := DBMS_CRYPTO.RANDOMBYTES(32);
      INSERT INTO noona_keystore (key_name, key_value) VALUES ('HIS_LINK', l);
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

  -- ================================================================ المسميات
  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_status WHEN 'QUEUED' THEN 'بالانتظار' WHEN 'SENT' THEN 'مرسلة' WHEN 'ACCEPTED' THEN 'مقبولة' WHEN 'PENDING' THEN 'قيد المراجعة'
      WHEN 'REJECTED' THEN 'مرفوضة' WHEN 'ERROR' THEN 'خطأ اتصال' WHEN 'ELIGIBLE' THEN 'مؤهل' WHEN 'NOT_ELIGIBLE' THEN 'غير مؤهل'
      WHEN 'APPROVED' THEN 'موافق عليه' WHEN 'REQUESTED' THEN 'مطلوب' ELSE p_status END;
  END status_label;

  FUNCTION type_label(p_type IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_type WHEN 'ELIGIBILITY' THEN 'التحقق من الأهلية' WHEN 'PREAUTH' THEN 'طلب موافقة مسبقة' WHEN 'PREAUTH_STATUS' THEN 'متابعة الموافقة'
      WHEN 'CLAIM' THEN 'إرسال المطالبة' WHEN 'CLAIM_STATUS' THEN 'متابعة المطالبة' WHEN 'PRESCRIPTION' THEN 'وصفة إلكترونية'
      WHEN 'PRESCRIPTION_CANCEL' THEN 'إلغاء وصفة إلكترونية' WHEN 'PING' THEN 'اختبار الاتصال' ELSE p_type END;
  END type_label;

  -- ================================================================ القنوات
  FUNCTION save_integration(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := l_o.get_number('id');
    l_code VARCHAR2(50) := UPPER(TRIM(l_o.get_string('code')));
    l_name VARCHAR2(200) := TRIM(l_o.get_string('name'));
    l_kind VARCHAR2(30) := NVL(l_o.get_string('kind'), 'INSURANCE');
    l_mode VARCHAR2(30) := NVL(l_o.get_string('mode'), 'SIMULATOR');
    l_url  VARCHAR2(1000) := TRIM(l_o.get_string('url'));
    l_auth VARCHAR2(30) := NVL(l_o.get_string('auth'), 'NONE');
    l_user VARCHAR2(200) := TRIM(l_o.get_string('user'));
    l_sec  VARCHAR2(1000) := l_o.get_string('secret');
    l_kh   VARCHAR2(100) := TRIM(l_o.get_string('key_header'));
    l_prov VARCHAR2(100) := TRIM(l_o.get_string('provider'));
    l_mail VARCHAR2(320) := TRIM(l_o.get_string('email'));
    l_to   NUMBER := NVL(l_o.get_number('timeout'), 30);
    l_wal  VARCHAR2(500) := TRIM(l_o.get_string('wallet'));
    l_st   VARCHAR2(30) := NVL(l_o.get_string('status'), 'ACTIVE');
    l_enc  VARCHAR2(2000);
    l_n    NUMBER;
  BEGIN
    guard('HIS_PAYER.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_code IS NOT NULL AND l_name IS NOT NULL, 'NOONA-HIS-200', 'رمز القناة واسمها إلزاميان', 'Code and name are required');
    NOONA_CORE_PKG.assert(l_mode <> 'REST' OR REGEXP_LIKE(l_url, '^https?://'), 'NOONA-HIS-201', 'أدخل عنوان الخدمة (http/https)',
                          'A valid service URL is required');
    NOONA_CORE_PKG.assert(l_mode <> 'EMAIL' OR INSTR(l_mail, '@') > 1, 'NOONA-HIS-202', 'أدخل بريد الجهة', 'Payer e-mail is required');
    NOONA_CORE_PKG.assert(l_to BETWEEN 5 AND 300, 'NOONA-HIS-203', 'مهلة الاتصال بين 5 و300 ثانية', 'Timeout must be 5-300 seconds');
    SELECT COUNT(*) INTO l_n FROM his_integration WHERE company_id = company AND code = l_code AND id <> NVL(l_id, -1);
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-HIS-204', 'رمز القناة مستخدم', 'Channel code already exists');
    l_enc := CASE WHEN l_sec IS NOT NULL THEN encrypt(l_sec) END;
    IF l_id IS NULL THEN
      INSERT INTO his_integration (company_id, code, name_ar, kind, link_mode, base_url, auth_type, username, secret_enc, key_header, provider_code, email,
                                   timeout_sec, wallet_path, status_code)
      VALUES (company, l_code, l_name, l_kind, l_mode, l_url, l_auth, l_user, l_enc, l_kh, l_prov, l_mail, l_to, l_wal, l_st)
      RETURNING id INTO l_id;
    ELSE
      UPDATE his_integration SET code = l_code, name_ar = l_name, kind = l_kind, link_mode = l_mode, base_url = l_url, auth_type = l_auth, username = l_user,
                                 secret_enc = NVL(l_enc, secret_enc), key_header = l_kh, provider_code = l_prov, email = l_mail, timeout_sec = l_to,
                                 wallet_path = l_wal, status_code = l_st
       WHERE id = l_id AND company_id = company;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-HIS-205', 'القناة غير موجودة', 'Channel not found');
    END IF;
    IF l_kind = 'ERX' AND l_st = 'ACTIVE' THEN
      -- قناة وصفات نشطة واحدة
      UPDATE his_integration SET status_code = 'INACTIVE' WHERE company_id = company AND kind = 'ERX' AND id <> l_id AND status_code = 'ACTIVE';
    END IF;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'HIS_INTEGRATION', l_id, 'SAVE', 'SUCCESS');
    RETURN l_id;
  END save_integration;

  PROCEDURE set_payer_link(p_payer_id IN NUMBER, p_integration_id IN NUMBER, p_link_code IN VARCHAR2) IS
    l_k VARCHAR2(30);
  BEGIN
    guard('HIS_PAYER.UPDATE');
    IF p_integration_id IS NOT NULL THEN
      SELECT kind INTO l_k FROM his_integration WHERE id = p_integration_id AND company_id = company;
      NOONA_CORE_PKG.assert(l_k = 'INSURANCE', 'NOONA-HIS-206', 'اختر قناة تأمين', 'Choose an insurance channel');
    END IF;
    UPDATE his_payer SET integration_id = p_integration_id, link_code = TRIM(p_link_code) WHERE id = p_payer_id AND company_id = company;
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-HIS-022', 'الجهة غير موجودة', 'Payer not found');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-205', 'القناة غير موجودة', 'Channel not found');
  END set_payer_link;

  FUNCTION erx_channel RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM his_integration WHERE company_id = company AND kind = 'ERX' AND status_code = 'ACTIVE';
    RETURN l;
  END erx_channel;

  FUNCTION payer_channel(p_payer_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(i.id) INTO l FROM his_payer p JOIN his_integration i ON i.id = p.integration_id
     WHERE p.id = p_payer_id AND i.status_code = 'ACTIVE' AND i.kind = 'INSURANCE';
    RETURN l;
  END payer_channel;

  FUNCTION has_secret(p_integration_id IN NUMBER) RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM his_integration WHERE id = p_integration_id AND company_id = company AND secret_enc IS NOT NULL;
    RETURN CASE WHEN l > 0 THEN 'Y' ELSE 'N' END;
  END has_secret;

  -- ================================================================ المحاكي
  -- قواعد ثابتة: الأهلية مرفوضة لعضوية تبدأ بـ X أو تأمين منتهٍ؛ الموافقة فورية حتى 5000 ومرفوضة فوق 20000 وقيد المراجعة بينهما؛
  -- قرار المطالبة يقبل الفاتورة كاملة إلا ما زاد على 2000 فيقبل 90% منه.
  FUNCTION simulate(p_type IN VARCHAR2, p_request IN CLOB) RETURN CLOB IS
    l_r   CLOB;
    l_mem VARCHAR2(100);
    l_exp VARCHAR2(30);
    l_dt  VARCHAR2(30);
    l_amt NUMBER;
    l_id  VARCHAR2(100);
    l_dec CLOB;
  BEGIN
    l_id := NVL(JSON_VALUE(p_request, '$.message_id'), TO_CHAR(SYSTIMESTAMP, 'HH24MISSFF3'));
    CASE p_type
      WHEN 'PING' THEN
        SELECT JSON_OBJECT('status' VALUE 'OK', 'message' VALUE 'Simulator is reachable') INTO l_r FROM dual;
      WHEN 'ELIGIBILITY' THEN
        l_mem := JSON_VALUE(p_request, '$.coverage.member');
        l_exp := JSON_VALUE(p_request, '$.coverage.expiry');
        l_dt := JSON_VALUE(p_request, '$.service_date');
        IF l_mem IS NULL OR UPPER(l_mem) LIKE 'X%' THEN
          SELECT JSON_OBJECT('status' VALUE 'NOT_ELIGIBLE', 'reference' VALUE 'ELG-' || l_id, 'message' VALUE 'Member not found or inactive') INTO l_r FROM dual;
        ELSIF l_exp IS NOT NULL AND l_exp < l_dt THEN
          SELECT JSON_OBJECT('status' VALUE 'NOT_ELIGIBLE', 'reference' VALUE 'ELG-' || l_id, 'message' VALUE 'Policy expired on ' || l_exp) INTO l_r FROM dual;
        ELSE
          SELECT JSON_OBJECT('status' VALUE 'ELIGIBLE', 'reference' VALUE 'ELG-' || l_id, 'message' VALUE 'Coverage active',
                             'plan' VALUE JSON_VALUE(p_request, '$.coverage.plan')) INTO l_r FROM dual;
        END IF;
      WHEN 'PREAUTH' THEN
        l_amt := TO_NUMBER(JSON_VALUE(p_request, '$.order.gross'));
        IF l_amt <= 5000 THEN
          SELECT JSON_OBJECT('status' VALUE 'APPROVED', 'reference' VALUE 'PA-' || l_id, 'approval_no' VALUE 'SIM-' || l_id, 'message' VALUE 'Approved')
            INTO l_r FROM dual;
        ELSIF l_amt > 20000 THEN
          SELECT JSON_OBJECT('status' VALUE 'REJECTED', 'reference' VALUE 'PA-' || l_id, 'message' VALUE 'Exceeds the policy benefit limit') INTO l_r FROM dual;
        ELSE
          SELECT JSON_OBJECT('status' VALUE 'PENDING', 'reference' VALUE 'PA-' || l_id, 'message' VALUE 'Under medical review') INTO l_r FROM dual;
        END IF;
      WHEN 'PREAUTH_STATUS' THEN
        SELECT JSON_OBJECT('status' VALUE 'APPROVED', 'reference' VALUE JSON_VALUE(p_request, '$.reference'),
                           'approval_no' VALUE 'SIM-' || REPLACE(JSON_VALUE(p_request, '$.reference'), 'PA-'), 'message' VALUE 'Approved after review')
          INTO l_r FROM dual;
      WHEN 'CLAIM' THEN
        SELECT JSON_OBJECT('status' VALUE 'RECEIVED', 'reference' VALUE 'SC-' || l_id, 'message' VALUE 'Claim batch received for adjudication')
          INTO l_r FROM dual;
      WHEN 'CLAIM_STATUS' THEN
        SELECT JSON_ARRAYAGG(JSON_OBJECT('invoice' VALUE x.inv, 'approved' VALUE CASE WHEN x.amt > 2000 THEN ROUND(x.amt * 0.9, 2) ELSE x.amt END,
                                         'reason' VALUE CASE WHEN x.amt > 2000 THEN 'Price above contract tariff' END ABSENT ON NULL) RETURNING CLOB)
          INTO l_dec
          FROM JSON_TABLE(p_request, '$.invoices[*]' COLUMNS (inv VARCHAR2(50) PATH '$.invoice', amt NUMBER PATH '$.amount')) x;
        SELECT JSON_OBJECT('status' VALUE 'ADJUDICATED', 'reference' VALUE JSON_VALUE(p_request, '$.reference'), 'message' VALUE 'Adjudication complete',
                           'decisions' VALUE NVL(l_dec, TO_CLOB('[]')) FORMAT JSON RETURNING CLOB)
          INTO l_r FROM dual;
      WHEN 'PRESCRIPTION' THEN
        SELECT JSON_OBJECT('status' VALUE 'ACCEPTED', 'erx_no' VALUE 'ERX' || TO_CHAR(SYSDATE, 'YYMMDD') || REGEXP_REPLACE(l_id, '\D'),
                           'message' VALUE 'Prescription registered; it can be dispensed at any pharmacy') INTO l_r FROM dual;
      WHEN 'PRESCRIPTION_CANCEL' THEN
        SELECT JSON_OBJECT('status' VALUE 'ACCEPTED', 'message' VALUE 'Prescription cancelled') INTO l_r FROM dual;
      ELSE
        SELECT JSON_OBJECT('status' VALUE 'ERROR', 'message' VALUE 'Unknown message type') INTO l_r FROM dual;
    END CASE;
    RETURN l_r;
  END simulate;

  -- ================================================================ النقل
  FUNCTION path_of(p_type VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_type WHEN 'ELIGIBILITY' THEN 'eligibility' WHEN 'PREAUTH' THEN 'preauth' WHEN 'PREAUTH_STATUS' THEN 'preauth/status'
      WHEN 'CLAIM' THEN 'claims' WHEN 'CLAIM_STATUS' THEN 'claims/status' WHEN 'PRESCRIPTION' THEN 'prescriptions'
      WHEN 'PRESCRIPTION_CANCEL' THEN 'prescriptions/cancel' ELSE 'ping' END;
  END path_of;

  FUNCTION send_rest(p_i his_integration%ROWTYPE, p_type VARCHAR2, p_req CLOB, p_http OUT NUMBER) RETURN CLOB IS
    l_r   CLOB;
    l_sec VARCHAR2(1000) := decrypt(p_i.secret_enc);
    l_n   PLS_INTEGER := 1;
  BEGIN
    APEX_WEB_SERVICE.g_request_headers.DELETE;
    APEX_WEB_SERVICE.g_request_headers(1).name := 'Content-Type';
    APEX_WEB_SERVICE.g_request_headers(1).value := 'application/json; charset=utf-8';
    IF p_i.provider_code IS NOT NULL THEN
      l_n := l_n + 1;
      APEX_WEB_SERVICE.g_request_headers(l_n).name := 'X-Provider-Id';
      APEX_WEB_SERVICE.g_request_headers(l_n).value := p_i.provider_code;
    END IF;
    IF p_i.auth_type = 'BEARER' THEN
      l_n := l_n + 1;
      APEX_WEB_SERVICE.g_request_headers(l_n).name := 'Authorization';
      APEX_WEB_SERVICE.g_request_headers(l_n).value := 'Bearer ' || l_sec;
    ELSIF p_i.auth_type = 'API_KEY' THEN
      l_n := l_n + 1;
      APEX_WEB_SERVICE.g_request_headers(l_n).name := NVL(p_i.key_header, 'X-API-Key');
      APEX_WEB_SERVICE.g_request_headers(l_n).value := l_sec;
    END IF;
    l_r := APEX_WEB_SERVICE.make_rest_request(
             p_url              => RTRIM(p_i.base_url, '/') || '/' || path_of(p_type),
             p_http_method      => 'POST',
             p_username         => CASE WHEN p_i.auth_type = 'BASIC' THEN p_i.username END,
             p_password         => CASE WHEN p_i.auth_type = 'BASIC' THEN l_sec END,
             p_body             => p_req,
             p_transfer_timeout => p_i.timeout_sec,
             p_wallet_path      => p_i.wallet_path);
    p_http := APEX_WEB_SERVICE.g_status_code;
    RETURN l_r;
  END send_rest;

  PROCEDURE send_email(p_i his_integration%ROWTYPE, p_type VARCHAR2, p_no VARCHAR2, p_req CLOB) IS
    l_id NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert(SYS_CONTEXT('APEX$SESSION', 'APP_ID') IS NOT NULL, 'NOONA-HIS-207', 'الإرسال بالبريد من داخل التطبيق فقط', 'E-mail is sent from the application only');
    l_id := APEX_MAIL.send(p_to => p_i.email, p_from => NVL(p_i.username, p_i.email),
                           p_subj => type_label(p_type) || ' / ' || p_type || ' ' || p_no || NVL2(p_i.provider_code, ' - ' || p_i.provider_code, ''),
                           p_body => 'Please find the attached ' || LOWER(REPLACE(p_type, '_', ' ')) || ' message ' || p_no || '.',
                           p_body_html => NULL);
    APEX_MAIL.add_attachment(p_mail_id => l_id, p_attachment => APEX_UTIL.clob_to_blob(p_req, 'AL32UTF8'),
                             p_filename => LOWER(p_type) || '-' || p_no || '.json', p_mime_type => 'application/json');
  END send_email;

  -- ينشئ الرسالة ويرسلها ويحفظ الاستجابة؛ يعيد معرف الرسالة. لا يرفع خطأ الاتصال (يسجل في الرسالة)
  FUNCTION exchange(p_int NUMBER, p_type VARCHAR2, p_payer NUMBER, p_entity VARCHAR2, p_entity_id NUMBER, p_req CLOB, p_msg_id NUMBER DEFAULT NULL)
    RETURN NUMBER IS
    l_i    his_integration%ROWTYPE;
    l_id   NUMBER := p_msg_id;
    l_no   VARCHAR2(30);
    l_req  CLOB := p_req;
    l_resp CLOB;
    l_http NUMBER;
    l_st   VARCHAR2(30);
    l_rs   VARCHAR2(30);
    l_err  VARCHAR2(1000);
    l_out  VARCHAR2(1000);
  BEGIN
    SELECT * INTO l_i FROM his_integration WHERE id = p_int AND company_id = company;
    NOONA_CORE_PKG.assert(l_i.status_code = 'ACTIVE', 'NOONA-HIS-208', 'قناة الربط موقوفة', 'Channel is inactive');
    IF l_id IS NULL THEN
      l_no := next_no;
      -- رقم الرسالة داخل الطلب (مرجع التتبع لدى الجهة)
      SELECT JSON_MERGEPATCH(p_req, JSON_OBJECT('message_id' VALUE l_no, 'provider' VALUE l_i.provider_code,
                                                'sent_at' VALUE TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')) RETURNING CLOB)
        INTO l_req FROM dual;
      INSERT INTO his_link_message (company_id, msg_no, msg_type, integration_id, payer_id, entity_type, entity_id, attempts, request_body, status_code)
      VALUES (company, l_no, p_type, p_int, p_payer, p_entity, p_entity_id, 0, l_req, 'QUEUED')
      RETURNING id INTO l_id;
    ELSE
      SELECT msg_no, request_body INTO l_no, l_req FROM his_link_message WHERE id = l_id;
    END IF;
    BEGIN
      CASE l_i.link_mode
        WHEN 'SIMULATOR' THEN
          l_resp := simulate(p_type, l_req); l_http := 200;
        WHEN 'REST' THEN
          l_resp := send_rest(l_i, p_type, l_req, l_http);
        WHEN 'EMAIL' THEN
          send_email(l_i, p_type, l_no, l_req); l_http := NULL;
          l_resp := '{"status":"SENT","message":"Sent by e-mail to ' || REPLACE(l_i.email, '"') || '; record the reply manually"}';
      END CASE;
      IF l_http IS NOT NULL AND l_http NOT BETWEEN 200 AND 299 THEN
        l_st := 'ERROR';
        l_err := 'HTTP ' || l_http || ': ' || DBMS_LOB.SUBSTR(l_resp, 300, 1);
      ELSE
        BEGIN
          l_rs := UPPER(JSON_VALUE(l_resp, '$.status' ERROR ON ERROR));
        EXCEPTION WHEN OTHERS THEN
          l_rs := NULL;
        END;
        l_st := CASE WHEN l_rs IN ('OK', 'ELIGIBLE', 'APPROVED', 'RECEIVED', 'ACCEPTED', 'ADJUDICATED') THEN 'ACCEPTED'
                     WHEN l_rs IN ('NOT_ELIGIBLE', 'REJECTED') THEN 'REJECTED' WHEN l_rs = 'PENDING' THEN 'PENDING' WHEN l_rs = 'SENT' THEN 'SENT'
                     ELSE 'ERROR' END;
        l_out := SUBSTR(l_rs || ': ' || JSON_VALUE(l_resp, '$.message'), 1, 1000);
        IF l_st = 'ERROR' THEN
          l_err := SUBSTR('Invalid response: ' || DBMS_LOB.SUBSTR(l_resp, 300, 1), 1, 1000);
        END IF;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      l_st := 'ERROR';
      l_err := SUBSTR(SQLERRM, 1, 1000);
    END;
    UPDATE his_link_message SET status_code = l_st, sent_at = SYSTIMESTAMP, http_status = l_http, attempts = attempts + 1, response_body = l_resp,
                                outcome = NVL(l_err, l_out), external_ref = NVL(SUBSTR(JSON_VALUE(l_resp, '$.reference' NULL ON ERROR), 1, 100), external_ref)
     WHERE id = l_id;
    IF l_st = 'ERROR' THEN
      UPDATE his_integration SET last_error = SUBSTR(l_no || ' ' || l_err, 1, 1000) WHERE id = p_int;
    ELSE
      UPDATE his_integration SET last_ok_at = SYSTIMESTAMP WHERE id = p_int;
    END IF;
    RETURN l_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-205', 'القناة غير موجودة', 'Channel not found');
  END exchange;

  FUNCTION msg(p_id NUMBER) RETURN his_link_message%ROWTYPE IS
    l his_link_message%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM his_link_message WHERE id = p_id;
    RETURN l;
  END msg;
  FUNCTION resp_value(p_m his_link_message%ROWTYPE, p_path VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN JSON_VALUE(p_m.response_body, p_path NULL ON ERROR);
  END resp_value;

  FUNCTION test_connection(p_integration_id IN NUMBER) RETURN VARCHAR2 IS
    l_m his_link_message%ROWTYPE;
  BEGIN
    guard('HIS_PAYER.UPDATE');
    l_m := msg(exchange(p_integration_id, 'PING', NULL, 'HIS_INTEGRATION', p_integration_id, '{"type":"ping","version":"1"}'));
    RETURN status_label(l_m.status_code) || ' - ' || l_m.outcome;
  END test_connection;

  -- ================================================================ الطلبات
  FUNCTION patient_json(p_patient_id NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    SELECT JSON_OBJECT('mrn' VALUE mrn, 'name' VALUE name_ar, 'name_en' VALUE name_en, 'gender' VALUE gender, 'birth' VALUE ymd(birth_date),
                       'id_type' VALUE id_type, 'id_no' VALUE id_no, 'nationality' VALUE nationality, 'mobile' VALUE mobile RETURNING CLOB)
      INTO l FROM his_patient WHERE id = p_patient_id;
    RETURN l;
  END patient_json;
  FUNCTION doctor_json(p_doctor_id NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    IF p_doctor_id IS NULL THEN RETURN TO_CLOB('null'); END IF;
    SELECT JSON_OBJECT('name' VALUE NVL(name_en, name_ar), 'license' VALUE license_no, 'specialty' VALUE specialty RETURNING CLOB)
      INTO l FROM his_doctor WHERE id = p_doctor_id;
    RETURN l;
  END doctor_json;

  FUNCTION check_eligibility(p_visit_id IN NUMBER) RETURN VARCHAR2 IS
    l_v   his_visit%ROWTYPE;
    l_p   his_patient%ROWTYPE;
    l_pl  his_payer_plan%ROWTYPE;
    l_py  his_payer%ROWTYPE;
    l_ch  NUMBER;
    l_req CLOB;
    l_pat CLOB;
    l_m   his_link_message%ROWTYPE;
    l_res VARCHAR2(30);
  BEGIN
    guard('HIS_VISIT.UPDATE');
    SELECT * INTO l_v FROM his_visit WHERE id = p_visit_id AND company_id = company;
    SELECT * INTO l_p FROM his_patient WHERE id = l_v.patient_id;
    NOONA_CORE_PKG.assert(NVL(l_v.payer_plan_id, l_p.payer_plan_id) IS NOT NULL, 'NOONA-HIS-210', 'المريض ليس على تأمين أو جهة', 'Patient has no coverage');
    SELECT * INTO l_pl FROM his_payer_plan WHERE id = NVL(l_v.payer_plan_id, l_p.payer_plan_id);
    SELECT * INTO l_py FROM his_payer WHERE id = l_pl.payer_id;
    l_ch := payer_channel(l_py.id);
    NOONA_CORE_PKG.assert(l_ch IS NOT NULL, 'NOONA-HIS-211', 'لا توجد قناة ربط نشطة للجهة ' || l_py.name_ar, 'Payer has no active channel');
    l_pat := patient_json(l_p.id);
    SELECT JSON_OBJECT('type' VALUE 'eligibility', 'version' VALUE '1', 'payer' VALUE NVL(l_py.link_code, l_py.code), 'visit' VALUE l_v.visit_no,
                       'service_date' VALUE ymd(CAST(l_v.visit_at AS DATE)), 'patient' VALUE l_pat FORMAT JSON,
                       'coverage' VALUE JSON_OBJECT('member' VALUE l_p.member_no, 'policy' VALUE l_p.policy_no, 'plan' VALUE l_pl.code,
                                                    'expiry' VALUE ymd(l_p.insurance_expiry)) RETURNING CLOB)
      INTO l_req FROM dual;
    l_m := msg(exchange(l_ch, 'ELIGIBILITY', l_py.id, 'HIS_VISIT', p_visit_id, l_req));
    l_res := CASE l_m.status_code WHEN 'ACCEPTED' THEN 'ELIGIBLE' WHEN 'REJECTED' THEN 'NOT_ELIGIBLE' WHEN 'ERROR' THEN 'ERROR' ELSE 'PENDING' END;
    UPDATE his_visit SET eligibility_status = l_res, eligibility_ref = NVL(l_m.external_ref, l_m.msg_no), eligibility_at = SYSTIMESTAMP WHERE id = p_visit_id;
    RETURN l_res;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-050', 'الزيارة غير موجودة', 'Visit not found');
  END check_eligibility;

  PROCEDURE apply_preauth(p_order_id NUMBER, p_m his_link_message%ROWTYPE) IS
    l_apr VARCHAR2(100);
  BEGIN
    IF p_m.status_code = 'ACCEPTED' THEN
      l_apr := NVL(resp_value(p_m, '$.approval_no'), NVL(p_m.external_ref, p_m.msg_no));
      UPDATE his_order SET preauth_status = 'APPROVED', preauth_ref = NVL(p_m.external_ref, preauth_ref) WHERE id = p_order_id;
      NOONA_HIS_PKG.set_approval(p_order_id, l_apr, 'Y');
    ELSIF p_m.status_code = 'REJECTED' THEN
      UPDATE his_order SET preauth_status = 'REJECTED', preauth_ref = NVL(p_m.external_ref, preauth_ref) WHERE id = p_order_id;
      NOONA_HIS_PKG.set_approval(p_order_id, NVL(resp_value(p_m, '$.message'), 'Rejected'), 'N');
    ELSE
      UPDATE his_order SET preauth_status = CASE p_m.status_code WHEN 'ERROR' THEN 'ERROR' WHEN 'SENT' THEN 'REQUESTED' ELSE 'PENDING' END,
                           preauth_ref = NVL(p_m.external_ref, preauth_ref)
       WHERE id = p_order_id;
    END IF;
  END apply_preauth;

  FUNCTION request_preauth(p_order_id IN NUMBER) RETURN VARCHAR2 IS
    l_o   his_order%ROWTYPE;
    l_v   his_visit%ROWTYPE;
    l_s   his_service%ROWTYPE;
    l_pl  his_payer_plan%ROWTYPE;
    l_py  his_payer%ROWTYPE;
    l_mem VARCHAR2(50);
    l_ch  NUMBER;
    l_req CLOB;
    l_pat CLOB;
    l_doc CLOB;
    l_m   his_link_message%ROWTYPE;
  BEGIN
    guard('HIS_ORDER.UPDATE');
    SELECT * INTO l_o FROM his_order WHERE id = p_order_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_o.status_code = 'APPROVAL_PENDING', 'NOONA-HIS-063', 'الطلب لا ينتظر موافقة', 'Order is not pending approval');
    SELECT * INTO l_v FROM his_visit WHERE id = l_o.visit_id;
    SELECT * INTO l_s FROM his_service WHERE id = l_o.service_id;
    SELECT * INTO l_pl FROM his_payer_plan WHERE id = l_v.payer_plan_id;
    SELECT * INTO l_py FROM his_payer WHERE id = l_pl.payer_id;
    SELECT member_no INTO l_mem FROM his_patient WHERE id = l_v.patient_id;
    l_ch := payer_channel(l_py.id);
    NOONA_CORE_PKG.assert(l_ch IS NOT NULL, 'NOONA-HIS-211', 'لا توجد قناة ربط نشطة للجهة ' || l_py.name_ar, 'Payer has no active channel');
    l_pat := patient_json(l_v.patient_id);
    l_doc := doctor_json(NVL(l_o.ordered_by_id, l_v.doctor_id));
    SELECT JSON_OBJECT('type' VALUE 'preauth', 'version' VALUE '1', 'payer' VALUE NVL(l_py.link_code, l_py.code), 'visit' VALUE l_v.visit_no,
                       'visit_type' VALUE l_v.visit_type, 'patient' VALUE l_pat FORMAT JSON,
                       'coverage' VALUE JSON_OBJECT('member' VALUE l_mem, 'plan' VALUE l_pl.code),
                       'diagnosis' VALUE JSON_OBJECT('text' VALUE l_v.diagnosis, 'icd10' VALUE l_v.icd10, 'complaint' VALUE l_v.chief_complaint),
                       'doctor' VALUE l_doc FORMAT JSON,
                       'order' VALUE JSON_OBJECT('line' VALUE l_o.line_no, 'code' VALUE l_s.code, 'billing_code' VALUE l_s.billing_code,
                                                 'name' VALUE NVL(l_s.name_en, l_s.name_ar), 'type' VALUE l_s.service_type, 'qty' VALUE l_o.quantity,
                                                 'unit_price' VALUE l_o.unit_price, 'gross' VALUE l_o.gross_amount,
                                                 'payer_amount' VALUE l_o.payer_net + l_o.payer_vat, 'notes' VALUE l_o.notes) RETURNING CLOB)
      INTO l_req FROM dual;
    l_m := msg(exchange(l_ch, 'PREAUTH', l_py.id, 'HIS_ORDER', p_order_id, l_req));
    apply_preauth(p_order_id, l_m);
    RETURN CASE l_m.status_code WHEN 'ACCEPTED' THEN 'APPROVED' WHEN 'REJECTED' THEN 'REJECTED' WHEN 'ERROR' THEN 'ERROR' WHEN 'SENT' THEN 'SENT'
                ELSE 'PENDING' END;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-212', 'الطلب أو تغطيته غير موجودة', 'Order or coverage not found');
  END request_preauth;

  FUNCTION poll_preauth(p_order_id IN NUMBER) RETURN VARCHAR2 IS
    l_o   his_order%ROWTYPE;
    l_py  NUMBER;
    l_ch  NUMBER;
    l_req CLOB;
    l_m   his_link_message%ROWTYPE;
  BEGIN
    guard('HIS_ORDER.UPDATE');
    SELECT * INTO l_o FROM his_order WHERE id = p_order_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_o.status_code = 'APPROVAL_PENDING' AND l_o.preauth_ref IS NOT NULL, 'NOONA-HIS-213', 'لا يوجد طلب موافقة قيد المتابعة',
                          'No pending pre-authorization');
    SELECT pl.payer_id INTO l_py FROM his_visit v JOIN his_payer_plan pl ON pl.id = v.payer_plan_id WHERE v.id = l_o.visit_id;
    l_ch := payer_channel(l_py);
    NOONA_CORE_PKG.assert(l_ch IS NOT NULL, 'NOONA-HIS-211', 'لا توجد قناة ربط نشطة للجهة', 'Payer has no active channel');
    SELECT JSON_OBJECT('type' VALUE 'preauth_status', 'version' VALUE '1', 'reference' VALUE l_o.preauth_ref RETURNING CLOB) INTO l_req FROM dual;
    l_m := msg(exchange(l_ch, 'PREAUTH_STATUS', l_py, 'HIS_ORDER', p_order_id, l_req));
    IF l_m.status_code IN ('ACCEPTED', 'REJECTED') THEN
      apply_preauth(p_order_id, l_m);
    END IF;
    RETURN CASE l_m.status_code WHEN 'ACCEPTED' THEN 'APPROVED' WHEN 'REJECTED' THEN 'REJECTED' WHEN 'ERROR' THEN 'ERROR' ELSE 'PENDING' END;
  END poll_preauth;

  FUNCTION send_claim(p_batch_id IN NUMBER) RETURN VARCHAR2 IS
    l_b   his_claim_batch%ROWTYPE;
    l_py  his_payer%ROWTYPE;
    l_ch  NUMBER;
    l_req CLOB;
    l_bj  CLOB;
    l_m   his_link_message%ROWTYPE;
  BEGIN
    guard('HIS_INVOICE.UPDATE');
    SELECT * INTO l_b FROM his_claim_batch WHERE id = p_batch_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_b.status_code = 'DRAFT', 'NOONA-HIS-163', 'ترسل الدفعة وهي مسودة', 'Only draft batches can be submitted');
    SELECT * INTO l_py FROM his_payer WHERE id = l_b.payer_id;
    l_ch := payer_channel(l_py.id);
    NOONA_CORE_PKG.assert(l_ch IS NOT NULL, 'NOONA-HIS-211', 'لا توجد قناة ربط نشطة للجهة ' || l_py.name_ar, 'Payer has no active channel');
    l_bj := NOONA_HIS_CLAIM_PKG.batch_json(p_batch_id);
    SELECT JSON_OBJECT('type' VALUE 'claim', 'version' VALUE '1', 'payer' VALUE NVL(l_py.link_code, l_py.code), 'batch' VALUE l_bj FORMAT JSON
                       RETURNING CLOB) INTO l_req FROM dual;
    l_m := msg(exchange(l_ch, 'CLAIM', l_py.id, 'HIS_CLAIM_BATCH', p_batch_id, l_req));
    IF l_m.status_code IN ('ACCEPTED', 'SENT', 'PENDING') THEN
      NOONA_HIS_CLAIM_PKG.submit_batch(p_batch_id, NVL(l_m.external_ref, l_m.msg_no));
    END IF;
    RETURN CASE l_m.status_code WHEN 'ACCEPTED' THEN 'SENT' WHEN 'PENDING' THEN 'SENT' ELSE l_m.status_code END;
  END send_claim;

  FUNCTION poll_claim(p_batch_id IN NUMBER) RETURN VARCHAR2 IS
    l_b   his_claim_batch%ROWTYPE;
    l_ch  NUMBER;
    l_req CLOB;
    l_inv CLOB;
    l_m   his_link_message%ROWTYPE;
    l_dec CLOB;
    l_n   NUMBER;
  BEGIN
    guard('HIS_INVOICE.UPDATE');
    SELECT * INTO l_b FROM his_claim_batch WHERE id = p_batch_id AND company_id = company;
    NOONA_CORE_PKG.assert(l_b.status_code = 'SUBMITTED', 'NOONA-HIS-164', 'تتابع الدفعة المرسلة التي لم يسجل ردها', 'Batch must be submitted');
    l_ch := payer_channel(l_b.payer_id);
    NOONA_CORE_PKG.assert(l_ch IS NOT NULL, 'NOONA-HIS-211', 'لا توجد قناة ربط نشطة للجهة', 'Payer has no active channel');
    SELECT JSON_ARRAYAGG(JSON_OBJECT('invoice' VALUE i.doc_no, 'amount' VALUE l.claimed_amount) ORDER BY i.doc_no RETURNING CLOB) INTO l_inv
      FROM his_claim_line l JOIN his_invoice i ON i.id = l.invoice_id WHERE l.batch_id = p_batch_id;
    SELECT JSON_OBJECT('type' VALUE 'claim_status', 'version' VALUE '1', 'reference' VALUE l_b.reference_no, 'batch' VALUE l_b.doc_no,
                       'invoices' VALUE l_inv FORMAT JSON RETURNING CLOB) INTO l_req FROM dual;
    l_m := msg(exchange(l_ch, 'CLAIM_STATUS', l_b.payer_id, 'HIS_CLAIM_BATCH', p_batch_id, l_req));
    SELECT COUNT(*) INTO l_n FROM JSON_TABLE(l_m.response_body, '$.decisions[*]' COLUMNS (inv VARCHAR2(50) PATH '$.invoice'));
    IF l_m.status_code = 'ACCEPTED' AND l_n > 0 THEN
      -- القرار: أرقام الفواتير إلى معرفاتها ثم تسجيل الرد (الرفض يقيد آلياً)
      SELECT JSON_ARRAYAGG(JSON_OBJECT('inv' VALUE i.id, 'approved' VALUE d.approved, 'reason' VALUE d.reason) RETURNING CLOB) INTO l_dec
        FROM JSON_TABLE(l_m.response_body, '$.decisions[*]' COLUMNS (inv VARCHAR2(50) PATH '$.invoice', approved NUMBER PATH '$.approved',
                                                                     reason VARCHAR2(500) PATH '$.reason')) d
        JOIN his_invoice i ON i.doc_no = d.inv AND i.company_id = company
        JOIN his_claim_line l ON l.invoice_id = i.id AND l.batch_id = p_batch_id;
      NOONA_HIS_CLAIM_PKG.record_response(p_batch_id, l_dec);
      RETURN 'ADJUDICATED';
    END IF;
    RETURN CASE l_m.status_code WHEN 'ERROR' THEN 'ERROR' WHEN 'REJECTED' THEN 'REJECTED' ELSE 'PENDING' END;
  END poll_claim;

  FUNCTION send_prescription(p_rx_id IN NUMBER) RETURN VARCHAR2 IS
    l_rx  his_prescription%ROWTYPE;
    l_v   his_visit%ROWTYPE;
    l_ch  NUMBER := erx_channel;
    l_req CLOB;
    l_pat CLOB;
    l_doc CLOB;
    l_it  CLOB;
    l_erx VARCHAR2(50);
    l_m   his_link_message%ROWTYPE;
  BEGIN
    guard('HIS_ORDER.CREATE');
    IF l_ch IS NULL THEN RETURN NULL; END IF;
    SELECT * INTO l_rx FROM his_prescription WHERE id = p_rx_id AND company_id = company;
    SELECT * INTO l_v FROM his_visit WHERE id = l_rx.visit_id;
    l_pat := patient_json(l_v.patient_id);
    l_doc := doctor_json(l_rx.doctor_id);
    SELECT JSON_ARRAYAGG(JSON_OBJECT('line' VALUE l.line_no, 'code' VALUE i.item_no, 'name' VALUE NVL(i.name_en, i.name_ar),
                                     'dose' VALUE l.dose, 'frequency' VALUE l.frequency, 'days' VALUE l.duration_days, 'qty' VALUE l.quantity,
                                     'instructions' VALUE l.instructions) ORDER BY l.line_no RETURNING CLOB)
      INTO l_it FROM his_prescription_line l JOIN inv_item i ON i.id = l.item_id WHERE l.prescription_id = p_rx_id;
    SELECT JSON_OBJECT('type' VALUE 'prescription', 'version' VALUE '1', 'rx_no' VALUE l_rx.rx_no, 'date' VALUE ymd(CAST(l_rx.rx_at AS DATE)),
                       'expires' VALUE ymd(l_rx.expires_on), 'visit' VALUE l_v.visit_no, 'patient' VALUE l_pat FORMAT JSON, 'doctor' VALUE l_doc FORMAT JSON,
                       'diagnosis' VALUE JSON_OBJECT('text' VALUE l_v.diagnosis, 'icd10' VALUE l_v.icd10), 'items' VALUE l_it FORMAT JSON RETURNING CLOB)
      INTO l_req FROM dual;
    l_m := msg(exchange(l_ch, 'PRESCRIPTION', NULL, 'HIS_PRESCRIPTION', p_rx_id, l_req));
    l_erx := SUBSTR(resp_value(l_m, '$.erx_no'), 1, 50);
    UPDATE his_prescription SET erx_status = CASE l_m.status_code WHEN 'ACCEPTED' THEN 'ACCEPTED' WHEN 'REJECTED' THEN 'REJECTED' WHEN 'ERROR' THEN 'ERROR'
                                                                  ELSE 'SENT' END,
                                erx_no = NVL(l_erx, erx_no)
     WHERE id = p_rx_id;
    RETURN l_m.status_code;
  END send_prescription;

  PROCEDURE cancel_prescription(p_rx_id IN NUMBER) IS
    l_rx  his_prescription%ROWTYPE;
    l_ch  NUMBER := erx_channel;
    l_req CLOB;
    l_m   his_link_message%ROWTYPE;
  BEGIN
    SELECT * INTO l_rx FROM his_prescription WHERE id = p_rx_id AND company_id = company;
    IF l_ch IS NULL OR l_rx.erx_status NOT IN ('ACCEPTED', 'SENT') THEN RETURN; END IF;
    SELECT JSON_OBJECT('type' VALUE 'prescription_cancel', 'version' VALUE '1', 'rx_no' VALUE l_rx.rx_no, 'erx_no' VALUE l_rx.erx_no RETURNING CLOB)
      INTO l_req FROM dual;
    l_m := msg(exchange(l_ch, 'PRESCRIPTION_CANCEL', NULL, 'HIS_PRESCRIPTION', p_rx_id, l_req));
    IF l_m.status_code = 'ACCEPTED' THEN
      UPDATE his_prescription SET erx_status = 'CANCELLED' WHERE id = p_rx_id;
    END IF;
  END cancel_prescription;

  FUNCTION retry(p_message_id IN NUMBER) RETURN VARCHAR2 IS
    l_m his_link_message%ROWTYPE;
    l_x NUMBER;
    l_r VARCHAR2(30);
  BEGIN
    guard('HIS_PAYER.UPDATE');
    SELECT * INTO l_m FROM his_link_message WHERE id = p_message_id AND company_id = company;
    NOONA_CORE_PKG.assert(l_m.status_code IN ('ERROR', 'QUEUED'), 'NOONA-HIS-214', 'تعاد الرسائل المتعثرة فقط', 'Only failed messages can be retried');
    -- العمليات تعاد بمنطقها لتطبيق النتيجة على المستند
    IF l_m.msg_type = 'PRESCRIPTION' THEN
      l_r := send_prescription(l_m.entity_id);
    ELSIF l_m.msg_type = 'PREAUTH' THEN
      l_r := request_preauth(l_m.entity_id);
    ELSIF l_m.msg_type = 'ELIGIBILITY' THEN
      l_r := check_eligibility(l_m.entity_id);
    ELSIF l_m.msg_type = 'CLAIM' THEN
      l_r := send_claim(l_m.entity_id);
    ELSE
      l_x := exchange(l_m.integration_id, l_m.msg_type, l_m.payer_id, l_m.entity_type, l_m.entity_id, NULL, p_message_id);
      l_r := msg(l_x).status_code;
    END IF;
    -- الرسالة القديمة تبقى للتاريخ مع الإشارة إلى إعادة إرسالها
    UPDATE his_link_message SET outcome = SUBSTR('Retried: ' || outcome, 1, 1000) WHERE id = p_message_id AND status_code = 'ERROR'
       AND msg_type IN ('PRESCRIPTION', 'PREAUTH', 'ELIGIBILITY', 'CLAIM');
    RETURN l_r;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-215', 'الرسالة غير موجودة', 'Message not found');
  END retry;

  FUNCTION can_retry(p_message_id IN NUMBER) RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM his_link_message WHERE id = p_message_id AND company_id = company AND status_code IN ('ERROR', 'QUEUED');
    RETURN CASE WHEN l > 0 THEN 'Y' ELSE 'N' END;
  END can_retry;

  FUNCTION process_pending RETURN NUMBER IS
    l_n PLS_INTEGER := 0;
    l_r VARCHAR2(30);
  BEGIN
    guard('HIS_PAYER.UPDATE');
    -- الموافقات قيد المراجعة والدفعات المرسلة على قنوات REST أو المحاكاة، والوصفات التي تعثر إرسالها
    FOR o IN (SELECT o.id FROM his_order o WHERE o.company_id = company AND o.status_code = 'APPROVAL_PENDING' AND o.preauth_status = 'PENDING') LOOP
      BEGIN l_r := poll_preauth(o.id); l_n := l_n + 1; EXCEPTION WHEN OTHERS THEN NULL; END;
    END LOOP;
    FOR b IN (SELECT b.id FROM his_claim_batch b JOIN his_payer p ON p.id = b.payer_id JOIN his_integration i ON i.id = p.integration_id
               WHERE b.company_id = company AND b.status_code = 'SUBMITTED' AND i.link_mode <> 'EMAIL' AND i.status_code = 'ACTIVE') LOOP
      BEGIN l_r := poll_claim(b.id); l_n := l_n + 1; EXCEPTION WHEN OTHERS THEN NULL; END;
    END LOOP;
    FOR x IN (SELECT id FROM his_prescription WHERE company_id = company AND erx_status = 'ERROR' AND status_code IN ('ACTIVE', 'PARTIAL')) LOOP
      BEGIN l_r := send_prescription(x.id); l_n := l_n + 1; EXCEPTION WHEN OTHERS THEN NULL; END;
    END LOOP;
    RETURN l_n;
  END process_pending;

  -- ================================================================ العرض
  FUNCTION pretty(p CLOB) RETURN CLOB IS
    l CLOB;
  BEGIN
    IF p IS NULL THEN RETURN NULL; END IF;
    SELECT JSON_SERIALIZE(p RETURNING CLOB PRETTY) INTO l FROM dual;
    RETURN l;
  EXCEPTION WHEN OTHERS THEN
    RETURN p;
  END pretty;

  FUNCTION message_html(p_message_id IN NUMBER) RETURN CLOB IS
    l_h CLOB;
  BEGIN
    guard('HIS_PAYER.VIEW');
    FOR m IN (SELECT m.*, i.name_ar ch, i.link_mode, p.name_ar payer FROM his_link_message m JOIN his_integration i ON i.id = m.integration_id
                LEFT JOIN his_payer p ON p.id = m.payer_id WHERE m.id = p_message_id AND m.company_id = company) LOOP
      l_h := '<div class="nn-his-card"><div class="nn-his-head"><div><b>' || esc(m.msg_no) || ' · ' || esc(type_label(m.msg_type))
          || '</b> <span class="nn-rst-chip">' || esc(status_label(m.status_code)) || '</span><br><small>' || esc(m.ch) || ' (' || m.link_mode || ')'
          || NVL2(m.payer, ' · ' || esc(m.payer), '') || ' · ' || TO_CHAR(m.sent_at, 'YYYY-MM-DD HH24:MI:SS') || NVL2(m.http_status, ' · HTTP ' || m.http_status, '')
          || ' · ' || m.attempts || ' محاولة' || NVL2(m.external_ref, ' · مرجع الجهة ' || esc(m.external_ref), '') || '</small>'
          || NVL2(m.outcome, '<br><span>' || esc(m.outcome) || '</span>', '') || '</div></div>'
          || '<div class="nn-his-json"><section><h4>Request</h4><pre dir="ltr">' || esc(DBMS_LOB.SUBSTR(pretty(m.request_body), 12000, 1)) || '</pre></section>'
          || '<section><h4>Response</h4><pre dir="ltr">' || esc(DBMS_LOB.SUBSTR(pretty(m.response_body), 12000, 1)) || '</pre></section></div></div>';
    END LOOP;
    RETURN l_h;
  END message_html;
END NOONA_HIS_LINK_PKG;
/
