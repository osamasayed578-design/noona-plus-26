-- =============================================================================
-- NOONA PLUS ERP | ترقية 26: المستشفى - المرحلة الثانية (التطبيق 141)
--   * المعامل التفصيلية: مكونات كل تحليل ومعدلاتها حسب الجنس والعمر، التقييم الآلي (منخفض/مرتفع/حرج)، تقرير إنجليزي
--   * قوالب تقارير الأشعة والقلب (إنجليزية)، وأسماء الفحوص والأشعة والأدوية بالإنجليزية
--   * الصيدلية الداخلية (الوصفة والفوترة والتسليم من مستودع الصيدلية)، التنويم (الأسرة والدخول والنقل وأيام السرير والخروج)،
--     جدولة العمليات، خطط العلاج الطبيعي بالجلسات، الأجهزة الطبية ومعايرتها، دفعات مطالبات التأمين والرد والرفض
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_26_healthcare2.sql
--   sqlplus NOONA_APP@//host:1521/PDB   @security/41_synonyms_noona_app.sql
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
PROMPT ========== جداول المرحلة الثانية
@@upgrade_parts/26_healthcare2.sql
PROMPT ========== أحداث الفواتير ورفض المطالبات
@@seed/13_healthcare.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== NOONA_ACE_PKG / NOONA_HIS_PKG / NOONA_HIS_CARE_PKG / NOONA_HIS_CLAIM_PKG
@@plsql/101_noona_ace_pkg.sql
@@plsql/117_noona_his_pkg.sql
@@plsql/118_noona_his_care_pkg.sql
@@plsql/119_noona_his_claim_pkg.sql
GRANT EXECUTE ON NOONA_HIS_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_HIS_CARE_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_HIS_CLAIM_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 26 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
