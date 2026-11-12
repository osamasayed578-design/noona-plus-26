-- =============================================================================
-- NOONA PLUS ERP | ترقية 61: مركز الإدارة والتواصل (التطبيق 151 NOONA_HUB)
--   بوابة العملاء برابط آمن، محرك واتساب (Cloud API أو wa.me) بالقوالب والسجل، توقع النقد 90 يوماً، الإنذار المبكر،
--   لوحة المدير، مساعدة كل شاشة، تصدير البيانات، سجل التغييرات المقروء، شاشات السائق (إثبات التسليم بالصورة والتوقيع)
--   والفني على الهاتف
-- =============================================================================
SET DEFINE OFF
SET FEEDBACK OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE
ALTER SESSION SET DDL_LOCK_TIMEOUT = 120;

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/
PROMPT ========== الوحدة والجداول والصلاحيات وعزل البيانات
@@upgrade_parts/61_eng_module.sql
@@upgrade_parts/61_eng.sql
@@upgrade_parts/61_trn_aut.sql
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الحزم
WHENEVER SQLERROR CONTINUE
@@plsql/131_noona_aut_pkg.sql
@@plsql/135_noona_trn_pkg.sql
@@plsql/142_noona_eng_pkg.sql
GRANT EXECUTE ON NOONA_ENG_PKG TO NOONA_APP;
@@plsql/85_noona_portal.sql

PROMPT ========== سجل التغييرات (مشغلات الجداول الرئيسية) وتجهيز المركز لكل شركة
DECLARE
  n NUMBER;
BEGIN
  NOONA_CORE_PKG.begin_system;
  n := NOONA_ENG_PKG.track_defaults;
  DBMS_OUTPUT.PUT_LINE('Change tracking on ' || n || ' tables');
  NOONA_CORE_PKG.end_system;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  DBMS_OUTPUT.PUT_LINE('WARN change tracking: ' || SQLERRM);
END;
/
PROMPT ========== مهمة الإنذار المبكر NOONA_ENG_ALERTS (كل 3 ساعات)
BEGIN
  BEGIN
    DBMS_SCHEDULER.DROP_JOB('NOONA_ENG_ALERTS', TRUE);
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  DBMS_SCHEDULER.CREATE_JOB(
    job_name        => 'NOONA_ENG_ALERTS',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'DECLARE n NUMBER; BEGIN n := NOONA_ENG_PKG.run_alerts; COMMIT; END;',
    start_date      => TRUNC(SYSTIMESTAMP) + INTERVAL '7' HOUR + INTERVAL '10' MINUTE,
    repeat_interval => 'FREQ=HOURLY;INTERVAL=3',
    enabled         => TRUE,
    comments        => 'NOONA PLUS: early-warning rules (cash, forecast, receivables, stock, sales, field collections)');
  DBMS_OUTPUT.PUT_LINE('Early-warning job scheduled (every 3 hours)');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('WARN early-warning job not created (' || SQLERRM || '). Run from SYS: GRANT CREATE JOB TO NOONA_OWNER; then rerun.');
END;
/

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 61 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP and import apps
EXIT
