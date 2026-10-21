-- =============================================================================
-- NOONA PLUS ERP | ترقية 12: المالية - أسعار الصرف في القيود والسندات، الإعدادات الافتراضية، مستندات JSON
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_12_fin_docs.sql
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
PROMPT ========== NOONA_UI_PKG / NOONA_GL_PKG / NOONA_CSH_PKG / NOONA_FIN_RPT_PKG
@@plsql/86_noona_ui_pkg.sql
@@plsql/100_noona_gl_pkg.sql
@@plsql/101_noona_ace_pkg.sql
@@plsql/102_noona_csh_pkg.sql
@@plsql/103_noona_fin_rpt_pkg.sql
GRANT EXECUTE ON NOONA_UI_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_GL_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_CSH_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_FIN_RPT_PKG TO NOONA_APP;
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 12 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
