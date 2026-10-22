-- =============================================================================
-- NOONA PLUS ERP | ترقية 21: الموارد البشرية والرواتب
--   * ملف الموظف (الهوية، المسمى، الإدارة، مركز التكلفة، البنك والآيبان، الإجازة السنوية) وهيكل الراتب
--   * الحركات الوظيفية، الإجازات حسب نظام العمل، الحضور والإضافي
--   * الرواتب: التشغيل والحساب والاعتماد والترحيل والصرف (WPS)، التأمينات، السلف، مخصصات نهاية الخدمة والإجازات،
--     مخالصة نهاية الخدمة، قسيمة الراتب والتقارير
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_21_hr_payroll.sql
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
PROMPT ========== أعمدة الموارد البشرية والرواتب الجديدة
@@upgrade_parts/21_hr_payroll.sql
PROMPT ========== أنواع الإجازات وعناصر الراتب وقواعد التأمينات وأحداث الرواتب المحاسبية
@@seed/10_hr_payroll.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== NOONA_ACE_PKG / NOONA_HR_PKG / NOONA_PAY_PKG / NOONA_PORTAL_PKG
@@plsql/101_noona_ace_pkg.sql
@@plsql/110_noona_hr_pkg.sql
@@plsql/111_noona_pay_pkg.sql
GRANT EXECUTE ON NOONA_HR_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_PAY_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 21 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
