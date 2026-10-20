-- =============================================================================
-- NOONA PLUS ERP | مهام اعتماد تجريبية لصندوق مهام ADMIN في البوابة (تطوير فقط)
-- ينشئ (مرة واحدة) مسار DEMO_PO_APPROVAL ثم يبدأ 3 طلبات جديدة في كل تشغيل.
--   sqlplus NOONA_OWNER@//host:1521/PDB @seed/91_demo_tasks_DEV_ONLY.sql
-- =============================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON
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
  l_tenant NUMBER;
  l_me     NUMBER;
  l_def    NUMBER;
  l_ver    NUMBER;
  l_id     NUMBER;
  l_n      NUMBER;
  l_base   NUMBER := TRUNC(DBMS_RANDOM.VALUE(1e6, 9e6)) * 10;
BEGIN
  NOONA_CTX_PKG.enable_system_mode;
  SELECT id INTO l_tenant FROM plt_tenant WHERE tenant_code = 'DEMO';
  NOONA_CTX_PKG.clear_context;
  NOONA_SECURITY_PKG.establish_session('ADMIN', l_tenant);
  l_me := NOONA_CTX_PKG.membership_id;

  SELECT COUNT(*) INTO l_n FROM wf_definition WHERE code = 'DEMO_PO_APPROVAL';
  IF l_n = 0 THEN
    l_def := NOONA_WORKFLOW_PKG.create_definition('DEMO_PO_APPROVAL', 'اعتماد أمر شراء (تجريبي)', 'PUR_ORDER',
                                                  p_name_en => 'Purchase order approval (demo)');
    l_ver := NOONA_WORKFLOW_PKG.new_version(l_def);
    l_id  := NOONA_WORKFLOW_PKG.add_step(l_ver, 'START', 'START', 'بداية');
    l_id  := NOONA_WORKFLOW_PKG.add_step(l_ver, 'MGR', 'APPROVAL', 'اعتماد مسؤول المؤسسة', 'USER', l_me, p_allow_self => 'Y');
    l_id  := NOONA_WORKFLOW_PKG.add_step(l_ver, 'END', 'END', 'نهاية');
    NOONA_WORKFLOW_PKG.add_transition(l_ver, 'START', 'MGR');
    NOONA_WORKFLOW_PKG.add_transition(l_ver, 'MGR', 'END', 'APPROVED');
    NOONA_WORKFLOW_PKG.publish_version(l_ver);
  END IF;

  l_id := NOONA_WORKFLOW_PKG.start_workflow('DEMO_PO_APPROVAL', 'PUR_ORDER', l_base + 1,
            '{"amount":12500,"currency":"SAR","priority":"HIGH"}');
  l_id := NOONA_WORKFLOW_PKG.start_workflow('DEMO_PO_APPROVAL', 'PUR_ORDER', l_base + 2,
            '{"amount":3400,"currency":"SAR","priority":"NORMAL"}');
  l_id := NOONA_WORKFLOW_PKG.start_workflow('DEMO_PO_APPROVAL', 'PUR_ORDER', l_base + 3,
            '{"amount":98000,"currency":"USD","priority":"URGENT"}');
  SELECT COUNT(*) INTO l_n FROM noona_v_my_tasks;
  NOONA_SECURITY_PKG.end_session;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Demo tasks ready. Open tasks for ADMIN: ' || l_n);
END;
/
EXIT
