-- =============================================================================
-- NOONA PLUS ERP | ترقية 30: المشروعات والمقاولات والإنشاءات (داخل التطبيق 139)
--   * مشروعات عامة وتخصيص للمقاولات والتطوير العقاري: WBS ونسب الإنجاز، الموازنة، التكاليف الفعلية
--     (مصروفات، مواد من المخزون، ساعات عمل)، العقود وجداول الكميات وأوامر التغيير
--   * المستخلصات للعملاء ولمقاولي الباطن بالمحتجز والدفعة المقدمة والضريبة، بقيودها وذممها
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_30_projects.sql
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
PROMPT ========== أعمدة المشروعات الجديدة
@@upgrade_parts/30_projects.sql
PROMPT ========== الأحداث المحاسبية ونوع القيد
@@seed/15_projects.sql
PROMPT ========== تقارير المشروعات في مركز التقارير
@@seed/14_reports_catalog.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الحزم (المحرك المحاسبي يسمح لحزمة المشروعات ثم الحزمة)
@@plsql/101_noona_ace_pkg.sql
@@plsql/102_noona_csh_pkg.sql
@@plsql/124_noona_prj_pkg.sql
GRANT EXECUTE ON NOONA_PRJ_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 30 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
