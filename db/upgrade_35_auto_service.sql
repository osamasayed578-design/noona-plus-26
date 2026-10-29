-- =============================================================================
-- NOONA PLUS ERP | ترقية 35: مراكز خدمة السيارات (التطبيق 145 NOONA_AUTO)
--   * المركبات وملاكها، كتالوج الخدمات ككروت بقطعها الافتراضية، الرافعات والفنيون، الحجوزات
--   * أمر الإصلاح: الخدمات وقطع الغيار والفني المنفذ ومدة العمل ومدة البقاء، وفاتورة واحدة تصرف القطع من المخزون
--   * شركات التأمين: خصومات متفق عليها، تحمل العميل، فاتورة آجلة لشركة التأمين بحصتها، ومتابعة المطالبات
--   * التقارير في مركز التقارير، وحدث «سيارة جاهزة للاستلام» للتكاملات والرسائل
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_35_auto_service.sql
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
PROMPT ========== وحدة مراكز خدمة السيارات
@@upgrade_parts/35_aut_module.sql
PROMPT ========== الجداول والصلاحيات وعزل البيانات
@@upgrade_parts/35_auto_service.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الحزم
@@plsql/131_noona_aut_pkg.sql
@@plsql/129_noona_api_pkg.sql
@@plsql/123_noona_bi_pkg.sql
@@plsql/85_noona_portal.sql
GRANT EXECUTE ON NOONA_AUT_PKG TO NOONA_APP;
PROMPT ========== كتالوج التقارير
@@seed/14_reports_catalog.sql
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 35 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP and import apex/NOONA_AUTO/f145
EXIT
