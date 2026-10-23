-- =============================================================================
-- NOONA PLUS ERP | ترقية 22: الأصول الثابتة
--   * التجهيز والفئات، الاقتناء والرسملة (بنك/صندوق/مورد آجل/حساب/رصيد افتتاحي)
--   * الإهلاك الشهري (ثابت، متناقص، متناقص مضاعف) مع اللحاق وعكس التشغيل
--   * الإضافات والانخفاض وتغيير العمر والنقل، والاستبعاد: بيع وتخريد وتبرع وفقد مع الأرباح والخسائر
--   * سجل الأصول، البطاقة، جدول الإهلاك، حركة الأصول ومطابقتها مع الأستاذ، تقرير الاستبعادات
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_22_fixed_assets.sql
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
PROMPT ========== أعمدة الأصول الثابتة الجديدة
@@upgrade_parts/22_fixed_assets.sql
PROMPT ========== أحداث وأنواع قيود الأصول
@@seed/11_fixed_assets.sql
PROMPT ========== NOONA_ACE_PKG / NOONA_FA_PKG
@@plsql/101_noona_ace_pkg.sql
@@plsql/112_noona_fa_pkg.sql
GRANT EXECUTE ON NOONA_FA_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 22 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
