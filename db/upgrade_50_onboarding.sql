-- =============================================================================
-- NOONA PLUS ERP | ترقية 50: بدء التشغيل ونقل البيانات
--   * استيراد ملفات Excel (xlsx) إضافة إلى CSV (بترميز UTF-8 أو Windows-1256 الذي يحفظ به Excel العربي)
--   * استيراد الموظفين (الهوية والجنسية والتعيين والوظيفة والفرع والآيبان والراتب والبدلات)
--   * الأرصدة الافتتاحية: الحسابات والنقدية والبنوك (قيد افتتاحي)، العملاء والموردون (فواتير مفتوحة)، المخزون (كمية وتكلفة)،
--     وإلغاء الدفعة بقيد عكسي، ومطابقة حسابات المراقبة وحساب الأرصدة الافتتاحية 3105
--   * تاريخ المستند للذمم الدائنة دون فاتورة؛ رصيد المورد وكشفه يشملان الأرصدة الافتتاحية ومستخلصات مقاولي الباطن
--   * صفحة «بدء التشغيل ونقل البيانات» في إدارة المؤسسة (التطبيق 123)
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_50_onboarding.sql
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
PROMPT ========== الأعمدة والقيود
@@upgrade_parts/50_onboarding.sql
PROMPT ========== الحدث المحاسبي ومصدر القيود
@@seed/20_onboarding.sql
PROMPT ========== الحزم
WHENEVER SQLERROR CONTINUE
@@plsql/101_noona_ace_pkg.sql
@@plsql/102_noona_csh_pkg.sql
@@plsql/105_noona_pur_pkg.sql
@@plsql/124_noona_prj_pkg.sql
@@plsql/130_noona_conn_pkg.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 50 done. Now import the rebuilt app 123 (NOONA_ADMIN)
EXIT
