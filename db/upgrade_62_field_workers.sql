-- =============================================================================
-- NOONA PLUS ERP | ترقية 62: العاملون الميدانيون من الموارد البشرية ومستحقاتهم
--   السائقون والمندوبون والفنيون يختارون من موظفي الموارد البشرية؛ مستحقاتهم الشهرية (بدل الرحلات، العمولات، المكافآت)
--   تصرف مع الراتب (مدخل متغير في المسير) أو نقداً أو تحويلاً (سند مصروفات بالاعتماد المالي)
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
PROMPT ========== الجداول والأعمدة والصلاحيات
@@upgrade_parts/62_wrk.sql
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الحزم
WHENEVER SQLERROR CONTINUE
@@plsql/143_noona_wrk_pkg.sql
GRANT EXECUTE ON NOONA_WRK_PKG TO NOONA_APP;
DECLARE
  n NUMBER;
BEGIN
  NOONA_CORE_PKG.begin_system;
  n := NOONA_ENG_PKG.track_defaults;
  NOONA_CORE_PKG.end_system;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
END;
/

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 62 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP and import apps
EXIT
