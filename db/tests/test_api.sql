-- =============================================================================
-- NOONA PLUS ERP | اختبار واجهات API والتكاملات:
--   عملاء API وحساب الخدمة، رمز الدخول وانتهاؤه وإلغاؤه، الصلاحيات لكل نقطة، Idempotency-Key وإعادة الاستجابة والتعارض،
--   حد المعدل وقائمة IP، أخطاء الأعمال كأكواد HTTP، سجل الطلبات، OpenAPI؛ العملاء والأصناف وفواتير المبيعات والتحصيل؛
--   Webhooks والتوقيع وإعادة المحاولة والإيقاف؛ قنوات SMS/واتساب بالقواعد؛ استيراد CSV؛ كشف البنك والمطابقة التلقائية؛
--   طلبات المتجر (بحساب NOONA_APP - يتراجع عن كل التغييرات)
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_api.sql
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
  g_pass  PLS_INTEGER := 0;
  g_fail  PLS_INTEGER := 0;
  l_sfx   VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'MISSFF3');
  l_d     VARCHAR2(10) := TO_CHAR(SYSDATE, 'YYYY-MM-DD');
  l_n     NUMBER;
  l_x     NUMBER;
  l_s     VARCHAR2(4000);
  l_c     CLOB;
  l_r     CLOB;
  l_st    NUMBER;
  l_role  NUMBER;
  l_cid   NUMBER;
  l_key   VARCHAR2(100);
  l_sec   VARCHAR2(100);
  l_tok   VARCHAR2(100);
  l_auth  VARCHAR2(200);
  l_co    NUMBER;
  l_box   NUMBER;
  l_bank  NUMBER;
  l_item  NUMBER;
  l_cust  NUMBER;
  l_inv   NUMBER;
  l_wh    NUMBER;
  l_wh2   NUMBER;
  l_ob    NUMBER;
  l_ch    NUMBER;
  l_job   NUMBER;
  l_stm   NUMBER;
  l_t1    NUMBER;
  l_t2    NUMBER;
  l_body  VARCHAR2(4000);

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || SUBSTR(p_info, 1, 600) END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  -- جلسة المسؤول (الواجهة تنظف السياق بعد كل طلب كما في ORDS)
  PROCEDURE admin IS
  BEGIN
    NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  END admin;
  FUNCTION api(p_method VARCHAR2, p_route VARCHAR2, p_id VARCHAR2 DEFAULT NULL, p_body CLOB DEFAULT NULL, p_idem VARCHAR2 DEFAULT NULL,
               p_params CLOB DEFAULT NULL, p_ip VARCHAR2 DEFAULT '10.0.0.5', p_auth VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l CLOB;
  BEGIN
    l := NOONA_API_PKG.handle(p_method, p_route, p_id, p_body, NVL(p_auth, l_auth), p_idem, p_params, p_ip, l_st);
    admin;
    RETURN l;
  END api;
  FUNCTION jv(p_doc CLOB, p_path VARCHAR2) RETURN VARCHAR2 IS
  BEGIN RETURN JSON_VALUE(p_doc, p_path); END jv;
BEGIN
  NOONA_APEX_PKG.cleanup_request;
  admin;
  l_co := NOONA_API_PKG.company;
  UPDATE dms_archive_rule SET is_active = 'N';
  UPDATE loc_einvoice_profile SET status_code = 'SUSPENDED' WHERE company_id = l_co;
  -- لا نرسل أحداث اشتراكات قائمة أثناء الاختبار
  UPDATE api_webhook_subscription SET status_code = 'PAUSED' WHERE status_code = 'ACTIVE';
  UPDATE api_integration_config SET status_code = 'DISABLED' WHERE status_code = 'ACTIVE';
  l_box := NOONA_CSH_PKG.create_cash_box('AB' || SUBSTR(l_sfx, 1, 6), 'صندوق اختبار الواجهات');
  l_n := NOONA_CSH_PKG.seed_defaults;
  SELECT MIN(id) INTO l_bank FROM csh_bank_account WHERE company_id = l_co AND status_code = 'ACTIVE';

  -- ======================================================== العميل وحساب الخدمة
  l_role := NOONA_SEC_ADMIN_PKG.create_role('API_T' || l_sfx, 'دور تكامل اختبار');
  FOR p IN (SELECT column_value c FROM TABLE(apex_t_varchar2('AR_CUSTOMER.VIEW', 'AR_CUSTOMER.CREATE', 'PTY_PARTY.VIEW', 'PTY_PARTY.CREATE', 'INV_ITEM.VIEW', 'INV_ITEM.CREATE',
              'SAL_INVOICE.VIEW', 'SAL_INVOICE.CREATE', 'AR_RECEIPT.CREATE', 'GL_ACCOUNT.VIEW', 'GL_JOURNAL.VIEW', 'API_WEBHOOK_SUBSCRIPTION.VIEW',
              'API_WEBHOOK_SUBSCRIPTION.CREATE', 'API_WEBHOOK_SUBSCRIPTION.UPDATE'))) LOOP
    NOONA_SEC_ADMIN_PKG.add_permission(l_role, p.c);
  END LOOP;
  -- حساب الخدمة يعمل كمستخدم عادي: يحتاج صلاحيات الوحدات التي تمسها العملية (لا يعطى المشتريات لاختبار الرفض)
  FOR m IN (SELECT column_value c FROM TABLE(apex_t_varchar2('REF', 'PTY', 'AR', 'SAL', 'INV', 'CSH', 'GL', 'ACE', 'LOC'))) LOOP
    l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, m.c, 'VIEW,CREATE,UPDATE,POST,SUBMIT,APPROVE');
  END LOOP;
  l_c := NOONA_API_PKG.create_client('{"name":"متجر اختبار ' || l_sfx || '","role":' || l_role || ',"rate":40,"ttl":30,"description":"اختبار"}');
  l_cid := jv(l_c, '$.id'); l_key := jv(l_c, '$.clientId'); l_sec := jv(l_c, '$.clientSecret');
  ok('client created, secret shown once', l_key LIKE 'nn\_%' ESCAPE '\' AND LENGTH(l_sec) = 48, l_c);
  SELECT COUNT(*) INTO l_n FROM api_client_secret WHERE api_client_id = l_cid AND secret_hash = NOONA_API_PKG.sha_hex(l_sec) AND secret_hint = SUBSTR(l_sec, -4);
  SELECT COUNT(*) INTO l_x FROM api_client c JOIN sec_user u ON u.id = c.service_user_id WHERE c.id = l_cid AND u.user_type = 'INTEGRATION';
  ok('only the hash is stored; service account is an integration user', l_n = 1 AND l_x = 1);
  BEGIN l_c := NOONA_API_PKG.create_client('{"name":"بلا دور"}'); ok('role is required', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('role is required', 'NOONA-API-001', SQLERRM); END;

  -- ======================================================== رمز الدخول
  l_r := api('POST', 'token', NULL, '{"client_id":"' || l_key || '","client_secret":"wrong"}');
  ok('wrong secret -> 401 invalid_client', l_st = 401 AND jv(l_r, '$.error.code') = 'invalid_client', l_st || ' ' || l_r);
  l_r := api('POST', 'token', NULL, '{"client_id":"' || l_key || '","client_secret":"' || l_sec || '"}');
  l_tok := jv(l_r, '$.access_token'); l_auth := 'Bearer ' || l_tok;
  ok('token issued (Bearer, 30 min)', l_st = 200 AND LENGTH(l_tok) = 64 AND jv(l_r, '$.expires_in') = '1800', l_r);
  l_r := api('GET', 'ping', p_auth => 'Bearer nope');
  ok('unknown token -> 401', l_st = 401 AND jv(l_r, '$.error.code') = 'invalid_token', l_r);
  l_r := api('GET', 'ping', p_auth => 'Basic abc');
  ok('missing bearer -> 401', l_st = 401, l_r);
  l_r := api('GET', 'ping');
  ok('ping runs as the service account in the client company', l_st = 200 AND jv(l_r, '$.client') = l_key AND jv(l_r, '$.company') = TO_CHAR(l_co)
     AND jv(l_r, '$.user') LIKE 'API\_%' ESCAPE '\', l_r);
  ok('context is cleared after each request', SYS_CONTEXT('NOONA_CTX', 'USERNAME') = 'ADMIN');
  l_r := api('GET', 'nothing-here');
  ok('unknown route -> 404', l_st = 404 AND jv(l_r, '$.error.code') = 'not_found', l_r);

  -- ======================================================== القراءة والصلاحيات
  l_r := api('GET', 'customers', p_params => '{"limit":"5"}');
  ok('customers page', l_st = 200 AND jv(l_r, '$.limit') = '5' AND JSON_EXISTS(l_r, '$.items'), SUBSTR(l_r, 1, 300));
  l_r := api('GET', 'suppliers');
  ok('no permission -> 403 forbidden', l_st = 403 AND jv(l_r, '$.error.code') = 'forbidden' AND INSTR(jv(l_r, '$.error.message'), 'AP_SUPPLIER.VIEW') > 0, l_r);
  l_r := api('GET', 'accounts');
  ok('chart of accounts', l_st = 200 AND JSON_EXISTS(l_r, '$.items[0].code'), SUBSTR(l_r, 1, 200));
  l_r := api('GET', 'trial-balance', p_params => '{"to":"' || l_d || '"}');
  ok('trial balance as of date', l_st = 200 AND jv(l_r, '$.asOf') = l_d, SUBSTR(l_r, 1, 200));

  -- ======================================================== الإنشاء
  l_r := api('POST', 'customers', NULL, '{"name":"عميل واجهة ' || l_sfx || '","phone":"05' || SUBSTR(l_sfx, 1, 8) || '","term":"NET30"}');
  l_cust := jv(l_r, '$.id');
  ok('customer created -> 201', l_st = 201 AND l_cust IS NOT NULL, l_r);
  l_r := api('GET', 'customers', TO_CHAR(l_cust));
  ok('customer by id with balance', l_st = 200 AND jv(l_r, '$.balance') = '0', SUBSTR(l_r, 1, 300));
  l_r := api('GET', 'customers', '999999999');
  ok('missing customer -> 404', l_st = 404, l_r);
  l_r := api('POST', 'items', NULL, '{"number":"API-' || l_sfx || '","name":"صنف خدمة واجهة","type":"SERVICE","price":100,"barcode":"99' || l_sfx || '"}');
  l_item := jv(l_r, '$.id');
  ok('service item created', l_st = 201 AND l_item IS NOT NULL, l_r);
  l_r := api('POST', 'items', NULL, '{"name":""}');
  ok('business rule -> 422 with NOONA code', l_st = 422 AND jv(l_r, '$.error.code') LIKE 'NOONA-%' AND jv(l_r, '$.error.requestId') IS NOT NULL, l_r);
  l_r := api('POST', 'customers', NULL, '{"name": broken');
  ok('malformed JSON -> 400', l_st = 400, l_r);

  -- ======================================================== فاتورة مبيعات بمنع التكرار
  l_body := '{"customer":' || l_cust || ',"date":"' || l_d || '","lines":[{"sku":"99' || l_sfx || '","qty":2,"price":100}]}';
  l_r := api('POST', 'sales-invoices', NULL, l_body);
  ok('invoice without Idempotency-Key -> 400', l_st = 400 AND jv(l_r, '$.error.code') = 'idempotency_key_required', l_r);
  l_r := api('POST', 'sales-invoices', NULL, l_body, 'INV-' || l_sfx);
  l_inv := jv(l_r, '$.id');
  ok('invoice posted -> 201', l_st = 201 AND l_inv IS NOT NULL, SUBSTR(l_r, 1, 400));
  SELECT status_code || '|' || total_amount INTO l_s FROM sal_invoice WHERE id = l_inv;
  ok('posted with 15% VAT: 230', l_s = 'POSTED|230', l_s);
  l_r := api('POST', 'sales-invoices', NULL, l_body, 'INV-' || l_sfx);
  ok('same key + same body -> same response, no new invoice', l_st = 201 AND jv(l_r, '$.id') = TO_CHAR(l_inv), SUBSTR(l_r, 1, 200));
  SELECT COUNT(*) INTO l_n FROM sal_invoice WHERE customer_account_id = l_cust;
  ok('still one invoice', l_n = 1, l_n);
  l_r := api('POST', 'sales-invoices', NULL, REPLACE(l_body, '"qty":2', '"qty":3'), 'INV-' || l_sfx);
  ok('same key + different body -> 409', l_st = 409 AND jv(l_r, '$.error.code') = 'idempotency_conflict', l_r);
  l_r := api('GET', 'sales-invoices', TO_CHAR(l_inv));
  ok('invoice read with e-invoice status and QR', l_st = 200 AND jv(l_r, '$.id') = TO_CHAR(l_inv) AND JSON_EXISTS(l_r, '$.qr'), SUBSTR(l_r, 1, 300));
  l_r := api('GET', 'sales-invoices', p_params => '{"from":"' || l_d || '","to":"' || l_d || '","customer":"' || l_cust || '"}');
  ok('invoice list filtered by customer', l_st = 200 AND jv(l_r, '$.count') = '1', SUBSTR(l_r, 1, 300));
  l_r := api('POST', 'receipts', NULL, '{"customer":' || l_cust || ',"amount":230,"place":"BOX:' || l_box || '","method":"CASH","allocations":[{"invoice":'
             || l_inv || ',"amount":230}]}', 'RCP-' || l_sfx);
  ok('receipt allocated to invoice -> 201', l_st = 201 AND jv(l_r, '$.amount') = '230', l_r);
  ok('customer balance settled', NOONA_SAL_PKG.customer_balance(l_cust) = 0, NOONA_SAL_PKG.customer_balance(l_cust));
  l_r := api('POST', 'receipts', NULL, '{"customer":' || l_cust || ',"amount":10,"place":"BOX:' || l_box || '","allocations":[{"invoice":' || l_inv
             || ',"amount":10}]}', 'RCP2-' || l_sfx);
  ok('allocation to a paid invoice -> 422', l_st = 422 AND jv(l_r, '$.error.code') = 'not_open', l_r);

  -- ======================================================== السجل والحدود
  SELECT COUNT(*), COUNT(CASE WHEN http_status >= 400 THEN 1 END) INTO l_n, l_x FROM api_request_log WHERE api_client_id = l_cid;
  ok('every request logged with status', l_n >= 15 AND l_x >= 6, l_n || '/' || l_x);
  SELECT COUNT(*) INTO l_n FROM api_request_log WHERE api_client_id = l_cid AND error_code = 'REPLAY';
  ok('replay logged', l_n = 1, l_n);
  UPDATE api_client SET ip_allowlist = '192.168.1.*, 10.9.9.9' WHERE id = l_cid;
  l_r := api('GET', 'ping');
  ok('IP outside allow list -> 403', l_st = 403 AND jv(l_r, '$.error.code') = 'ip_not_allowed', l_r);
  l_r := api('GET', 'ping', p_ip => '192.168.1.44');
  ok('IP wildcard allowed', l_st = 200, l_r);
  UPDATE api_client SET ip_allowlist = NULL, rate_limit_per_min = 3 WHERE id = l_cid;
  l_r := api('GET', 'ping');
  ok('rate limit -> 429', l_st = 429 AND jv(l_r, '$.error.code') = 'rate_limited', l_r);
  UPDATE api_client SET rate_limit_per_min = 1000 WHERE id = l_cid;
  l_c := NOONA_API_PKG.openapi;
  SELECT COUNT(*) INTO l_n FROM dual WHERE JSON_EXISTS(l_c, '$.paths."/customers/{id}".get');
  ok('OpenAPI document', DBMS_LOB.INSTR(l_c, '"/sales-invoices"') > 0 AND DBMS_LOB.INSTR(l_c, '"Idempotency-Key"') > 0 AND l_n = 1, SUBSTR(l_c, 1, 300));
  l_r := api('GET', 'openapi.json', p_auth => 'none');
  ok('openapi.json without token', l_st = 200 AND jv(l_r, '$.openapi') = '3.0.3');

  -- ======================================================== Webhooks
  l_r := api('POST', 'webhooks', NULL, '{"event":"SAL_INVOICE.POSTED","url":"test://ok/hook","description":"متجر"}');
  l_wh := jv(l_r, '$.id');
  ok('webhook registered with signing secret', l_st = 201 AND jv(l_r, '$.secret') LIKE 'whsec\_%' ESCAPE '\', l_r);
  l_c := NOONA_API_PKG.save_webhook('{"event":"*","url":"test://fail/hook"}');
  l_wh2 := jv(l_c, '$.id');
  BEGIN l_c := NOONA_API_PKG.save_webhook('{"event":"X.Y","url":"https://a.b"}'); ok('unknown event rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('unknown event rejected', 'NOONA-API-011', SQLERRM); END;
  BEGIN l_c := NOONA_API_PKG.save_webhook('{"event":"*","url":"ftp://a.b"}'); ok('https only', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('https only', 'NOONA-API-010', SQLERRM); END;
  l_r := api('GET', 'webhooks');
  ok('client lists its webhooks only', l_st = 200 AND jv(l_r, '$.items[0].url') = 'test://ok/hook' AND jv(l_r, '$.items[1].id') IS NULL, l_r);
  -- فاتورة جديدة ترحل -> حدث لكل اشتراك مطابق
  l_r := api('POST', 'sales-invoices', NULL, '{"customer":' || l_cust || ',"lines":[{"item":' || l_item || ',"qty":1,"price":50}]}', 'INV2-' || l_sfx);
  l_inv := jv(l_r, '$.id');
  SELECT COUNT(*) INTO l_n FROM api_outbox WHERE aggregate_type = 'SAL_INVOICE' AND aggregate_id = l_inv AND event_type = 'SAL_INVOICE.POSTED' AND status_code = 'PENDING';
  ok('posting publishes to both subscriptions (exact + *)', l_n = 2, l_n);
  SELECT payload INTO l_c FROM api_outbox WHERE destination = 'WEBHOOK:' || l_wh AND aggregate_id = l_inv FETCH FIRST 1 ROW ONLY;
  ok('payload: event, entity and invoice data', jv(l_c, '$.event') = 'SAL_INVOICE.POSTED' AND jv(l_c, '$.data.id') = TO_CHAR(l_inv), SUBSTR(l_c, 1, 300));
  l_n := NOONA_API_PKG.dispatch;
  SELECT status_code INTO l_s FROM api_outbox WHERE destination = 'WEBHOOK:' || l_wh AND aggregate_id = l_inv;
  ok('delivered to test://ok -> SENT', l_s = 'SENT', l_s);
  SELECT status_code || '|' || attempts || '|' || CASE WHEN next_attempt_at > SYSTIMESTAMP THEN 'later' END INTO l_s
    FROM api_outbox WHERE destination = 'WEBHOOK:' || l_wh2 AND aggregate_id = l_inv;
  ok('failed delivery scheduled for retry with backoff', l_s = 'FAILED|1|later', l_s);
  SELECT COUNT(*) INTO l_n FROM api_webhook_delivery WHERE subscription_id IN (l_wh, l_wh2) AND outbox_id IS NOT NULL;
  SELECT last_http_status || '|' || failure_count INTO l_s FROM api_webhook_subscription WHERE id = l_wh2;
  ok('delivery log and subscription health', l_n = 2 AND l_s = '500|1', l_n || ' ' || l_s);
  -- قيمة مرجعية محسوبة خارجياً: HMAC-SHA256(key='whsec_x', msg='1700000000.{"a":1}')
  ok('signature: sha256 HMAC of timestamp.body', NOONA_API_PKG.sign('whsec_x', '1700000000', '{"a":1}') = 'sha256=b3438763ab46d9634b9844c8722818eaf523f803db1327484c6067462a5fd6d1',
     NOONA_API_PKG.sign('whsec_x', '1700000000', '{"a":1}'));
  UPDATE api_outbox SET attempts = 9, next_attempt_at = SYSTIMESTAMP - INTERVAL '1' SECOND WHERE destination = 'WEBHOOK:' || l_wh2 AND aggregate_id = l_inv
  RETURNING id INTO l_ob;
  l_n := NOONA_API_PKG.dispatch;
  SELECT status_code INTO l_s FROM api_outbox WHERE id = l_ob;
  ok('after 10 attempts -> DEAD', l_s = 'DEAD', l_s);
  NOONA_API_PKG.retry_outbox(l_ob);
  SELECT status_code || attempts INTO l_s FROM api_outbox WHERE id = l_ob;
  ok('manual retry re-queues', l_s = 'PENDING0', l_s);
  l_r := api('POST', 'webhooks', TO_CHAR(l_wh));
  ok('test ping queued', l_st = 202, l_r);
  SELECT COUNT(*) INTO l_n FROM api_outbox WHERE destination = 'WEBHOOK:' || l_wh AND event_type = 'PING';
  ok('ping in outbox', l_n = 1);
  NOONA_API_PKG.set_webhook_status(l_wh2, 'PAUSED');
  l_n := NOONA_API_PKG.dispatch;
  SELECT status_code INTO l_s FROM api_outbox WHERE id = l_ob;
  ok('paused subscription: queued event cancelled', l_s = 'CANCELLED', l_s);
  l_r := api('DELETE', 'webhooks', TO_CHAR(l_wh));
  SELECT status_code INTO l_s FROM api_webhook_subscription WHERE id = l_wh;
  ok('client deletes its webhook', l_st = 200 AND l_s = 'DISABLED', l_s);
  NOONA_API_PKG.set_webhook_status(l_wh2, 'DISABLED');

  -- ======================================================== الرسائل
  l_ch := NOONA_API_PKG.save_channel('{"channel":"SMS","adapter":"SIMULATOR","sender":"NOONA","secret":"k-123",'
          || '"rules":[{"event":"AR_RECEIPT.CREATED","template":"شكراً {{name}}، استلمنا {{total}} - {{company}}"}]}');
  SELECT secret_ref INTO l_s FROM api_integration_config WHERE id = l_ch;
  ok('channel secret stored encrypted', l_s IS NOT NULL AND l_s <> 'k-123');
  l_r := api('POST', 'receipts', NULL, '{"customer":' || l_cust || ',"amount":57.5,"place":"BOX:' || l_box || '","allocations":[{"invoice":' || l_inv
             || ',"amount":57.5}]}', 'RCP3-' || l_sfx);
  SELECT payload INTO l_c FROM api_outbox WHERE destination = 'SMS:' || l_ch AND event_type = 'AR_RECEIPT.CREATED' ORDER BY id DESC FETCH FIRST 1 ROW ONLY;
  ok('receipt rule -> SMS to customer mobile with template', jv(l_c, '$.to') = '05' || SUBSTR(l_sfx, 1, 8) AND INSTR(jv(l_c, '$.text'), 'شكراً عميل واجهة') = 1
     AND INSTR(jv(l_c, '$.text'), '57.50') > 0, SUBSTR(l_c, 1, 300));
  l_ob := NOONA_API_PKG.send_message('SMS', '+966500000001', 'رسالة يدوية');
  l_n := NOONA_API_PKG.dispatch;
  SELECT status_code INTO l_s FROM api_outbox WHERE id = l_ob;
  ok('manual SMS sent by simulator', l_s = 'SENT', l_s);
  BEGIN l_ob := NOONA_API_PKG.send_message('SMS', '12', 'x'); ok('invalid number', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('invalid number', 'NOONA-API-023', SQLERRM); END;
  BEGIN l_ob := NOONA_API_PKG.send_message('WHATSAPP', '+966500000001', 'x'); ok('unconfigured channel', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('unconfigured channel', 'NOONA-API-022', SQLERRM); END;

  -- ======================================================== الإلغاء والتدوير
  l_s := NOONA_API_PKG.rotate_secret(l_cid);
  l_r := api('GET', 'ping');
  ok('rotating the secret revokes tokens', l_st = 401, l_r);
  l_r := api('POST', 'token', NULL, '{"client_id":"' || l_key || '","client_secret":"' || l_sec || '"}');
  ok('old secret no longer works', l_st = 401, l_r);
  l_r := api('POST', 'token', NULL, '{"clientId":"' || l_key || '","clientSecret":"' || l_s || '"}');
  l_auth := 'Bearer ' || jv(l_r, '$.access_token');
  ok('new secret works', l_st = 200, l_r);
  UPDATE api_access_token SET expires_at = SYSTIMESTAMP - INTERVAL '1' SECOND WHERE api_client_id = l_cid;
  l_r := api('GET', 'ping');
  ok('expired token -> 401', l_st = 401 AND INSTR(jv(l_r, '$.error.message'), 'expired') > 0, l_r);
  UPDATE api_access_token SET expires_at = SYSTIMESTAMP + INTERVAL '10' MINUTE WHERE api_client_id = l_cid;
  NOONA_API_PKG.set_client_status(l_cid, 'SUSPENDED');
  l_r := api('GET', 'ping');
  ok('suspended client -> 401', l_st = 401, l_r);
  NOONA_API_PKG.set_client_status(l_cid, 'ACTIVE');
  l_r := api('POST', 'token', NULL, '{"clientId":"' || l_key || '","clientSecret":"' || l_s || '"}');
  l_auth := 'Bearer ' || jv(l_r, '$.access_token');
  ok('reactivated client gets a new token', l_st = 200, l_r);

  -- ======================================================== استيراد CSV
  l_job := NOONA_CONN_PKG.import_csv('CUSTOMERS', 'customers.csv', 'الاسم,الجوال,الرقم الضريبي' || CHR(13) || CHR(10)
           || '"مؤسسة ""الأمل"" ' || l_sfx || '",0551110001,' || CHR(10) || 'شركة الشروق ' || l_sfx || ',0551110002,' || CHR(10)
           || ',0551110003,' || CHR(10) || 'شركة الشروق ' || l_sfx || ',0551110004,' || CHR(10));
  SELECT ok_rows || '|' || failed_rows || '|' || status_code INTO l_s FROM api_import_job WHERE id = l_job;
  ok('customers CSV: 2 imported, empty name and duplicate rejected', l_s = '2|2|PARTIAL', l_s);
  SELECT COUNT(*) INTO l_n FROM pty_party WHERE display_name_ar = 'مؤسسة "الأمل" ' || l_sfx;
  ok('quoted field with escaped quotes', l_n = 1);
  ok('job errors per row', DBMS_LOB.INSTR(NOONA_CONN_PKG.job_html(l_job), 'موجود مسبقاً') > 0 AND DBMS_LOB.INSTR(NOONA_CONN_PKG.job_html(l_job), 'الاسم فارغ') > 0);
  l_job := NOONA_CONN_PKG.import_csv('ITEMS', 'items.csv', 'no;name;type;price;barcode' || CHR(10) || 'CSV-' || l_sfx || ';صنف مستورد;SERVICE;12,50;'
           || CHR(10) || 'CSV-' || l_sfx || ';مكرر;SERVICE;1;' || CHR(10));
  SELECT ok_rows || '|' || failed_rows INTO l_s FROM api_import_job WHERE id = l_job;
  ok('items CSV with ; separator, duplicate number rejected', l_s = '1|1', l_s);
  BEGIN l_job := NOONA_CONN_PKG.import_csv('ITEMS', 'x.csv', 'price' || CHR(10) || '1'); ok('name column required', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('name column required', 'NOONA-CON-004', SQLERRM); END;
  ok('CSV templates', NOONA_CONN_PKG.template_csv('BANK_STATEMENT') LIKE 'date,amount%');

  -- ======================================================== كشف البنك والمطابقة
  IF l_bank IS NOT NULL THEN
    l_x := NOONA_SAL_PKG.receive('{"cust":' || l_cust || ',"date":"' || TO_CHAR(SYSDATE - 1, 'YYYY-MM-DD') || '","amount":1234.56,"place":"BANK:' || l_bank
                                 || '","method":"BANK_APP"}');
    SELECT MAX(id) INTO l_t1 FROM csh_transaction WHERE source_entity_type = 'AR_RECEIPT' AND source_entity_id = l_x;
    l_n := NOONA_PUR_PKG.save_supplier('{"name":"مورد مطابقة ' || l_sfx || '","term":"NET30"}');
    l_x := NOONA_PUR_PKG.pay_supplier('{"sup":' || l_n || ',"date":"' || l_d || '","amount":789,"place":"BANK:' || l_bank || '","method":"BANK_APP"}');
    SELECT MAX(id) INTO l_t2 FROM csh_transaction WHERE source_entity_type = 'AP_PAYMENT' AND source_entity_id = l_x;
    SELECT doc_no INTO l_s FROM csh_transaction WHERE id = l_t1;
    l_c := 'التاريخ,إيداع,سحب,المرجع,البيان' || CHR(10)
        || TO_CHAR(SYSDATE - 1, 'DD/MM/YYYY') || ',"1,234.56",,' || l_s || ',تحويل' || CHR(10)
        || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ',,789.00,CHQ,سداد' || CHR(10)
        || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ',,15,,رسوم بنكية ' || l_sfx || CHR(10)
        || 'غير تاريخ,5,,,' || CHR(10);
    l_stm := NOONA_CONN_PKG.import_bank_statement(l_bank, 'stmt-' || l_sfx || '.csv', l_c);
    SELECT COUNT(*), SUM(amount) INTO l_n, l_x FROM csh_bank_statement_line WHERE statement_id = l_stm;
    ok('statement lines imported (debit/credit columns, bad date skipped)', l_n = 3 AND l_x = 1234.56 - 789 - 15, l_n || ' ' || l_x);
    SELECT LISTAGG(l.status_code || ':' || m.transaction_id, ',') WITHIN GROUP (ORDER BY l.line_no) INTO l_s
      FROM csh_bank_statement_line l LEFT JOIN csh_recon_match m ON m.statement_line_id = l.id WHERE l.statement_id = l_stm;
    ok('auto-match by amount, direction and date', l_s = 'SUGGESTED:' || l_t1 || ',SUGGESTED:' || l_t2 || ',UNMATCHED:', l_s);
    SELECT confidence_pct INTO l_x FROM csh_recon_match m JOIN csh_bank_statement_line l ON l.id = m.statement_line_id WHERE l.statement_id = l_stm AND m.transaction_id = l_t1;
    ok('reference match raises confidence', l_x >= 85, l_x);
    BEGIN l_x := NOONA_CONN_PKG.import_bank_statement(l_bank, 'again.csv', l_c); ok('same file twice rejected', FALSE);
    EXCEPTION WHEN OTHERS THEN expect('same file twice rejected', 'NOONA-CON-021', SQLERRM); END;
    l_n := NOONA_CONN_PKG.confirm_all(l_stm);
    SELECT is_reconciled INTO l_s FROM csh_transaction WHERE id = l_t1;
    ok('confirm marks transactions reconciled', l_n = 2 AND l_s = 'Y', l_n || ' ' || l_s);
    FOR m IN (SELECT m.id FROM csh_recon_match m WHERE m.transaction_id = l_t2 AND m.status_code = 'CONFIRMED') LOOP
      NOONA_CONN_PKG.reject_match(m.id);
    END LOOP;
    SELECT is_reconciled INTO l_s FROM csh_transaction WHERE id = l_t2;
    ok('undo a confirmed match', l_s = 'N');
    FOR l IN (SELECT id FROM csh_bank_statement_line WHERE statement_id = l_stm AND status_code = 'UNMATCHED') LOOP
      NOONA_CONN_PKG.ignore_line(l.id);
    END LOOP;
    l_n := NOONA_CONN_PKG.auto_match(l_stm);
    l_n := NOONA_CONN_PKG.confirm_all(l_stm);
    SELECT status_code INTO l_s FROM csh_bank_statement WHERE id = l_stm;
    ok('statement reconciled', l_s = 'RECONCILED', l_s);
    ok('reconciliation screens', DBMS_LOB.INSTR(NOONA_CONN_PKG.statement_html(l_stm), 'رسوم بنكية ' || l_sfx) > 0
       AND DBMS_LOB.INSTR(NOONA_CONN_PKG.statements_html, 'stmt-' || SUBSTR(l_sfx, 1, 4)) > 0);
  ELSE
    DBMS_OUTPUT.PUT_LINE('SKIP  bank statement tests (no bank account in the company)');
  END IF;

  -- ======================================================== طلبات المتجر
  l_body := '{"orderId":"WEB-' || l_sfx || '","customer":{"name":"زبون متجر ' || l_sfx || '","phone":"0569' || SUBSTR(l_sfx, 1, 6) || '"},'
         || '"lines":[{"sku":"99' || l_sfx || '","qty":1,"price":115}],"shipping":23,"paid":true,"place":"BOX:' || l_box || '","method":"CARD"}';
  l_r := api('POST', 'orders', NULL, l_body);
  l_inv := jv(l_r, '$.invoice');
  ok('order -> posted invoice (prices incl. VAT + shipping)', l_st = 201 AND jv(l_r, '$.total') = '138', l_r);
  SELECT status_code INTO l_s FROM sal_invoice WHERE id = l_inv;
  SELECT SUM(open_amount) INTO l_x FROM ar_open_item WHERE source_entity_type = 'SAL_INVOICE' AND source_entity_id = l_inv;
  ok('paid order collected', l_x = 0 AND jv(l_r, '$.receipt') IS NOT NULL, l_s || ' open ' || l_x);
  l_r := api('POST', 'orders', NULL, l_body);
  ok('same order again -> duplicate, no second invoice', l_st = 201 AND jv(l_r, '$.duplicate') = 'true' AND jv(l_r, '$.result.invoice') = TO_CHAR(l_inv), l_r);
  l_r := api('POST', 'orders', NULL, REPLACE(REPLACE(l_body, 'WEB-', 'WEB2-'), '"paid":true', '"paid":false'));
  l_ob := jv(l_r, '$.invoice');
  SELECT customer_account_id INTO l_x FROM sal_invoice WHERE id = l_ob;
  SELECT customer_account_id INTO l_n FROM sal_invoice WHERE id = l_inv;
  ok('returning customer matched by phone', l_x = l_n, l_x || ' vs ' || l_n);
  l_r := api('POST', 'orders', NULL, '{"orderId":"BAD-' || l_sfx || '","customer":{"name":"x"},"lines":[{"sku":"NO-SUCH-SKU","qty":1}]}');
  ok('unknown SKU -> 422', l_st = 422 AND INSTR(jv(l_r, '$.error.message'), 'NO-SUCH-SKU') > 0, l_r);

  -- ======================================================== الشاشات
  ok('admin screens', DBMS_LOB.INSTR(NOONA_API_PKG.summary_html, 'عملاء API فعالون') > 0 AND DBMS_LOB.INSTR(NOONA_API_PKG.clients_html, l_key) > 0
     AND DBMS_LOB.INSTR(NOONA_API_PKG.requests_html(l_cid), '/v1/sales-invoices') > 0 AND NOONA_API_PKG.webhooks_html IS NOT NULL
     AND DBMS_LOB.INSTR(NOONA_API_PKG.outbox_html, 'فاتورة مبيعات مرحلة') > 0 AND DBMS_LOB.INSTR(NOONA_API_PKG.channels_html, 'المحاكي') > 0
     AND DBMS_LOB.INSTR(NOONA_API_PKG.endpoints_html, '/v1/receipts') > 0 AND DBMS_LOB.INSTR(NOONA_CONN_PKG.jobs_html, 'items.csv') > 0);

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
