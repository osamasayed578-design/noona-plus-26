-- =============================================================================
-- NOONA PLUS ERP | ترقية 08: حدود الاشتراك (المستخدمون والفروع والشركات) يحددها مالك المنصة وتدير المؤسسة بياناتها ضمنها
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_08_limits.sql
--   sqlplus NOONA_APP@//host:1521/PDB   @security/41_synonyms_noona_app.sql
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
PROMPT ========== NOONA_PLATFORM_PKG
@@plsql/40_noona_platform_pkg.sql
PROMPT ========== NOONA_UI_PKG
@@plsql/86_noona_ui_pkg.sql
PROMPT ========== NOONA_SEC_ADMIN_PKG
@@plsql/88_noona_sec_admin_pkg.sql
PROMPT ========== NOONA_PLATFORM_ADMIN_PKG
@@plsql/91_noona_platform_admin_pkg.sql
GRANT EXECUTE ON NOONA_PLATFORM_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_UI_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_SEC_ADMIN_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_PLATFORM_ADMIN_PKG TO NOONA_APP;
PROMPT ========== Recompile dependents
EXEC DBMS_UTILITY.COMPILE_SCHEMA(schema => USER, compile_all => FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
PROMPT ========== Upgrade 08 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
