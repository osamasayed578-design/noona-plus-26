-- =============================================================================
-- NOONA PLUS ERP | ترقية 27: المستشفى - المرحلة الثالثة (التطبيق 141)
--   * الربط الإلكتروني: قنوات شركات التأمين وبوابات المطالبات ومنصة الوصفات الإلكترونية (محاكاة، REST، بريد) للتحقق من الأهلية
--     والموافقات المسبقة وإرسال المطالبات ومتابعة قرارها وإرسال الوصفات، مع سجل الرسائل وتشفير الأسرار
--   * الصرف من الصيدلية الداخلية اختياري: الوصفة ترسل وتبقى سارية حتى انتهاء صلاحيتها، وتصرف لاحقاً أو خارجياً
--   * الطوارئ (الفرز CTAS)، العلامات الحيوية، الملاحظات السريرية، سجل إعطاء الأدوية، التقارير الطبية والإجازات المرضية،
--     الملف الطبي للمريض، وتسوية عمولات الأطباء بقيد استحقاق
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_27_healthcare3.sql
--   sqlplus NOONA_APP@//host:1521/PDB   @security/41_synonyms_noona_app.sql
-- للربط الحقيقي (REST): شغّل his_link_windows.bat (SYS) لكل مضيف خارجي.
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
PROMPT ========== جداول المرحلة الثالثة
@@upgrade_parts/27_healthcare3.sql
@@upgrade_parts/27_his_rx_status.sql
PROMPT ========== حدث استحقاق عمولات الأطباء
@@seed/13_healthcare.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== NOONA_ACE_PKG / NOONA_HIS_PKG / NOONA_HIS_CARE_PKG / NOONA_HIS_CLAIM_PKG / NOONA_HIS_LINK_PKG / NOONA_HIS_CLIN_PKG
@@plsql/101_noona_ace_pkg.sql
@@plsql/117_noona_his_pkg.sql
@@plsql/118_noona_his_care_pkg.sql
@@plsql/119_noona_his_claim_pkg.sql
@@plsql/120_noona_his_link_pkg.sql
@@plsql/121_noona_his_clin_pkg.sql
GRANT EXECUTE ON NOONA_HIS_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_HIS_CARE_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_HIS_CLAIM_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_HIS_LINK_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_HIS_CLIN_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 27 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
