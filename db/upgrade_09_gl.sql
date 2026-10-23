-- =============================================================================
-- NOONA PLUS ERP | ترقية 09: تطبيق المالية - الأستاذ العام (NOONA_GL_PKG)
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_09_gl.sql
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
PROMPT ========== متطلبات محرك المستندات (جداول وأنواع وحزم) قبل حزم المالية - قابلة للتكرار
@@upgrade_parts/13_dms_rule.sql
@@upgrade_parts/14_dms_required.sql
@@seed/04_dms_types.sql
@@upgrade_parts/sync_admin_roles.sql
@@plsql/95_noona_dms_pkg.sql
@@plsql/96_noona_pty_pkg.sql
GRANT EXECUTE ON NOONA_DMS_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_PTY_PKG TO NOONA_APP;
PROMPT ========== NOONA_UI_PKG
@@plsql/86_noona_ui_pkg.sql
PROMPT ========== NOONA_GL_PKG
@@plsql/100_noona_gl_pkg.sql
GRANT EXECUTE ON NOONA_UI_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_GL_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 09 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
