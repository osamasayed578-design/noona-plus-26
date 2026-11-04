-- =============================================================================
-- NOONA PLUS ERP | ترقية 47: مقارنة السنوات وأرقام السنوات السابقة
--   * فتح السنة المالية السابقة لأقدم سنة (NOONA_GL_PKG.open_previous_year) لإدخال قيود السنوات السابقة
--   * أرقام شهرية من النظام السابق لأي مؤشر في أي موديول (BI_HISTORY_VALUE) إدخالاً يدوياً أو استيراد CSV،
--     لا تقبل لشهر فيه بيانات فعلية (منعاً للازدواج) وتضاف للتحليلات والتنبؤ
--   * شاشة «مقارنة السنوات» في التحليلات: أشهر كل سنة متقابلة مع الإجمالي والمنقضي من السنة والنمو
--   * قائمة الدخل لعدة سنوات في المالية (السنة كاملة أو الفترة نفسها من كل سنة)
--   * إصلاح: جاهزية المبيعات والمشتريات لا تتأثر بوجود تسلسلات مستندات لأكثر من سنة؛ قيود إقفال السنة لا تدخل في مؤشرات التحليلات
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_47_history.sql
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
PROMPT ========== جدول أرقام السنوات السابقة والصلاحيات وعزل البيانات
@@upgrade_parts/47_history.sql
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الحزم
@@plsql/100_noona_gl_pkg.sql
@@plsql/105_noona_pur_pkg.sql
@@plsql/106_noona_sal_pkg.sql
@@plsql/103_noona_fin_rpt_pkg.sql
@@plsql/134_noona_anl_pkg.sql
@@plsql/123_noona_bi_pkg.sql
PROMPT ========== كتالوج التقارير
@@seed/14_reports_catalog.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 47 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP and import the rebuilt apps
EXIT
