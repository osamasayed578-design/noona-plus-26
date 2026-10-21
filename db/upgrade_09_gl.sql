-- =============================================================================
-- NOONA PLUS ERP | ترقية 09: تطبيق المالية - الأستاذ العام (NOONA_GL_PKG)
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_09_gl.sql
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
PROMPT ========== NOONA_UI_PKG
@@plsql/86_noona_ui_pkg.sql
PROMPT ========== NOONA_GL_PKG
@@plsql/100_noona_gl_pkg.sql
GRANT EXECUTE ON NOONA_UI_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_GL_PKG TO NOONA_APP;
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
PROMPT ========== Upgrade 09 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
