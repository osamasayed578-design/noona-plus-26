-- =============================================================================
-- NOONA PLUS ERP | ترقية 45: شروط العروض والتخفيضات + سجل التقارير المفتوحة والمفضلة
--   * العرض يتحدد بالفترة وأيام الأسبوع والساعات (قائمة) وأضيف: أيام الشهر (1-5,25-31)، تواريخ مستثناة (العطلات)،
--     عدة فروع، العملاء (الكل، المسجلون، الجدد لأول شراء، عملاء محددون)، وحدود الاستخدام (كلي ولكل عميل)
--     مع سجل استخدام لكل مستند (SAL_PROMOTION_USE) في الفواتير ونقاط البيع والمستشفيات وخدمة السيارات
--   * مركز التقارير: صفحة «تقاريري» (المفضلة، آخر ما فتحته بالوقت وعدد المرات، الأكثر استخداماً) مع الإزالة من السجل
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_45_promo_rules.sql
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
PROMPT ========== أعمدة شروط العروض وسجل الاستخدام
@@upgrade_parts/45_promo_rules.sql
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الحزم
@@plsql/133_noona_prc_pkg.sql
@@plsql/106_noona_sal_pkg.sql
@@plsql/107_noona_pos_pkg.sql
@@plsql/117_noona_his_pkg.sql
@@plsql/131_noona_aut_pkg.sql
@@plsql/123_noona_bi_pkg.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 45 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP and import f133, f141, f143, f145
EXIT
