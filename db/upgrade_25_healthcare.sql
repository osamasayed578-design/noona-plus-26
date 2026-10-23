-- =============================================================================
-- NOONA PLUS ERP | ترقية 25: المستشفيات والمراكز الطبية (التطبيق 141) - المرحلة الأولى
--   * الأقسام: عيادات، طوارئ، معامل منفصلة بمستودعاتها، أشعة وموجات، تشخيص القلب، علاج طبيعي، وحدات علاجية، عمليات، تنويم، صيدلية
--   * الأطباء وساعات العمل، دليل الخدمات ومواد كل خدمة، شركات التأمين والجهات المتعاقدة بفئات التغطية وأسعار العقود
--   * المرضى والحجوزات والزيارات والطلبات والموافقات والنتائج، صرف المواد، والفاتورة بحصة المريض وحصة الجهة وقيدها
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_25_healthcare.sql
--   sqlplus NOONA_APP@//host:1521/PDB   @security/41_synonyms_noona_app.sql
-- =============================================================================
SET DEFINE OFF
SET FEEDBACK OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE
-- تعديل الجداول ينتظر حتى دقيقتين إذا كان جدول مستخدماً في جلسة أخرى (بدلاً من الخطأ ORA-00054)
ALTER SESSION SET DDL_LOCK_TIMEOUT = 120;

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/
PROMPT ========== وحدة المستشفيات وجداولها
@@upgrade_parts/25_his_module.sql
@@upgrade_parts/25_healthcare.sql
PROMPT ========== حدث فاتورة الزيارة ونوع ومصدر القيود الطبية
@@seed/13_healthcare.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== NOONA_ACE_PKG / NOONA_HIS_PKG / NOONA_PORTAL_PKG
@@plsql/101_noona_ace_pkg.sql
@@plsql/117_noona_his_pkg.sql
@@plsql/85_noona_portal.sql
GRANT EXECUTE ON NOONA_HIS_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 25 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
