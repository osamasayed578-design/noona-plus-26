-- =============================================================================
-- NOONA PLUS ERP | اختبار وكيل التخزين المحلي (NOONA_DMS_AGENT_PKG) بحساب NOONA_APP
--   يحاكي الوكيل باستدعاء دوال الواجهة نفسها (hello / jobs / download / done / upload) داخل معاملة تُلغى في النهاية
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_storage_agent.sql
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
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'HH24MISSFF3');
  l_key  VARCHAR2(100);
  l_key2 VARCHAR2(100);
  l_aid  NUMBER;
  l_doc  NUMBER;
  l_cid  NUMBER;
  l_job  NUMBER;
  l_n    NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_pdf  BLOB;
  l_b    BLOB;
  l_hash VARCHAR2(128);

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  PROCEDURE login(p_user VARCHAR2) IS
  BEGIN
    NOONA_APEX_PKG.cleanup_request;
    NOONA_APEX_PKG.post_auth(p_user, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  END login;
  FUNCTION job_of(p_type VARCHAR2, p_content NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) INTO l FROM dms_agent_job WHERE agent_id = l_aid AND job_type = p_type AND NVL(content_id, -1) = NVL(p_content, -1);
    RETURN l;
  END job_of;
BEGIN
  login('ADMIN');
  l_n := NOONA_DMS_PKG.quick_setup;
  DELETE FROM dms_storage_profile;                                -- حالة نظيفة داخل المعاملة

  -- ----------------------------------------------------------- تسجيل الوكيل
  BEGIN l_key := NOONA_DMS_AGENT_PKG.create_agent(' '); ok('agent name required', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('agent name required', 'NOONA-DMS-160', SQLERRM); END;
  l_key := NOONA_DMS_AGENT_PKG.create_agent('خادم الأرشيف ' || l_sfx);
  SELECT id INTO l_aid FROM dms_storage_agent WHERE name = 'خادم الأرشيف ' || l_sfx;
  SELECT COUNT(*) INTO l_n FROM dms_storage_agent WHERE id = l_aid AND key_hash <> l_key AND key_hint = SUBSTR(l_key, -4);
  ok('key shown once, only its hash is stored', l_key LIKE 'nsa_%' AND LENGTH(l_key) = 52 AND l_n = 1, l_key);
  BEGIN l_key2 := NOONA_DMS_AGENT_PKG.create_agent('خادم الأرشيف ' || l_sfx); ok('duplicate agent name rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('duplicate agent name rejected', 'NOONA-DMS-161', SQLERRM); END;
  ok('new agent is not online yet', NOONA_DMS_AGENT_PKG.is_online(l_aid) = 'N');

  -- ----------------------------------------------------------- مصادقة الوكيل
  BEGIN l_c := NOONA_DMS_AGENT_PKG.hello('nsa_wrong_key_wrong_key_wrong', '{}'); ok('wrong key rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('wrong key rejected', 'NOONA-DMS-171', SQLERRM); END;
  l_c := NOONA_DMS_AGENT_PKG.hello(l_key, '{"host":"ARCHIVE-SRV","version":"1.0.0 windows","path":"D:\\NoonaArchive","free":500000000000,"files":0,"bytes":0}');
  ok('hello: agent online with its host and path', NOONA_DMS_AGENT_PKG.is_online(l_aid) = 'Y' AND INSTR(l_c, '"poll":2') > 0, l_c);
  l_c := NOONA_DMS_AGENT_PKG.agents_html;
  ok('agents page shows status, host and path', INSTR(l_c, 'متصل') > 0 AND INSTR(l_c, 'ARCHIVE-SRV') > 0 AND INSTR(l_c, 'NoonaArchive') > 0);

  -- ----------------------------------------------------------- اختيار الوكيل مكاناً للحفظ
  BEGIN NOONA_DMS_PKG.set_storage('LOCAL_AGENT'); ok('agent required for local agent storage', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('agent required for local agent storage', 'NOONA-DMS-147', SQLERRM); END;
  NOONA_DMS_PKG.set_storage('LOCAL_AGENT', p_agent_id => l_aid);
  ok('storage is the local agent', INSTR(NOONA_DMS_PKG.storage_html, 'وكيل تخزين محلي') > 0);
  BEGIN NOONA_DMS_AGENT_PKG.set_status(l_aid, 'DISABLED'); ok('cannot disable the agent in use', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('cannot disable the agent in use', 'NOONA-DMS-164', SQLERRM); END;

  -- ----------------------------------------------------------- أرشفة: يبقى في القاعدة حتى يؤكد الوكيل
  l_pdf := UTL_RAW.CAST_TO_RAW('%PDF-1.4' || CHR(10) || '% NOONA agent test ' || l_sfx || CHR(10) || '%%EOF');
  l_doc := NOONA_DMS_PKG.archive_document(NULL, NULL, 'GENERAL', 'عقد إيجار ' || l_sfx, 'C-' || l_sfx, NULL, NULL, NULL,
                                          'lease.pdf', 'application/pdf', l_pdf);
  SELECT v.content_id INTO l_cid FROM dms_document d JOIN dms_document_version v ON v.id = d.current_version_id WHERE d.id = l_doc;
  SELECT hash_value INTO l_hash FROM dms_file_content WHERE id = l_cid;
  ok('file hash recorded at archiving', LENGTH(l_hash) = 64);
  SELECT COUNT(*) INTO l_n FROM dms_file_content WHERE id = l_cid AND storage_medium = 'AGENT' AND agent_id = l_aid
     AND status_code = 'PENDING' AND content_blob IS NOT NULL;
  ok('new file: kept in the database until the agent confirms', l_n = 1);
  l_b := NOONA_DMS_PKG.read_content(l_cid);
  ok('pending file is viewable immediately', DBMS_LOB.COMPARE(l_b, l_pdf) = 0);
  l_c := NOONA_DMS_AGENT_PKG.jobs(l_key);
  ok('agent receives a PUT job with the file hash', INSTR(l_c, '"type":"PUT"') > 0 AND INSTR(l_c, l_hash) > 0, SUBSTR(l_c, 1, 300));
  l_job := job_of('PUT', l_cid);
  l_b := NOONA_DMS_AGENT_PKG.download(l_key, l_cid);
  ok('agent downloads the file', DBMS_LOB.COMPARE(l_b, l_pdf) = 0);
  BEGIN l_b := NOONA_DMS_AGENT_PKG.download(l_key, -1); ok('only its own pending files', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('only its own pending files', 'NOONA-DMS-173', SQLERRM); END;

  -- بصمة خاطئة: لا يعتمد ويبقى المحتوى
  l_c := NOONA_DMS_AGENT_PKG.done(l_key, l_job, '{"ok":true,"sha256":"00ff","ref":"2026/10/x.pdf"}');
  SELECT COUNT(*) INTO l_n FROM dms_file_content WHERE id = l_cid AND status_code = 'PENDING' AND content_blob IS NOT NULL;
  ok('hash mismatch: not accepted, content stays in the database', l_n = 1);
  -- بصمة صحيحة: يحذف من القاعدة
  l_c := NOONA_DMS_AGENT_PKG.jobs(l_key);
  l_c := NOONA_DMS_AGENT_PKG.done(l_key, l_job, '{"ok":true,"sha256":"' || l_hash || '","ref":"2026/10/lease_' || l_sfx || '.pdf"}');
  SELECT COUNT(*) INTO l_n FROM dms_file_content WHERE id = l_cid AND status_code = 'STORED' AND content_blob IS NULL
     AND storage_key = '2026/10/lease_' || l_sfx || '.pdf';
  ok('confirmed with the same hash: stored at the agent, removed from the database', l_n = 1);
  SELECT COUNT(*) INTO l_n FROM dms_agent_job WHERE id = l_job AND status_code = 'DONE';
  ok('PUT job done', l_n = 1);
  ok('storage page counts files at the agent', INSTR(NOONA_DMS_PKG.storage_html, 'عند وكيل الشركة') > 0);

  -- ----------------------------------------------------------- العرض: جلب من الوكيل
  l_c := NOONA_DMS_AGENT_PKG.jobs(l_key);                         -- لا مهام
  ok('no jobs when idle', l_c = '{"jobs":[]}', l_c);
  -- الوكيل لا يرد خلال المهلة (المحاكاة في نفس الجلسة): رسالة واضحة، ويبقى الطلب للوكيل
  BEGIN l_b := NOONA_DMS_PKG.read_content(l_cid); ok('offline agent: clear message', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('offline agent: clear message', 'NOONA-DMS-148', SQLERRM); END;
  l_c := NOONA_DMS_AGENT_PKG.jobs(l_key);
  ok('agent receives a GET job for the requested file', INSTR(l_c, '"type":"GET"') > 0 AND INSTR(l_c, 'lease_' || l_sfx) > 0, SUBSTR(l_c, 1, 300));
  l_job := job_of('GET', l_cid);
  BEGIN l_c := NOONA_DMS_AGENT_PKG.upload(l_key, l_cid, l_job, UTL_RAW.CAST_TO_RAW('tampered')); ok('changed file rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('changed file rejected', 'NOONA-DMS-175', SQLERRM); END;
  UPDATE dms_file_content SET status_code = 'STORED' WHERE id = l_cid;   -- الفشل يعلم الملف تالفاً؛ نعيده لنكمل
  UPDATE dms_agent_job SET status_code = 'SENT' WHERE id = l_job;
  l_c := NOONA_DMS_AGENT_PKG.upload(l_key, l_cid, l_job, l_pdf);
  l_b := NOONA_DMS_PKG.read_content(l_cid);
  ok('fetched from the agent and viewable', DBMS_LOB.COMPARE(l_b, l_pdf) = 0);
  SELECT COUNT(*) INTO l_n FROM dms_file_content WHERE id = l_cid AND cache_until > SYSTIMESTAMP AND content_blob IS NOT NULL;
  ok('temporary copy kept for an hour', l_n = 1);
  UPDATE dms_file_content SET cache_until = SYSTIMESTAMP - INTERVAL '1' MINUTE WHERE id = l_cid;
  NOONA_DMS_AGENT_PKG.purge_cache;
  SELECT COUNT(*) INTO l_n FROM dms_file_content WHERE id = l_cid AND content_blob IS NULL AND status_code = 'STORED';
  ok('expired temporary copy removed', l_n = 1);

  -- ----------------------------------------------------------- فشل المهمة ونقل الملفات القديمة
  l_n := NOONA_DMS_PKG.archive_document(NULL, NULL, 'GENERAL', 'مرفق ' || l_sfx, 'D-' || l_sfx, NULL, NULL, NULL,
                                        'b.pdf', 'application/pdf', l_pdf);
  l_c := NOONA_DMS_AGENT_PKG.jobs(l_key);
  SELECT MAX(id) INTO l_job FROM dms_agent_job WHERE agent_id = l_aid AND job_type = 'PUT' AND status_code = 'SENT';
  l_c := NOONA_DMS_AGENT_PKG.done(l_key, l_job, '{"ok":false,"error":"القرص ممتلئ"}');
  SELECT COUNT(*) INTO l_n FROM dms_agent_job WHERE id = l_job AND status_code = 'PENDING' AND error_text = 'القرص ممتلئ';
  ok('failed job retried with the agent error recorded', l_n = 1);
  ok('agent error shown on the agents page', INSTR(NOONA_DMS_AGENT_PKG.agents_html, 'القرص ممتلئ') > 0);
  NOONA_DMS_PKG.set_storage('DATABASE');
  l_n := NOONA_DMS_PKG.archive_document(NULL, NULL, 'GENERAL', 'قديم ' || l_sfx, 'E-' || l_sfx, NULL, NULL, NULL,
                                        'old.pdf', 'application/pdf', l_pdf);
  NOONA_DMS_PKG.set_storage('LOCAL_AGENT', p_agent_id => l_aid);
  l_n := NOONA_DMS_PKG.move_files(1000);
  ok('move files: database files queued for the agent', l_n >= 1, l_n);

  -- ----------------------------------------------------------- العودة من الوكيل إلى قاعدة البيانات
  NOONA_DMS_PKG.set_storage('DATABASE');
  l_n := NOONA_DMS_PKG.move_files(1000);
  ok('back to the database: agent files requested', l_n >= 1, l_n);
  l_c := NOONA_DMS_AGENT_PKG.jobs(l_key);
  l_job := job_of('RETURN', l_cid);
  ok('agent receives a RETURN job', INSTR(l_c, '"type":"RETURN"') > 0 AND l_job IS NOT NULL, SUBSTR(l_c, 1, 200));
  l_c := NOONA_DMS_AGENT_PKG.upload(l_key, l_cid, l_job, l_pdf);
  SELECT COUNT(*) INTO l_n FROM dms_file_content WHERE id = l_cid AND storage_medium = 'SECUREFILE' AND agent_id IS NULL
     AND content_blob IS NOT NULL AND cache_until IS NULL;
  ok('returned file kept permanently in the database', l_n = 1);
  l_b := NOONA_DMS_PKG.read_content(l_cid);
  ok('returned file readable without the agent', DBMS_LOB.COMPARE(l_b, l_pdf) = 0);
  NOONA_DMS_PKG.set_storage('LOCAL_AGENT', p_agent_id => l_aid);

  -- ----------------------------------------------------------- المفتاح والإيقاف
  l_key2 := NOONA_DMS_AGENT_PKG.new_key(l_aid);
  BEGIN l_c := NOONA_DMS_AGENT_PKG.jobs(l_key); ok('old key stops after rotation', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('old key stops after rotation', 'NOONA-DMS-171', SQLERRM); END;
  l_c := NOONA_DMS_AGENT_PKG.jobs(l_key2);
  ok('new key works', INSTR(l_c, '"jobs"') > 0);
  NOONA_DMS_PKG.set_storage('DATABASE');
  NOONA_DMS_AGENT_PKG.set_status(l_aid, 'DISABLED');
  BEGIN l_c := NOONA_DMS_AGENT_PKG.jobs(l_key2); ok('disabled agent rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('disabled agent rejected', 'NOONA-DMS-172', SQLERRM); END;
  l_c := NOONA_DMS_AGENT_PKG.setup_html(l_aid, l_key2);
  ok('setup instructions include the key and config file', INSTR(l_c, l_key2) > 0 AND INSTR(l_c, 'noona-agent.json') > 0);

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
