-- =============================================================================
-- NOONA PLUS ERP | ترقية 49: محاسبة عقود المقاولات
--   * الاعتراف بالإيراد حسب نسبة الإنجاز (بالتكلفة أو بالإنجاز الفعلي) وأصول والتزامات العقود، والتكلفة المتوقعة عند الإنجاز،
--     ومخصص خسائر العقود (PRJ_REVENUE_RUN)
--   * غرامات التأخير (يومية بسقف) والمواد المشونة بالموقع في المستخلص، والمستخلص الختامي والحساب الختامي للعقد
--   * المعدات وتكلفة الساعة وتشغيلها على المشروعات (PRJ_EQUIPMENT، PRJ_EQUIPMENT_USAGE)
--   * خطابات الضمان: الإصدار بغطاء نقدي، التمديد، التخفيض، الإفراج، التسييل، والتنبيه قبل الانتهاء
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_49_construction.sql
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
PROMPT ========== الجداول والأعمدة والصلاحيات وعزل البيانات
@@upgrade_parts/49_construction.sql
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الأحداث المحاسبية
@@seed/15_projects.sql
PROMPT ========== الحزم
WHENEVER SQLERROR CONTINUE
@@plsql/101_noona_ace_pkg.sql
@@plsql/102_noona_csh_pkg.sql
@@plsql/124_noona_prj_pkg.sql
@@plsql/137_noona_prj_ctr_pkg.sql
GRANT EXECUTE ON NOONA_PRJ_CTR_PKG TO NOONA_APP;

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 49 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP and import the rebuilt app 139
EXIT
