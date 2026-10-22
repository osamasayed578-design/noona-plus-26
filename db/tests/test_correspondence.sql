-- =============================================================================
-- NOONA PLUS ERP | اختبار المراسلات (NOONA_COR_PKG) بحساب NOONA_APP - يتراجع عن كل التغييرات في النهاية
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_correspondence.sql
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
  l_co   NUMBER;
  l_adm  NUMBER;
  l_u1   NUMBER;
  l_u2   NUMBER;
  l_u3   NUMBER;
  l_id   NUMBER;
  l_rep  NUMBER;
  l_dr   NUMBER;
  l_fw   NUMBER;
  l_in   NUMBER;
  l_doc  NUMBER;
  l_n    NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_png  BLOB;

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
  FUNCTION has(p_clob CLOB, p_text VARCHAR2) RETURN BOOLEAN IS
  BEGIN RETURN DBMS_LOB.INSTR(p_clob, p_text) > 0; END;
  FUNCTION who(p_member NUMBER) RETURN VARCHAR2 IS
  BEGIN RETURN '{"k":"U","id":' || p_member || '}'; END;
BEGIN
  login('ADMIN');
  l_co  := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  l_adm := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID'));
  l_u1 := NOONA_SEC_ADMIN_PKG.create_user('CR1' || l_sfx, 'سارة المراسلات', 'cr1' || l_sfx || '@noona.test', l_co);
  l_u2 := NOONA_SEC_ADMIN_PKG.create_user('CR2' || l_sfx, 'خالد المتابعة', 'cr2' || l_sfx || '@noona.test', l_co);
  l_u3 := NOONA_SEC_ADMIN_PKG.create_user('CR3' || l_sfx, 'طرف غير معني', 'cr3' || l_sfx || '@noona.test', l_co);

  -- الأساسيات
  l_c := NOONA_COR_PKG.meta_json;
  ok('meta lists instructions and types', has(l_c, '"c":"ACTION"') AND has(l_c, '"c":"INTERNAL_MEMO"'));
  l_c := NOONA_COR_PKG.directory_json('CR1' || l_sfx);
  ok('directory finds users', has(l_c, '"id":' || l_u1));

  -- التحقق
  BEGIN l_n := NOONA_COR_PKG.send('{"kind":"INTERNAL","subject":"بدون مستلم","body":"x"}'); ok('recipient required', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('recipient required', 'NOONA-COR-014', SQLERRM); END;
  BEGIN l_n := NOONA_COR_PKG.send('{"kind":"OUTGOING","subject":"صادر بلا جهة","body":"x"}'); ok('outgoing needs party', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('outgoing needs party', 'NOONA-COR-015', SQLERRM); END;

  -- مذكرة داخلية بتعليمة ومهلة ومرفق
  l_id := NOONA_COR_PKG.save_draft('{"kind":"INTERNAL","to":[' || who(l_u1) || '],"cc":[' || who(l_u2) || '],"bcc":[' || who(l_u3)
          || '],"subject":"طلب تقرير المبيعات ' || l_sfx || '","body":"نرجو إعداد تقرير المبيعات الشهري.\nمع الشكر",'
          || '"priority":"URGENT","instr":"ACTION","due":"' || TO_CHAR(TRUNC(SYSDATE) + 3, 'YYYY-MM-DD') || '"}');
  l_c := NOONA_COR_PKG.list_json('DRAFTS');
  ok('draft listed in drafts', has(l_c, '"id":' || l_id));
  l_png := HEXTORAW('89504E470D0A1A0A0000000D4948445200000001000000010806000000');
  l_doc := NOONA_COR_PKG.attach(l_id, 'chart.png', 'image/png', l_png);
  ok('attachment stored in archive', l_doc IS NOT NULL);
  l_c := NOONA_COR_PKG.draft_json(l_id);
  ok('draft reopens with recipients and attachment', has(l_c, '"id":' || l_u1) AND has(l_c, 'chart.png') AND has(l_c, '"instr":"ACTION"'));
  l_n := NOONA_COR_PKG.send('{"id":' || l_id || ',"kind":"INTERNAL","to":[' || who(l_u1) || '],"cc":[' || who(l_u2) || '],"bcc":['
          || who(l_u3) || '],"subject":"طلب تقرير المبيعات ' || l_sfx || '","body":"نرجو إعداد تقرير المبيعات الشهري.\nمع الشكر",'
          || '"priority":"URGENT","instr":"ACTION","due":"' || TO_CHAR(TRUNC(SYSDATE) + 3, 'YYYY-MM-DD') || '"}');
  ok('send keeps the draft id', l_n = l_id);
  SELECT correspondence_no, status_code INTO l_s, l_s FROM cor_correspondence WHERE id = l_id;
  SELECT correspondence_no INTO l_s FROM cor_correspondence WHERE id = l_id;
  ok('internal number allocated', l_s LIKE 'INT-%', l_s);
  SELECT COUNT(*) INTO l_n FROM cor_recipient WHERE correspondence_id = l_id;
  ok('three recipients delivered (to, cc, bcc)', l_n = 3, l_n);
  SELECT COUNT(*) INTO l_n FROM ntf_notification WHERE source_entity_type = 'COR_CORRESPONDENCE' AND source_entity_id = l_id;
  ok('recipients notified', l_n = 3, l_n);
  BEGIN l_doc := NOONA_COR_PKG.attach(l_id, 'late.png', 'image/png', l_png); ok('no attachments after sending', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('no attachments after sending', 'NOONA-COR-017', SQLERRM); END;
  l_c := NOONA_COR_PKG.list_json('SENT');
  ok('sent folder shows the memo', has(l_c, '"id":' || l_id));
  ok('drafts folder empty of it', NOT has(NOONA_COR_PKG.list_json('DRAFTS'), '"id":' || l_id || ','));
  ok('letter prints with number', DBMS_LOB.INSTR(NOONA_COR_PKG.letter_html(l_id), l_s) > 0);

  -- المستلم الأول
  login('CR1' || l_sfx);
  ok('unread counted', NOONA_COR_PKG.unread_count = 1, NOONA_COR_PKG.unread_count);
  l_c := NOONA_COR_PKG.list_json('INBOX');
  ok('inbox shows unread memo', has(l_c, '"id":' || l_id) AND has(l_c, '"u":"Y"'));
  ok('required-action folder shows it', has(NOONA_COR_PKG.list_json('TASKS'), '"id":' || l_id));
  ok('search finds by subject', has(NOONA_COR_PKG.list_json('INBOX', 'تقرير المبيعات ' || l_sfx), '"id":' || l_id));
  l_c := NOONA_COR_PKG.thread_json(l_id);
  ok('thread shows body, attachment and my instruction', has(l_c, 'تقرير المبيعات الشهري') AND has(l_c, 'chart.png')
     AND has(l_c, '"ins":"لاتخاذ اللازم"'));
  ok('blind copy hidden from recipients', NOT has(l_c, 'طرف غير معني'));
  ok('opening marks it read', NOONA_COR_PKG.unread_count = 0);
  NOONA_COR_PKG.set_star(l_id, 'Y');
  ok('starred folder', has(NOONA_COR_PKG.list_json('STARRED'), '"id":' || l_id));
  NOONA_COR_PKG.acknowledge(l_id);
  SELECT action_status INTO l_s FROM cor_recipient WHERE correspondence_id = l_id AND membership_id = l_u1;
  ok('acknowledged', l_s = 'ACKNOWLEDGED', l_s);
  NOONA_COR_PKG.refer(l_id, l_u2, 'STUDY', TRUNC(SYSDATE) + 2, 'أرجو دراسة الأرقام وإفادتي');
  SELECT action_status INTO l_s FROM cor_recipient WHERE correspondence_id = l_id AND membership_id = l_u1;
  ok('referrer marked forwarded', l_s = 'FORWARDED', l_s);
  ok('referral leaves the required-action folder', NOT has(NOONA_COR_PKG.list_json('TASKS'), '"id":' || l_id || ','));
  NOONA_COR_PKG.archive_thread(l_id);
  ok('archived thread leaves inbox', NOT has(NOONA_COR_PKG.list_json('INBOX'), '"id":' || l_id || ','));
  ok('archived thread in archive', has(NOONA_COR_PKG.list_json('ARCHIVE'), '"id":' || l_id));
  NOONA_COR_PKG.restore_thread(l_id);
  ok('restored to inbox', has(NOONA_COR_PKG.list_json('INBOX'), '"id":' || l_id));
  BEGIN l_n := NOONA_COR_PKG.send('{"kind":"INCOMING","to":[' || who(l_u2) || '],"subject":"وارد","party":"جهة","body":"x"}');
    ok('registering incoming needs permission', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('registering incoming needs permission', 'NOONA-COR-009', SQLERRM); END;

  -- المحال إليه
  login('CR2' || l_sfx);
  l_c := NOONA_COR_PKG.thread_json(l_id);
  ok('referral shown with note', has(l_c, 'أرجو دراسة الأرقام') AND has(l_c, '"ins":"للدراسة"'));
  ok('referred task in required-action folder', has(NOONA_COR_PKG.list_json('TASKS'), '"id":' || l_id));
  l_rep := NOONA_COR_PKG.send('{"kind":"INTERNAL","parent":' || l_id || ',"rel":"REPLY","to":[' || who(l_u1) || ',' || who(l_adm)
           || '],"subject":"رد: طلب تقرير المبيعات ' || l_sfx || '","body":"تمت الدراسة؛ التقرير مرفق لاحقاً"}');
  SELECT NVL(thread_id, id) INTO l_n FROM cor_correspondence WHERE id = l_rep;
  ok('reply joins the thread', l_n = l_id, l_n);
  SELECT action_status INTO l_s FROM cor_recipient WHERE correspondence_id = l_id AND membership_id = l_u2;
  ok('reply completes my required action', l_s = 'ACTIONED', l_s);
  SELECT COUNT(*) INTO l_n FROM cor_circulation WHERE correspondence_id = l_id AND to_member_id = l_u2 AND status_code = 'COMPLETED';
  ok('referral station completed', l_n = 1, l_n);
  l_fw := NOONA_COR_PKG.save_draft('{"kind":"INTERNAL","parent":' || l_id || ',"rel":"FORWARD","to":[' || who(l_u3)
          || '],"subject":"تحويل: طلب تقرير المبيعات","body":"للاطلاع"}');
  ok('forward carries attachments', DBMS_LOB.INSTR(NOONA_COR_PKG.draft_json(l_fw), 'chart.png') > 0);
  NOONA_COR_PKG.delete_draft(l_fw);
  ok('deleted draft gone', NOT has(NOONA_COR_PKG.list_json('DRAFTS'), '"id":' || l_fw || ','));

  -- طرف غير معني بالرد
  login('CR3' || l_sfx);
  ok('blind copy recipient sees the memo', has(NOONA_COR_PKG.list_json('INBOX'), '"t":' || l_id));
  BEGIN l_c := NOONA_COR_PKG.thread_json(l_rep); ok('reply not visible to non-party', NOT has(l_c, 'تمت الدراسة'));
  EXCEPTION WHEN OTHERS THEN ok('reply not visible to non-party', TRUE); END;
  BEGIN NOONA_COR_PKG.complete(l_rep); ok('non-recipient cannot complete', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('non-recipient cannot complete', 'NOONA-COR-019', SQLERRM); END;

  -- المرسل يرى الرد في سلسلته
  login('ADMIN');
  l_c := NOONA_COR_PKG.thread_json(l_id);
  ok('author sees the whole conversation', has(l_c, 'تمت الدراسة') AND has(l_c, '"bcc":["طرف غير معني"]'));
  SELECT COUNT(*) INTO l_n FROM cor_recipient WHERE correspondence_id = l_rep AND membership_id = l_adm;
  ok('author received the reply', l_n = 1, l_n);

  -- وارد خارجي يسجل ويوزع، وصادر لجهة خارجية
  l_in := NOONA_COR_PKG.send('{"kind":"INCOMING","to":[' || who(l_u1) || '],"subject":"خطاب الهيئة رقم 55/' || l_sfx
          || '","party":"هيئة الزكاة والضريبة","ext_no":"55/' || l_sfx || '","letter_date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD')
          || '","instr":"STUDY","body":"نص الخطاب الوارد"}');
  SELECT correspondence_no, status_code INTO l_s, l_s FROM cor_correspondence WHERE id = l_in;
  ok('incoming registered and distributed', l_s = 'DISTRIBUTED', l_s);
  SELECT correspondence_no INTO l_s FROM cor_correspondence WHERE id = l_in;
  ok('incoming number', l_s LIKE 'IN-%', l_s);
  ok('incoming register lists it', has(NOONA_COR_PKG.list_json('INCOMING', '55/' || l_sfx), '"id":' || l_in));
  l_n := NOONA_COR_PKG.send('{"kind":"OUTGOING","subject":"رد على خطاب الهيئة","party":"هيئة الزكاة والضريبة","parent":' || l_in
          || ',"rel":"REPLY","body":"نفيدكم بأن..."}');
  SELECT correspondence_no INTO l_s FROM cor_correspondence WHERE id = l_n;
  ok('outgoing number', l_s LIKE 'OUT-%', l_s);
  ok('outgoing register lists it', has(NOONA_COR_PKG.list_json('OUTGOING'), '"id":' || l_n));

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
