-- =============================================================================
-- NOONA PLUS ERP | ترقية 29: مركز التقارير الموحد (التطبيق 143 NOONA_BI)
--   * كتالوج يجمع تقارير كل الوحدات، مقسمة بكروت الوحدات في الشاشة الرئيسية
--   * يظهر التقرير حسب اشتراك المؤسسة في وحدته وصلاحية المستخدم، والمفضلة وآخر ما فتح لكل مستخدم
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_29_reports_hub.sql
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
PROMPT ========== أعمدة الكتالوج وجدول المفضلة
@@upgrade_parts/29_reports_hub.sql
PROMPT ========== كتالوج التقارير
@@seed/14_reports_catalog.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الحزم
@@plsql/123_noona_bi_pkg.sql
@@plsql/85_noona_portal.sql
GRANT EXECUTE ON NOONA_BI_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 29 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
