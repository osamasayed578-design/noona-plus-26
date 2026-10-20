-- =============================================================================
-- NOONA PLUS ERP | ترقية 02: البوابة NOONA_PORTAL (لقاعدة مثبتة مسبقاً)
--   * NOONA_PORTAL_PKG + واجهات: مهامي، سجل المسار، إشعاراتي، التطبيقات
--   * NOONA_WORKFLOW_PKG: رابط المهمة في الإشعار يفتح صفحة TASK في البوابة
-- التشغيل من مجلد db (أو عبر install_windows.bat للتثبيت الكامل):
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_02_portal.sql
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

PROMPT ========== NOONA_WORKFLOW_PKG
@@plsql/70_noona_workflow_pkg.sql
PROMPT ========== NOONA_PORTAL_PKG + views
@@plsql/85_noona_portal.sql
PROMPT ========== Grants
GRANT EXECUTE ON NOONA_PORTAL_PKG TO NOONA_APP;
GRANT SELECT ON NOONA_V_MY_TASKS TO NOONA_APP;
GRANT SELECT ON NOONA_V_TASK_HISTORY TO NOONA_APP;
GRANT SELECT ON NOONA_V_MY_NOTIFICATIONS TO NOONA_APP;
GRANT SELECT ON NOONA_V_APPS TO NOONA_APP;

EXEC DBMS_UTILITY.compile_schema(USER, FALSE)
PROMPT ========== Invalid objects (should be none)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
PROMPT ========== Upgrade 02 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
