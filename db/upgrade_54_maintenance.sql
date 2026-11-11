-- =============================================================================
-- NOONA PLUS ERP | ترقية 54: صيانة الأصول وتمديد العمر الإنتاجي وصيانة أسطول النقل
--   * المالية ← الأصول: تسجيل صيانة الأصل كمصروف (5205) أو رأسمالية تضاف لتكلفته مع تمديد عمره الإنتاجي،
--     تمديد العمر مباشرة، خطط صيانة دورية بالأشهر ومستحقاتها، سجل الصيانة وعكس صيانة المصروف
--   * النقل ← صيانة الأسطول: برامج دورية بالكيلومتر أو الأيام، أوامر صيانة (ورشة داخلية/خارجية، قطع غيار وعمالة)،
--     العربة «في الصيانة» حتى الإقفال، ترحيل التكلفة عبر صيانة الأصول، تكلفة الصيانة لكل عربة ولكل كيلومتر
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_54_maintenance.sql
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
PROMPT ========== الجداول والصلاحيات وعزل البيانات
@@upgrade_parts/54_fa_maintenance.sql
@@upgrade_parts/54_trn_maintenance.sql
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الحزم
WHENEVER SQLERROR CONTINUE
@@plsql/112_noona_fa_pkg.sql
@@plsql/135_noona_trn_pkg.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 54 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP and import apps 127 and 147
EXIT
