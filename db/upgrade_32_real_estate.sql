-- =============================================================================
-- NOONA PLUS ERP | ترقية 32: التطوير العقاري وبيع الوحدات وإدارة الأملاك (داخل التطبيق 139)
--   * بيع الوحدات: قوائم الأسعار وخطط السداد، الحجز بعربون، عقد البيع وأقساطه (تفوتر كفواتير مبيعات)، التسليم والاعتراف بالإيراد
--     والتكلفة، الإفراغ، الفسخ، عمولات الوسطاء، رسملة تكاليف التطوير على الوحدات
--   * إدارة الأملاك: اتفاقيات إدارة أملاك الغير وكشوف الملاك، عقود الإيجار وجدولها وفوترتها، التأمينات، التجديد والإنهاء، العدادات
\1 NOONA_OWNER@//host:1521/PDB @upgrade_32_real_estate.sql
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
PROMPT ========== أعمدة البيع والإيجار الجديدة
@@upgrade_parts/32_real_estate.sql
PROMPT ========== الأحداث المحاسبية ونوع القيد
@@seed/17_real_estate.sql
PROMPT ========== تقارير العقارات في مركز التقارير
@@seed/14_reports_catalog.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الحزم
@@plsql/101_noona_ace_pkg.sql
@@plsql/102_noona_csh_pkg.sql
@@plsql/106_noona_sal_pkg.sql
@@plsql/124_noona_prj_pkg.sql
@@plsql/127_noona_res_pkg.sql
@@plsql/128_noona_prp_pkg.sql
@@plsql/123_noona_bi_pkg.sql
GRANT EXECUTE ON NOONA_RES_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_PRP_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 32 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
