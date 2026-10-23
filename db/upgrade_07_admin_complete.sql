-- =============================================================================
-- NOONA PLUS ERP | ترقية 07: إكمال تطبيق الإدارة، الدخول الموحد وشاشة الأنظمة، البوابة، لوحة المنصة
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_07_admin_complete.sql
--   sqlplus NOONA_APP@//host:1521/PDB   @security/41_synonyms_noona_app.sql
-- =============================================================================
SET DEFINE OFF
SET FEEDBACK OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE
-- تعديل الجداول ينتظر حتى دقيقتين إذا كان جدول مستخدماً في جلسة أخرى (بدلاً من الخطأ ORA-00054)
ALTER SESSION SET DDL_LOCK_TIMEOUT = 120;

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/
PROMPT ========== NOONA_WORKFLOW_PKG
@@plsql/70_noona_workflow_pkg.sql
PROMPT ========== NOONA_PORTAL_PKG + NOONA_V_APPS
@@plsql/85_noona_portal.sql
PROMPT ========== NOONA_UI_PKG
@@plsql/86_noona_ui_pkg.sql
PROMPT ========== NOONA_SEC_ADMIN_PKG
@@plsql/88_noona_sec_admin_pkg.sql
PROMPT ========== NOONA_REFDATA_PKG
@@plsql/90_noona_refdata_pkg.sql
PROMPT ========== NOONA_PLATFORM_ADMIN_PKG
@@plsql/91_noona_platform_admin_pkg.sql
GRANT EXECUTE ON NOONA_WORKFLOW_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_REFDATA_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_PLATFORM_ADMIN_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_SEC_ADMIN_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_UI_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_PORTAL_PKG TO NOONA_APP;
GRANT SELECT ON NOONA_V_APPS TO NOONA_APP;
PROMPT ========== Recompile dependents
EXEC DBMS_UTILITY.COMPILE_SCHEMA(schema => USER, compile_all => FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
PROMPT ========== Upgrade 07 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
