-- =============================================================================
-- NOONA PLUS ERP | ترقية 19: أسعار الصرف لكل شركة
--   * أسعار الصرف خاصة بكل شركة ومستقلة عن الشركات الأخرى (كانت مشتركة على مستوى المؤسسة)
--   * الأسعار القائمة تنسخ لكل شركة في المؤسسة؛ ثم تعدل كل شركة أسعارها من تطبيق المالية
--   * إدارة المؤسسة (123) تحتفظ بأنواع الأسعار فقط
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_19_company_rates.sql
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
PROMPT ========== REF_EXCHANGE_RATE.COMPANY_ID ونقل الأسعار القائمة إلى الشركات
@@upgrade_parts/19_company_rates.sql
PROMPT ========== NOONA_REFERENCE_PKG / NOONA_REFDATA_PKG
@@plsql/20_noona_reference_pkg.sql
@@plsql/90_noona_refdata_pkg.sql
PROMPT ========== NOONA_PLATFORM_ADMIN_PKG (سجل تدقيق المنصة)
@@plsql/91_noona_platform_admin_pkg.sql
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
DECLARE
  l_n NUMBER;
BEGIN
  NOONA_CORE_PKG.begin_system;
  SELECT COUNT(*) INTO l_n FROM ref_exchange_rate;
  NOONA_CORE_PKG.end_system;
  DBMS_OUTPUT.PUT_LINE('Company exchange rates: ' || l_n);
END;
/
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 19 done
EXIT
