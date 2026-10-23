-- =============================================================================
-- NOONA PLUS ERP | ترقية 04: مكونات واجهة HTML (NOONA_UI_PKG) لتصميم البوابة الجديد
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_04_ui.sql
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
PROMPT ========== NOONA_UI_PKG
@@plsql/86_noona_ui_pkg.sql
GRANT EXECUTE ON NOONA_UI_PKG TO NOONA_APP;
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
PROMPT ========== Upgrade 04 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
