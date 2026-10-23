-- =============================================================================
-- NOONA PLUS ERP | ترقية 20: المراسلات (بريد داخلي إداري بتصميم Gmail في تطبيق المستندات والمراسلات 129)
--   * مراسلات داخلية بين المستخدمين والوحدات، وتسجيل الوارد والصادر الخارجي برقم مستقل لكل شركة وسنة
--   * الرد والتحويل والإحالة بتعليمة ومهلة، والمطلوب مني، والنجمة والأرشفة، ومرفقات في الأرشيف، وإشعار المستلم
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_20_correspondence.sql
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
PROMPT ========== أعمدة النجمة للمراسلات
@@upgrade_parts/20_correspondence.sql
PROMPT ========== أنواع المراسلات ونوع مرفق المراسلة
@@seed/09_correspondence.sql
PROMPT ========== NOONA_DMS_PKG / NOONA_COR_PKG / NOONA_PORTAL_PKG
@@plsql/95_noona_dms_pkg.sql
@@plsql/109_noona_cor_pkg.sql
@@plsql/85_noona_portal.sql
GRANT EXECUTE ON NOONA_COR_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 20 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
