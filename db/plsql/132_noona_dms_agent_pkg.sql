-- =============================================================================
-- NOONA PLUS ERP | NOONA_DMS_AGENT_PKG - وكيل التخزين المحلي لملفات الأرشيف
--   برنامج صغير (tools/storage_agent) يثبت عند الشركة ويحفظ الملفات على أجهزتها. الوكيل هو من يتصل بالنظام
--   (لا يفتح منفذ في شبكة الشركة) عبر وحدة ORDS: /ords/noona/agent/v1/ بترويسة X-Agent-Key.
--   * الإدارة (من التطبيق 129): تسجيل وكيل ومفتاحه (يعرض مرة واحدة)، تغيير المفتاح، الإيقاف، الحالة
--   * صف المهام DMS_AGENT_JOB: PUT (احفظ عندك) / GET (أرسل الملف للعرض) / RETURN (أعده للقاعدة نهائياً) / TEST
--   * حفظ الملف عند الوكيل لا يعتمد إلا بعد مطابقة بصمته SHA-256؛ عندها يحذف من قاعدة البيانات
--   * الجلب للعرض يحفظ نسخة مؤقتة ساعة واحدة ثم تحذف (purge_cache)
-- =============================================================================
CREATE OR REPLACE PACKAGE NOONA_DMS_AGENT_PKG AUTHID DEFINER AS
  c_online_sec CONSTANT NUMBER := 90;    -- يعتبر الوكيل متصلاً إن اتصل خلال هذه الثواني
  c_cache_min  CONSTANT NUMBER := 60;    -- مدة النسخة المؤقتة بعد الجلب

  FUNCTION company RETURN NUMBER;
  FUNCTION sha_hex(p IN VARCHAR2) RETURN VARCHAR2;

  -- ---------------------------------------------------------------- الإدارة (جلسة APEX)
  -- يعيد المفتاح مرة واحدة فقط (لا يحفظ إلا بصمته)
  FUNCTION create_agent(p_name IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION new_key(p_agent_id IN NUMBER) RETURN VARCHAR2;
  PROCEDURE set_status(p_agent_id IN NUMBER, p_status IN VARCHAR2);
  FUNCTION is_online(p_agent_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION agents_html RETURN CLOB;
  FUNCTION setup_html(p_agent_id IN NUMBER, p_key IN VARCHAR2) RETURN CLOB;

  -- ---------------------------------------------------------------- واجهة الوكيل (ORDS؛ المصادقة بالمفتاح)
  PROCEDURE api_hello(p_key IN VARCHAR2, p_body IN CLOB, p_status OUT NUMBER);
  PROCEDURE api_jobs(p_key IN VARCHAR2, p_status OUT NUMBER);
  PROCEDURE api_download(p_key IN VARCHAR2, p_content_id IN NUMBER, p_status OUT NUMBER);
  PROCEDURE api_upload(p_key IN VARCHAR2, p_content_id IN NUMBER, p_job_id IN NUMBER, p_body IN BLOB, p_status OUT NUMBER);
  PROCEDURE api_done(p_key IN VARCHAR2, p_job_id IN NUMBER, p_body IN CLOB, p_status OUT NUMBER);

  -- منطق مستقل عن HTTP (يستخدمه الاختبار وواجهة ORDS)
  FUNCTION hello(p_key IN VARCHAR2, p_body IN CLOB) RETURN CLOB;
  FUNCTION jobs(p_key IN VARCHAR2) RETURN CLOB;
  FUNCTION download(p_key IN VARCHAR2, p_content_id IN NUMBER) RETURN BLOB;
  FUNCTION upload(p_key IN VARCHAR2, p_content_id IN NUMBER, p_job_id IN NUMBER, p_body IN BLOB) RETURN CLOB;
  FUNCTION done(p_key IN VARCHAR2, p_job_id IN NUMBER, p_body IN CLOB) RETURN CLOB;
  PROCEDURE purge_cache;
END NOONA_DMS_AGENT_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_DMS_AGENT_PKG AS
  g_http NUMBER;
  g_keep BOOLEAN := FALSE;

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;
  FUNCTION sha_hex(p IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN LOWER(RAWTOHEX(DBMS_CRYPTO.HASH(UTL_I18N.STRING_TO_RAW(p, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256)));
  END sha_hex;
  FUNCTION company RETURN NUMBER IS BEGIN RETURN NOONA_DMS_PKG.company; END;

  PROCEDURE guard IS
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('DMS_STORAGE_PROFILE.UPDATE', company);
  END guard;

  PROCEDURE fail(p_http NUMBER, p_code VARCHAR2, p_ar VARCHAR2, p_en VARCHAR2) IS
  BEGIN
    g_http := p_http;
    NOONA_CORE_PKG.raise_error(p_code, p_ar, p_en);
  END fail;

  FUNCTION gen_key RETURN VARCHAR2 IS
  BEGIN
    RETURN 'nsa_' || LOWER(RAWTOHEX(DBMS_CRYPTO.RANDOMBYTES(24)));
  END gen_key;

  -- ================================================================ الإدارة
  FUNCTION create_agent(p_name IN VARCHAR2) RETURN VARCHAR2 IS
    l_key VARCHAR2(100) := gen_key;
    l_id  NUMBER;
  BEGIN
    guard;
    NOONA_CORE_PKG.assert(TRIM(p_name) IS NOT NULL, 'NOONA-DMS-160', 'اكتب اسماً للوكيل (مثل: خادم الأرشيف - المقر الرئيسي)', 'Agent name is required');
    INSERT INTO dms_storage_agent (company_id, name, key_hash, key_hint, status_code)
    VALUES (company, TRIM(p_name), sha_hex(l_key), SUBSTR(l_key, -4), 'ACTIVE')
    RETURNING id INTO l_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'DMS_STORAGE_AGENT', l_id, 'CREATE_AGENT', 'SUCCESS', p_new_values => '{"name":' || NOONA_CORE_PKG.json_text(p_name) || '}');
    RETURN l_key;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-DMS-161', 'يوجد وكيل بنفس الاسم في هذه الشركة', 'An agent with this name exists');
  END create_agent;

  FUNCTION new_key(p_agent_id IN NUMBER) RETURN VARCHAR2 IS
    l_key VARCHAR2(100) := gen_key;
  BEGIN
    guard;
    UPDATE dms_storage_agent SET key_hash = sha_hex(l_key), key_hint = SUBSTR(l_key, -4) WHERE id = p_agent_id AND company_id = company;
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-DMS-162', 'الوكيل غير موجود', 'Agent not found');
    NOONA_AUDIT_PKG.log_event('SECURITY', 'DMS_STORAGE_AGENT', p_agent_id, 'ROTATE_KEY', 'SUCCESS');
    RETURN l_key;
  END new_key;

  PROCEDURE set_status(p_agent_id IN NUMBER, p_status IN VARCHAR2) IS
    l_n NUMBER;
  BEGIN
    guard;
    NOONA_CORE_PKG.assert(p_status IN ('ACTIVE', 'DISABLED'), 'NOONA-DMS-163', 'حالة غير صالحة', 'Invalid status');
    IF p_status = 'DISABLED' THEN
      SELECT COUNT(*) INTO l_n FROM dms_storage_profile WHERE company_id = company AND storage_medium = 'LOCAL_AGENT' AND agent_id = p_agent_id;
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-DMS-164', 'الوكيل هو مكان الحفظ الحالي للشركة؛ غيّر مكان الحفظ أولاً',
                            'Agent is the current storage; change storage first');
    END IF;
    UPDATE dms_storage_agent SET status_code = p_status WHERE id = p_agent_id AND company_id = company;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'DMS_STORAGE_AGENT', p_agent_id, 'SET_STATUS', 'SUCCESS', p_new_values => '{"status":"' || p_status || '"}');
  END set_status;

  FUNCTION is_online(p_agent_id IN NUMBER) RETURN VARCHAR2 IS
    l_n NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_n FROM dms_storage_agent
     WHERE id = p_agent_id AND status_code = 'ACTIVE' AND last_seen_at > SYSTIMESTAMP - NUMTODSINTERVAL(c_online_sec, 'SECOND');
    RETURN CASE WHEN l_n > 0 THEN 'Y' ELSE 'N' END;
  END is_online;

  FUNCTION size_text(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL THEN '-' WHEN p >= 1073741824 THEN TO_CHAR(ROUND(p / 1073741824, 1)) || ' GB'
                WHEN p >= 1048576 THEN TO_CHAR(ROUND(p / 1048576, 1)) || ' MB' ELSE TO_CHAR(ROUND(p / 1024)) || ' KB' END;
  END size_text;

  FUNCTION agents_html RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    l_h := '<table class="nn-rpt"><thead><tr><th>الوكيل</th><th>الحالة</th><th>الجهاز</th><th>مسار الحفظ</th><th>آخر اتصال</th>'
        || '<th>الملفات عنده</th><th>المساحة الحرة</th><th>بانتظار النقل</th><th>المفتاح</th></tr></thead><tbody>';
    FOR r IN (SELECT a.*, (SELECT COUNT(*) FROM dms_agent_job j WHERE j.agent_id = a.id AND j.status_code IN ('PENDING', 'SENT')) pend
                FROM dms_storage_agent a WHERE a.company_id = company ORDER BY a.name) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr><td class="nn-rpt-text"><b>' || esc(r.name) || '</b></td><td>'
          || CASE WHEN r.status_code = 'DISABLED' THEN '<span class="nn-badge is-muted">موقوف</span>'
                  WHEN is_online(r.id) = 'Y' THEN '<span class="nn-badge is-success">متصل</span>'
                  WHEN r.last_seen_at IS NULL THEN '<span class="nn-badge is-warning">لم يتصل بعد</span>'
                  ELSE '<span class="nn-badge is-danger">غير متصل</span>' END
          || CASE WHEN r.last_error IS NOT NULL THEN '<br><small class="nn-hint">' || esc(r.last_error) || '</small>' END
          || '</td><td dir="ltr">' || esc(NVL(r.host_name, '-')) || CASE WHEN r.agent_version IS NOT NULL THEN ' (v' || esc(r.agent_version) || ')' END
          || '</td><td dir="ltr">' || esc(NVL(r.storage_path, '-')) || '</td><td>' || NVL(TO_CHAR(r.last_seen_at, 'YYYY-MM-DD HH24:MI:SS'), '-')
          || '</td><td>' || NVL(TO_CHAR(r.stored_files), '-') || CASE WHEN r.stored_bytes IS NOT NULL THEN ' (' || size_text(r.stored_bytes) || ')' END
          || '</td><td>' || size_text(r.free_bytes) || '</td><td>' || r.pend || '</td><td dir="ltr">…' || esc(r.key_hint) || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN
      l_h := l_h || '<tr><td colspan="9" class="nn-rpt-text">لا يوجد وكيل بعد؛ أضف وكيلاً ثم ثبّت البرنامج على جهاز الشركة</td></tr>';
    END IF;
    RETURN l_h || '</tbody></table>';
  END agents_html;

  -- تعليمات التثبيت مع المفتاح (تعرض مرة واحدة بعد الإنشاء أو تغيير المفتاح)
  FUNCTION setup_html(p_agent_id IN NUMBER, p_key IN VARCHAR2) RETURN CLOB IS
    l_url VARCHAR2(1000);
    l_name dms_storage_agent.name%TYPE;
  BEGIN
    SELECT name INTO l_name FROM dms_storage_agent WHERE id = p_agent_id AND company_id = company;
    BEGIN
      l_url := OWA_UTIL.get_cgi_env('REQUEST_PROTOCOL') || '://' || OWA_UTIL.get_cgi_env('HTTP_HOST') || '/ords/noona/agent/v1/';
    EXCEPTION WHEN OTHERS THEN l_url := 'https://<server>/ords/noona/agent/v1/';
    END;
    RETURN '<div class="t-Alert t-Alert--warning t-Alert--horizontal"><div class="t-Alert-body"><p><b>احفظ المفتاح الآن: لن يظهر مرة أخرى.</b> '
        || 'إن فقد يمكن إصدار مفتاح جديد (يتوقف القديم فوراً).</p></div></div>'
        || '<div class="nn-fields"><div class="nn-field"><div class="nn-field-label">الوكيل</div><div class="nn-field-value"><b>' || esc(l_name) || '</b></div></div>'
        || '<div class="nn-field"><div class="nn-field-label">عنوان النظام (server)</div><div class="nn-field-value" dir="ltr"><code>' || esc(l_url) || '</code></div></div>'
        || '<div class="nn-field"><div class="nn-field-label">مفتاح الوكيل (key)</div><div class="nn-field-value" dir="ltr"><code>' || esc(p_key) || '</code></div></div></div>'
        || '<p class="nn-hint">التثبيت على جهاز الشركة (Windows أو Linux): انسخ برنامج الوكيل من حزمة النظام (<span dir="ltr">tools/storage_agent/dist</span>)، '
        || 'ثم أنشئ بجانبه ملف <span dir="ltr">noona-agent.json</span>:</p><pre dir="ltr">{\n  "server": "' || esc(l_url) || '",\n  "key": "' || esc(p_key)
        || '",\n  "path": "D:\\NoonaArchive"\n}</pre>'
        || '<p class="nn-hint">ثم شغّله كخدمة: <span dir="ltr"><code>noona-agent.exe install</code></span> على Windows، '
        || 'أو <span dir="ltr"><code>sudo ./noona-agent install</code></span> على Linux. خلال دقيقة تظهر حالته «متصل» هنا؛ اختبر الاتصال ثم اختر الوكيل مكاناً للحفظ.</p>';
  END setup_html;

  -- ================================================================ واجهة الوكيل
  FUNCTION auth(p_key VARCHAR2) RETURN dms_storage_agent%ROWTYPE IS
    l dms_storage_agent%ROWTYPE;
  BEGIN
    IF p_key IS NULL OR LENGTH(p_key) < 20 THEN fail(401, 'NOONA-DMS-170', 'مفتاح الوكيل مطلوب', 'Agent key required'); END IF;
    BEGIN
      SELECT * INTO l FROM dms_storage_agent WHERE key_hash = sha_hex(TRIM(p_key));
    EXCEPTION WHEN NO_DATA_FOUND THEN
      fail(401, 'NOONA-DMS-171', 'مفتاح الوكيل غير صحيح', 'Invalid agent key');
    END;
    IF l.status_code <> 'ACTIVE' THEN fail(403, 'NOONA-DMS-172', 'الوكيل موقوف من النظام', 'Agent is disabled'); END IF;
    RETURN l;
  END auth;

  PROCEDURE purge_cache IS
  BEGIN
    UPDATE dms_file_content SET content_blob = NULL, cache_until = NULL
     WHERE storage_medium = 'AGENT' AND status_code = 'STORED' AND cache_until < SYSTIMESTAMP AND content_blob IS NOT NULL;
  END purge_cache;

  FUNCTION hello(p_key IN VARCHAR2, p_body IN CLOB) RETURN CLOB IS
    l dms_storage_agent%ROWTYPE;
  BEGIN
    NOONA_CORE_PKG.begin_system;
    l := auth(p_key);
    UPDATE dms_storage_agent
       SET last_seen_at = SYSTIMESTAMP,
           host_name = SUBSTR(JSON_VALUE(p_body, '$.host'), 1, 200), agent_version = SUBSTR(JSON_VALUE(p_body, '$.version'), 1, 50),
           storage_path = SUBSTR(JSON_VALUE(p_body, '$.path'), 1, 500), free_bytes = JSON_VALUE(p_body, '$.free' RETURNING NUMBER),
           stored_files = JSON_VALUE(p_body, '$.files' RETURNING NUMBER), stored_bytes = JSON_VALUE(p_body, '$.bytes' RETURNING NUMBER),
           last_error = SUBSTR(JSON_VALUE(p_body, '$.error'), 1, 1000)
     WHERE id = l.id;
    purge_cache;
    NOONA_CORE_PKG.end_system;
    RETURN JSON_OBJECT('agent' VALUE l.name, 'tenant' VALUE l.tenant_id, 'company' VALUE l.company_id, 'poll' VALUE 2);
  EXCEPTION WHEN OTHERS THEN NOONA_CORE_PKG.end_system; RAISE;
  END hello;

  FUNCTION jobs(p_key IN VARCHAR2) RETURN CLOB IS
    l    dms_storage_agent%ROWTYPE;
    l_js CLOB := '[';
    l_n  PLS_INTEGER := 0;
  BEGIN
    NOONA_CORE_PKG.begin_system;
    l := auth(p_key);
    UPDATE dms_storage_agent SET last_seen_at = SYSTIMESTAMP WHERE id = l.id;
    -- مهمة أرسلت ولم تنجز خلال 5 دقائق تعاد (انقطع الوكيل أثناءها)
    UPDATE dms_agent_job SET status_code = 'PENDING'
     WHERE agent_id = l.id AND status_code = 'SENT' AND sent_at < SYSTIMESTAMP - INTERVAL '5' MINUTE AND attempts < 5;
    FOR j IN (SELECT j.id, j.job_type, j.content_id, c.storage_key, c.file_size_bytes, c.hash_value, c.detected_mime
                FROM dms_agent_job j LEFT JOIN dms_file_content c ON c.id = j.content_id
               WHERE j.agent_id = l.id AND j.status_code = 'PENDING' ORDER BY CASE j.job_type WHEN 'GET' THEN 0 WHEN 'TEST' THEN 1 WHEN 'PUT' THEN 2 ELSE 3 END, j.id
               FETCH FIRST 20 ROWS ONLY) LOOP
      l_n := l_n + 1;
      l_js := l_js || (CASE WHEN l_n > 1 THEN ',' END || JSON_OBJECT('id' VALUE j.id, 'type' VALUE j.job_type, 'content' VALUE j.content_id,
              'ref' VALUE j.storage_key, 'size' VALUE j.file_size_bytes, 'sha256' VALUE j.hash_value, 'mime' VALUE j.detected_mime ABSENT ON NULL));
      UPDATE dms_agent_job SET status_code = 'SENT', sent_at = SYSTIMESTAMP, attempts = attempts + 1 WHERE id = j.id;
    END LOOP;
    NOONA_CORE_PKG.end_system;
    RETURN '{"jobs":' || l_js || ']}';
  EXCEPTION WHEN OTHERS THEN NOONA_CORE_PKG.end_system; RAISE;
  END jobs;

  -- محتوى ملف لمهمة PUT: الوكيل يحمله ليحفظه عنده
  FUNCTION download(p_key IN VARCHAR2, p_content_id IN NUMBER) RETURN BLOB IS
    l   dms_storage_agent%ROWTYPE;
    l_b BLOB;
  BEGIN
    NOONA_CORE_PKG.begin_system;
    l := auth(p_key);
    BEGIN
      SELECT c.content_blob INTO l_b FROM dms_file_content c
       WHERE c.id = p_content_id AND c.agent_id = l.id AND c.content_blob IS NOT NULL
         AND EXISTS (SELECT 1 FROM dms_agent_job j WHERE j.content_id = c.id AND j.agent_id = l.id AND j.job_type = 'PUT' AND j.status_code IN ('PENDING', 'SENT'));
    EXCEPTION WHEN NO_DATA_FOUND THEN
      fail(404, 'NOONA-DMS-173', 'لا يوجد ملف بانتظار الحفظ عند هذا الوكيل', 'No pending file for this agent');
    END;
    NOONA_CORE_PKG.end_system;
    RETURN l_b;
  EXCEPTION WHEN OTHERS THEN NOONA_CORE_PKG.end_system; RAISE;
  END download;

  -- الوكيل يرسل ملفاً طُلب للعرض (مهمة GET): يحفظ مؤقتاً بعد مطابقة البصمة
  FUNCTION upload(p_key IN VARCHAR2, p_content_id IN NUMBER, p_job_id IN NUMBER, p_body IN BLOB) RETURN CLOB IS
    l   dms_storage_agent%ROWTYPE;
    l_c dms_file_content%ROWTYPE;
    l_h VARCHAR2(128);
    l_n NUMBER;
  BEGIN
    NOONA_CORE_PKG.begin_system;
    l := auth(p_key);
    BEGIN
      SELECT * INTO l_c FROM dms_file_content WHERE id = p_content_id AND agent_id = l.id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      fail(404, 'NOONA-DMS-174', 'الملف لا يخص هذا الوكيل', 'File does not belong to this agent');
    END;
    l_h := LOWER(RAWTOHEX(DBMS_CRYPTO.HASH(p_body, DBMS_CRYPTO.HASH_SH256)));
    IF l_h <> l_c.hash_value THEN
      UPDATE dms_agent_job SET status_code = 'FAILED', done_at = SYSTIMESTAMP, error_text = 'بصمة الملف المرسل لا تطابق الأصل'
       WHERE id = p_job_id AND agent_id = l.id;
      UPDATE dms_file_content SET status_code = 'CORRUPTED' WHERE id = l_c.id;
      g_keep := TRUE;
      fail(409, 'NOONA-DMS-175', 'بصمة الملف لا تطابق الأصل المؤرشف (تغير الملف على جهاز الوكيل)', 'File hash mismatch');
    END IF;
    SELECT COUNT(*) INTO l_n FROM dms_agent_job
     WHERE agent_id = l.id AND content_id = l_c.id AND job_type = 'RETURN' AND status_code IN ('PENDING', 'SENT');
    IF l_n > 0 THEN
      -- إعادة نهائية للقاعدة (توقف الشركة عن استخدام الوكيل)؛ تبقى نسخة الوكيل حتى يحذفها مسؤول الجهاز
      UPDATE dms_file_content SET storage_medium = 'SECUREFILE', agent_id = NULL, storage_key = NULL, content_blob = p_body,
                                  cache_until = NULL, last_verified_at = SYSTIMESTAMP
       WHERE id = l_c.id;
    ELSE
      UPDATE dms_file_content SET content_blob = p_body, cache_until = SYSTIMESTAMP + NUMTODSINTERVAL(c_cache_min, 'MINUTE'),
                                  last_verified_at = SYSTIMESTAMP
       WHERE id = l_c.id;
    END IF;
    UPDATE dms_agent_job SET status_code = 'DONE', done_at = SYSTIMESTAMP
     WHERE agent_id = l.id AND content_id = l_c.id AND job_type IN ('GET', 'RETURN') AND status_code IN ('PENDING', 'SENT');
    NOONA_CORE_PKG.end_system;
    RETURN JSON_OBJECT('ok' VALUE 'true' FORMAT JSON);
  EXCEPTION WHEN OTHERS THEN NOONA_CORE_PKG.end_system; RAISE;
  END upload;

  -- نتيجة مهمة: PUT تعتمد فقط ببصمة مطابقة ثم يحذف المحتوى من القاعدة (عدا ما يلزم بقاؤه)
  FUNCTION done(p_key IN VARCHAR2, p_job_id IN NUMBER, p_body IN CLOB) RETURN CLOB IS
    l    dms_storage_agent%ROWTYPE;
    l_j  dms_agent_job%ROWTYPE;
    l_c  dms_file_content%ROWTYPE;
    l_ok VARCHAR2(10) := LOWER(JSON_VALUE(p_body, '$.ok'));
    l_err VARCHAR2(1000) := SUBSTR(JSON_VALUE(p_body, '$.error'), 1, 1000);
  BEGIN
    NOONA_CORE_PKG.begin_system;
    l := auth(p_key);
    BEGIN
      SELECT * INTO l_j FROM dms_agent_job WHERE id = p_job_id AND agent_id = l.id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      fail(404, 'NOONA-DMS-176', 'المهمة غير موجودة لهذا الوكيل', 'Job not found');
    END;
    IF l_ok <> 'true' THEN
      UPDATE dms_agent_job SET status_code = CASE WHEN attempts >= 5 THEN 'FAILED' ELSE 'PENDING' END,
                               error_text = NVL(l_err, 'فشل غير محدد'), done_at = CASE WHEN attempts >= 5 THEN SYSTIMESTAMP END
       WHERE id = l_j.id;
      UPDATE dms_storage_agent SET last_error = l_err WHERE id = l.id;
    ELSIF l_j.job_type = 'PUT' THEN
      SELECT * INTO l_c FROM dms_file_content WHERE id = l_j.content_id;
      IF LOWER(JSON_VALUE(p_body, '$.sha256')) = l_c.hash_value AND JSON_VALUE(p_body, '$.ref') IS NOT NULL THEN
        UPDATE dms_file_content SET storage_key = SUBSTR(JSON_VALUE(p_body, '$.ref'), 1, 1000), status_code = 'STORED',
                                    content_blob = NULL, cache_until = NULL, last_verified_at = SYSTIMESTAMP
         WHERE id = l_c.id;
        UPDATE dms_agent_job SET status_code = 'DONE', done_at = SYSTIMESTAMP, error_text = NULL WHERE id = l_j.id;
      ELSE
        -- البصمة لا تطابق: المحتوى يبقى في القاعدة وتعاد المهمة
        UPDATE dms_agent_job SET status_code = CASE WHEN attempts >= 5 THEN 'FAILED' ELSE 'PENDING' END,
                                 error_text = 'بصمة الملف المحفوظ عند الوكيل لا تطابق الأصل' WHERE id = l_j.id;
      END IF;
    ELSE
      UPDATE dms_agent_job SET status_code = 'DONE', done_at = SYSTIMESTAMP, error_text = NULL WHERE id = l_j.id;
    END IF;
    UPDATE dms_storage_agent SET last_seen_at = SYSTIMESTAMP, last_error = CASE WHEN l_ok = 'true' THEN NULL ELSE last_error END WHERE id = l.id;
    NOONA_CORE_PKG.end_system;
    RETURN JSON_OBJECT('ok' VALUE 'true' FORMAT JSON);
  EXCEPTION WHEN OTHERS THEN NOONA_CORE_PKG.end_system; RAISE;
  END done;

  -- ================================================================ غلاف HTTP
  PROCEDURE out_json(p_json CLOB) IS
    l_pos PLS_INTEGER := 1;
  BEGIN
    OWA_UTIL.mime_header('application/json', TRUE, 'UTF-8');
    WHILE l_pos <= NVL(DBMS_LOB.getlength(p_json), 0) LOOP
      HTP.prn(DBMS_LOB.substr(p_json, 8000, l_pos));
      l_pos := l_pos + 8000;
    END LOOP;
  END out_json;

  PROCEDURE out_error(p_status OUT NUMBER) IS
    l_msg VARCHAR2(4000) := SQLERRM;
    l_code VARCHAR2(30) := REGEXP_SUBSTR(l_msg, 'NOONA-[A-Z]+-[0-9]+');
  BEGIN
    -- تسجيل فشل البصمة يحفظ رغم الخطأ؛ غير ذلك يتراجع
    IF g_keep THEN COMMIT; ELSE ROLLBACK; END IF;
    g_keep := FALSE;
    p_status := NVL(g_http, CASE WHEN l_code IS NOT NULL THEN 422 ELSE 500 END);
    g_http := NULL;
    out_json(JSON_OBJECT('error' VALUE JSON_OBJECT('code' VALUE NVL(l_code, 'server_error'),
             'message' VALUE REGEXP_REPLACE(REGEXP_SUBSTR(l_msg, '[^' || CHR(10) || ']+'), '^ORA-[0-9]+: ', ''))));
  END out_error;

  PROCEDURE api_hello(p_key IN VARCHAR2, p_body IN CLOB, p_status OUT NUMBER) IS
  BEGIN
    g_http := NULL; g_keep := FALSE; out_json(hello(p_key, p_body)); COMMIT; p_status := 200;
  EXCEPTION WHEN OTHERS THEN out_error(p_status);
  END api_hello;

  PROCEDURE api_jobs(p_key IN VARCHAR2, p_status OUT NUMBER) IS
  BEGIN
    g_http := NULL; g_keep := FALSE; out_json(jobs(p_key)); COMMIT; p_status := 200;
  EXCEPTION WHEN OTHERS THEN out_error(p_status);
  END api_jobs;

  PROCEDURE api_download(p_key IN VARCHAR2, p_content_id IN NUMBER, p_status OUT NUMBER) IS
    l_b BLOB;
  BEGIN
    g_http := NULL; g_keep := FALSE;
    l_b := download(p_key, p_content_id);
    OWA_UTIL.mime_header('application/octet-stream', FALSE);
    HTP.p('Content-Length: ' || DBMS_LOB.getlength(l_b));
    OWA_UTIL.http_header_close;
    WPG_DOCLOAD.download_file(l_b);
    p_status := 200;
  EXCEPTION WHEN OTHERS THEN out_error(p_status);
  END api_download;

  PROCEDURE api_upload(p_key IN VARCHAR2, p_content_id IN NUMBER, p_job_id IN NUMBER, p_body IN BLOB, p_status OUT NUMBER) IS
  BEGIN
    g_http := NULL; g_keep := FALSE; out_json(upload(p_key, p_content_id, p_job_id, p_body)); COMMIT; p_status := 200;
  EXCEPTION WHEN OTHERS THEN out_error(p_status);
  END api_upload;

  PROCEDURE api_done(p_key IN VARCHAR2, p_job_id IN NUMBER, p_body IN CLOB, p_status OUT NUMBER) IS
  BEGIN
    g_http := NULL; g_keep := FALSE; out_json(done(p_key, p_job_id, p_body)); COMMIT; p_status := 200;
  EXCEPTION WHEN OTHERS THEN out_error(p_status);
  END api_done;
END NOONA_DMS_AGENT_PKG;
/
