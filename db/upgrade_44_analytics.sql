-- =============================================================================
-- NOONA PLUS ERP | ترقية 44: محرك التحليلات والتنبؤ (NOONA_ANL_PKG)
--   * كتالوج مؤشرات لكل موديول بصلاحية العرض الخاصة به، محصور بالشركة والفرع
--   * سلاسل زمنية، مقارنة بالفترة السابقة، تنبؤ Holt-Winters بنطاق ثقة، كشف القيم الشاذة
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_44_analytics.sql
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
PROMPT ========== الحزمة
@@plsql/134_noona_anl_pkg.sql
GRANT EXECUTE ON NOONA_ANL_PKG TO NOONA_APP;

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 44 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
