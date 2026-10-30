-- =============================================================================
-- NOONA PLUS ERP | اختبار إيصال الصادر الخارجي (بريد إلكتروني / تسليم ورقي / الاثنان) بحساب NOONA_APP - يتراجع في النهاية
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_cor_delivery.sql
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
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'MISSFF3');
  l_n    NUMBER;
  l_id   NUMBER;
  l_p    NUMBER;
  l_e    NUMBER;
  l_b    NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_mail NUMBER;

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION has(p_clob CLOB, p_text VARCHAR2) RETURN BOOLEAN IS BEGIN RETURN DBMS_LOB.INSTR(p_clob, p_text) > 0; END;
  FUNCTION st(p_id NUMBER, p_ch VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) KEEP (DENSE_RANK LAST ORDER BY id) INTO l FROM cor_dispatch WHERE correspondence_id = p_id AND channel = p_ch;
    RETURN l;
  END st;
  FUNCTION letter(p_delivery VARCHAR2, p_email VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN NOONA_COR_PKG.send('{"kind":"OUTGOING","subject":"عرض سعر ' || l_sfx || '","party":"شركة الأمل","body":"نرفق لكم عرض السعر.",'
      || '"delivery":"' || p_delivery || '","email":' || CASE WHEN p_email IS NULL THEN 'null' ELSE '"' || p_email || '"' END || '}');
  END letter;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  -- البريد يوضع في طابور مساحة عمل التطبيق (في التطبيق تحددها جلسة APEX)
  APEX_UTIL.set_workspace('NOONAPLUS');
  DELETE FROM cor_mail_profile;

  -- التحقق
  BEGIN l_n := letter('EMAIL', NULL); ok('email delivery needs an address', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('email delivery needs an address', 'NOONA-COR-032', SQLERRM); END;
  BEGIN l_n := letter('EMAIL', 'not-an-email'); ok('invalid address rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('invalid address rejected', 'NOONA-COR-032', SQLERRM); END;
  BEGIN l_n := letter('FAX', NULL); ok('unknown method rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('unknown method rejected', 'NOONA-COR-030', SQLERRM); END;

  -- طباعة فقط (الافتراضي)
  l_p := letter('PRINT', NULL);
  ok('print letter waits for handover', st(l_p, 'PRINT_HANDOVER') = 'QUEUED' AND st(l_p, 'EMAIL') IS NULL);
  BEGIN NOONA_COR_PKG.record_handover(l_p, ' '); ok('receiver name required', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('receiver name required', 'NOONA-COR-037', SQLERRM); END;
  NOONA_COR_PKG.record_handover(l_p, 'محمد - مكتب الاستقبال');
  SELECT MAX(received_by) INTO l_s FROM cor_dispatch WHERE correspondence_id = l_p AND channel = 'PRINT_HANDOVER';
  ok('handover recorded with receiver', st(l_p, 'PRINT_HANDOVER') = 'DELIVERED' AND l_s = 'محمد - مكتب الاستقبال');
  ok('print copy has no auto-print in email version', has(NOONA_COR_PKG.letter_html(l_p), 'window.print'));

  -- بريد بلا بريد شركة معرف: يسجل الفشل ولا يمنع تسجيل الصادر
  l_e := letter('EMAIL', 'Info@Alamal.Example');
  SELECT MAX(error_message), MAX(destination) INTO l_s, l_c FROM cor_dispatch WHERE correspondence_id = l_e AND channel = 'EMAIL';
  ok('email without company mailbox fails clearly', st(l_e, 'EMAIL') = 'FAILED' AND l_s LIKE '%بريد الشركة%', l_s);
  ok('address normalised', l_c = 'info@alamal.example', l_c);
  SELECT status_code INTO l_s FROM cor_correspondence WHERE id = l_e;
  ok('letter still registered as sent', l_s = 'SENT');

  -- بريد الشركة ثم إعادة الإرسال
  BEGIN NOONA_COR_PKG.save_mail_profile('bad', NULL, NULL, NULL, NULL); ok('sender address validated', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('sender address validated', 'NOONA-COR-033', SQLERRM); END;
  NOONA_COR_PKG.save_mail_profile('Letters@Noona.Example', 'إدارة الاتصالات', 'inbox@noona.example', 'archive@noona.example', 'مع التحية');
  ok('mail profile saved', has(NOONA_COR_PKG.mail_profile_json, '"from":"letters@noona.example"'));
  NOONA_COR_PKG.resend_email(l_e);
  SELECT MAX(TO_NUMBER(provider_message_id)) INTO l_mail FROM cor_dispatch WHERE correspondence_id = l_e AND channel = 'EMAIL';
  ok('resend queues the mail', st(l_e, 'EMAIL') = 'SENDING' AND l_mail IS NOT NULL);
  SELECT COUNT(*) INTO l_n FROM apex_mail_queue WHERE id = l_mail AND mail_to = 'info@alamal.example' AND mail_subj LIKE 'عرض سعر%';
  ok('mail in APEX queue with subject', l_n = 1, l_n);
  SELECT COUNT(*) INTO l_n FROM cor_dispatch WHERE correspondence_id = l_e AND channel = 'EMAIL';
  ok('each attempt kept', l_n = 2);
  ok('dispatch json shows status', has(NOONA_COR_PKG.dispatch_json(l_e), '"stl":"في طابور البريد"'));

  -- الاثنان مع مرفق
  l_b := NOONA_COR_PKG.save_draft('{"kind":"OUTGOING","subject":"عقد توريد ' || l_sfx || '","party":"مؤسسة النور","body":"مرفق العقد.",'
    || '"delivery":"BOTH","email":"contracts@alnoor.example"}');
  l_n := NOONA_COR_PKG.attach(l_b, 'contract.png', 'image/png', HEXTORAW('89504E470D0A1A0A0000000D49484452000000010000000108060000001F15C4890000000D4944415478DA63FCCFC0500F000485018084A98C210000000049454E44AE426082'));
  ok('draft keeps method and email', has(NOONA_COR_PKG.draft_json(l_b), '"delivery":"BOTH","email":"contracts@alnoor.example"'));
  l_n := NOONA_COR_PKG.send('{"id":' || l_b || ',"kind":"OUTGOING","subject":"عقد توريد ' || l_sfx || '","party":"مؤسسة النور",'
    || '"body":"مرفق العقد.","delivery":"BOTH","email":"contracts@alnoor.example"}');
  SELECT MAX(TO_NUMBER(provider_message_id)) INTO l_mail FROM cor_dispatch WHERE correspondence_id = l_b AND channel = 'EMAIL';
  ok('both: mail queued and paper waits', st(l_b, 'EMAIL') = 'SENDING' AND st(l_b, 'PRINT_HANDOVER') = 'QUEUED');
  SELECT COUNT(*) INTO l_n FROM apex_mail_attachments WHERE mail_id = l_mail AND filename = 'contract.png';
  ok('attachment sent with the mail', l_n = 1, l_n);
  SELECT COUNT(*) INTO l_n FROM apex_mail_queue WHERE id = l_mail AND mail_bcc = 'archive@noona.example'
     AND DBMS_LOB.INSTR(mail_body_html, 'عقد توريد') > 0 AND DBMS_LOB.INSTR(mail_body_html, 'window.print') = 0;
  ok('html letter without print script, archive bcc', l_n = 1, l_n);
  BEGIN NOONA_COR_PKG.record_handover(NOONA_COR_PKG.send('{"kind":"INCOMING","to":[{"k":"U","id":' || SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID')
          || '}],"subject":"وارد","party":"جهة","body":"x","channel":"EMAIL"}'), 'x'); ok('handover only for outgoing', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('handover only for outgoing', 'NOONA-COR-036', SQLERRM); END;
  SELECT COUNT(*) INTO l_n FROM cor_correspondence WHERE subject = 'وارد' AND inbound_channel = 'EMAIL' AND created_at > SYSTIMESTAMP - INTERVAL '1' MINUTE;
  ok('incoming letter registered from e-mail channel', l_n >= 1);

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
