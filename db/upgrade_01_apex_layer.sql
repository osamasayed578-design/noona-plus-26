-- =============================================================================
-- NOONA PLUS ERP | ترقية 01: طبقة ربط APEX (لقاعدة مثبتة مسبقاً)
--   * NOONA_CORE_PKG : إصلاح وضع النظام عبر طلبات الـPool + reset_system
--   * NOONA_APEX_PKG : Post-Auth و Initialization و Cleanup وقواعد الصلاحيات
-- التشغيل من مجلد db:
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_01_apex_layer.sql
--   sqlplus NOONA_APP@//host:1521/PDB   @security/41_synonyms_noona_app.sql
-- (التثبيت الجديد عبر install.sql يتضمن هذه الترقية تلقائياً)
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

PROMPT ========== NOONA_CORE_PKG
@@plsql/03_noona_core_pkg.sql
PROMPT ========== NOONA_APEX_PKG
@@plsql/80_noona_apex_pkg.sql
PROMPT ========== Grants
GRANT EXECUTE ON NOONA_APEX_PKG TO NOONA_APP;

EXEC DBMS_UTILITY.compile_schema(USER, FALSE)
PROMPT ========== Invalid objects (should be none)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
PROMPT ========== Upgrade 01 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
