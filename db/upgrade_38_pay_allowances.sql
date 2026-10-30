-- =============================================================================
-- NOONA PLUS ERP | ترقية 38: بدلات مرنة لكل شركة ودولة
--   * لكل عنصر في راتب الموظف طريقة احتساب: مبلغ ثابت، أو نسبة من الأساسي (أو من عنصر آخر)، أو حسب سياسة الشركة، أو مستثنى
--   * سياسة البدلات: قاعدة لكل شركة، أو لكل شركات المؤسسة في دولة، بمبلغ أو نسبة وحد أدنى وأعلى وفئة موظف،
--     والتلقائية منها تطبق على كل موظفي النطاق؛ والقاعدة الجديدة تسري من تاريخها وتبقى القديمة للفترات السابقة
--   * عناصر خاصة بالمؤسسة (بدل وجبة، بدل اتصال، بدل طبيعة عمل ...)
--   * التأمينات الاجتماعية السعودية مقيدة بالشركات في السعودية؛ وأساس الاشتراك من القاعدة
--   * فئات الموظفين: مواطن/وافد حسب دولة الشركة (سعودي/غير سعودي في السعودية)
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_38_pay_allowances.sql
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
PROMPT ========== أعمدة الدولة وطريقة الاحتساب
@@upgrade_parts/38_pay_allowances.sql
PROMPT ========== التأمينات السعودية للشركات في السعودية فقط
BEGIN
  NOONA_CORE_PKG.begin_system;
  UPDATE pay_element_rule r SET country_code = 'SA'
   WHERE r.tenant_id IS NULL AND r.country_code IS NULL
     AND r.element_id IN (SELECT id FROM pay_element WHERE tenant_id IS NULL AND code IN ('GOSI_EE', 'GOSI_ER'));
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
PROMPT ========== الحزم
@@plsql/110_noona_hr_pkg.sql
@@plsql/111_noona_pay_pkg.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 38 done
EXIT
