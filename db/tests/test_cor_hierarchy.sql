-- =============================================================================
-- NOONA PLUS ERP | اختبار المراسلات الداخلية حسب الهيكل التنظيمي (الأعلى/الأدنى/الأفقي دون تجاوز) بحساب NOONA_APP - يتراجع في النهاية
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_cor_hierarchy.sql
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
  g_k    PLS_INTEGER := 0;
  l_co   NUMBER;
  l_n    NUMBER;
  l_id   NUMBER;
  l_c    CLOB;
  l_job  NUMBER;
  l_st   NUMBER; l_ver NUMBER;
  u_ceo NUMBER; u_fin NUMBER; u_hr NUMBER; u_ap NUMBER;
  p_ceo NUMBER; p_fin NUMBER; p_hr NUMBER; p_a1 NUMBER; p_a2 NUMBER;
  m_ceo NUMBER; m_fin NUMBER; m_hr NUMBER; m_a1 NUMBER; m_a2 NUMBER; m_none NUMBER;
  l_role NUMBER;
  l_msg  NUMBER;

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION has(p_clob CLOB, p_text VARCHAR2) RETURN BOOLEAN IS BEGIN RETURN DBMS_LOB.INSTR(p_clob, p_text) > 0; END;
  PROCEDURE login(p_user VARCHAR2) IS
  BEGIN
    NOONA_APEX_PKG.cleanup_request;
    NOONA_APEX_PKG.post_auth(p_user, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  END login;
  FUNCTION person(p_code VARCHAR2, p_name VARCHAR2) RETURN NUMBER IS
    l_m NUMBER; l_emp NUMBER; l_ee NUMBER;
  BEGIN
    g_k := g_k + 1;
    l_m := NOONA_SEC_ADMIN_PKG.create_user(p_code || l_sfx, p_name, LOWER(p_code) || l_sfx || '@noona.test', l_co);
    l_emp := NOONA_HR_PKG.save_employee('{"name_ar":"' || p_name || '","national_id":"1' || SUBSTR(l_sfx, -5) || LPAD(g_k, 4, '0')
      || '","nationality":"SA","gender":"M","hire_date":"' || TO_CHAR(SYSDATE - 60, 'YYYY-MM-DD') || '","job_title":"x","salary":{"BASIC":5000}}');
    SELECT employee_id INTO l_ee FROM hr_employment WHERE id = l_emp;
    UPDATE sec_user_membership SET employee_id = l_ee WHERE id = l_m;
    IF l_role IS NOT NULL THEN l_n := NOONA_SEC_ADMIN_PKG.grant_role(l_m, l_role, l_co); END IF;
    RETURN l_m;
  END person;
  FUNCTION emp_of(p_m NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT e.id INTO l FROM sec_user_membership m JOIN hr_employment e ON e.employee_id = m.employee_id WHERE m.id = p_m;
    RETURN l;
  END emp_of;
  FUNCTION who(p_k VARCHAR2, p_id NUMBER) RETURN VARCHAR2 IS BEGIN RETURN '{"k":"' || p_k || '","id":' || p_id || '}'; END;
  FUNCTION send_to(p_k VARCHAR2, p_id NUMBER, p_parent NUMBER DEFAULT NULL) RETURN NUMBER IS
  BEGIN
    RETURN NOONA_COR_PKG.send('{"kind":"INTERNAL","to":[' || who(p_k, p_id) || '],"subject":"اختبار الهيكل ' || l_sfx || '","body":"x"'
      || CASE WHEN p_parent IS NOT NULL THEN ',"parent":' || p_parent || ',"rel":"REPLY"' END || '}');
  END send_to;
  FUNCTION try(p_name VARCHAR2, p_k VARCHAR2, p_id NUMBER, p_allowed BOOLEAN, p_parent NUMBER DEFAULT NULL) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    l := send_to(p_k, p_id, p_parent);
    ok(p_name, p_allowed, 'sent but should be blocked');
    RETURN l;
  EXCEPTION WHEN OTHERS THEN
    IF p_allowed THEN ok(p_name, FALSE, SQLERRM); ELSE expect(p_name, 'NOONA-COR-040', SQLERRM); END IF;
    RETURN NULL;
  END try;
BEGIN
  login('ADMIN');
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  -- الهيكل: الرئيس التنفيذي ← (المالية، الموارد البشرية) ؛ المالية ← الحسابات (محاسبان)
  INSERT INTO org_job (code, name_ar, status_code) VALUES ('JH' || l_sfx, 'وظيفة اختبار', 'ACTIVE') RETURNING id INTO l_job;
  l_st := NOONA_ORG_PKG.create_structure(l_co, 'H' || l_sfx, 'هيكل الاختبار', p_is_primary => 'N');
  l_ver := NOONA_ORG_PKG.new_version(l_st, 'Initial');
  u_ceo := NOONA_ORG_PKG.add_unit(l_ver, 'CEO', 'مكتب الرئيس', 'OFFICE');
  u_fin := NOONA_ORG_PKG.add_unit(l_ver, 'FIN', 'الإدارة المالية', 'DEPARTMENT', 'CEO');
  u_hr  := NOONA_ORG_PKG.add_unit(l_ver, 'HR', 'الموارد البشرية', 'DEPARTMENT', 'CEO');
  u_ap  := NOONA_ORG_PKG.add_unit(l_ver, 'AP', 'الحسابات', 'SECTION', 'FIN');
  p_ceo := NOONA_ORG_PKG.create_position(u_ceo, l_job, 'HC' || l_sfx, 'الرئيس', 'Y');
  p_fin := NOONA_ORG_PKG.create_position(u_fin, l_job, 'HF' || l_sfx, 'مدير المالية', 'Y', p_ceo);
  p_hr  := NOONA_ORG_PKG.create_position(u_hr, l_job, 'HH' || l_sfx, 'مدير الموارد', 'Y', p_ceo);
  p_a1  := NOONA_ORG_PKG.create_position(u_ap, l_job, 'HA' || l_sfx, 'محاسب', 'N', p_fin);
  p_a2  := NOONA_ORG_PKG.create_position(u_ap, l_job, 'HB' || l_sfx, 'محاسب ثان', 'N', p_fin);
  NOONA_ORG_PKG.activate_version(l_ver);
  UPDATE org_unit SET receives_correspondence = 'Y' WHERE id IN (u_ceo, u_fin, u_hr, u_ap);
  -- دور الموظفين: الاتصال بالأعلى والأدنى والأفقي (دون ANY)
  l_role := NOONA_SEC_ADMIN_PKG.create_role('CH' || l_sfx, 'موظف مراسلات');
  NOONA_SEC_ADMIN_PKG.add_permission(l_role, 'COR_CONTACT.UP');
  NOONA_SEC_ADMIN_PKG.add_permission(l_role, 'COR_CONTACT.DOWN');
  NOONA_SEC_ADMIN_PKG.add_permission(l_role, 'COR_CONTACT.PEER');
  m_ceo := person('HCEO', 'الرئيس ' || l_sfx);
  m_fin := person('HFIN', 'مدير المالية ' || l_sfx);
  m_hr  := person('HHR', 'مدير الموارد ' || l_sfx);
  m_a1  := person('HA1', 'المحاسب الأول ' || l_sfx);
  m_a2  := person('HA2', 'المحاسب الثاني ' || l_sfx);
  m_none := person('HNP', 'بلا منصب ' || l_sfx);
  l_id := NOONA_ORG_PKG.assign_position(emp_of(m_ceo), p_ceo);
  l_id := NOONA_ORG_PKG.assign_position(emp_of(m_fin), p_fin);
  l_id := NOONA_ORG_PKG.assign_position(emp_of(m_hr), p_hr);
  l_id := NOONA_ORG_PKG.assign_position(emp_of(m_a1), p_a1);
  l_id := NOONA_ORG_PKG.assign_position(emp_of(m_a2), p_a2);
  ok('hierarchy: accountant reports to finance manager', NOONA_ORG_PKG.manager_of(m_a1) = m_fin);

  -- العلاقات
  ok('relation UP', NOONA_COR_PKG.relation(m_a1, 'U', m_fin) = 'UP');
  ok('relation DOWN', NOONA_COR_PKG.relation(m_fin, 'U', m_a1) = 'DOWN');
  ok('relation PEER (same manager)', NOONA_COR_PKG.relation(m_a1, 'U', m_a2) = 'PEER' AND NOONA_COR_PKG.relation(m_fin, 'U', m_hr) = 'PEER');
  ok('no relation when skipping a level', NOONA_COR_PKG.relation(m_a1, 'U', m_ceo) IS NULL AND NOONA_COR_PKG.relation(m_ceo, 'U', m_a1) IS NULL);
  ok('no relation across departments', NOONA_COR_PKG.relation(m_a1, 'U', m_hr) IS NULL);
  ok('units: head sees parent/child/sibling', NOONA_COR_PKG.relation(m_fin, 'O', u_ceo) = 'UP' AND NOONA_COR_PKG.relation(m_fin, 'O', u_ap) = 'DOWN'
     AND NOONA_COR_PKG.relation(m_fin, 'O', u_hr) = 'PEER');
  ok('units: employee only own unit', NOONA_COR_PKG.relation(m_a1, 'O', u_ap) = 'UP' AND NOONA_COR_PKG.relation(m_a1, 'O', u_fin) IS NULL);

  -- بدون تفعيل السياسة: لا قيد (السلوك السابق)
  login('HA1' || l_sfx);
  l_id := try('policy off: accountant may write to the CEO', 'U', m_ceo, TRUE);

  -- تفعيل السياسة
  login('ADMIN');
  NOONA_COR_PKG.save_policy('Y', 'Y');
  ok('policy saved', has(NOONA_COR_PKG.policy_json, '"restrict":"Y"'));
  login('HA1' || l_sfx);
  l_id := try('accountant -> finance manager (up)', 'U', m_fin, TRUE);
  l_id := try('accountant -> colleague (peer)', 'U', m_a2, TRUE);
  l_id := try('accountant -> CEO blocked (skips manager)', 'U', m_ceo, FALSE);
  l_id := try('accountant -> HR manager blocked', 'U', m_hr, FALSE);
  l_id := try('accountant -> own unit (to its head)', 'O', u_ap, TRUE);
  l_id := try('accountant -> finance department blocked', 'O', u_fin, FALSE);
  BEGIN
    l_id := send_to('U', m_ceo);
  EXCEPTION WHEN OTHERS THEN ok('error names the direct manager', INSTR(SQLERRM, 'مدير المالية ' || l_sfx) > 0, SQLERRM);
  END;
  l_c := NOONA_COR_PKG.directory_json(l_sfx);
  ok('directory shows manager and colleague', has(l_c, '"id":' || m_fin || ',') AND has(l_c, '"id":' || m_a2 || ',') AND has(l_c, 'رئيسك المباشر'));
  ok('directory hides CEO and HR', NOT has(l_c, '"id":' || m_ceo || ',') AND NOT has(l_c, '"id":' || m_hr || ','));

  login('HFIN' || l_sfx);
  l_id := try('finance manager -> accountant (down)', 'U', m_a1, TRUE);
  l_id := try('finance manager -> CEO (up)', 'U', m_ceo, TRUE);
  l_id := try('finance manager -> HR manager (peer)', 'U', m_hr, TRUE);
  l_id := try('finance manager -> HR department (peer unit)', 'O', u_hr, TRUE);
  l_id := try('finance manager -> CEO office (parent unit)', 'O', u_ceo, TRUE);

  login('HCEO' || l_sfx);
  l_msg := try('CEO -> finance manager (down)', 'U', m_fin, TRUE);
  l_id := try('CEO -> accountant blocked (skips manager)', 'U', m_a1, FALSE);
  l_c := NOONA_COR_PKG.directory_json(l_sfx);
  ok('CEO directory: direct reports only', has(l_c, '"id":' || m_fin || ',') AND has(l_c, '"id":' || m_hr || ',') AND NOT has(l_c, '"id":' || m_a1 || ','));

  -- الرد على من راسلك مسموح (المدير العام راسل محاسباً عبر ANY ثم يرد المحاسب)
  login('ADMIN');
  l_msg := send_to('U', m_a1);
  ok('admin (ANY) may write to anyone', l_msg IS NOT NULL);
  login('HA1' || l_sfx);
  SELECT author_member_id INTO l_n FROM cor_correspondence WHERE id = l_msg;
  l_id := try('reply to whoever wrote to you is allowed', 'U', l_n, TRUE, l_msg);

  -- الصلاحيات تحكم الاتجاه
  login('ADMIN');
  DELETE FROM sec_role_permission WHERE role_id = l_role AND permission_id = (SELECT id FROM sec_permission WHERE permission_code = 'COR_CONTACT.PEER');
  login('HA1' || l_sfx);
  l_id := try('without PEER permission colleague is blocked', 'U', m_a2, FALSE);
  l_id := try('UP permission still works', 'U', m_fin, TRUE);

  -- الإحالة تتبع الهيكل
  login('HFIN' || l_sfx);
  l_id := send_to('U', m_a1);
  login('HA1' || l_sfx);
  BEGIN NOONA_COR_PKG.refer(l_id, m_ceo, 'ACTION'); ok('accountant cannot refer to CEO', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('accountant cannot refer to CEO', 'NOONA-COR-040', SQLERRM); END;

  -- من لا منصب له: لا يراسل إلا بالرد
  login('HNP' || l_sfx);
  l_id := try('user without a position cannot write directly', 'U', m_fin, FALSE);

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
