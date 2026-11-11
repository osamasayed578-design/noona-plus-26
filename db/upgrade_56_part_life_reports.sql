-- =============================================================================
-- NOONA PLUS ERP | ترقية 56: عمر استبدال قطع الغيار وتقارير مصروفات قطع الغيار وأداء العربات والسائقين
--   * عمر الصنف بالكيلومتر أو الأيام؛ عند صرفه في أمر صيانة يحدد موعد استبداله التالي من عداد الخروج وتاريخه
--     ويظهر في «صيانة الأسطول» عند اقترابه
--   * تقرير مصروفات قطع الغيار لكل عربة خلال فترة مع العمر الفعلي للقطعة بين استبدالين
--   * أداء العربات (رحلات، كم، وقود، أعطال، تكلفة الصيانة لكل كم) وأداء السائقين (الحوادث والأعطال والصيانة المنسوبة)
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_56_part_life_reports.sql
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
PROMPT ========== الأعمدة
@@upgrade_parts/56_part_life.sql
PROMPT ========== الحزم
WHENEVER SQLERROR CONTINUE
@@plsql/135_noona_trn_pkg.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 56 done. Now import app 147
EXIT
