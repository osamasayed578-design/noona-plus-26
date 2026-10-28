-- =============================================================================
-- NOONA PLUS ERP | ترقية 31: حزم الدول والتوطين والضرائب
--   * حزم الدول (السعودية، الإمارات، البحرين، عمان، قطر، الكويت، مصر، السودان): أكواد الضرائب ونسبها بإصدارات مؤرخة،
--     التسجيلات القانونية وصيغها، الأشكال القانونية؛ والضريبة في كل الوحدات حسب دولة الشركة
--   * إقرار ضريبة القيمة المضافة من السجل الضريبي الموحد، الاستقطاع وشهاداته، الفوترة الإلكترونية (المرحلة الثانية)
\1 NOONA_OWNER@//host:1521/PDB @upgrade_31_localization.sql
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
PROMPT ========== أعمدة الضرائب والفوترة الإلكترونية الجديدة
@@upgrade_parts/31_localization.sql
PROMPT ========== حزم الدول وأكوادها ونسبها والأحداث المحاسبية
@@seed/16_country_packs.sql
PROMPT ========== تقارير الضرائب في مركز التقارير
@@seed/14_reports_catalog.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الحزم
@@plsql/101_noona_ace_pkg.sql
@@plsql/102_noona_csh_pkg.sql
@@plsql/104_noona_inv_pkg.sql
@@plsql/114_noona_hsp_pkg.sql
@@plsql/117_noona_his_pkg.sql
@@plsql/106_noona_sal_pkg.sql
@@plsql/125_noona_loc_pkg.sql
@@plsql/126_noona_einv_pkg.sql
@@plsql/123_noona_bi_pkg.sql
GRANT EXECUTE ON NOONA_LOC_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_EINV_PKG TO NOONA_APP;
GRANT SELECT ON NOONA_V_TAX_REGISTER TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 31 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
