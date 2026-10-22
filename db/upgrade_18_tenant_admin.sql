-- =============================================================================
-- NOONA PLUS ERP | ترقية 18: فصل إدارة المنصة عن إدارة المؤسسات
--   * المنصة: الاشتراكات (باقة وفترة وتجديد)، المشتركون الجدد، القريب انتهاؤه والمنتهي، قواعد الانتهاء اليومية
--     (سماح ← قراءة فقط ← تعليق) دون الاطلاع على بيانات أعمال المؤسسات
--   * المؤسسة: مسؤول المؤسسة يعين مسؤولي الشركات (COMPANY_ADMIN) ليديروا مستخدمي شركاتهم وفروعها وصلاحياتهم
--     بنطاق الشركة أو الفرع، وإضافة الفروع والمستخدمين ضمن حدود الاشتراك، وعرض الاشتراك لمسؤوليها
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_18_tenant_admin.sql
-- =============================================================================
SET DEFINE OFF
SET FEEDBACK OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/
PROMPT ========== باقات الاشتراك
@@seed/08_subscription_plans.sql
PROMPT ========== NOONA_SEC_ADMIN_PKG / NOONA_PLATFORM_PKG / NOONA_PLATFORM_ADMIN_PKG / NOONA_PORTAL_PKG
@@plsql/88_noona_sec_admin_pkg.sql
@@plsql/40_noona_platform_pkg.sql
@@plsql/91_noona_platform_admin_pkg.sql
@@plsql/85_noona_portal.sql
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
PROMPT ========== دور مسؤول الشركة لكل مؤسسة
DECLARE
  l_n PLS_INTEGER := 0;
BEGIN
  NOONA_CORE_PKG.begin_system;
  FOR t IN (SELECT id FROM plt_tenant) LOOP
    NOONA_PLATFORM_PKG.ensure_company_admin_role(t.id);
    l_n := l_n + 1;
  END LOOP;
  NOONA_CORE_PKG.end_system;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('COMPANY_ADMIN role ready for ' || l_n || ' organisation(s)');
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
PROMPT ========== مهمة يومية لقواعد انتهاء الاشتراك (01:15)
BEGIN
  BEGIN
    DBMS_SCHEDULER.DROP_JOB('NOONA_SUBSCRIPTION_EXPIRY', TRUE);
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  DBMS_SCHEDULER.CREATE_JOB(
    job_name        => 'NOONA_SUBSCRIPTION_EXPIRY',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'DECLARE n NUMBER; BEGIN n := NOONA_PLATFORM_ADMIN_PKG.apply_expiry; COMMIT; END;',
    repeat_interval => 'FREQ=DAILY;BYHOUR=1;BYMINUTE=15',
    enabled         => TRUE,
    comments        => 'NOONA PLUS: grace / read-only / suspension after subscription end');
  DBMS_OUTPUT.PUT_LINE('Daily expiry job scheduled');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('WARN  daily expiry job not created (' || SQLERRM || '). Run from SYS: GRANT CREATE JOB TO NOONA_OWNER; '
    || 'or press "تطبيق قواعد الانتهاء" in the platform console.');
END;
/
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 18 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
