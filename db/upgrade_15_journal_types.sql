-- =============================================================================
-- NOONA PLUS ERP | ترقية 15: أنواع القيود (افتتاحي، تسوية، استحقاق بعكس آلي، إهلاك، مخصصات، إعادة تبويب، ...)
--                  وربطها بشاشة القيد والسندات والتقارير
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_15_journal_types.sql
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
PROMPT ========== جدول أنواع القيود
@@upgrade_parts/15_journal_types.sql
PROMPT ========== الأنواع الافتراضية وتصنيف القيود السابقة
@@seed/05_journal_types.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== NOONA_GL_PKG / NOONA_ACE_PKG / NOONA_CSH_PKG / NOONA_FIN_RPT_PKG
@@plsql/100_noona_gl_pkg.sql
@@plsql/101_noona_ace_pkg.sql
@@plsql/102_noona_csh_pkg.sql
@@plsql/103_noona_fin_rpt_pkg.sql
GRANT EXECUTE ON NOONA_GL_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_FIN_RPT_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 15 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
