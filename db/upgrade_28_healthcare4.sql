-- =============================================================================
-- NOONA PLUS ERP | ترقية 28: المستشفى - المرحلة الرابعة: متابعة المنومين (التطبيق 141)
--   * ورديات التمريض وجدول المناوبات (الجناح، الغرف المسندة، مسؤول الوردية) والممرض المناوب الآن
--   * جدول جرعات المنومين من تكرار الوصفة أو أوقات محددة، وتسجيل كل جرعة (أعطيت، أجلت، رفضها المريض، فاتت)
--   * مهام المتابعة التمريضية المتكررة، محطة التمريض، تنبيهات مواعيد الجرعات والمتابعة، والملف الإلكتروني للمنوم
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_28_healthcare4.sql
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
PROMPT ========== جداول المرحلة الرابعة
@@upgrade_parts/28_healthcare4.sql
PROMPT ========== أنواع إشعارات التمريض
@@seed/13_healthcare.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الحزم (حزمة التمريض أولاً: تستدعيها الحزم التالية)
@@plsql/122_noona_his_nurse_pkg.sql
@@plsql/117_noona_his_pkg.sql
@@plsql/118_noona_his_care_pkg.sql
@@plsql/120_noona_his_link_pkg.sql
@@plsql/121_noona_his_clin_pkg.sql
GRANT EXECUTE ON NOONA_HIS_NURSE_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
@@upgrade_parts/28_his_alert_job.sql
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 28 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
