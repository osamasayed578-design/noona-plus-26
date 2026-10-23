-- =============================================================================
-- NOONA PLUS ERP | ترقية 24: المطاعم والكافتريا (صفحات 60-66 في تطبيق المبيعات ونقاط البيع 133)
--   * الصالات والطاولات وقائمة الطعام بأسعار شاملة الضريبة
--   * الطلب على الطاولة أو سفري أو توصيل أو على حساب عميل آجل، دفعات المطبخ وشاشة المطبخ، النقل والدمج والتقسيم
--   * المحاسبة بالطاولة كاملة أو بالطلب: نقدي/شبكة/محافظ/مختلط أو آجل (إيصال نقطة بيع وقيد عند إقفال الوردية)
--   * العملاء الآجلون والتحصيل منهم، ولوحة مبيعات المطعم
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_24_restaurant.sql
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
PROMPT ========== جداول المطعم: الصالات والطاولات والطلبات وأصنافها
@@upgrade_parts/24_restaurant.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== NOONA_RST_PKG
@@plsql/116_noona_rst_pkg.sql
GRANT EXECUTE ON NOONA_RST_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 24 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
