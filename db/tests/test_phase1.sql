-- =============================================================================
-- NOONA PLUS ERP | اختبارات المرحلة الأولى (Core Packages) - بيئة تطوير فقط
--   NOONA_PLATFORM_PKG / NOONA_ORG_PKG / NOONA_DELEGATION_PKG / NOONA_WORKFLOW_PKG
-- المتطلبات: install.sql + seed/90_demo_tenant_DEV_ONLY.sql (مؤسسة DEMO + مستخدما ADMIN و PLATFORM)
-- التشغيل: sqlplus NOONA_OWNER@//host:1521/PDB @tests/test_phase1.sql
-- قابل لإعادة التشغيل: كل البيانات بلاحقة فريدة. النتيجة: سطر PASS/FAIL لكل حالة + ملخص.
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
  g_pass   PLS_INTEGER := 0;
  g_fail   PLS_INTEGER := 0;
  l_sfx    VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'DDHH24MISSFF2');
  l_demo   NUMBER;
  l_co     NUMBER;
  l_br     NUMBER;
  l_admin  NUMBER;

  -- أعضاء الاختبار
  m_emp    NUMBER;
  m_mgr    NUMBER;
  m_ceo    NUMBER;
  m_dlg    NUMBER;
  u_emp    VARCHAR2(50);
  u_mgr    VARCHAR2(50);
  u_ceo    VARCHAR2(50);
  u_dlg    VARCHAR2(50);

  l_tenant NUMBER;
  l_tenant2 NUMBER;
  l_acme_co NUMBER;
  l_n      NUMBER;
  l_s      VARCHAR2(4000);
  l_id     NUMBER;

  l_struct NUMBER;
  l_ver    NUMBER;
  l_ver2   NUMBER;
  u_ceo_unit NUMBER;
  u_fin    NUMBER;
  u_ap     NUMBER;
  l_job    NUMBER;
  p_ceo    NUMBER;
  p_finmgr NUMBER;
  p_acct   NUMBER;
  p_acct2  NUMBER;

  l_def    NUMBER;
  l_wver   NUMBER;
  l_rule   NUMBER;
  l_inst   NUMBER;
  l_task   NUMBER;
  l_dlgid  NUMBER;
  l_obj    NUMBER := TO_NUMBER(SUBSTR(l_sfx, -6)) * 10;

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN
      g_pass := g_pass + 1;
      DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE
      g_fail := g_fail + 1;
      DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;

  PROCEDURE expect_err(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN
    ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error raised'));
  END expect_err;

  PROCEDURE login(p_user VARCHAR2, p_tenant NUMBER DEFAULT NULL) IS
  BEGIN
    NOONA_SECURITY_PKG.establish_session(p_user, NVL(p_tenant, l_demo));
  END login;

  PROCEDURE login_platform IS
  BEGIN
    NOONA_SECURITY_PKG.establish_platform_session('PLATFORM');
  END login_platform;

  FUNCTION open_task(p_inst NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) INTO l FROM wf_task
     WHERE instance_id = p_inst AND status_code IN ('PENDING', 'CLAIMED', 'IN_PROGRESS', 'WAITING_INFO', 'ESCALATED');
    RETURN l;
  END open_task;

  FUNCTION task_assignee(p_task NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT assignee_member_id INTO l FROM wf_task WHERE id = p_task;
    RETURN l;
  END task_assignee;

  FUNCTION inst_state(p_inst NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(100);
  BEGIN
    SELECT status_code || '/' || outcome_code INTO l FROM wf_instance WHERE id = p_inst;
    RETURN l;
  END inst_state;

  -- ينشئ مستخدماً موظفاً في شركة DEMO (بيانات أساس للاختبار - وضع النظام)
  FUNCTION make_employee(p_user VARCHAR2, p_name VARCHAR2) RETURN NUMBER IS
    l_u NUMBER; l_p NUMBER; l_e NUMBER; l_m NUMBER;
  BEGIN
    INSERT INTO sec_user (username, email, display_name, user_type, status_code)
    VALUES (p_user, LOWER(p_user) || '@demo.noona.local', p_name, 'EMPLOYEE', 'ACTIVE') RETURNING id INTO l_u;
    INSERT INTO pty_party (tenant_id, party_no, party_type, display_name_ar)
    VALUES (l_demo, 'P-' || p_user, 'PERSON', p_name) RETURNING id INTO l_p;
    INSERT INTO hr_employee (tenant_id, person_party_id, employee_no, status_code)
    VALUES (l_demo, l_p, 'E-' || p_user, 'ACTIVE') RETURNING id INTO l_e;
    INSERT INTO hr_employment (tenant_id, employee_id, company_id, branch_id, employment_type, start_date, status_code)
    VALUES (l_demo, l_e, l_co, l_br, 'PERMANENT', TRUNC(SYSDATE) - 30, 'ACTIVE');
    INSERT INTO sec_user_membership (tenant_id, user_id, person_party_id, employee_id, default_company_id,
                                     default_branch_id, status_code)
    VALUES (l_demo, l_u, l_p, l_e, l_co, l_br, 'ACTIVE') RETURNING id INTO l_m;
    RETURN l_m;
  END make_employee;

  FUNCTION employment_of(p_member NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT e.id INTO l FROM sec_user_membership m JOIN hr_employment e ON e.employee_id = m.employee_id
     WHERE m.id = p_member;
    RETURN l;
  END employment_of;

BEGIN
  DBMS_OUTPUT.PUT_LINE('=== NOONA PLUS phase-1 tests, suffix ' || l_sfx);
  SELECT id INTO l_demo FROM plt_tenant WHERE tenant_code = 'DEMO';

  -- ------------------------------------------------------------------ setup
  NOONA_CTX_PKG.enable_system_mode;
  SELECT id INTO l_co FROM org_company WHERE tenant_id = l_demo AND code = 'DEMO-SA';
  SELECT id INTO l_br FROM org_branch WHERE company_id = l_co AND code = 'HQ';
  u_emp := 'EMP' || l_sfx; u_mgr := 'MGR' || l_sfx; u_ceo := 'CEO' || l_sfx; u_dlg := 'DLG' || l_sfx;
  NOONA_CTX_PKG.set_context(p_tenant_id => l_demo, p_user_id => NULL, p_membership_id => NULL,
                            p_company_id => l_co, p_branch_id => l_br, p_username => 'TEST_SETUP');
  NOONA_CTX_PKG.enable_system_mode;
  m_emp := make_employee(u_emp, 'موظف الحسابات');
  m_mgr := make_employee(u_mgr, 'مدير المالية');
  m_ceo := make_employee(u_ceo, 'الرئيس التنفيذي');
  m_dlg := make_employee(u_dlg, 'محاسب أول (بديل)');
  INSERT INTO org_job (code, name_ar, status_code) VALUES ('JOB' || l_sfx, 'وظيفة اختبار', 'ACTIVE')
  RETURNING id INTO l_job;
  NOONA_CTX_PKG.clear_context;
  COMMIT;

  -- ================================================================== 1) أمن الجلسة
  BEGIN
    NOONA_PLATFORM_PKG.change_tenant_status(l_demo, 'READ_ONLY', 'x');
    ok('SEC: tenant API without session is denied', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('SEC: tenant API without session is denied', 'NOONA-SEC-031', SQLERRM);
  END;
  BEGIN
    NOONA_SECURITY_PKG.establish_platform_session('ADMIN');
    ok('SEC: tenant admin cannot open platform session', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('SEC: tenant admin cannot open platform session', 'NOONA-SEC-016', SQLERRM);
  END;

  -- ================================================================== 2) المنصة: تجهيز مؤسسة
  login_platform;
  ok('PLT: platform session flag', NOONA_CTX_PKG.is_platform_admin = 'Y' AND NOONA_CTX_PKG.tenant_id IS NULL);
  l_tenant := NOONA_PLATFORM_PKG.provision_tenant(
                p_tenant_code => 'AC' || l_sfx, p_tenant_slug => 'acme-' || l_sfx,
                p_name_ar => 'شركة أكمي القابضة', p_name_en => 'ACME Holding', p_country_code => 'SA',
                p_base_currency => 'SAR', p_admin_username => 'ACADM' || l_sfx,
                p_admin_email => 'admin' || l_sfx || '@acme.test', p_admin_name => 'مسؤول أكمي',
                p_company_code => 'ACME-SA', p_company_name_ar => 'أكمي السعودية', p_idempotency_key => 'PROV-' || l_sfx);
  NOONA_CORE_PKG.begin_system;
  SELECT status_code INTO l_s FROM plt_tenant WHERE id = l_tenant;
  ok('PLT: provisioned tenant is ACTIVE', l_s = 'ACTIVE', l_s);
  SELECT COUNT(*) INTO l_n FROM plt_provisioning_step s JOIN plt_provisioning_run r ON r.id = s.run_id
   WHERE r.tenant_id = l_tenant AND s.status_code = 'DONE';
  ok('PLT: 6 provisioning steps DONE', l_n = 6, l_n);
  SELECT COUNT(*) INTO l_n FROM ref_rate_type WHERE tenant_id = l_tenant;
  ok('PLT: tenant defaults (4 rate types)', l_n = 4, l_n);
  SELECT id INTO l_acme_co FROM org_company WHERE tenant_id = l_tenant AND code = 'ACME-SA';
  NOONA_CORE_PKG.end_system;
  l_tenant2 := NOONA_PLATFORM_PKG.provision_tenant(
                p_tenant_code => 'AC' || l_sfx, p_tenant_slug => 'acme-' || l_sfx,
                p_name_ar => 'x', p_name_en => 'x', p_country_code => 'SA', p_base_currency => 'SAR',
                p_admin_username => 'ACADM' || l_sfx, p_admin_email => 'x@x', p_admin_name => 'x',
                p_company_code => 'ACME-SA', p_company_name_ar => 'x', p_idempotency_key => 'PROV-' || l_sfx);
  ok('PLT: provisioning is idempotent (same key => same tenant)', l_tenant2 = l_tenant);
  BEGIN
    NOONA_PLATFORM_PKG.change_tenant_status(l_tenant, 'PROSPECT', 'invalid');
    ok('PLT: invalid tenant transition rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('PLT: invalid tenant transition rejected', 'NOONA-PLT-013', SQLERRM);
  END;
  NOONA_PLATFORM_PKG.change_tenant_status(l_tenant, 'READ_ONLY', 'Overdue invoice');
  NOONA_SECURITY_PKG.end_session;

  -- مسؤول المؤسسة الجديدة: وضع القراءة فقط يمنع الإنشاء
  login('ACADM' || l_sfx, l_tenant);
  BEGIN
    l_id := NOONA_PLATFORM_PKG.create_company('ACME-AE', 'أكمي الإمارات', 'ACME UAE', 'AE', 'AED');
    ok('PLT: READ_ONLY tenant blocks new company', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('PLT: READ_ONLY tenant blocks new company', 'NOONA-PLT-001', SQLERRM);
  END;
  NOONA_SECURITY_PKG.end_session;
  login_platform;
  NOONA_PLATFORM_PKG.change_tenant_status(l_tenant, 'ACTIVE', 'Paid');
  NOONA_SECURITY_PKG.end_session;

  login('ACADM' || l_sfx, l_tenant);
  -- عزل المؤسسات: مسؤول أكمي لا يرى شركات DEMO
  SELECT COUNT(*) INTO l_n FROM org_company WHERE tenant_id = l_demo;
  ok('PLT: tenant isolation (ACME admin sees 0 DEMO companies)', l_n = 0, l_n);
  l_n := NOONA_PLATFORM_PKG.run_activation_checks(l_acme_co);
  ok('PLT: activation checks fail on new company (no FY/COA/sequences)', l_n > 0, l_n);
  SELECT status_code INTO l_s FROM org_company WHERE id = l_acme_co;
  ok('PLT: company stays UNDER_CONFIGURATION', l_s = 'UNDER_CONFIGURATION', l_s);
  BEGIN
    NOONA_PLATFORM_PKG.activate_company(l_acme_co);
    ok('PLT: activation blocked while checks fail', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('PLT: activation blocked while checks fail', 'NOONA-PLT-041', SQLERRM);
  END;
  BEGIN
    NOONA_PLATFORM_PKG.waive_check(l_acme_co, 'FUNCTIONAL_CURRENCY', 'try');
    ok('PLT: non-waivable check cannot be waived', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('PLT: non-waivable check cannot be waived', 'NOONA-PLT-040', SQLERRM);
  END;
  -- استثناء كل الفحوص القابلة ثم التفعيل
  FOR c IN (SELECT check_code FROM org_company_check WHERE company_id = l_acme_co AND status_code = 'FAILED') LOOP
    NOONA_PLATFORM_PKG.waive_check(l_acme_co, c.check_code, 'Test waiver');
  END LOOP;
  NOONA_PLATFORM_PKG.activate_company(l_acme_co);
  SELECT status_code INTO l_s FROM org_company WHERE id = l_acme_co;
  ok('PLT: company ACTIVE after waivers', l_s = 'ACTIVE', l_s);
  SELECT COUNT(*) INTO l_n FROM org_config_snapshot WHERE company_id = l_acme_co AND snapshot_type = 'ACTIVATION';
  ok('PLT: activation snapshot stored', l_n = 1, l_n);
  l_id := NOONA_PLATFORM_PKG.create_branch(l_acme_co, 'JED', 'فرع جدة', 'Jeddah', 'BRANCH');
  BEGIN
    l_id := NOONA_PLATFORM_PKG.create_branch(l_acme_co, 'HQ2', 'مركز ثان', 'HQ2', 'HEAD_OFFICE', 'Y');
    ok('PLT: second head office rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('PLT: second head office rejected', INSTR(SQLERRM, 'NOONA-PLT-') > 0, SQLERRM);
  END;
  NOONA_SECURITY_PKG.end_session;
  COMMIT;

  -- ================================================================== 3) الهيكل التنظيمي والمناصب
  login('ADMIN');
  l_struct := NOONA_ORG_PKG.create_structure(l_co, 'ADM' || l_sfx, 'الهيكل الإداري', p_is_primary => 'N');
  l_ver := NOONA_ORG_PKG.new_version(l_struct, 'Initial');
  u_ceo_unit := NOONA_ORG_PKG.add_unit(l_ver, 'CEO', 'مكتب الرئيس التنفيذي', 'OFFICE');
  u_fin := NOONA_ORG_PKG.add_unit(l_ver, 'FIN', 'الإدارة المالية', 'DEPARTMENT', 'CEO');
  u_ap  := NOONA_ORG_PKG.add_unit(l_ver, 'AP', 'الحسابات الدائنة', 'SECTION', 'FIN');
  SELECT hier_path INTO l_s FROM org_unit WHERE id = u_ap;
  ok('ORG: hierarchy path /CEO/FIN/AP', l_s = '/CEO/FIN/AP', l_s);
  BEGIN
    NOONA_ORG_PKG.move_unit(u_ceo_unit, u_ap, 'cycle');
    ok('ORG: move creating a cycle is rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('ORG: move creating a cycle is rejected', 'NOONA-ORG-006', SQLERRM);
  END;
  p_ceo    := NOONA_ORG_PKG.create_position(u_ceo_unit, l_job, 'P-CEO' || l_sfx, 'الرئيس التنفيذي', 'Y');
  p_finmgr := NOONA_ORG_PKG.create_position(u_fin, l_job, 'P-FIN' || l_sfx, 'مدير المالية', 'Y', p_ceo);
  p_acct   := NOONA_ORG_PKG.create_position(u_ap, l_job, 'P-AP1' || l_sfx, 'محاسب', 'N', p_finmgr);
  p_acct2  := NOONA_ORG_PKG.create_position(u_ap, l_job, 'P-AP2' || l_sfx, 'محاسب أول', 'N', p_finmgr);
  NOONA_ORG_PKG.activate_version(l_ver);
  SELECT COUNT(*) INTO l_n FROM org_unit WHERE structure_version_id = l_ver AND status_code = 'ACTIVE';
  ok('ORG: version activated (3 active units)', l_n = 3, l_n);
  SELECT head_position_id INTO l_id FROM org_unit WHERE id = u_fin;
  ok('ORG: unit head position set on activation', l_id = p_finmgr);

  l_id := NOONA_ORG_PKG.assign_position(employment_of(m_ceo), p_ceo);
  l_id := NOONA_ORG_PKG.assign_position(employment_of(m_mgr), p_finmgr);
  l_id := NOONA_ORG_PKG.assign_position(employment_of(m_emp), p_acct);
  l_id := NOONA_ORG_PKG.assign_position(employment_of(m_dlg), p_acct2);
  BEGIN
    l_id := NOONA_ORG_PKG.assign_position(employment_of(m_dlg), p_acct);
    ok('ORG: second overlapping primary position rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('ORG: second overlapping primary position rejected', 'NOONA-ORG-023', SQLERRM);
  END;
  BEGIN
    l_id := NOONA_ORG_PKG.assign_position(employment_of(m_mgr), p_acct, 'ADDITIONAL');
    ok('ORG: position FTE capacity enforced', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('ORG: position FTE capacity enforced', 'NOONA-ORG-024', SQLERRM);
  END;
  SELECT status_code INTO l_s FROM org_position WHERE id = p_acct;
  ok('ORG: assigned position becomes OCCUPIED', l_s = 'OCCUPIED', l_s);
  ok('ORG: manager_of(employee) = finance manager', NOONA_ORG_PKG.manager_of(m_emp) = m_mgr);
  ok('ORG: manager_of(finance manager) = CEO', NOONA_ORG_PKG.manager_of(m_mgr) = m_ceo);
  ok('ORG: manager_of(CEO) is NULL (top)', NOONA_ORG_PKG.manager_of(m_ceo) IS NULL);
  ok('ORG: unit_head(AP) is NULL (unit has no head position)', NOONA_ORG_PKG.unit_head(u_ap) IS NULL);

  -- إصدار جديد: المناصب تنتقل للوحدات المطابقة بالرمز
  l_ver2 := NOONA_ORG_PKG.new_version(l_struct, 'Re-org 2');
  SELECT COUNT(*) INTO l_n FROM org_unit WHERE structure_version_id = l_ver2;
  ok('ORG: new version copies 3 units', l_n = 3, l_n);
  NOONA_ORG_PKG.activate_version(l_ver2);
  SELECT COUNT(*) INTO l_n FROM org_position p JOIN org_unit u ON u.id = p.org_unit_id
   WHERE u.structure_version_id = l_ver2 AND p.id IN (p_ceo, p_finmgr, p_acct, p_acct2);
  ok('ORG: positions remapped to new version', l_n = 4, l_n);
  SELECT status_code INTO l_s FROM org_structure_version WHERE id = l_ver;
  ok('ORG: old version SUPERSEDED', l_s = 'SUPERSEDED', l_s);
  ok('ORG: manager_of still resolves after re-org', NOONA_ORG_PKG.manager_of(m_emp) = m_mgr);
  COMMIT;

  -- ================================================================== 4) Workflow: تعريف ونشر
  l_def  := NOONA_WORKFLOW_PKG.create_definition('PO' || l_sfx, 'اعتماد أمر شراء', 'PUR_ORDER');
  l_wver := NOONA_WORKFLOW_PKG.new_version(l_def);
  l_id := NOONA_WORKFLOW_PKG.add_step(l_wver, 'START', 'START', 'بداية');
  l_id := NOONA_WORKFLOW_PKG.add_step(l_wver, 'MGR', 'APPROVAL', 'اعتماد المدير', 'MANAGER');
  l_id := NOONA_WORKFLOW_PKG.add_step(l_wver, 'CHK', 'DECISION', 'فحص المبلغ');
  l_id := NOONA_WORKFLOW_PKG.add_step(l_wver, 'CEO', 'APPROVAL', 'اعتماد الرئيس التنفيذي', 'POSITION', p_ceo);
  l_id := NOONA_WORKFLOW_PKG.add_step(l_wver, 'END', 'END', 'نهاية');
  BEGIN
    NOONA_WORKFLOW_PKG.publish_version(l_wver);
    ok('WF: publish rejects steps without outgoing transitions', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('WF: publish rejects steps without outgoing transitions', 'NOONA-WF-011', SQLERRM);
  END;
  l_rule := NOONA_WORKFLOW_PKG.create_rule('BIG' || l_sfx, 'مبلغ كبير',
              '{"all":[{"field":"amount","op":">","value":10000},{"field":"currency","op":"=","value":"SAR"}]}');
  ok('WF: rule true for 50000 SAR', NOONA_WORKFLOW_PKG.eval_rule(l_rule, '{"amount":50000,"currency":"SAR"}'));
  ok('WF: rule false for 5000 SAR', NOT NOONA_WORKFLOW_PKG.eval_rule(l_rule, '{"amount":5000,"currency":"SAR"}'));
  NOONA_WORKFLOW_PKG.add_transition(l_wver, 'START', 'MGR');
  NOONA_WORKFLOW_PKG.add_transition(l_wver, 'MGR', 'CHK', 'APPROVED');
  NOONA_WORKFLOW_PKG.add_transition(l_wver, 'CHK', 'CEO', p_rule_id => l_rule);
  NOONA_WORKFLOW_PKG.add_transition(l_wver, 'CHK', 'END', p_is_default => 'Y');
  NOONA_WORKFLOW_PKG.add_transition(l_wver, 'CEO', 'END', 'APPROVED');
  NOONA_WORKFLOW_PKG.publish_version(l_wver);
  SELECT status_code INTO l_s FROM wf_definition_version WHERE id = l_wver;
  ok('WF: version published ACTIVE', l_s = 'ACTIVE', l_s);
  BEGIN
    l_id := NOONA_WORKFLOW_PKG.add_step(l_wver, 'X', 'APPROVAL', 'x', 'MANAGER');
    ok('WF: published version is immutable', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('WF: published version is immutable', 'NOONA-WF-001', SQLERRM);
  END;
  NOONA_SECURITY_PKG.end_session;
  COMMIT;

  -- ================================================================== 5) Workflow: تشغيل
  -- (أ) مبلغ صغير: المدير فقط
  login(u_emp);
  l_inst := NOONA_WORKFLOW_PKG.start_workflow('PO' || l_sfx, 'PUR_ORDER', l_obj + 1, '{"amount":5000,"currency":"SAR"}');
  l_task := open_task(l_inst);
  ok('WF: task routed to MANAGER of requester', task_assignee(l_task) = m_mgr);
  ok('WF: start is idempotent', NOONA_WORKFLOW_PKG.start_workflow('PO' || l_sfx, 'PUR_ORDER', l_obj + 1) = l_inst);
  BEGIN
    NOONA_WORKFLOW_PKG.act(l_task, 'APPROVE');
    ok('WF: non-assignee cannot act', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('WF: non-assignee cannot act', 'NOONA-WF-044', SQLERRM);
  END;
  SELECT COUNT(*) INTO l_n FROM ntf_notification WHERE source_entity_type = 'WF_TASK' AND source_entity_id = l_task;
  ok('WF: assignment notification created for approver', l_n = 1, l_n);
  login(u_mgr);
  NOONA_WORKFLOW_PKG.act(l_task, 'APPROVE', 'موافق');
  ok('WF: small PO completes after manager approval', inst_state(l_inst) = 'COMPLETED/APPROVED', inst_state(l_inst));
  SELECT COUNT(*) INTO l_n FROM api_outbox WHERE aggregate_type = 'WF_INSTANCE' AND aggregate_id = l_inst;
  ok('WF: completion event written to outbox', l_n = 1, l_n);

  -- (ب) مبلغ كبير: المدير ثم الرئيس التنفيذي
  login(u_emp);
  l_inst := NOONA_WORKFLOW_PKG.start_workflow('PO' || l_sfx, 'PUR_ORDER', l_obj + 2, '{"amount":50000,"currency":"SAR"}');
  login(u_mgr);
  NOONA_WORKFLOW_PKG.act(open_task(l_inst), 'APPROVE');
  l_task := open_task(l_inst);
  ok('WF: big PO routed to CEO after manager (rule)', task_assignee(l_task) = m_ceo);
  ok('WF: instance WAITING at CEO step', inst_state(l_inst) = 'WAITING/APPROVED', inst_state(l_inst));
  login(u_ceo);
  NOONA_WORKFLOW_PKG.act(l_task, 'APPROVE');
  ok('WF: big PO completes after CEO', inst_state(l_inst) = 'COMPLETED/APPROVED', inst_state(l_inst));

  -- (ج) رفض
  login(u_emp);
  l_inst := NOONA_WORKFLOW_PKG.start_workflow('PO' || l_sfx, 'PUR_ORDER', l_obj + 3, '{"amount":700,"currency":"SAR"}');
  login(u_mgr);
  NOONA_WORKFLOW_PKG.act(open_task(l_inst), 'REJECT', 'خارج الميزانية');
  ok('WF: rejection completes instance as REJECTED', inst_state(l_inst) = 'COMPLETED/REJECTED', inst_state(l_inst));

  -- (د) طلب معلومات ثم الإرجاع
  login(u_emp);
  l_inst := NOONA_WORKFLOW_PKG.start_workflow('PO' || l_sfx, 'PUR_ORDER', l_obj + 4, '{"amount":900,"currency":"SAR"}');
  l_task := open_task(l_inst);
  login(u_mgr);
  NOONA_WORKFLOW_PKG.act(l_task, 'REQUEST_INFO', 'أرفق عرض السعر');
  SELECT status_code INTO l_s FROM wf_task WHERE id = l_task;
  ok('WF: REQUEST_INFO puts task WAITING_INFO', l_s = 'WAITING_INFO', l_s);
  NOONA_WORKFLOW_PKG.act(l_task, 'RETURN', 'أعد التقديم');
  ok('WF: RETURN completes instance as RETURNED', inst_state(l_inst) = 'COMPLETED/RETURNED', inst_state(l_inst));

  -- (هـ) فصل المهام: الطالب هو المعتمد المحدد => يرفع لمديره
  login('ADMIN');
  l_def  := NOONA_WORKFLOW_PKG.create_definition('SOD' || l_sfx, 'اختبار فصل المهام', 'CSH_PETTY_CASH_CLAIM');
  l_wver := NOONA_WORKFLOW_PKG.new_version(l_def);
  l_id := NOONA_WORKFLOW_PKG.add_step(l_wver, 'S', 'START', 'بداية');
  l_id := NOONA_WORKFLOW_PKG.add_step(l_wver, 'A', 'APPROVAL', 'اعتماد', 'USER', m_emp);
  l_id := NOONA_WORKFLOW_PKG.add_step(l_wver, 'E', 'END', 'نهاية');
  NOONA_WORKFLOW_PKG.add_transition(l_wver, 'S', 'A');
  NOONA_WORKFLOW_PKG.add_transition(l_wver, 'A', 'E', 'APPROVED');
  NOONA_WORKFLOW_PKG.publish_version(l_wver);
  login(u_emp);
  l_inst := NOONA_WORKFLOW_PKG.start_workflow('SOD' || l_sfx, 'CSH_PETTY_CASH_CLAIM', l_obj + 5, '{"amount":100,"currency":"SAR"}');
  l_task := open_task(l_inst);
  ok('WF: SoD - self-approval step escalated to manager', task_assignee(l_task) = m_mgr);
  SELECT JSON_VALUE(resolution_snapshot, '$.sod_escalated') INTO l_s FROM wf_task WHERE id = l_task;
  ok('WF: SoD escalation recorded in resolution snapshot', l_s = 'Y', l_s);
  login(u_mgr);
  BEGIN
    NOONA_WORKFLOW_PKG.act(l_task, 'REASSIGN', 'إعادة', m_emp);
    ok('WF: reassign to initiator is blocked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('WF: reassign to initiator is blocked', 'NOONA-WF-046', SQLERRM);
  END;
  NOONA_WORKFLOW_PKG.act(l_task, 'APPROVE');
  ok('WF: escalated SoD task approved by manager', inst_state(l_inst) = 'COMPLETED/APPROVED', inst_state(l_inst));
  NOONA_SECURITY_PKG.end_session;
  COMMIT;

  -- ================================================================== 6) التفويض
  login(u_mgr);
  BEGIN
    l_id := NOONA_DELEGATION_PKG.create_delegation('APPROVAL', m_mgr, m_mgr, SYSTIMESTAMP, SYSTIMESTAMP + 7, 'x');
    ok('DLG: self-delegation rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('DLG: self-delegation rejected', 'NOONA-DLG-011', SQLERRM);
  END;
  BEGIN
    l_id := NOONA_DELEGATION_PKG.create_delegation('APPROVAL', m_ceo, m_dlg, SYSTIMESTAMP, SYSTIMESTAMP + 7, 'x');
    ok('DLG: cannot delegate on behalf of another user', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('DLG: cannot delegate on behalf of another user', 'NOONA-DLG-010', SQLERRM);
  END;
  BEGIN
    l_id := NOONA_DELEGATION_PKG.create_delegation('APPROVAL', m_mgr, m_dlg, SYSTIMESTAMP, NULL, 'open');
    ok('DLG: open-ended delegation rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('DLG: open-ended delegation rejected', 'NOONA-DLG-014', SQLERRM);
  END;
  l_dlgid := NOONA_DELEGATION_PKG.create_delegation('APPROVAL', m_mgr, m_dlg, SYSTIMESTAMP - INTERVAL '1' MINUTE,
                                                    SYSTIMESTAMP + 7, 'إجازة سنوية');
  NOONA_DELEGATION_PKG.add_scope(l_dlgid, 'WORKFLOW', p_value_code => 'PO' || l_sfx);
  NOONA_DELEGATION_PKG.set_limit(l_dlgid, 'SAR', 20000, 25000);
  NOONA_DELEGATION_PKG.submit(l_dlgid);
  SELECT delegation_no INTO l_s FROM dlg_delegation WHERE id = l_dlgid;
  ok('DLG: delegation number DLG-YYYY-nnnnnn', REGEXP_LIKE(l_s, '^DLG-[0-9]{4}-[0-9]{6}$'), l_s);
  BEGIN
    NOONA_DELEGATION_PKG.approve(l_dlgid);
    ok('DLG: grantor cannot approve own delegation', FALSE);
  EXCEPTION WHEN OTHERS THEN
    ok('DLG: grantor cannot approve own delegation',
       INSTR(SQLERRM, 'NOONA-DLG-041') > 0 OR INSTR(SQLERRM, 'NOONA-SEC-') > 0, SQLERRM);
  END;
  -- دورة: المفوض إليه يفوض المانح بنفس النوع والنطاق
  login(u_dlg);
  l_id := NOONA_DELEGATION_PKG.create_delegation('APPROVAL', m_dlg, m_mgr, SYSTIMESTAMP, SYSTIMESTAMP + 3, 'cycle');
  BEGIN
    NOONA_DELEGATION_PKG.submit(l_id);
    ok('DLG: mutual delegation cycle rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('DLG: mutual delegation cycle rejected', 'NOONA-DLG-030', SQLERRM);
  END;
  login('ADMIN');
  NOONA_DELEGATION_PKG.approve(l_dlgid, 'معتمد');
  SELECT status_code INTO l_s FROM dlg_delegation WHERE id = l_dlgid;
  ok('DLG: approved delegation starting now is ACTIVE', l_s = 'ACTIVE', l_s);
  ok('DLG: find_delegation matches scope + limit',
     NOONA_DELEGATION_PKG.find_delegation(m_mgr, 'APPROVE', p_workflow_code => 'PO' || l_sfx,
                                          p_amount => 8000, p_currency => 'SAR') = l_dlgid);
  ok('DLG: find_delegation ignores other workflows',
     NOONA_DELEGATION_PKG.find_delegation(m_mgr, 'APPROVE', p_workflow_code => 'OTHER',
                                          p_amount => 8000, p_currency => 'SAR') IS NULL);
  ok('DLG: find_delegation respects per-transaction limit',
     NOONA_DELEGATION_PKG.find_delegation(m_mgr, 'APPROVE', p_workflow_code => 'PO' || l_sfx,
                                          p_amount => 30000, p_currency => 'SAR') IS NULL);
  COMMIT;

  -- توجيه المهمة للمفوض إليه والتنفيذ نيابة عن المانح
  login(u_emp);
  l_inst := NOONA_WORKFLOW_PKG.start_workflow('PO' || l_sfx, 'PUR_ORDER', l_obj + 6, '{"amount":8000,"currency":"SAR"}');
  l_task := open_task(l_inst);
  ok('WF+DLG: task routed to delegate', task_assignee(l_task) = m_dlg);
  SELECT original_member_id, delegation_id INTO l_n, l_id FROM wf_task WHERE id = l_task;
  ok('WF+DLG: original authority & delegation kept on task', l_n = m_mgr AND l_id = l_dlgid);
  login(u_dlg);
  NOONA_WORKFLOW_PKG.act(l_task, 'APPROVE', 'نيابة عن المدير');
  ok('WF+DLG: delegate approval completes PO', inst_state(l_inst) = 'COMPLETED/APPROVED', inst_state(l_inst));
  SELECT acting_capacity || ':' || on_behalf_member_id INTO l_s FROM wf_task_action
   WHERE task_id = l_task AND action_code = 'APPROVE';
  ok('WF+DLG: action recorded as DELEGATE on behalf of grantor', l_s = 'DELEGATE:' || m_mgr, l_s);
  SELECT COUNT(*) INTO l_n FROM dlg_exercise_event WHERE delegation_id = l_dlgid AND task_id = l_task;
  ok('WF+DLG: exercise event with policy snapshot', l_n = 1, l_n);
  SELECT used_cumulative INTO l_n FROM dlg_limit WHERE delegation_id = l_dlgid AND currency_code = 'SAR';
  ok('WF+DLG: cumulative usage 8000', l_n = 8000, l_n);

  -- تجاوز الحد التراكمي (8000 + 18000 > 25000) => يعود للمانح
  login(u_emp);
  l_inst := NOONA_WORKFLOW_PKG.start_workflow('PO' || l_sfx, 'PUR_ORDER', l_obj + 7, '{"amount":18000,"currency":"SAR"}');
  ok('WF+DLG: cumulative limit exceeded => routed to grantor', task_assignee(open_task(l_inst)) = m_mgr);

  -- إلغاء التفويض يعيد المهام المفتوحة للمانح
  l_inst := NOONA_WORKFLOW_PKG.start_workflow('PO' || l_sfx, 'PUR_ORDER', l_obj + 8, '{"amount":1000,"currency":"SAR"}');
  l_task := open_task(l_inst);
  ok('WF+DLG: small PO goes to delegate', task_assignee(l_task) = m_dlg);
  login(u_mgr);
  NOONA_DELEGATION_PKG.revoke_delegation(l_dlgid, 'عدت من الإجازة');
  ok('DLG: revoke returns open task to grantor', task_assignee(l_task) = m_mgr);
  login(u_dlg);
  BEGIN
    NOONA_WORKFLOW_PKG.act(l_task, 'APPROVE');
    ok('DLG: revoked delegate can no longer act', FALSE);
  EXCEPTION WHEN OTHERS THEN expect_err('DLG: revoked delegate can no longer act', 'NOONA-WF-044', SQLERRM);
  END;
  login(u_emp);
  NOONA_WORKFLOW_PKG.cancel_instance(l_inst, 'لم يعد مطلوباً');
  ok('WF: requester can cancel own instance', inst_state(l_inst) = 'CANCELLED/CANCELLED', inst_state(l_inst));
  NOONA_SECURITY_PKG.end_session;
  COMMIT;

  -- ================================================================== 7) سلامة التدقيق
  NOONA_CTX_PKG.enable_system_mode;
  SELECT COUNT(*) INTO l_n FROM aud_event WHERE action_code = 'SELF_APPROVAL_BLOCKED' OR action_code LIKE 'WORKFLOW_%';
  ok('AUD: workflow events audited', l_n > 0, l_n);
  SELECT COUNT(*) INTO l_n FROM aud_event WHERE result_code = 'DENIED' AND tenant_id = l_demo;
  ok('AUD: denied attempts persisted (autonomous)', l_n > 0, l_n);
  ok('AUD: DEMO hash chain intact', NOONA_AUDIT_PKG.verify_chain(l_demo) IS NULL,
     NOONA_AUDIT_PKG.verify_chain(l_demo));
  ok('AUD: ACME hash chain intact', NOONA_AUDIT_PKG.verify_chain(l_tenant) IS NULL,
     NOONA_AUDIT_PKG.verify_chain(l_tenant));
  NOONA_CTX_PKG.clear_context;

  -- ================================================================== 8) وضع النظام عبر طلبات الـPool
  NOONA_CORE_PKG.begin_system;            -- طلب سابق انتهى بخطأ دون end_system
  NOONA_CTX_PKG.clear_context;            -- طلب جديد على نفس الاتصال
  NOONA_CORE_PKG.begin_system;
  NOONA_CORE_PKG.end_system;
  ok('CORE: stale system-mode depth cannot leak VPD bypass', NOONA_CTX_PKG.is_system_mode = 'N');
  NOONA_CORE_PKG.reset_system;
  NOONA_CTX_PKG.clear_context;

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
    NOONA_CTX_PKG.clear_context;
    RAISE;
END;
/
EXIT
