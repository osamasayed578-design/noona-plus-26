-- =============================================================================
-- NOONA PLUS ERP | ترقية 48: ترويسة التقارير والمستندات ووسائل الاتصال وتذييل الفواتير
--   * NOONA_BRAND_PKG: ترويسة بالشعار والفرع والعنوان والهاتف والجوال والبريد والسجل التجاري والرقم الضريبي،
--     وتذييل المستندات بخانات التوقيع وختم الشركة وسطر الاتصال؛ حفظ عنوان الشركة والفرع ووسائل اتصالهما
--   * فاتورة المبيعات والمشتريات بالترويسة الجديدة (بيانات الفرع) والتذييل
--   * الأرشيف: شركة لم يجهز أرشيفها تنشأ لها أرقام الأرشيف تلقائياً عند أول أرشفة (كان يرفض بـ NOONA-REF-001)
--   * الشركة القابضة: دليل حسابات خاص بكل شركة أو دليل المجموعة الموحد، والقوائم المالية الموحدة (NOONA_CONSOL_PKG)
--   * التصميم الجديد (الترويسة بتدرج، القائمة الداكنة، الأرقام الرقمية، اختيار المظهر) في ملفات التطبيقات: أعد استيرادها
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_48_design.sql
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
WHENEVER SQLERROR CONTINUE
@@plsql/89_noona_brand_pkg.sql
@@plsql/95_noona_dms_pkg.sql
@@plsql/100_noona_gl_pkg.sql
@@plsql/136_noona_consol_pkg.sql
GRANT EXECUTE ON NOONA_CONSOL_PKG TO NOONA_APP;
@@plsql/105_noona_pur_pkg.sql
@@plsql/106_noona_sal_pkg.sql
@@plsql/110_noona_hr_pkg.sql
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 48 done. Now import the rebuilt apps
EXIT
