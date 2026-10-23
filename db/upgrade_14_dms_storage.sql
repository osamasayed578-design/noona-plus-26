-- =============================================================================
-- NOONA PLUS ERP | ترقية 14: مكان حفظ الملفات لكل شركة (قاعدة البيانات أو مجلد الخادم/NAS)، معاينة المستندات،
--                  مستندات وشهادات الأطراف وصلاحيتها، NOONA_PTY_PKG
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_14_dms_storage.sql
--   sqlplus NOONA_APP@//host:1521/PDB   @security/41_synonyms_noona_app.sql
-- مجلد الخادم: ينشئ مسؤول قاعدة البيانات (SYS) لكل مؤسسة:
--   CREATE DIRECTORY NOONA_DMS_T<رقم المؤسسة> AS '/mnt/noona/<المؤسسة>';
--   GRANT READ, WRITE ON DIRECTORY NOONA_DMS_T<رقم المؤسسة> TO NOONA_OWNER;
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
PROMPT ========== المستندات المطلوبة للأطراف وإعدادات التخزين
@@upgrade_parts/14_dms_required.sql
PROMPT ========== أنواع مستندات وشهادات الأطراف
@@seed/04_dms_types.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== NOONA_DMS_PKG / NOONA_PTY_PKG / الحزم المعتمدة عليها
@@plsql/95_noona_dms_pkg.sql
@@plsql/96_noona_pty_pkg.sql
@@plsql/102_noona_csh_pkg.sql
@@plsql/103_noona_fin_rpt_pkg.sql
GRANT EXECUTE ON NOONA_DMS_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_PTY_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 14 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
