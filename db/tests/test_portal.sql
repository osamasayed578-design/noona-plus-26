-- =============================================================================
-- NOONA PLUS ERP | اختبار طبقة البوابة (NOONA_PORTAL_PKG + الواجهات) بحساب NOONA_APP
-- المتطلبات: install.sql + synonyms + seed/90_demo_tenant_DEV_ONLY.sql
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_portal.sql
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
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'DDHH24MISSFF2');
  l_sess NUMBER := TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12));
  l_me   NUMBER;
  l_def  NUMBER;
  l_ver  NUMBER;
  l_id   NUMBER;
  l_inst NUMBER;
  l_task NUMBER;
  l_n    NUMBER;
  l_s    VARCHAR2(4000);

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN
      g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE
      g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
BEGIN
  DBMS_OUTPUT.PUT_LINE('=== NOONA portal tests as ' || USER || ', suffix ' || l_sfx);

  -- بلا جلسة: لا شيء
  SELECT COUNT(*) INTO l_n FROM noona_v_my_tasks;
  ok('no session: no tasks', l_n = 0);
  SELECT COUNT(*) INTO l_n FROM noona_v_apps;
  ok('no session: no apps', l_n = 0);

  -- مسؤول المؤسسة يعرف مساراً بسيطاً يعتمده بنفسه ثم يبدؤه
  NOONA_APEX_PKG.post_auth('ADMIN', l_sess);
  l_me := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID'));
  l_def := NOONA_WORKFLOW_PKG.create_definition('PTL' || l_sfx, 'اعتماد تجريبي للبوابة', 'PUR_ORDER');
  l_ver := NOONA_WORKFLOW_PKG.new_version(l_def);
  l_id  := NOONA_WORKFLOW_PKG.add_step(l_ver, 'S', 'START', 'بداية');
  l_id  := NOONA_WORKFLOW_PKG.add_step(l_ver, 'A', 'APPROVAL', 'اعتماد المدير', 'USER', l_me, p_allow_self => 'Y');
  l_id  := NOONA_WORKFLOW_PKG.add_step(l_ver, 'E', 'END', 'نهاية');
  NOONA_WORKFLOW_PKG.add_transition(l_ver, 'S', 'A');
  NOONA_WORKFLOW_PKG.add_transition(l_ver, 'A', 'E', 'APPROVED');
  NOONA_WORKFLOW_PKG.publish_version(l_ver);
  l_inst := NOONA_WORKFLOW_PKG.start_workflow('PTL' || l_sfx, 'PUR_ORDER', TO_NUMBER(SUBSTR(l_sfx, -6)),
                                              '{"amount":1500,"currency":"SAR","priority":"HIGH"}');

  SELECT MAX(task_id), COUNT(*) INTO l_task, l_n FROM noona_v_my_tasks WHERE instance_id = l_inst;
  ok('my tasks: new task visible', l_n = 1, l_n);
  SELECT workflow_name_ar || '|' || step_name_ar || '|' || priority_label || '|' || amount || '|' || currency_code
    INTO l_s FROM noona_v_my_tasks WHERE task_id = l_task;
  ok('my tasks: names, priority label, amount', l_s = 'اعتماد تجريبي للبوابة|اعتماد المدير|مرتفعة|1500|SAR', l_s);
  ok('open_task_count > 0', NOONA_PORTAL_PKG.open_task_count > 0);

  SELECT COUNT(*), MAX(link_url) INTO l_n, l_s FROM noona_v_my_notifications
   WHERE source_entity_type = 'WF_TASK' AND source_entity_id = l_task;
  ok('notification created for task', l_n = 1, l_n);
  ok('notification link opens portal TASK page', l_s = 'f?p=NOONA_PORTAL:TASK:::NO::P2_TASK_ID:' || l_task, l_s);
  ok('unread_count > 0', NOONA_PORTAL_PKG.unread_count > 0);
  NOONA_PORTAL_PKG.mark_all_read;
  ok('mark_all_read clears unread', NOONA_PORTAL_PKG.unread_count = 0);

  BEGIN
    NOONA_PORTAL_PKG.task_action(l_task, 'REJECT', NULL);
    ok('reject without comments blocked', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('reject without comments blocked', INSTR(SQLERRM, 'NOONA-WF-061') > 0, SQLERRM);
  END;
  BEGIN
    NOONA_PORTAL_PKG.task_action(l_task, 'DELETE', NULL);
    ok('unsupported action blocked', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('unsupported action blocked', INSTR(SQLERRM, 'NOONA-WF-060') > 0, SQLERRM);
  END;

  NOONA_PORTAL_PKG.task_action(l_task, 'APPROVE', 'موافق من البوابة');
  SELECT COUNT(*) INTO l_n FROM noona_v_my_tasks WHERE task_id = l_task;
  ok('approved task leaves my tasks', l_n = 0);
  SELECT COUNT(*), MAX(action_label || '|' || comments) INTO l_n, l_s FROM noona_v_task_history WHERE instance_id = l_inst;
  ok('history shows approval with comment', l_n = 1 AND l_s = 'اعتماد|موافق من البوابة', l_s);

  SELECT LISTAGG(app_alias, ',') WITHIN GROUP (ORDER BY sort_order) INTO l_s FROM noona_v_apps;
  ok('tenant admin sees admin app, not platform console',
     INSTR(l_s, 'NOONA_ADMIN') > 0 AND INSTR(l_s, 'NOONA_PLATFORM') = 0, l_s);
  COMMIT;
  NOONA_APEX_PKG.cleanup_request;

  -- مسؤول المنصة يرى لوحة المنصة فقط
  NOONA_APEX_PKG.post_auth('PLATFORM', l_sess + 1);
  SELECT LISTAGG(app_alias, ',') WITHIN GROUP (ORDER BY sort_order) INTO l_s FROM noona_v_apps;
  ok('platform admin sees only platform console', l_s = 'NOONA_PLATFORM', l_s);
  SELECT COUNT(*) INTO l_n FROM noona_v_task_history;
  ok('platform admin sees no tenant task history', l_n = 0, l_n);
  COMMIT;
  NOONA_APEX_PKG.cleanup_request;

  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
  IF g_fail > 0 THEN
    RAISE_APPLICATION_ERROR(-20999, g_fail || ' test(s) failed');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ABORT: ' || SQLERRM);
    DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
    ROLLBACK;
    NOONA_APEX_PKG.cleanup_request;
    RAISE;
END;
/
EXIT
